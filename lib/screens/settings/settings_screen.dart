import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/responsive.dart';
import '../../config/app_config.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_widget.dart';
import '../../services/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Set status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: theme.brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: Responsive.fontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: Responsive.padding(all: 16),
              children: [
                // App Theme Section
                _buildSectionHeader(context, 'Appearance'),
                SizedBox(height: Responsive.spacing(8)),
                Card(
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
                          themeProvider.themeMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : themeProvider.themeMode == ThemeMode.light
                                  ? Icons.light_mode
                                  : Icons.brightness_auto,
                          color: Color(AppConfig.primary600),
                        ),
                        title: Text(
                          'Theme',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          _getThemeModeText(themeProvider.themeMode),
                          style: TextStyle(
                            fontSize: Responsive.fontSize(14),
                            color: Color(AppConfig.neutral500),
                          ),
                        ),
                        trailing: Switch(
                          value: themeProvider.themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            themeProvider.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light,
                            );
                          },
                          activeColor: Color(AppConfig.primary600),
                        ),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.brightness_auto,
                          color: Color(AppConfig.primary600),
                        ),
                        title: Text(
                          'Use System Theme',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),
                        trailing: Switch(
                          value: themeProvider.themeMode == ThemeMode.system,
                          onChanged: (value) {
                            themeProvider.setThemeMode(
                              value ? ThemeMode.system : ThemeMode.light,
                            );
                          },
                          activeColor: Color(AppConfig.primary600),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(24)),

                // Account Section
                _buildSectionHeader(context, 'Account'),
                SizedBox(height: Responsive.spacing(8)),
                Card(
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
                      if (authProvider.isAuthenticated && authProvider.user != null) ...[
                        ListTile(
                          leading: CircleAvatar(
                            radius: Responsive.radius(20),
                            backgroundColor: Color(AppConfig.primary100),
                            child: Text(
                              authProvider.user!.username.isNotEmpty
                                  ? authProvider.user!.username[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                color: Color(AppConfig.primary600),
                                fontSize: Responsive.fontSize(18),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            authProvider.user!.username,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(16),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            authProvider.user!.email,
                            style: TextStyle(
                              fontSize: Responsive.fontSize(14),
                              color: Color(AppConfig.neutral500),
                            ),
                          ),
                        ),
                        Divider(height: 1),
                        if (authProvider.isVip)
                          ListTile(
                            leading: Icon(
                              Icons.star,
                              color: Color(AppConfig.primary600),
                            ),
                            title: Text(
                              'VIP Member',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(16),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Active subscription',
                              style: TextStyle(
                                fontSize: Responsive.fontSize(14),
                                color: Color(AppConfig.neutral500),
                              ),
                            ),
                          ),
                        if (authProvider.isVip) Divider(height: 1),
                      ],
                      ListTile(
                        leading: Icon(
                          authProvider.isAuthenticated
                              ? Icons.logout
                              : Icons.login,
                          color: authProvider.isAuthenticated
                              ? Colors.red
                              : Color(AppConfig.primary600),
                        ),
                        title: Text(
                          authProvider.isAuthenticated ? 'Sign Out' : 'Sign In',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                            fontWeight: FontWeight.w500,
                            color: authProvider.isAuthenticated
                                ? Colors.red
                                : null,
                          ),
                        ),
                        onTap: () async {
                          if (authProvider.isAuthenticated) {
                            // Show interstitial ad before sign out
                            await AdService.instance.showInterstitialAd(
                              onAdClosed: () async {
                                await authProvider.signout();
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                            );
                          } else {
                            // Navigate to sign in
                            Navigator.of(context).pushNamed('/auth');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(24)),

                // About Section
                _buildSectionHeader(context, 'About'),
                SizedBox(height: Responsive.spacing(8)),
                Card(
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
                          Icons.info_outline,
                          color: Color(AppConfig.primary600),
                        ),
                        title: Text(
                          'App Version',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),
                        subtitle: Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(14),
                            color: Color(AppConfig.neutral500),
                          ),
                        ),
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.description_outlined,
                          color: Color(AppConfig.primary600),
                        ),
                        title: Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Color(AppConfig.neutral400),
                        ),
                        onTap: () {
                          // TODO: Navigate to terms
                        },
                      ),
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(
                          Icons.privacy_tip_outlined,
                          color: Color(AppConfig.primary600),
                        ),
                        title: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Color(AppConfig.neutral400),
                        ),
                        onTap: () {
                          // TODO: Navigate to privacy policy
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Responsive.spacing(24)),

                // Native Ad
                NativeAdWidget(
                  height: Responsive.height(300),
                  margin: Responsive.padding(vertical: 8),
                ),
                SizedBox(height: Responsive.spacing(16)),
              ],
            ),
          ),
          // Banner Ad at bottom
          AdaptiveBannerAdWidget(
            margin: Responsive.padding(vertical: 8),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: Responsive.fontSize(18),
        fontWeight: FontWeight.bold,
        color: Color(AppConfig.neutral700),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }
}

