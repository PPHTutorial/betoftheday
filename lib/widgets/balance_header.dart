import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';
import 'gradient_card.dart';

/// Balance Header Card (Simplified for non-auth version)
class BalanceHeader extends StatelessWidget {
  final VoidCallback? onAddFunds;
  final VoidCallback? onNotificationTap;

  const BalanceHeader({
    super.key,
    this.onAddFunds,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Container(
      margin: Responsive.padding(horizontal: 16, vertical: 12),
      child: GradientCard(
        colors: [
          Color(AppConfig.primary500),
          Color(AppConfig.primary600),
        ],
        margin: EdgeInsets.zero,
        padding: Responsive.padding(all: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bet of the Day',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(24),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(4)),
                  Text(
                    'Daily AI Predictions',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: Responsive.fontSize(14),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(Responsive.spacing(10)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: Responsive.fontSize(32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
