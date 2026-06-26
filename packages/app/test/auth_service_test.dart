import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/auth_service.dart';

void main() {
  test('ensureSignedIn signs in anonymously when no user', () async {
    final auth = AuthService(auth: MockFirebaseAuth());
    final uid = await auth.ensureSignedIn();
    expect(uid, isNotEmpty);
    expect(auth.currentUser, isNotNull);
    expect(auth.isSignedInWithAccount, isFalse);
  });

  test('ensureSignedIn returns the existing uid', () async {
    final mock = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'existing-uid', isAnonymous: false),
    );
    final auth = AuthService(auth: mock);
    expect(await auth.ensureSignedIn(), 'existing-uid');
    expect(auth.isSignedInWithAccount, isTrue);
  });

  test('signInWithEmail authenticates', () async {
    final auth = AuthService(auth: MockFirebaseAuth());
    final cred = await auth.signInWithEmail('a@b.com', 'secret123');
    expect(cred.user, isNotNull);
  });

  test('signUpWithEmail creates an account', () async {
    final auth = AuthService(auth: MockFirebaseAuth());
    final cred = await auth.signUpWithEmail('new@b.com', 'secret123');
    expect(cred.user, isNotNull);
  });
}
