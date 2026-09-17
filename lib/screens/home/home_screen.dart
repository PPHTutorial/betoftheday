import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/predictions_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/balance_header.dart';
import '../../widgets/match_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../screens/detail/prediction_detail_screen.dart';

import '../../models/prediction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPredictions();
      }
    });
  }

  Future<void> _loadPredictions() async {
    final predictionsProvider =
        Provider.of<PredictionsProvider>(context, listen: false);
    // Initial load - defaults to Today (offset 0)
    await predictionsProvider.loadMatches();
  }

  void _onNavTap(int index) {
    if (_currentNavIndex == index) return;

    setState(() {
      _currentNavIndex = index;
    });

    final provider = Provider.of<PredictionsProvider>(context, listen: false);

    // Switch data source based on tab
    switch (index) {
      case 0: // Home -> Today
        provider.setDayOffset(0);
        break;
      case 1: // Live -> Today (filtered in UI)
        if (provider.selectedDayOffset != 0) provider.setDayOffset(0);
        break;
      case 2: // VIP -> Tomorrow (Day +1)
        provider.setDayOffset(1);
        break;
      case 3: // My Bets -> Day +2
        provider.setDayOffset(2);
        break;
      case 4: // Profile -> Settings?
        // Keep current data or navigate
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    // Calculate item count with ads
    // Logic: Item at index i maps to match at index (i - ads_before_i)
    // But since we removed ad insertion logic for simplicity, we just use length.

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Balance Header at Top (Static/Welcome)
            const BalanceHeader(),

            // Main Content
            Expanded(
              child: Consumer<PredictionsProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading && provider.matches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text('Loading matches...',
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    );
                  }

                  if (provider.error != null && provider.matches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 48, color: theme.colorScheme.error),
                          const SizedBox(height: 16),
                          Text('Error loading matches',
                              style: theme.textTheme.titleMedium),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Text(
                              provider.error!,
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => provider.loadMatches(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter matches based on tab
                  List<MatchPrediction> displayMatches = provider.matches;
                  String emptyMessage = 'No matches found';

                  if (_currentNavIndex == 1) {
                    // Live Tab
                    displayMatches = provider.liveMatches;
                    emptyMessage = 'No live matches right now';
                  }

                  if (displayMatches.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.sports_soccer,
                              size: 64, color: theme.colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(emptyMessage,
                              style: theme.textTheme.titleMedium),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.refreshMatches,
                    child: ListView.builder(
                      padding: EdgeInsets.only(bottom: Responsive.spacing(80)),
                      itemCount: displayMatches.length,
                      itemBuilder: (context, index) {
                        final match = displayMatches[index];
                        return MatchCard(
                          prediction: match,
                          showDate: true,
                          onTap: () {
                            if (match.matchUrl.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PredictionDetailScreen(prediction: match),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
