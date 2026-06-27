import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/tokens.dart';
import '../app_scope.dart';
import '../services/billing_service.dart';
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
  static const _privacyUrl = 'https://pandianss.github.io/20260627-SR4/';

  String _selectedOption = 'monthly'; // 'monthly' | 'bundle'
  bool _busy = false;
  BillingService? _billing;
  StreamSubscription<BillingEvent>? _eventSub;

  String get _selectedProductId => _selectedOption == 'bundle'
      ? BillingService.lifetimeId
      : BillingService.monthlyId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final billing = AppScope.of(context).billingService;
    if (billing != null && billing != _billing) {
      _billing = billing;
      _eventSub?.cancel();
      _eventSub = billing.events.listen(_onBillingEvent);
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _onBillingEvent(BillingEvent event) {
    if (!mounted) return;
    switch (event) {
      case BillingEvent.pending:
        setState(() => _busy = true);
        break;
      case BillingEvent.purchased:
      case BillingEvent.restored:
        final restored = event == BillingEvent.restored;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: context.tokens.accent,
            content: Text(
              restored
                  ? 'Purchases restored — premium unlocked.'
                  : 'Premium unlocked. Thank you!',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        );
        break;
      case BillingEvent.error:
        setState(() => _busy = false);
        _snack('Purchase failed. Please try again.');
        break;
      case BillingEvent.canceled:
        setState(() => _busy = false);
        break;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _purchase() async {
    final billing = _billing;
    if (billing == null || !billing.available) {
      _snack('Purchases are unavailable on this device.');
      return;
    }
    final product = billing.productById(_selectedProductId);
    if (product == null) {
      _snack('This plan is not available right now.');
      return;
    }
    setState(() => _busy = true);
    try {
      await billing.buy(product);
    } catch (e) {
      if (mounted) setState(() => _busy = false);
      _snack('Could not start the purchase.');
    }
  }

  Future<void> _restore() async {
    final billing = _billing;
    if (billing == null || !billing.available) {
      _snack('Purchases are unavailable on this device.');
      return;
    }
    setState(() => _busy = true);
    try {
      await billing.restore();
    } finally {
      // Restored entitlements arrive via the event stream; if none come back,
      // clear the spinner shortly after.
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _busy = false);
      });
    }
  }

  String _priceFor(String productId, String fallback) {
    return _billing?.productById(productId)?.price ?? fallback;
  }

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
          onPressed: _busy ? null : () => Navigator.pop(context),
        ),
        title: Text(
          'Unlock Premium',
          style: AppTypography.heading(t).copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _busy ? null : _restore,
            child: Text('Restore',
                style: AppTypography.caption(t).copyWith(color: t.accentText)),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                          style:
                              AppTypography.title(t).copyWith(color: t.onInk),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CAIIB certification supports salary increments and promotions. Study smarter.',
                          style: AppTypography.bodySm(t)
                              .copyWith(color: t.onInk.withValues(alpha: 0.7)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Choose Your Plan', style: AppTypography.heading(t)),
                  const SizedBox(height: 12),
                  _buildPricingCard(
                    t: t,
                    id: 'monthly',
                    title: 'Monthly Subscription',
                    price: _priceFor(BillingService.monthlyId, '₹99/mo'),
                    subtitle: 'Cancel anytime, study at your own pace',
                    tag: 'POPULAR',
                    tagColor: t.accent,
                  ),
                  const SizedBox(height: 10),
                  _buildPricingCard(
                    t: t,
                    id: 'bundle',
                    title: 'Lifetime CAIIB Unlock',
                    price: _priceFor(BillingService.lifetimeId, '₹499'),
                    subtitle: 'One-time payment — yours for this exam family',
                  ),
                  const SizedBox(height: 28),
                  Text('What\'s Included', style: AppTypography.heading(t)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.25,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _buildFeatureTile(t, Icons.loop_outlined,
                          'Unlimited Review', 'Study all cards in your daily SRS review queues.'),
                      _buildFeatureTile(t, Icons.quiz_outlined, 'All Mock Exams',
                          'Access 15+ mock blueprints for all compulsory papers.'),
                      _buildFeatureTile(t, Icons.analytics_outlined,
                          'Smart Analytics', 'Predictive scores and personal weak-point insights.'),
                      _buildFeatureTile(t, Icons.cloud_off_outlined,
                          '100% Offline Mode', 'Study during train commutes or offline branches.'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  CalmButton.primary(
                    text: _selectedOption == 'monthly'
                        ? 'Subscribe'
                        : 'Unlock Lifetime',
                    onPressed: _busy ? null : _purchase,
                  ),
                  const SizedBox(height: 12),
                  _legalFooter(t),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            if (_busy)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(
                    child: CircularProgressIndicator(color: t.accent),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _legalFooter(AppTokens t) {
    final monthly = _selectedOption == 'monthly';
    return Column(
      children: [
        Text(
          monthly
              ? 'Auto-renews monthly until cancelled. Manage or cancel anytime in Google Play.'
              : 'One-time purchase. No recurring charges.',
          style: AppTypography.micro(t).copyWith(color: t.textTertiary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => launchUrl(Uri.parse(_privacyUrl),
              mode: LaunchMode.externalApplication),
          child: Text('Privacy Policy',
              style: AppTypography.micro(t).copyWith(color: t.accentText)),
        ),
      ],
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
      onTap: _busy ? null : () => setState(() => _selectedOption = id),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? t.accent.withValues(alpha: 0.08) : t.bgSurface,
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
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.heading(t)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTypography.caption(t)
                        .copyWith(color: t.textSecondary),
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

  Widget _buildFeatureTile(
      AppTokens t, IconData icon, String title, String desc) {
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
            style: AppTypography.body(t)
                .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Text(
              desc,
              style: AppTypography.micro(t)
                  .copyWith(color: t.textSecondary, height: 1.25),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
