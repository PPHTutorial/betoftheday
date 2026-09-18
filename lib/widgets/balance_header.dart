import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../services/storage_service.dart';
import '../screens/notifications/notification_inbox_screen.dart';
import 'gradient_card.dart';

/// Balance Header Card (Simplified for non-auth version)
class BalanceHeader extends StatefulWidget {
  final VoidCallback? onAddFunds;
  final VoidCallback? onNotificationTap;

  const BalanceHeader({
    super.key,
    this.onAddFunds,
    this.onNotificationTap,
  });

  @override
  State<BalanceHeader> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await StorageService().getUnreadNotificationCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Container(
      margin: Responsive.padding(horizontal: 16, vertical: 12),
      child: GradientCard(
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
            GestureDetector(
              onTap: () async {
                if (widget.onNotificationTap != null) {
                  widget.onNotificationTap!();
                } else {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationInboxScreen()),
                  );
                  _loadUnreadCount();
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(Responsive.spacing(10)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: Colors.white,
                      size: Responsive.fontSize(26),
                    ),
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 14,
                        ),
                        child: Text(
                          _unreadCount > 99 ? '99+' : '$_unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
