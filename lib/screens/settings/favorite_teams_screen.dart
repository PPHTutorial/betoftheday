import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/predictions_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/logo_loader.dart';
import '../../utils/responsive.dart';
import '../explore/match_list_screen.dart';
import '../../services/iap_service.dart';
import '../../utils/paywall_guard.dart';

class FavoriteTeamsScreen extends StatefulWidget {
  const FavoriteTeamsScreen({super.key});

  @override
  State<FavoriteTeamsScreen> createState() => _FavoriteTeamsScreenState();
}

class _FavoriteTeamsScreenState extends State<FavoriteTeamsScreen> {
  final StorageService _storage = StorageService();
  final TextEditingController _searchController = TextEditingController();

  List<String> _favoriteTeams = [];
  bool _notifsEnabled = true;
  bool _isLoading = true;
  String _searchQuery = '';

  // Well-known popular teams to suggest if not yet added
  static const List<String> _popularTeams = [
    'Arsenal',
    'Manchester City',
    'Liverpool',
    'Real Madrid',
    'Barcelona',
    'Bayern Munich',
    'Paris Saint-Germain',
    'Inter Milan',
    'AC Milan',
    'Juventus',
    'Chelsea',
    'Manchester United',
    'Atletico Madrid',
    'Borussia Dortmund',
    'Bayer Leverkusen',
    'Tottenham Hotspur',
    'Aston Villa',
    'Sporting CP',
    'Benfica',
    'Ajax',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(() {
      setState(
          () => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final teams = await _storage.getFavoriteTeams();
    final notifs = await _storage.getFavoriteTeamsNotifsEnabled();
    if (mounted) {
      setState(() {
        _favoriteTeams = teams;
        _notifsEnabled = notifs;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTeam(String team) async {
    final nowFav = await _storage.toggleFavoriteTeam(team);
    final updated = await _storage.getFavoriteTeams();
    if (mounted) {
      setState(() => _favoriteTeams = updated);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowFav
                ? '⭐ Added $team to favorites'
                : 'Removed $team from favorites',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<PredictionsProvider>(context, listen: false);

    // Collect all available team names from currently loaded fixtures
    final Set<String> allTeamsSet = {};
    for (final m in provider.matches) {
      if (m.homeTeam.trim().isNotEmpty) allTeamsSet.add(m.homeTeam.trim());
      if (m.awayTeam.trim().isNotEmpty) allTeamsSet.add(m.awayTeam.trim());
    }
    // Also add popular teams
    allTeamsSet.addAll(_popularTeams);

    final allTeams = allTeamsSet.toList()..sort((a, b) => a.compareTo(b));

    final filteredTeams = _searchQuery.isEmpty
        ? allTeams
        : allTeams
            .where((t) => t.toLowerCase().contains(_searchQuery))
            .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'FAVORITE TEAMS',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: Responsive.fontSize(16),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context, _favoriteTeams),
        ),
      ),
      body: Consumer<IAPService>(
        builder: (context, iap, _) {
          if (!iap.isSubscribed) {
            return _buildPaywallPlaceholder(context, theme);
          }
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Notification Preference Card
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(16),
                        vertical: Responsive.spacing(8),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(Responsive.spacing(14)),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF161922)
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(Responsive.radius(16)),
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(Responsive.spacing(10)),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.notifications_active_rounded,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(12)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Matchday Alerts',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: Responsive.spacing(2)),
                                  Text(
                                    'Receive notifications when your teams play, go live, or finish.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                      fontSize: Responsive.fontSize(11),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _notifsEnabled,
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) async {
                                setState(() => _notifsEnabled = val);
                                await _storage
                                    .setFavoriteTeamsNotifsEnabled(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(16),
                        vertical: Responsive.spacing(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search club (e.g. Arsenal, Real Madrid)...',
                          hintStyle: TextStyle(
                            fontSize: Responsive.fontSize(13),
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon:
                                      const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF13161F)
                              : theme.colorScheme.surfaceContainerHighest,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: Responsive.spacing(12),
                            horizontal: Responsive.spacing(16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Responsive.radius(14)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Current Favorites Horizontal Chips (if any)
                    if (_favoriteTeams.isNotEmpty && _searchQuery.isEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(16),
                          vertical: Responsive.spacing(4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'MY FAVORITES (${_favoriteTeams.length})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Tap to view matches',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: Responsive.fontSize(10),
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Responsive.height(56),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(16),
                            vertical: Responsive.spacing(6),
                          ),
                          itemCount: _favoriteTeams.length,
                          itemBuilder: (context, idx) {
                            final team = _favoriteTeams[idx];
                            return Padding(
                              padding:
                                  EdgeInsets.only(right: Responsive.spacing(8)),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    Responsive.radius(20)),
                                onTap: () {
                                  final teamMatches = provider.matches
                                      .where((m) =>
                                          m.homeTeam.toLowerCase() ==
                                              team.toLowerCase() ||
                                          m.awayTeam.toLowerCase() ==
                                              team.toLowerCase())
                                      .toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MatchListScreen(
                                        title: '$team Matches',
                                        matches: teamMatches,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.spacing(12),
                                    vertical: Responsive.spacing(6),
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                        Responsive.radius(20)),
                                    border: Border.all(
                                      color: theme.colorScheme.primary
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      LogoLoader.teamLogo(team, size: 20),
                                      SizedBox(width: Responsive.spacing(6)),
                                      Text(
                                        team,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: Responsive.fontSize(12),
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      SizedBox(width: Responsive.spacing(6)),
                                      GestureDetector(
                                        onTap: () => _toggleTeam(team),
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 16),
                    ],

                    // All Teams List
                    Expanded(
                      child: filteredTeams.isEmpty
                          ? Center(
                              child: Text(
                                'No clubs found for "$_searchQuery"',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                horizontal: Responsive.spacing(16),
                                vertical: Responsive.spacing(8),
                              ),
                              itemCount: filteredTeams.length,
                              itemBuilder: (context, idx) {
                                final team = filteredTeams[idx];
                                final isFav = _favoriteTeams.contains(team);

                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: Responsive.spacing(8)),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF141720)
                                        : theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(
                                        Responsive.radius(14)),
                                    border: isFav
                                        ? Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.4),
                                            width: 1.5,
                                          )
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child:
                                          LogoLoader.teamLogo(team, size: 26),
                                    ),
                                    title: Text(
                                      team,
                                      style: TextStyle(
                                        fontWeight: isFav
                                            ? FontWeight.w900
                                            : FontWeight.w600,
                                        fontSize: Responsive.fontSize(14),
                                        color: isFav
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isFav
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: isFav
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.3),
                                        size: 26,
                                      ),
                                      onPressed: () => _toggleTeam(team),
                                    ),
                                    onTap: () => _toggleTeam(team),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  Widget _buildPaywallPlaceholder(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.2),
                    theme.colorScheme.primary.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star_rounded,
                size: 56,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'VIP FEATURE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Favorite Teams',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Follow your clubs and receive instant matchday alerts when your favorite teams kick off, go live, or finish.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PaywallGuard.showPaywall(context),
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('UNLOCK VIP ACCESS',
                    style: TextStyle(fontWeight: FontWeight.w900)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
