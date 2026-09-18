import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home/scheduled_matches_screen.dart';
import 'live/live_matches_screen.dart';
import 'explore/explore_screen.dart';
import 'settings/settings_screen.dart';
import 'analytics/advanced_analytics_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Default to Live Matches as requested (active menu)

  final List<Widget> _screens = [
    const AdvancedAnalyticsScreen(),
    const ScheduledMatchesScreen(),
    const LiveMatchesScreen(),
    const ExploreScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
