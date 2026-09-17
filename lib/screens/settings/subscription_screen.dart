import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/responsive.dart';
import '../../services/iap_service.dart';
import '../offers/offers_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<IAPService>(
      builder: (context, iapService, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: Text(
              'PREMIUM ACCESS',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(24),
              vertical: Responsive.spacing(16),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      size: 64, color: Colors.amber),
                ),
                SizedBox(height: Responsive.spacing(16)),
                Text(
                  'Unlock Winning Insights',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(12)),
                Text(
                  'Get unlimited access to expert predictions, live match analytics, and safe betting trends.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.spacing(36)),
                _buildFeatureRow(theme, Icons.check_circle_rounded,
                    'Unlimited Match Predictions'),
                _buildFeatureRow(theme, Icons.check_circle_rounded,
                    'Deep xG & Trend Analytics'),
                _buildFeatureRow(
                    theme, Icons.check_circle_rounded, 'Ad-Free Experience'),
                _buildFeatureRow(theme, Icons.check_circle_rounded,
                    'Priority Push Notifications'),
                SizedBox(height: Responsive.spacing(36)),

                // Active Subscription Status
                if (iapService.isSubscribed)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded,
                            color: Colors.green, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You are a VIP Member!',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'All daily predictions and statistical models are unlocked.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Dynamic Pricing Cards
                  if (iapService.errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              iapService.errorMessage!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (iapService.products.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...iapService.products.map((product) {
                      final bool isYearly = product.isYearly;
                      final bool isLifetime = product.isLifetime;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildPricingCard(
                          theme: theme,
                          title: product.title.split('(').first.trim(),
                          price: product.price,
                          period: product.period,
                          badge: isYearly
                              ? 'BEST VALUE (SAVE 50%)'
                              : isLifetime
                                  ? 'ONE-TIME PURCHASE'
                                  : null,
                          isHighlight: isYearly,
                          onTap: () => iapService.buySubscription(product),
                        ),
                      );
                    }),
                ],

                SizedBox(height: Responsive.spacing(20)),

                // Promo code link
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OffersScreen()),
                    );
                  },
                  icon: Icon(Icons.confirmation_num_outlined,
                      size: 18, color: theme.colorScheme.primary),
                  label: Text(
                    'Have a promo code? Redeem here',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 6),
                TextButton(
                  onPressed: () => _restorePurchases(context, iapService),
                  child: Text(
                    'Restore Purchases',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(14)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_rounded, color: Colors.green, size: 16),
          ),
          SizedBox(width: Responsive.spacing(14)),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard({
    required ThemeData theme,
    required String title,
    required String price,
    required String period,
    String? badge,
    required bool isHighlight,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.spacing(20)),
        decoration: BoxDecoration(
          color: isHighlight
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(Responsive.radius(24)),
          boxShadow: [
            if (isHighlight)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: Column(
          children: [
            if (badge != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isHighlight
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badge,
                    style: TextStyle(
                        color: isHighlight ? Colors.white : theme.colorScheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1)),
              ),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                )),
            SizedBox(height: Responsive.spacing(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    )),
                if (period != 'once')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(period,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                          fontWeight: FontWeight.bold,
                        )),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _restorePurchases(BuildContext context, IAPService iapService) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await iapService.restorePurchases();

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Restoration request sent.')),
      );
    }
  }
}
