import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../../config/app_config.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_widget.dart';
import '../settings/settings_screen.dart';
import '../../services/ad_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: authProvider.user != null
                  ? _buildProfileContent(context, theme, authProvider)
                  : const Center(child: CircularProgressIndicator()),
            ),
            // Banner Ad at bottom
            AdaptiveBannerAdWidget(
              margin: Responsive.padding(vertical: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, ThemeData theme, AuthProvider authProvider) {
    return CustomScrollView(
      slivers: [
        // User Info Header
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.padding(all: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(16)),
                side: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: Responsive.padding(all: 24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: Responsive.radius(40),
                      backgroundColor: Color(AppConfig.primary100),
                      child: Text(
                        authProvider.user!.username.isNotEmpty
                            ? authProvider.user!.username[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Color(AppConfig.primary600),
                          fontSize: Responsive.fontSize(32),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(16)),
                    Text(
                      authProvider.user!.username,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Responsive.spacing(4)),
                    Text(
                      authProvider.user!.email,
                      style: TextStyle(
                        fontSize: Responsive.fontSize(14),
                        color: Color(AppConfig.neutral500),
                      ),
                    ),
                    if (authProvider.isVip) ...[
                      SizedBox(height: Responsive.spacing(16)),
                      Container(
                        padding: Responsive.padding(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(AppConfig.primary500),
                              Color(AppConfig.primary600),
                            ],
                          ),
                          borderRadius:
                              BorderRadius.circular(Responsive.radius(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: Responsive.fontSize(20),
                            ),
                            SizedBox(width: Responsive.spacing(8)),
                            Text(
                              'VIP Member',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.fontSize(14),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.padding(horizontal: 16),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: Responsive.fontSize(18),
                fontWeight: FontWeight.bold,
                color: Color(AppConfig.neutral700),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: Responsive.spacing(8)),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.padding(horizontal: 16),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.radius(12)),
                side: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: Color(AppConfig.primary600),
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(16),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Color(AppConfig.neutral400),
                    ),
                    onTap: () async {
                      // Show rewarded ad before opening settings
                      await AdService.instance.showRewardedAd(
                        onRewarded: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                        onError: (error) {
                          // If ad fails, still navigate
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // Native Ad
        SliverToBoxAdapter(
          child: Padding(
            padding: Responsive.padding(all: 16),
            child: NativeAdWidget(
              height: Responsive.height(300),
            ),
          ),
        ),

        // Bottom padding
        SliverToBoxAdapter(
          child: SizedBox(height: Responsive.spacing(80)),
        ),
      ],
    );
  }
}
