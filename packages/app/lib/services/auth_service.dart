import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper over [FirebaseAuth].
///
/// Anonymous-first: every user gets a stable uid immediately (so progress can
/// be backed up to the cloud with zero sign-in friction), and can later create
/// an email/password account which is *linked* to that same uid — preserving
/// their data and unlocking cross-device sync.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  bool get isSignedInWithAccount =>
      _auth.currentUser != null && !_auth.currentUser!.isAnonymous;

  /// Ensure there is a signed-in user, falling back to anonymous. Returns the uid.
  Future<String> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing.uid;
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  /// Create an email/password account. If the current session is anonymous, the
  /// account is *linked* to the existing uid (data is preserved); otherwise a
  /// fresh account is created.
  Future<UserCredential> signUpWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      return user.linkWithCredential(credential);
    }
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Sign out of the account, then re-establish an anonymous session so the app
  /// always has a uid to key local/cloud data by. Returns the new uid.
  Future<String> signOutToAnonymous() async {
    await _auth.signOut();
    return ensureSignedIn();
  }

  /// Permanently delete the current Firebase Auth user. Caller is responsible
  /// for deleting the user's stored data first. May throw a
  /// `requires-recent-login` [FirebaseAuthException] for accounts that signed in
  /// a while ago — the UI should prompt a re-sign-in and retry.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }

  // ── Google ─────────────────────────────────────────────────────────────────

  bool _googleReady = false;

  /// Firebase Web OAuth client ID for project superrecall-3afe5 — the audience
  /// the Google idToken must be issued for so Firebase accepts it. This value is
  /// public (it also ships in google-services.json), so embedding it is fine.
  static const _googleWebClientId =
      '524369176132-ktm8db0gnavlfbs1c5ougjneu9ntlm1g.apps.googleusercontent.com';

  /// Interactive Google sign-in (mobile). Requires the app's SHA-1/SHA-256
  /// fingerprints registered in the Firebase console (they are) and the Google
  /// provider enabled. [serverClientId] overrides the default Web client ID.
  Future<UserCredential?> signInWithGoogle({String? serverClientId}) async {
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(
          serverClientId: serverClientId ?? _googleWebClientId);
      _googleReady = true;
    }
    if (!google.supportsAuthenticate()) {
      throw UnsupportedError(
          'Google sign-in is not available on this platform.');
    }
    final account = await google.authenticate();
    if (account == null) {
      return null;
    }
    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'missing-id-token',
        message: 'Could not retrieve ID token from Google.',
      );
    }
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _linkOrSignIn(credential);
  }

  // ── Phone (OTP) ──────────────────────────────────────────────────────────

  /// Begin phone verification. On Android the code may auto-resolve
  /// ([onAutoVerified]); otherwise [onCodeSent] fires with a verificationId to
  /// pass to [confirmPhoneCode]. Requires the Blaze plan + an SMS quota.
  Future<void> startPhoneSignIn({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onError,
    void Function(UserCredential credential)? onAutoVerified,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential cred) async {
        try {
          onAutoVerified?.call(await _linkOrSignIn(cred));
        } catch (_) {
          // Auto-verification race; the user can still enter the code manually.
        }
      },
      verificationFailed: onError,
      codeSent: (String verificationId, int? _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (String _) {},
    );
  }

  /// Complete phone sign-in with the SMS [smsCode] for [verificationId].
  Future<UserCredential> confirmPhoneCode(
      String verificationId, String smsCode) {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return _linkOrSignIn(credential);
  }

  /// Link [credential] to the current anonymous user (preserving their uid +
  /// data); if it already belongs to an account, sign in with it instead.
  Future<UserCredential> _linkOrSignIn(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user != null && user.isAnonymous) {
      try {
        return await user.linkWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          return _auth.signInWithCredential(credential);
        }
        rethrow;
      }
    }
    return _auth.signInWithCredential(credential);
  }
}
