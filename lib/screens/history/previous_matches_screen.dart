import 'package:btd/models/league_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/predictions_provider.dart';
import '../../widgets/match_card.dart';
import '../../config/app_config.dart';

class PreviousMatchesScreen extends StatefulWidget {
  const PreviousMatchesScreen({super.key});

  @override
  State<PreviousMatchesScreen> createState() => _PreviousMatchesScreenState();
}

class _PreviousMatchesScreenState extends State<PreviousMatchesScreen> {
  String _selectedLeagueId = 'ALL';
  Timer? _reloadTimer;
  final ScrollController _scrollController = ScrollController();

  Map<String, String> _getLeagues(List<League> discoveredLeagues) {
    final map = {
      'ALL': 'All Matches',
    };
    for (final l in discoveredLeagues) {
      map[l.id] = l.name;
    }
    for (final entry in AppConfig.popularLeagues.entries) {
      if (!map.containsKey(entry.key)) {
        map[entry.key] = entry.value;
      }
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _startAutoReload();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Trigger load more when near bottom
      context.read<PredictionsProvider>().loadMoreHistory();
    }
  }

  void _startAutoReload() {
    _reloadTimer?.cancel();
    _reloadTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted && _selectedLeagueId != 'ALL') {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    _reloadTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    Provider.of<PredictionsProvider>(context, listen: false)
        .loadPreviousMatches(_selectedLeagueId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Matches'),
      ),
      body: Column(
        children: [
          // League Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Consumer<PredictionsProvider>(
              builder: (context, provider, child) {
                final leagues = _getLeagues(provider.leagues);
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: leagues.length,
                  itemBuilder: (context, index) {
                    final leagueId = leagues.keys.elementAt(index);
                    final leagueName = leagues[leagueId]!;
                    final isSelected = _selectedLeagueId == leagueId;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        backgroundColor: theme.colorScheme.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        label: Text(leagueName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedLeagueId = leagueId);
                            _loadData();
                          }
                        },
                        selectedColor:
                            theme.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Match List
          Expanded(
            child: Consumer<PredictionsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.previousMatches.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.previousMatches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No previous matches found'),
                      ],
                    ),
                  );
                }

                // Sorting is now handled partially by DB for 'ALL',
                // but we keep local sort for consistency in other league loads
                final sortedMatches = List.of(provider.previousMatches);
                if (_selectedLeagueId != 'ALL') {
                  sortedMatches
                      .sort((a, b) => b.matchDate.compareTo(a.matchDate));
                }

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: sortedMatches.length +
                        (provider.hasMoreHistory ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == sortedMatches.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      }
                      final match = sortedMatches[index];
                      return MatchCard(
                        prediction: match,
                        showDate: true,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
