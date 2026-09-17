import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';
import '../utils/responsive.dart';

class FirstUnlockDialog extends StatelessWidget {
  const FirstUnlockDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const FirstUnlockDialog(),
    );
  }

  Future<void> _handleRate(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      } else {
        await inAppReview.openStoreListing();
      }
    } catch (_) {}
    if (context.mounted) nav.pop();
  }

  Future<void> _handleShare(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '⚽ I just unlocked an AI prediction on ${AppConfig.appName}! Check out today\'s match analysis and expected goals: https://play.google.com/store/apps/details?id=com.codeinktechnologies.betoftheday',
          subject: '${AppConfig.appName} - AI Football Predictions',
        ),
      );
    } catch (_) {}
    if (context.mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.spacing(24),
        Responsive.spacing(16),
        Responsive.spacing(24),
        Responsive.spacing(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(20)),

          // Celebration Icon with gradient glow
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 40,
              color: Colors.white,
            ),
          ),
          SizedBox(height: Responsive.spacing(18)),

          // Title
          Text(
            '1st Free Prediction Unlocked! 🎉',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: Responsive.spacing(10)),

          // Body text
          Text(
            'You\'re now viewing full AI probability metrics and xG analytics. If you love the edge, help us keep improving by giving us a quick 5-star rating or sharing with your crew!',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.spacing(24)),

          // Action 1: Rate 5 Stars
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _handleRate(context),
              icon: const Icon(Icons.star_rounded, color: Colors.white, size: 22),
              label: const Text(
                'Rate 5 Stars on Google Play',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),

          // Action 2: Share with Friends
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _handleShare(context),
              icon: Icon(Icons.share_rounded,
                  color: isDark ? Colors.white : const Color(0xFF0F172A), size: 20),
              label: Text(
                'Share with Fellow Punters',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : const Color(0xFFCBD5E1),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),

          // Action 3: Continue
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue to Match Analysis',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
