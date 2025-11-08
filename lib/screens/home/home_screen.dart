import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/predictions_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive.dart';
import '../../widgets/balance_header.dart';
import '../../widgets/summary_stats_section.dart';
import '../../widgets/match_card.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/feature_detail_dialog.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/native_ad_widget.dart';
import '../../models/prediction_model.dart';
import '../../config/app_config.dart';
import '../auth/auth_screen.dart';
import '../profile/profile_screen.dart';
import 'prediction_detail_screen.dart';
import '../../services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  static const int _nativeAdInterval = 2;

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
    await predictionsProvider.loadPredictions();
  }

  bool _isNativeAdIndex(int index) {
    return (index + 1) % (_nativeAdInterval + 1) == 0;
  }

  int _getPredictionIndexForPosition(int index) {
    return index - (index ~/ (_nativeAdInterval + 1));
  }

  int _getItemCountWithNativeAds(int itemCount) {
    if (itemCount <= 0) return 0;
    return itemCount + (itemCount ~/ _nativeAdInterval);
  }

  Widget _buildNativeAdTile(int position) {
    return Padding(
      padding: Responsive.padding(horizontal: 16, vertical: 12),
      child: NativeAdWidget(
        key: ValueKey('native_ad_$position'),
        height: Responsive.height(280),
      ),
    );
  }

  List<Widget> _buildVipMatchSection(List<PredictionModel> matches) {
    final List<Widget> widgets = [];
    for (int i = 0; i < matches.length; i++) {
      if (i > 0 && i % _nativeAdInterval == 0) {
        widgets.add(_buildNativeAdTile(i));
      }

      final prediction = matches[i];
      widgets.add(
        MatchCard(
          prediction: prediction,
          showDate: true,
          onTap: () => _handlePredictionTap(prediction),
        ),
      );
    }
    return widgets;
  }

  Future<void> _handlePredictionTap(PredictionModel prediction) async {
    try {
      await AdService.instance.showRandomAd(
        onRewarded: () {},
        onError: (error) {
          debugPrint('Ad error: $error');
        },
      );
    } catch (e) {
      debugPrint('Ad exception: $e');
    }

    if (!mounted) return;
    _openPredictionDetail(prediction);
  }

  void _openPredictionDetail(PredictionModel prediction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PredictionDetailScreen(prediction: prediction),
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  // Get previously played matches (not pending) - for Home tab
  List<PredictionModel> _getPreviouslyPlayedMatches(
      List<PredictionModel> predictions) {
    return predictions.where((p) => !p.isPending).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  // Get pending FREE_GAME matches - for Live tab
  List<PredictionModel> _getLiveFreeGames(List<PredictionModel> predictions) {
    return predictions
        .where((p) => p.isPending && p.gameType == GameType.freeGame)
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  // Get VIP matches (non-FREE_GAME, excluding Correct Score) - for VIP tab
  List<PredictionModel> _getVipMatches(List<PredictionModel> predictions) {
    return predictions
        .where((p) =>
            p.isPending &&
            p.gameType != GameType.freeGame &&
            p.gameType != GameType.correctScore)
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  // Get Correct Score matches - for MY BETS tab
  List<PredictionModel> _getCorrectScoreMatches(
      List<PredictionModel> predictions) {
    return predictions
        .where((p) => p.isPending && p.gameType == GameType.correctScore)
        .toList()
      ..sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
  }

  // Check if VIP features require auth
  Future<bool> _checkAuthForVip(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      final result = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Sign In Required'),
            ),
            body: const AuthScreen(),
          ),
          fullscreenDialog: true,
        ),
      );
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    return Scaffold(
      body: SafeArea(
        child: Consumer2<AuthProvider, PredictionsProvider>(
          builder: (context, authProvider, predictionsProvider, child) {
            // Show loading or error states
            if (predictionsProvider.isLoading &&
                predictionsProvider.predictions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading predictions...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            if (predictionsProvider.error != null &&
                predictionsProvider.predictions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading predictions',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        predictionsProvider.error!,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadPredictions(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final predictions = predictionsProvider.predictions;
            final previouslyPlayed = _getPreviouslyPlayedMatches(predictions);

            // Get current tab content based on bottom nav index
            Widget currentContent;
            switch (_currentNavIndex) {
              case 0: // Home - Previously Played
                currentContent = _buildHomeTab(previouslyPlayed);
                break;
              case 1: // Live - Free Games
                currentContent = _buildLiveTab(predictions);
                break;
              case 2: // Sport/VIP - VIP, Correct Score, non-FREE_GAME
                // Check auth for VIP
                if (!authProvider.isAuthenticated) {
                  currentContent = _buildAuthRequiredTab();
                } else {
                  currentContent = _buildVipTab(predictions);
                }
                break;
              case 3: // My Bets - Correct Score matches
                if (!authProvider.isAuthenticated) {
                  currentContent = _buildAuthRequiredTab();
                } else {
                  currentContent = _buildMyBetsTab(predictions);
                }
                break;
              case 4: // Profile
                if (!authProvider.isAuthenticated) {
                  currentContent = _buildAuthRequiredTab();
                } else {
                  currentContent = const ProfileScreen();
                }
                break;
              default:
                currentContent = _buildHomeTab(previouslyPlayed);
            }

            return Column(
              children: [
                // Fixed Balance Header at Top
                BalanceHeader(
                  onAddFunds: () async {
                    if (!authProvider.isAuthenticated) {
                      await _checkAuthForVip(context);
                    } else {
                      // Show rewarded interstitial ad before navigating
                      await AdService.instance.showRewardedInterstitialAd(
                        onRewarded: () {
                          // TODO: Navigate to add funds screen
                        },
                        onError: (error) {
                          // If ad fails, still navigate
                          // TODO: Navigate to add funds screen
                        },
                      );
                    }
                  },
                  onNotificationTap: () async {
                    if (!authProvider.isAuthenticated) {
                      await _checkAuthForVip(context);
                    } else {
                      // TODO: Navigate to notifications
                    }
                  },
                ),

                // Current Tab Content (scrollable)
                Expanded(child: currentContent),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: ModernBottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildHomeTab(List<PredictionModel> previouslyPlayed) {
    return RefreshIndicator(
      onRefresh: _loadPredictions,
      color: Color(AppConfig.primary600),
      child: CustomScrollView(
        slivers: [
          // Summary Stats Section (scrollable)
          SliverToBoxAdapter(
            child: SummaryStatsSection(
              predictions: previouslyPlayed,
              onWinningStreakTap: () {
                _showWinningStreakDialog(previouslyPlayed);
              },
              onTopLeaguesTap: () {
                _showTopLeaguesDialog(previouslyPlayed);
              },
              onStatsTap: () {
                _showStatsDialog(previouslyPlayed);
              },
            ),
          ),

          // Previously Played Matches
          if (previouslyPlayed.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: Responsive.fontSize(64),
                      color: Color(AppConfig.neutral400),
                    ),
                    SizedBox(height: Responsive.spacing(16)),
                    Text(
                      'No previously played matches',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Color(AppConfig.neutral600),
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.only(bottom: Responsive.spacing(80)),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    // Show banner ad every 4 matches
                    if (index > 0 && index % 3 == 0) {
                      return Column(
                        children: [
                          MatchCard(
                            prediction: previouslyPlayed[index],
                            showDate: true,
                            onTap: () {
                              // TODO: Navigate to prediction details
                            },
                          ),
                          Padding(
                            padding: Responsive.padding(vertical: 8),
                            child: AdaptiveBannerAdWidget(),
                          ),
                        ],
                      );
                    }
                    return MatchCard(
                      prediction: previouslyPlayed[index],
                      showDate: true,
                      onTap: () async {
                        // Show interstitial ad on match card click
                        await AdService.instance.showInterstitialAdOnImageClick(
                          onAdClosed: () {
                            // TODO: Navigate to prediction details
                          },
                        );
                      },
                    );
                  },
                  childCount: previouslyPlayed.length,
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
          // Banner ad at bottom of list
          SliverToBoxAdapter(
            child: Padding(
              padding: Responsive.padding(vertical: 8),
              child: AdaptiveBannerAdWidget(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab(List<PredictionModel> predictions) {
    final liveGames = _getLiveFreeGames(predictions);

    return RefreshIndicator(
      onRefresh: _loadPredictions,
      color: Color(AppConfig.primary600),
      child: liveGames.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt_outlined,
                    size: Responsive.fontSize(64),
                    color: Color(AppConfig.neutral400),
                  ),
                  SizedBox(height: Responsive.spacing(16)),
                  Text(
                    'No live free games',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Color(AppConfig.neutral600),
                        ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: Responsive.spacing(8)),
                    itemCount: _getItemCountWithNativeAds(liveGames.length),
                    itemBuilder: (context, index) {
                      if (_isNativeAdIndex(index)) {
                        return _buildNativeAdTile(index);
                      }

                      final itemIndex = _getPredictionIndexForPosition(index);
                      if (itemIndex < 0 || itemIndex >= liveGames.length) {
                        return const SizedBox.shrink();
                      }

                      final prediction = liveGames[itemIndex];
                      return MatchCard(
                        prediction: prediction,
                        showDate: true,
                        onTap: () => _handlePredictionTap(prediction),
                      );
                    },
                  ),
                ),
                // Native Ad
                Padding(
                  padding: Responsive.padding(all: 16),
                  child: NativeAdWidget(
                    height: Responsive.height(300),
                  ),
                ),
                // Banner ad at bottom
                AdaptiveBannerAdWidget(
                  margin: Responsive.padding(vertical: 8),
                ),
              ],
            ),
    );
  }

  Widget _buildVipTab(List<PredictionModel> predictions) {
    final vipMatches = _getVipMatches(predictions);

    // Group by game type
    final Map<GameType, List<PredictionModel>> grouped = {};
    for (final match in vipMatches) {
      grouped.putIfAbsent(match.gameType, () => []).add(match);
    }

    return RefreshIndicator(
      onRefresh: _loadPredictions,
      color: Color(AppConfig.primary600),
      child: vipMatches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_outline,
                    size: Responsive.fontSize(64),
                    color: Color(AppConfig.neutral400),
                  ),
                  SizedBox(height: Responsive.spacing(16)),
                  Text(
                    'No VIP matches available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Color(AppConfig.neutral600),
                        ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(bottom: Responsive.spacing(80)),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final gameType = grouped.keys.elementAt(index);
                final matches = grouped[gameType]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Header
                    Padding(
                      padding: Responsive.padding(horizontal: 16, vertical: 12),
                      child: Text(
                        gameType.displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(18),
                            ),
                      ),
                    ),
                    // Matches
                    ..._buildVipMatchSection(matches),
                    SizedBox(height: Responsive.spacing(12)),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildAuthRequiredTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: Responsive.fontSize(64),
            color: Color(AppConfig.neutral400),
          ),
          SizedBox(height: Responsive.spacing(16)),
          Text(
            'Sign In Required',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Color(AppConfig.neutral600),
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: Responsive.spacing(8)),
          Text(
            'Please sign in to access this feature',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Color(AppConfig.neutral500),
                ),
          ),
          SizedBox(height: Responsive.spacing(24)),
          ElevatedButton(
            onPressed: () async {
              await _checkAuthForVip(context);
              if (mounted) {
                setState(() {}); // Refresh to show VIP content if authenticated
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(AppConfig.primary600),
              padding: Responsive.padding(horizontal: 32, vertical: 16),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: Responsive.fontSize(16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBetsTab(List<PredictionModel> predictions) {
    final correctScoreMatches = _getCorrectScoreMatches(predictions);

    return RefreshIndicator(
      onRefresh: _loadPredictions,
      color: Color(AppConfig.primary600),
      child: correctScoreMatches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_soccer_outlined,
                    size: Responsive.fontSize(64),
                    color: Color(AppConfig.neutral400),
                  ),
                  SizedBox(height: Responsive.spacing(16)),
                  Text(
                    'No Correct Score predictions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Color(AppConfig.neutral600),
                        ),
                  ),
                  SizedBox(height: Responsive.spacing(8)),
                  Text(
                    'Check back later for new predictions',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Color(AppConfig.neutral500),
                        ),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: Responsive.padding(all: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Correct Score Predictions',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(20),
                              ),
                        ),
                        SizedBox(height: Responsive.spacing(8)),
                        Text(
                          '${correctScoreMatches.length} prediction${correctScoreMatches.length != 1 ? 's' : ''} available',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Color(AppConfig.neutral600),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Correct Score Matches List
                SliverPadding(
                  padding: EdgeInsets.only(bottom: Responsive.spacing(80)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (_isNativeAdIndex(index)) {
                          return _buildNativeAdTile(index);
                        }

                        final itemIndex = _getPredictionIndexForPosition(index);
                        if (itemIndex < 0 ||
                            itemIndex >= correctScoreMatches.length) {
                          return const SizedBox.shrink();
                        }

                        final prediction = correctScoreMatches[itemIndex];
                        return MatchCard(
                          prediction: prediction,
                          showDate: true,
                          onTap: () => _handlePredictionTap(prediction),
                        );
                      },
                      childCount: _getItemCountWithNativeAds(
                          correctScoreMatches.length),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showWinningStreakDialog(List<PredictionModel> predictions) {
    final sorted = predictions.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    final winningStreak = <PredictionModel>[];
    for (final pred in sorted) {
      if (pred.isWon) {
        winningStreak.add(pred);
      } else {
        break;
      }
    }

    FeatureDetailDialog.show(
      context,
      title: 'Winning Streak',
      description: 'Your consecutive winning predictions',
      predictions: winningStreak,
    );
  }

  void _showTopLeaguesDialog(List<PredictionModel> predictions) {
    final leagueStats = <String, Map<String, int>>{};

    for (final pred in predictions) {
      leagueStats.putIfAbsent(pred.league, () => {'won': 0, 'total': 0});
      leagueStats[pred.league]!['total'] =
          (leagueStats[pred.league]!['total'] ?? 0) + 1;
      if (pred.isWon) {
        leagueStats[pred.league]!['won'] =
            (leagueStats[pred.league]!['won'] ?? 0) + 1;
      }
    }

    final topLeagues = leagueStats.entries.map((entry) {
      final stats = entry.value;
      return {
        'league': entry.key,
        'won': stats['won']!,
        'total': stats['total']!,
      };
    }).toList()
      ..sort((a, b) => (b['won'] as int).compareTo(a['won'] as int));

    final topLeagueNames =
        topLeagues.map((e) => e['league'] as String).toList();
    final topLeaguePredictions = predictions
        .where((p) => topLeagueNames.contains(p.league))
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    FeatureDetailDialog.show(
      context,
      title: 'Top Leagues',
      description: 'Leagues with most wins',
      predictions: topLeaguePredictions,
    );
  }

  void _showStatsDialog(List<PredictionModel> predictions) {
    final played = predictions.where((p) => !p.isPending).toList();
    final won = played.where((p) => p.isWon).toList();
    final lost = played.where((p) => p.isLost).toList();

    FeatureDetailDialog.show(
      context,
      title: 'Statistics',
      description:
          'Total Played: ${played.length}\nWon: ${won.length}\nLost: ${lost.length}',
      predictions: played,
    );
  }
}
