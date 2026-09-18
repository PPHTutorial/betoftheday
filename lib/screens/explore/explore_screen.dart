import 'package:btd/models/league_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../utils/responsive.dart';
import '../../providers/predictions_provider.dart';
import '../../models/prediction_model.dart';
import 'match_list_screen.dart';
import '../highlights/highlights_screen.dart';
import '../history/previous_matches_screen.dart';
import '../../services/storage_service.dart';
import '../../widgets/match_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    // Get all matches from provider to search locally
    final provider = Provider.of<PredictionsProvider>(context);
    final allMatches = [...provider.matches, ...provider.previousMatches];

    List<MatchPrediction> searchResults = [];
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      searchResults = allMatches.where((m) {
        return m.homeTeam.toLowerCase().contains(q) ||
            m.awayTeam.toLowerCase().contains(q) ||
            m.league.toLowerCase().contains(q);
      }).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'EXPLORE',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: Responsive.fontSize(16),
          ),
        ),
        centerTitle: true,
      ),
      body: _searchQuery.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(20),
                    vertical: Responsive.spacing(10),
                  ),
                  child: _buildSearchBar(theme),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.spacing(20),
                    vertical: Responsive.spacing(8),
                  ),
                  child: Text(
                    'SEARCH RESULTS (${searchResults.length})',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Expanded(
                  child: searchResults.isEmpty
                      ? SizedBox(
                          height: Responsive.height(200),
                          child: const Center(
                              child: Text('No fixtures or clubs found.')),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            bottom: Responsive.spacing(40),
                          ),
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: Responsive.spacing(12)),
                              child: MatchCard(
                                  prediction: searchResults[index]),
                            );
                          },
                        ),
                ),
              ],
            )
          : ListView(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.spacing(20),
                vertical: Responsive.spacing(10),
              ),
              children: [
                _buildSearchBar(theme),
                SizedBox(height: Responsive.spacing(24)),
                _SectionHeader(
                  title: 'TOP LEAGUES',
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MatchListScreen(
                          title: 'ALL MATCHES',
                          matches: provider.matches,
                        ),
                      ),
                    );
                  },
                ),
                const _LeagueGrid(),
                SizedBox(height: Responsive.spacing(32)),
                _SectionHeader(
                  title: 'MATCH ANALYSIS SEGMENTS',
                  onSeeAll: () {},
                ),
                const _SegmentList(),
                SizedBox(height: Responsive.spacing(40)),
              ],
            ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Responsive.radius(16)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search leagues, clubs or fixtures...',
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: Responsive.fontSize(14),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'See All',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: Responsive.fontSize(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeagueGrid extends StatelessWidget {
  const _LeagueGrid();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = Provider.of<PredictionsProvider>(context);
    final leagues = provider.leagues.isNotEmpty
        ? provider.leagues
        : AppConfig.popularLeagues.entries
            .map((e) => League(
                id: e.key,
                name: e.value,
                country: '',
                url: '',
                leagueLogo: '',
                leagueCountry: '',
                leagueCountryFlag: ''))
            .toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: Responsive.spacing(12),
        mainAxisSpacing: Responsive.spacing(12),
        childAspectRatio: 2.4,
      ),
      itemCount: leagues.length.clamp(0, 6),
      itemBuilder: (context, index) {
        final league = leagues[index];
        final id = league.id;
        final name = league.name;

        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(Responsive.radius(20)),
            boxShadow: [
              BoxShadow(
                color: theme.cardTheme.shadowColor ??
                    theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MatchListScreen(
                          title: name,
                          matches: provider.matches
                              .where((m) =>
                                  m.leagueId == id ||
                                  m.league.toLowerCase().trim() ==
                                      name.toLowerCase().trim())
                              .toList())));
            },
            borderRadius: BorderRadius.circular(Responsive.radius(20)),
            child: Center(
              child: Text(
                name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: Responsive.fontSize(12),
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SegmentList extends StatelessWidget {
  const _SegmentList();

  double _parseProb(String? probStr) {
    if (probStr == null) return 0.0;
    return double.tryParse(probStr.replaceAll('%', '')) ?? 0.0;
  }

  double _parseXG(String? xgStr) {
    if (xgStr == null) return 0.0;
    return double.tryParse(xgStr) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final segments = [
      {
        'id': 'trends',
        'title': 'Top Trends',
        'icon': Icons.trending_up,
        'color': Colors.blue
      },
      {
        'id': 'xg',
        'title': 'High xG Wins',
        'icon': Icons.bolt,
        'color': Colors.amber
      },
      {
        'id': 'history',
        'title': 'Match History',
        'icon': Icons.history_rounded,
        'color': Colors.purple
      },
      {
        'id': 'safe',
        'title': 'Safe Bets',
        'icon': Icons.verified_user_rounded,
        'color': Colors.green
      },
      {
        'id': 'longspots',
        'title': 'Long Shots',
        'icon': Icons.track_changes,
        'color': Colors.orange
      },
      {
        'id': 'goals',
        'title': 'Most Goals',
        'icon': Icons.sports_soccer,
        'color': Colors.red
      },
      {
        'id': 'highlights',
        'title': 'Highlights',
        'icon': Icons.play_circle_fill,
        'color': Colors.redAccent
      },
      {
        'id': 'bookmarks',
        'title': 'Bookmarks',
        'icon': Icons.bookmark_rounded,
        'color': theme.colorScheme.primary
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final item = segments[index];

        return Container(
          margin: EdgeInsets.only(bottom: Responsive.spacing(12)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: isDark ? 0.2 : 0.03),
            borderRadius: BorderRadius.circular(Responsive.radius(16)),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(16),
              vertical: Responsive.spacing(4),
            ),
            leading: Container(
              padding: EdgeInsets.all(Responsive.spacing(10)),
              decoration: BoxDecoration(
                color: (item['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.radius(12)),
              ),
              child: Icon(
                item['icon'] as IconData,
                color: item['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              item['title'] as String,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: Responsive.fontSize(14),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            onTap: () async {
              final provider =
                  Provider.of<PredictionsProvider>(context, listen: false);
              final allMatches = provider.matches;
              List<MatchPrediction> filtered = [];

              switch (item['id']) {
                case 'trends':
                  filtered = List.from(allMatches)
                    ..sort((a, b) {
                      final wa =
                          int.tryParse(a.weight?.replaceAll('%', '') ?? '0') ??
                              0;
                      final wb =
                          int.tryParse(b.weight?.replaceAll('%', '') ?? '0') ??
                              0;
                      return wb.compareTo(wa);
                    });
                  filtered = filtered.take(20).toList();
                  break;
                case 'xg':
                  filtered = allMatches.where((m) {
                    final hXg = _parseXG(m.matchStats?.homeTeamExpectedGoals);
                    final aXg = _parseXG(m.matchStats?.awayTeamExpectedGoals);
                    return (hXg + aXg) > 2.5; // High expected goals
                  }).toList();
                  filtered.sort((a, b) {
                    final aXg = _parseXG(a.matchStats?.homeTeamExpectedGoals) +
                        _parseXG(a.matchStats?.awayTeamExpectedGoals);
                    final bXg = _parseXG(b.matchStats?.homeTeamExpectedGoals) +
                        _parseXG(b.matchStats?.awayTeamExpectedGoals);
                    return bXg.compareTo(aXg);
                  });
                  break;
                case 'safe':
                case 'safe_bets':
                  filtered = allMatches.where((m) {
                    final hp = _parseProb(m.matchResult?.homeTeamProb);
                    final ap = _parseProb(m.matchResult?.awayTeamProb);
                    return hp > 65 || ap > 65;
                  }).toList();
                  break;
                case 'longspots':
                case 'long_shots':
                  filtered = allMatches.where((m) {
                    final hp = _parseProb(m.matchResult?.homeTeamProb);
                    final ap = _parseProb(m.matchResult?.awayTeamProb);
                    final dp = _parseProb(m.matchResult?.drawProb);
                    final maxProb =
                        [hp, ap, dp].reduce((a, b) => a > b ? a : b);
                    return maxProb > 0 && maxProb < 45; // No clear favorite
                  }).toList();
                  break;
                case 'goals':
                case 'most_goals':
                  filtered = allMatches.where((m) {
                    final hXg = _parseXG(m.matchStats?.homeTeamExpectedGoals);
                    final aXg = _parseXG(m.matchStats?.awayTeamExpectedGoals);
                    return (hXg + aXg) > 2.5;
                  }).toList();
                  filtered.sort((a, b) {
                    final aXg = _parseXG(a.matchStats?.homeTeamExpectedGoals) +
                        _parseXG(a.matchStats?.awayTeamExpectedGoals);
                    final bXg = _parseXG(b.matchStats?.homeTeamExpectedGoals) +
                        _parseXG(b.matchStats?.awayTeamExpectedGoals);
                    return bXg.compareTo(aXg);
                  });
                  break;
                case 'history':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PreviousMatchesScreen(),
                    ),
                  );
                  return;
                case 'highlights':
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HighlightsScreen(
                              searchQuery: 'Football Match Highlights today')));
                  return;
                case 'bookmarks':
                  final bookmarkedIds =
                      await StorageService().getBookmarkedMatchIds();
                  final allCombined = [
                    ...provider.matches,
                    ...provider.previousMatches,
                  ];
                  filtered = allCombined
                      .where((m) => bookmarkedIds.contains(m.id))
                      .toList();
                  break;
              }

              if (!context.mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MatchListScreen(
                          title: item['title'] as String, matches: filtered)));
            },
          ),
        );
      },
    );
  }
}
