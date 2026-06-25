import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../app_scope.dart';
import '../components/card.dart';
import '../components/button.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Paywall',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return const PaywallScreen();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutQuart)),
          child: child,
        );
      },
    );
  }

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  String _selectedOption = 'bundle'; // 'bundle', 'monthly', 'modular'

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    return Scaffold(
      backgroundColor: t.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: t.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Unlock Premium',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: t.ink,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.stars, color: Colors.amber, size: 40),
                    const SizedBox(height: 12),
                    Text(
                      'Accelerate Your Career',
                      style: AppTypography.title(t).copyWith(color: t.onInk),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'CAIIB certification guarantees salary increments and promotions. Study smarter.',
                      style: AppTypography.bodySm(t).copyWith(color: t.onInk.withOpacity(0.7)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Choose Your Plan',
                style: AppTypography.heading(t),
              ),
              const SizedBox(height: 12),
              _buildPricingCard(
                t: t,
                id: 'bundle',
                title: 'Full Study Bundle',
                price: '₹699',
                subtitle: 'One-time payment for this exam cycle',
                tag: 'BEST VALUE',
                tagColor: t.accent,
              ),
              const SizedBox(height: 10),
              _buildPricingCard(
                t: t,
                id: 'monthly',
                title: 'Monthly Subscription',
                price: '₹199/mo',
                subtitle: 'Cancel anytime, study at your own pace',
              ),
              const SizedBox(height: 10),
              _buildPricingCard(
                t: t,
                id: 'modular',
                title: 'Modular Subject Package',
                price: '₹399',
                subtitle: 'Unlock a single compulsory or elective paper',
              ),
              const SizedBox(height: 28),
              Text(
                'What\'s Included',
                style: AppTypography.heading(t),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.25,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildFeatureTile(t, Icons.loop_outlined, 'Unlimited Review', 'Study all cards in your daily SRS review queues.'),
                  _buildFeatureTile(t, Icons.quiz_outlined, 'All Mock Exams', 'Access 15+ mock blueprints for all compulsory papers.'),
                  _buildFeatureTile(t, Icons.analytics_outlined, 'Smart Analytics', 'Predictive scores and personal weak-point insights.'),
                  _buildFeatureTile(t, Icons.cloud_off_outlined, '100% Offline Mode', 'Study during train commutes or offline branches.'),
                ],
              ),
              const SizedBox(height: 32),
              CalmButton.primary(
                text: 'Unlock Premium Now',
                onPressed: () {
                  final scope = AppScope.of(context);
                  if (scope.onBuyPremium != null) {
                    scope.onBuyPremium!();
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: t.accent,
                      content: Text(
                        'Congratulations! Premium Access Unlocked.',
                        style: AppTypography.body(t).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required AppTokens t,
    required String id,
    required String title,
    required String price,
    required String subtitle,
    String? tag,
    Color? tagColor,
  }) {
    final selected = _selectedOption == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedOption = id),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? t.accent.withOpacity(0.08) : t.bgSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.accent : t.border,
            width: selected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption(t).copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: AppTypography.title(t).copyWith(
                color: selected ? t.accent : t.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(AppTokens t, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.accent, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTypography.body(t).copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              desc,
              style: AppTypography.micro(t).copyWith(color: t.textSecondary, height: 1.25),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
