import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';
import 'gradient_card.dart';

/// Balance Header Card (fixed at top)
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

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Container(
          margin: Responsive.padding(horizontal: 16, vertical: 12),
          child: GradientCard(
            colors: [
              Color(AppConfig.primary500), // Orange 500
              Color(AppConfig.primary600), // Orange 600
            ],
            margin: EdgeInsets.zero,
            padding: Responsive.padding(all: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Profile and Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // User Profile
                    Row(
                      children: [
                        CircleAvatar(
                          radius: Responsive.width(24),
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: user != null
                              ? Text(
                                  (user.username.isNotEmpty
                                      ? user.username[0].toUpperCase()
                                      : 'U'),
                                  style: TextStyle(
                                    fontSize: Responsive.fontSize(18),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: Responsive.fontSize(20),
                                  color: Colors.white,
                                ),
                        ),
                        SizedBox(width: Responsive.spacing(12)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Guest User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(16),
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(4)),
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: Responsive.fontSize(14),
                                  color: Colors.white,
                                ),
                                SizedBox(width: Responsive.spacing(4)),
                                Text(
                                  '\$0.00',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: Responsive.fontSize(14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Action Buttons
                    Row(
                      children: [
                        if (onNotificationTap != null)
                          IconButton(
                            onPressed: onNotificationTap,
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: Responsive.fontSize(24),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: const CircleBorder(),
                            ),
                          ),
                        SizedBox(width: Responsive.spacing(8)),
                        if (onAddFunds != null)
                          IconButton(
                            onPressed: onAddFunds,
                            icon: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: Responsive.fontSize(24),
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              shape: const CircleBorder(),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: Responsive.spacing(20)),

                // Balance Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Balance',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: Responsive.fontSize(12),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(4)),
                        Text(
                          '\$0.00',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(28),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Last deposit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: Responsive.fontSize(12),
                          ),
                        ),
                        SizedBox(height: Responsive.spacing(4)),
                        Text(
                          '\$0.00',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
