import 'package:flutter/material.dart';
import '../components/button.dart';
import '../components/card.dart';
import '../theme/tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(DateTime date, String email, String token, String examCode)
      onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _selectedExam = 'JAIIB';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 90)); // default to 90 days out

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
            Icon(Icons.spa_outlined, size: 64, color: t.accent),
            const SizedBox(height: 24),
            Text(
              'Calm Prep',
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
            const SizedBox(height: 24),
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
            _examCard(t, 'JAIIB',
                'Junior Associate of the Indian Institute of Bankers'),
            const SizedBox(height: 12),
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

    return Row(
      children: [
        Expanded(
          child: CalmButton.secondary(
            text: 'Back',
            onPressed: () {
              setState(() {
                _currentStep -= 1;
                _authError = null;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CalmButton.primary(
            text: _currentStep == 3 ? 'Begin Studying' : 'Next',
            onPressed: () {
              if (_currentStep == 1) {
                // Validate credentials
                final email = _emailController.text.trim();
                final password = _passwordController.text;

                if (email.isEmpty || !email.contains('@')) {
                  setState(() => _authError = 'Please enter a valid email address.');
                  return;
                }
                if (password.length < 6) {
                  setState(() => _authError = 'Password must be at least 6 characters.');
                  return;
                }

                setState(() {
                  _authError = null;
                  _currentStep = 2;
                });
              } else if (_currentStep == 3) {
                widget.onComplete(
                  _selectedDate,
                  _emailController.text.trim(),
                  'JWT_dummy_token_${_emailController.text.trim().hashCode}',
                  _selectedExam,
                );
              } else {
                setState(() {
                  _currentStep += 1;
                });
              }
            },
          ),
        ),
      ],
    );
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

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
