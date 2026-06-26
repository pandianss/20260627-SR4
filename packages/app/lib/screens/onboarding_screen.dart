import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/button.dart';
import '../components/card.dart';
import '../services/auth_service.dart';
import '../theme/tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(DateTime date, String email, String token, String examCode)
      onComplete;

  /// Real auth backend. When null (e.g. in tests), the account step validates
  /// input but skips the Firebase call and proceeds as a guest.
  final AuthService? authService;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
    this.authService,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _selectedExam = 'CAIIB';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90)); // default to 90 days out

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String _loginMethod = 'email'; // 'email', 'google', 'phone'
  bool _otpSent = false;
  bool _authBusy = false;
  String? _verificationId;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header progress indicator
                if (_currentStep > 0) _buildHeaderProgress(t),
                const Spacer(),
                // Animated step content switcher
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildStepContent(t),
                ),
                const Spacer(),
                // Navigation actions
                _buildActions(t),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderProgress(AppTokens t) {
    return Row(
      children: [
        for (int i = 1; i <= 3; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i <= _currentStep ? t.accent : t.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < 3) const SizedBox(width: 8),
        ]
      ],
    );
  }

  Widget _buildStepContent(AppTokens t) {
    switch (_currentStep) {
      case 0:
        return Column(
          key: const ValueKey(0),
          children: [
            SvgPicture.asset(
              'assets/logo.svg',
              width: 80,
              height: 80,
              colorFilter: ColorFilter.mode(t.accent, BlendMode.srcIn),
            ),
            const SizedBox(height: 24),
            Text(
              'SuperRecall Banker',
              style: AppTypography.display(t).copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'A quiet, micro-learning space built for working bankers. 5 minutes a day is all it takes.',
              style: AppTypography.body(t).copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: SvgPicture.asset(
                'assets/logo.svg',
                width: 48,
                height: 48,
                colorFilter: ColorFilter.mode(t.accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create your account',
              style: AppTypography.title(t),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your progress syncs across devices.',
              style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _loginMethodTab(t, 'email', Icons.email_outlined, 'Email'),
                const SizedBox(width: 8),
                _loginMethodTab(t, 'google', Icons.g_mobiledata, 'Google'),
                const SizedBox(width: 8),
                _loginMethodTab(t, 'phone', Icons.phone_android_outlined, 'Phone'),
              ],
            ),
            const SizedBox(height: 20),
            if (_loginMethod == 'email') ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: AppTypography.body(t),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                  hintText: 'name@bank.com',
                  hintStyle: AppTypography.bodySm(t).copyWith(color: t.textTertiary),
                  prefixIcon: Icon(Icons.email_outlined, color: t.textSecondary),
                  filled: true,
                  fillColor: t.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: t.accent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: AppTypography.body(t),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                  prefixIcon: Icon(Icons.lock_outline, color: t.textSecondary),
                  filled: true,
                  fillColor: t.bgSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: t.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: t.accent, width: 2),
                  ),
                ),
              ),
            ] else if (_loginMethod == 'google') ...[
              CalmCard(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    const Icon(Icons.account_circle_outlined, size: 48, color: Colors.blueAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Use your Google Account to log in quickly.',
                      style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _authBusy ? null : _handleStep1Auth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.redAccent),
                      label: Text('Continue with Google', style: AppTypography.body(t).copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )
            ] else ...[
              if (!_otpSent) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: AppTypography.body(t),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                    hintText: '98765 43210',
                    hintStyle: AppTypography.bodySm(t).copyWith(color: t.textTertiary),
                    prefixIcon: Icon(Icons.phone, color: t.textSecondary),
                    filled: true,
                    fillColor: t.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.accent, width: 2),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'OTP sent to +91 ${_phoneController.text.trim()}',
                  style: AppTypography.bodySm(t).copyWith(color: t.accent, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: AppTypography.body(t),
                  decoration: InputDecoration(
                    labelText: 'Enter 6-Digit OTP',
                    labelStyle: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
                    hintText: '123456',
                    hintStyle: AppTypography.bodySm(t).copyWith(color: t.textTertiary),
                    prefixIcon: Icon(Icons.security, color: t.textSecondary),
                    filled: true,
                    fillColor: t.bgSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: t.accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: Text('Resend OTP / Change Number', style: AppTypography.caption(t).copyWith(color: t.accent)),
                ),
              ],
            ],
            if (_authError != null) ...[
              const SizedBox(height: 12),
              Text(
                _authError!,
                style: AppTypography.caption(t).copyWith(color: t.danger),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      case 2:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your exam',
              style: AppTypography.title(t),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We customize your spaced reviews to match your syllabus.',
              style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _examCard(t, 'CAIIB',
                'Certified Associate of the Indian Institute of Bankers'),
          ],
        );
      case 3:
        return Column(
          key: const ValueKey(3),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set your exam date',
              style: AppTypography.title(t),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'We optimize review intervals so you finish the syllabus in time.',
              style: AppTypography.bodySm(t).copyWith(color: t.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: CalmCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target Date', style: AppTypography.caption(t)),
                        const SizedBox(height: 4),
                        Text(
                          '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} ${_selectedDate.year}',
                          style: AppTypography.heading(t).copyWith(color: t.accent),
                        ),
                      ],
                    ),
                    Icon(Icons.calendar_today_outlined, color: t.accent),
                  ],
                ),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActions(AppTokens t) {
    if (_currentStep == 0) {
      return CalmButton.primary(
        text: 'Start Preparation',
        onPressed: () => setState(() => _currentStep = 1),
      );
    }

    final row = Row(
      children: [
        Expanded(
          child: CalmButton.secondary(
            text: 'Back',
            onPressed: _authBusy
                ? null
                : () => setState(() {
                      _currentStep -= 1;
                      _authError = null;
                    }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CalmButton.primary(
            text: _nextLabel(),
            onPressed: _authBusy ? null : _onPrimaryAction,
          ),
        ),
      ],
    );

    if (_currentStep != 1) return row;

    // Account step also offers a guest (anonymous) path.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        row,
        const SizedBox(height: 4),
        if (_authBusy)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
            ),
          )
        else
          TextButton(
            onPressed: _continueAsGuest,
            child: Text(
              'Continue as guest',
              style: AppTypography.caption(t).copyWith(color: t.textSecondary),
            ),
          ),
      ],
    );
  }

  String _nextLabel() {
    if (_currentStep == 3) return 'Begin Studying';
    if (_currentStep == 1 && _loginMethod == 'phone') {
      return _otpSent ? 'Verify' : 'Send OTP';
    }
    return 'Next';
  }

  void _onPrimaryAction() {
    if (_currentStep == 1) {
      _handleStep1Auth();
    } else if (_currentStep == 3) {
      _finish();
    } else {
      setState(() => _currentStep += 1);
    }
  }

  void _continueAsGuest() => setState(() {
        _authError = null;
        _currentStep = 2;
      });

  void _finish() {
    final email = widget.authService?.currentUser?.email ??
        (_loginMethod == 'email' ? _emailController.text.trim() : '');
    widget.onComplete(_selectedDate, email, '', _selectedExam);
  }

  void _advanceToExam() {
    if (!mounted) return;
    setState(() {
      _authError = null;
      _authBusy = false;
      _currentStep = 2;
    });
  }

  void _setError(String msg) {
    if (!mounted) return;
    setState(() {
      _authError = msg;
      _authBusy = false;
    });
  }

  String _friendlyAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect.';
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

  Future<void> _handleStep1Auth() async {
    // Validate inputs first (runs even without an auth backend, e.g. in tests).
    if (_loginMethod == 'email') {
      final email = _emailController.text.trim();
      if (email.isEmpty || !email.contains('@')) {
        setState(() => _authError = 'Please enter a valid email address.');
        return;
      }
      if (_passwordController.text.length < 6) {
        setState(() => _authError = 'Password must be at least 6 characters.');
        return;
      }
    } else if (_loginMethod == 'phone') {
      final phone = _phoneController.text.trim();
      if (phone.length < 10) {
        setState(() => _authError = 'Please enter a valid 10-digit phone number.');
        return;
      }
      if (_otpSent && _otpController.text.trim().length != 6) {
        setState(() => _authError = 'Please enter a valid 6-digit OTP code.');
        return;
      }
    }

    final auth = widget.authService;
    // No auth backend (tests / no Firebase) — preserve the original step flow.
    if (auth == null) {
      if (_loginMethod == 'phone' && !_otpSent) {
        setState(() {
          _otpSent = true;
          _authError = null;
        });
      } else {
        _advanceToExam();
      }
      return;
    }

    setState(() {
      _authError = null;
      _authBusy = true;
    });
    try {
      if (_loginMethod == 'email') {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        try {
          await auth.signUpWithEmail(email, password);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use') {
            await auth.signInWithEmail(email, password);
          } else {
            rethrow;
          }
        }
        _advanceToExam();
      } else if (_loginMethod == 'google') {
        await auth.signInWithGoogle();
        _advanceToExam();
      } else {
        final phone = _phoneController.text.trim();
        final e164 = phone.startsWith('+') ? phone : '+91$phone';
        if (!_otpSent) {
          await auth.startPhoneSignIn(
            phoneNumber: e164,
            onCodeSent: (id) {
              if (!mounted) return;
              setState(() {
                _verificationId = id;
                _otpSent = true;
                _authBusy = false;
              });
            },
            onError: (e) => _setError(_friendlyAuth(e)),
            onAutoVerified: (_) => _advanceToExam(),
          );
          return; // wait for the codeSent / autoVerified callback
        }
        final id = _verificationId;
        if (id == null) {
          _setError('Please request a new code.');
          return;
        }
        await auth.confirmPhoneCode(id, _otpController.text.trim());
        _advanceToExam();
      }
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyAuth(e));
    } catch (_) {
      _setError('Something went wrong. Please try again.');
    }
  }

  Widget _examCard(AppTokens t, String code, String subtitle) {
    final selected = _selectedExam == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedExam = code),
      child: CalmCard(
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? t.accent : t.textTertiary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(code, style: AppTypography.heading(t)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.caption(t)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        final t = context.tokens;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: t.accent,
              onPrimary: t.onAccent,
              surface: t.bgSurface,
              onSurface: t.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _loginMethodTab(AppTokens t, String method, IconData icon, String label) {
    final selected = _loginMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _loginMethod = method;
          _authError = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? t.accent.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: selected ? t.accent : t.border,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? t.accent : t.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.caption(t).copyWith(
                color: selected ? t.accent : t.textSecondary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
