import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_config.dart';
import '../../providers/theme_provider.dart';
import '../../providers/predictions_provider.dart';
import '../../utils/responsive.dart';
import '../../services/storage_service.dart';
import '../explore/match_list_screen.dart';
import '../highlights/highlights_screen.dart';
import '../offers/offers_screen.dart';
import '../onboarding/onboarding_screen.dart';
import 'subscription_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '1.0.0';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    final notifs = await StorageService().getNotificationsEnabled();
    if (mounted) {
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
        _notificationsEnabled = notifs;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: Responsive.fontSize(16),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(20),
          vertical: Responsive.spacing(10),
        ),
        children: [
          _buildCategory(theme, 'PROFILE'),
          _buildSettingsGroup(
            theme,
            isDark,
            [
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.workspace_premium_rounded,
                color: theme.colorScheme.primary,
                title: 'VIP Subscription',
                subtitle: 'Manage unlock access & plans',
                trailing: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SubscriptionScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text('UPGRADE',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary)),
                ),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.confirmation_num_rounded,
                color: Colors.teal,
                title: 'Offers & Promo Codes',
                subtitle: 'Redeem pass or claim free codes',
                trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OffersScreen()),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(30)),
          _buildCategory(theme, 'PREFERENCES'),
          _buildSettingsGroup(
            theme,
            isDark,
            [
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.palette_rounded,
                color: theme.colorScheme.primary,
                title: 'Appearance',
                subtitle: 'Theme & Styling',
                trailing: _buildThemeToggle(context),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.color_lens_rounded,
                color: theme.colorScheme.primary,
                title: 'Accent Color',
                subtitle: 'Customize app primary color',
                trailing: _buildAccentColorPicker(context),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.notifications_active_rounded,
                color: theme.colorScheme.primary,
                title: 'Notifications',
                subtitle: 'Match updates & tips',
                trailing: Switch.adaptive(
                  value: _notificationsEnabled,
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) async {
                    setState(() => _notificationsEnabled = val);
                    await StorageService().setNotificationsEnabled(val);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(30)),
          _buildCategory(theme, 'ACTIVITY'),
          _buildSettingsGroup(
            theme,
            isDark,
            [
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.bookmark_rounded,
                color: theme.colorScheme.primary,
                title: 'Bookmarked Matches',
                subtitle: 'Your saved match alerts',
                onTap: () async {
                  final provider =
                      Provider.of<PredictionsProvider>(context, listen: false);
                  final bookmarkedIds =
                      await StorageService().getBookmarkedMatchIds();
                  final filtered = provider.matches
                      .where((m) => bookmarkedIds.contains(m.id))
                      .toList();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchListScreen(
                          title: 'Bookmarked Matches',
                          matches: filtered,
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.play_circle_fill_rounded,
                color: theme.colorScheme.primary,
                title: 'Top Highlights',
                subtitle: 'Watch recent match recaps',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HighlightsScreen(
                        searchQuery: 'Football Match Highlights today',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(30)),
          _buildCategory(theme, 'APP SETTINGS'),
          _buildSettingsGroup(
            theme,
            isDark,
            [
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.share_rounded,
                color: theme.colorScheme.primary,
                title: 'Share App',
                onTap: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Check out Bet Of The Day for expert football predictions!',
                  ),
                ),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.star_rounded,
                color: theme.colorScheme.primary,
                title: 'Rate App',
                onTap: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  await inAppReview.requestReview();
                },
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.cloud_upload_rounded,
                color: theme.colorScheme.primary,
                title: 'Backup Data',
                onTap: () => _confirmAction(
                    context, 'Backup', 'Do you want to backup your favorites?'),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.delete_forever_rounded,
                color: theme.colorScheme.primary,
                title: 'Clear Data',
                onTap: () => _confirmAction(context, 'Clear All Data',
                    'This will reset all settings and cached matches.',
                    isDestructive: true),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(30)),
          _buildCategory(theme, 'ABOUT'),
          _buildSettingsGroup(
            theme,
            isDark,
            [
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.info_outline_rounded,
                color: theme.colorScheme.primary,
                title: 'App Version',
                trailing: Text(
                  _version,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.explore_rounded,
                color: theme.colorScheme.primary,
                title: 'App Tour & Walkthrough',
                subtitle: 'Revisit feature overview & tips',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const OnboardingScreen()),
                  );
                },
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.gavel_rounded,
                color: theme.colorScheme.primary,
                title: 'Terms of Service',
                onTap: () => _launchUrl(AppConfig.termsOfServiceUrl),
              ),
              _buildSettingTile(
                theme,
                isDark,
                icon: Icons.privacy_tip_rounded,
                color: theme.colorScheme.primary,
                title: 'Privacy Policy',
                onTap: () => _launchUrl(AppConfig.privacyPolicyUrl),
              ),
            ],
          ),
          SizedBox(height: Responsive.spacing(40)),
          Center(
            child: Text(
              '© 2026 BET OF THE DAY\nPREMIUM FOOTBALL ANALYSIS',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(40)),
        ],
      ),
    );
  }

  Widget _buildCategory(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4, bottom: Responsive.spacing(12)),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(
      ThemeData theme, bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: isDark ? 0.35 : 0.08),
        borderRadius: BorderRadius.circular(Responsive.radius(20)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingTile(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding:
          EdgeInsets.symmetric(horizontal: Responsive.spacing(20), vertical: 4),
      leading: Container(
        padding: EdgeInsets.all(Responsive.spacing(12)),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(Responsive.radius(14)),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: Responsive.fontSize(14),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: Responsive.fontSize(11),
              ),
            )
          : null,
      trailing: trailing ??
          Icon(Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
    );
  }

  Widget _buildAccentColorPicker(BuildContext context) {
    final colors = [
      const Color(0xFFE4572E), // Orange
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF10B981), // Emerald
      const Color(0xFFEC4899), // Pink
      const Color(0xFF3B82F6), // Blue
    ];

    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: colors.map((c) {
            final isSelected = provider.accentColor.value == c.value;
            return GestureDetector(
              onTap: () => provider.setAccentColor(c),
              child: Container(
                margin: const EdgeInsets.only(left: 8),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c.withValues(alpha: 0.5),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, _) {
        return InkWell(
          onTap: () => provider.toggleTheme(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  provider.themeMode == ThemeMode.dark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 6),
                Text(
                  provider.themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmAction(BuildContext context, String title, String msg,
      {bool isDestructive = false}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (isDestructive) {
                // Clear storage
                await StorageService().clearAll();
                // Reset in-memory provider state
                if (context.mounted) {
                  Provider.of<PredictionsProvider>(context, listen: false)
                      .resetData();
                }
              }
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Action successful')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(title),
          ),
        ],
      ),
    );
  }
}
