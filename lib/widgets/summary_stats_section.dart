import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';

/// Summary Stats Section (scrollable, part of content)
class SummaryStatsSection extends StatelessWidget {
  final List<PredictionModel> predictions;
  final VoidCallback? onWinningStreakTap;
  final VoidCallback? onTopLeaguesTap;
  final VoidCallback? onStatsTap;

  const SummaryStatsSection({
    super.key,
    required this.predictions,
    this.onWinningStreakTap,
    this.onTopLeaguesTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    // Calculate stats
    final stats = _calculateStats(predictions);
    final topLeagues = _getTopLeagues(predictions);
    final winningStreak = _getWinningStreak(predictions);

    return Container(
      margin: Responsive.padding(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Summary',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(20),
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),

          // Stats Cards Row
          Row(
            children: [
              // Winning Streak Card
              Expanded(
                child: _StatCard(
                  title: 'Winning Streak',
                  value: '${winningStreak}',
                  subtitle: 'consecutive wins',
                  icon: Icons.local_fire_department,
                  color: Color(AppConfig.success500),
                  onTap: onWinningStreakTap,
                ),
              ),
              SizedBox(width: Responsive.spacing(12)),

              // Win Rate Card
              Expanded(
                child: _StatCard(
                  title: 'Win Rate',
                  value: '${stats['winRate']}%',
                  subtitle: '${stats['totalWon']}/${stats['totalPlayed']}',
                  icon: Icons.trending_up,
                  color: Color(AppConfig.primary600),
                  onTap: onStatsTap,
                ),
              ),
            ],
          ),

          SizedBox(height: Responsive.spacing(12)),

          // Top Leagues Card
          _TopLeaguesCard(
            topLeagues: topLeagues,
            onTap: onTopLeaguesTap,
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats(List<PredictionModel> predictions) {
    final played = predictions.where((p) => !p.isPending).toList();
    final won = played.where((p) => p.isWon).toList();

    final totalPlayed = played.length;
    final totalWon = won.length;
    final winRate =
        totalPlayed > 0 ? ((totalWon / totalPlayed) * 100).round() : 0;

    return {
      'totalPlayed': totalPlayed,
      'totalWon': totalWon,
      'winRate': winRate,
    };
  }

  List<Map<String, dynamic>> _getTopLeagues(List<PredictionModel> predictions) {
    final leagueStats = <String, Map<String, int>>{};

    for (final pred in predictions.where((p) => !p.isPending)) {
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
      final winRate = stats['total']! > 0
          ? (stats['won']! / stats['total']! * 100).round()
          : 0;
      return {
        'league': entry.key,
        'won': stats['won']!,
        'total': stats['total']!,
        'winRate': winRate,
      };
    }).toList()
      ..sort((a, b) => (b['winRate'] as int).compareTo(a['winRate'] as int));

    return topLeagues.take(3).toList();
  }

  int _getWinningStreak(List<PredictionModel> predictions) {
    final sorted = predictions.where((p) => !p.isPending).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    int streak = 0;
    for (final pred in sorted) {
      if (pred.isWon) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.padding(all: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: Responsive.fontSize(12),
                  ),
                ),
                Icon(icon, size: Responsive.fontSize(20), color: color),
              ],
            ),
            SizedBox(height: Responsive.spacing(8)),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: Responsive.fontSize(24),
              ),
            ),
            SizedBox(height: Responsive.spacing(4)),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: Responsive.fontSize(11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopLeaguesCard extends StatelessWidget {
  final List<Map<String, dynamic>> topLeagues;
  final VoidCallback? onTap;

  const _TopLeaguesCard({
    required this.topLeagues,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Responsive.padding(all: 16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Leagues',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: Responsive.fontSize(14),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: Responsive.fontSize(14),
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(12)),
            if (topLeagues.isEmpty)
              Text(
                'No data available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              )
            else
              ...topLeagues.asMap().entries.map((entry) {
                final index = entry.key;
                final league = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: Responsive.spacing(8)),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.width(24),
                        height: Responsive.width(24),
                        decoration: BoxDecoration(
                          color: index == 0
                              ? Color(AppConfig.warning500)
                              : theme.colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: index == 0
                                  ? Colors.white
                                  : theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(11),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.spacing(12)),
                      Expanded(
                        child: Text(
                          league['league'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.fontSize(13),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${league['winRate']}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Color(AppConfig.success500),
                          fontWeight: FontWeight.bold,
                          fontSize: Responsive.fontSize(12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
