import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';

enum _Mode { email, phone }

/// Sign-in / sign-up surface offering Google, email/password, and phone OTP.
/// Because the app is anonymous-first, signing in *links* the new credential to
/// the existing uid — progress is preserved and now syncs across devices.
class SignInScreen extends StatefulWidget {
  final AuthService authService;
  const SignInScreen({super.key, required this.authService});

  static Future<bool?> show(BuildContext context, AuthService auth) =>
      Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => SignInScreen(authService: auth)),
      );

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  _Mode _mode = _Mode.email;
  bool _createAccount = false;
  bool _busy = false;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  String? _verificationId;

  AuthService get _auth => widget.authService;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      _snack(_friendly(e));
    } on UnsupportedError catch (e) {
      _snack(e.message ?? 'Not supported on this device.');
    } catch (e) {
      _snack('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _done() {
    if (mounted) Navigator.of(context).pop(true);
  }

  String _friendly(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'That email already has an account — try signing in.';
      case 'weak-password':
        return 'Pick a stronger password (at least 6 characters).';
      case 'invalid-verification-code':
        return 'That code is incorrect.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }

  Future<void> _google() => _run(() async {
        final cred = await _auth.signInWithGoogle();
        if (cred != null) {
          _done();
        }
      });

  Future<void> _submitEmail() => _run(() async {
        final email = _email.text.trim();
        final pass = _password.text;
        if (_createAccount) {
          await _auth.signUpWithEmail(email, pass);
        } else {
          await _auth.signInWithEmail(email, pass);
        }
        _done();
      });

  Future<void> _forgotPassword() => _run(() async {
        final email = _email.text.trim();
        if (email.isEmpty) {
          _snack('Enter your email first.');
          return;
        }
        await _auth.sendPasswordReset(email);
        _snack('Password reset email sent.');
      });

  Future<void> _sendCode() => _run(() async {
        await _auth.startPhoneSignIn(
          phoneNumber: _phone.text.trim(),
          onCodeSent: (id) {
            if (mounted) setState(() => _verificationId = id);
            _snack('Code sent.');
          },
          onError: (e) => _snack(_friendly(e)),
          onAutoVerified: (_) => _done(),
        );
      });

  Future<void> _verifyCode() => _run(() async {
        final id = _verificationId;
        if (id == null) return;
        await _auth.confirmPhoneCode(id, _otp.text.trim());
        _done();
      });

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: t.bgBase,
        elevation: 0,
        foregroundColor: t.textPrimary,
        title: Text('Sign in', style: AppTypography.title(t)),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text(
                'Sign in to back up your progress and sync it across devices.',
                style: AppTypography.body(t).copyWith(color: t.textSecondary),
              ),
              const SizedBox(height: 20),
              _googleButton(t),
              const SizedBox(height: 20),
              _dividerOr(t),
              const SizedBox(height: 20),
              _modeToggle(t),
              const SizedBox(height: 16),
              if (_mode == _Mode.email) _emailForm(t) else _phoneForm(t),
              if (_busy) ...[
                const SizedBox(height: 24),
                Center(child: CircularProgressIndicator(color: t.accent)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _googleButton(AppTokens t) => OutlinedButton.icon(
        onPressed: _busy ? null : _google,
        icon: const Icon(Icons.g_mobiledata, size: 28),
        label: const Text('Continue with Google'),
        style: OutlinedButton.styleFrom(
          foregroundColor: t.textPrimary,
          side: BorderSide(color: t.borderStrong),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _dividerOr(AppTokens t) => Row(
        children: [
          Expanded(child: Divider(color: t.border)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: AppTypography.caption(t)),
          ),
          Expanded(child: Divider(color: t.border)),
        ],
      );

  Widget _modeToggle(AppTokens t) => Row(
        children: [
          Expanded(child: _modeChip(t, _Mode.email, 'Email')),
          const SizedBox(width: 8),
          Expanded(child: _modeChip(t, _Mode.phone, 'Phone')),
        ],
      );

  Widget _modeChip(AppTokens t, _Mode mode, String label) {
    final active = _mode == mode;
    return GestureDetector(
      onTap: () => setState(() => _mode = mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? t.accentSoft : t.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? t.accent : t.border),
        ),
        child: Text(
          label,
          style: AppTypography.body(t).copyWith(
            color: active ? t.accentText : t.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _field(AppTokens t, TextEditingController c, String label,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      style: AppTypography.body(t),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.body(t).copyWith(color: t.textTertiary),
        filled: true,
        fillColor: t.bgSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: t.accent),
        ),
      ),
    );
  }

  Widget _emailForm(AppTokens t) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(t, _email, 'Email', keyboard: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field(t, _password, 'Password', obscure: true),
          const SizedBox(height: 16),
          CalmButton.primary(
            text: _createAccount ? 'Create account' : 'Sign in',
            onPressed: _busy ? null : _submitEmail,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () =>
                    setState(() => _createAccount = !_createAccount),
                child: Text(
                  _createAccount
                      ? 'Have an account? Sign in'
                      : 'New here? Create account',
                  style: AppTypography.caption(t).copyWith(color: t.accentText),
                ),
              ),
              if (!_createAccount)
                TextButton(
                  onPressed: _busy ? null : _forgotPassword,
                  child: Text('Forgot password?',
                      style:
                          AppTypography.caption(t).copyWith(color: t.accentText)),
                ),
            ],
          ),
        ],
      );

  Widget _phoneForm(AppTokens t) {
    final codeSent = _verificationId != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _field(t, _phone, 'Phone (e.g. +91…)', keyboard: TextInputType.phone),
        if (!codeSent) ...[
          const SizedBox(height: 16),
          CalmButton.primary(
              text: 'Send code', onPressed: _busy ? null : _sendCode),
        ] else ...[
          const SizedBox(height: 12),
          _field(t, _otp, '6-digit code', keyboard: TextInputType.number),
          const SizedBox(height: 16),
          CalmButton.primary(
              text: 'Verify', onPressed: _busy ? null : _verifyCode),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy
                ? null
                : () => setState(() {
                      _verificationId = null;
                      _otp.clear();
                    }),
            child: Text('Use a different number',
                style: AppTypography.caption(t).copyWith(color: t.accentText)),
          ),
        ],
      ],
    );
  }
}
