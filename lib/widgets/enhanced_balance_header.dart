import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';
import 'gradient_card.dart';

/// Enhanced Balance Header with integrated Summary Dashboard
class EnhancedBalanceHeader extends StatelessWidget {
  final List<PredictionModel> predictions;
  final VoidCallback? onAddFunds;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWinningStreakTap;
  final VoidCallback? onTopLeaguesTap;
  final VoidCallback? onStatsTap;

  const EnhancedBalanceHeader({
    super.key,
    required this.predictions,
    this.onAddFunds,
    this.onNotificationTap,
    this.onWinningStreakTap,
    this.onTopLeaguesTap,
    this.onStatsTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        // Calculate stats
        final stats = _calculateStats(predictions);
        final topLeagues = _getTopLeagues(predictions);
        final winningStreak = _getWinningStreak(predictions);

        return Container(
          margin: Responsive.padding(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Balance Card
              GradientCard(
                colors: [
                  Color(AppConfig.primary500), // Orange
                  Color(AppConfig.primary600), // Darker orange
                ],
                margin: EdgeInsets.zero,
                padding: Responsive.padding(all: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Profile and Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // User Profile
                        Row(
                          children: [
                            CircleAvatar(
                              radius: Responsive.width(24),
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: user != null
                                  ? Text(
                                      (user.username.isNotEmpty
                                          ? user.username[0].toUpperCase()
                                          : 'U'),
                                      style: TextStyle(
                                        fontSize: Responsive.fontSize(18),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: Responsive.fontSize(20),
                                      color: Colors.white,
                                    ),
                            ),
                            SizedBox(width: Responsive.spacing(12)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.username ?? 'Guest User',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Responsive.fontSize(16),
                                  ),
                                ),
                                SizedBox(height: Responsive.spacing(4)),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up,
                                      size: Responsive.fontSize(14),
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: Responsive.spacing(4)),
                                    Text(
                                      '\$0.00',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: Responsive.fontSize(14),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Action Buttons
                        Row(
                          children: [
                            if (onNotificationTap != null)
                              IconButton(
                                onPressed: onNotificationTap,
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: Responsive.fontSize(24),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            SizedBox(width: Responsive.spacing(8)),
                            if (onAddFunds != null)
                              IconButton(
                                onPressed: onAddFunds,
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: Responsive.fontSize(24),
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  shape: const CircleBorder(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: Responsive.spacing(20)),

                    // Balance Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Balance',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: Responsive.fontSize(12),
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(4)),
                            Text(
                              '\$0.00',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(28),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Last deposit',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: Responsive.fontSize(12),
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(4)),
                            Text(
                              '\$0.00',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: Responsive.spacing(12)),

              // Summary Stats Row
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
      },
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                    color: Color(AppConfig.neutral600),
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
                color: Color(AppConfig.neutral500),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.radius(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
                  color: Color(AppConfig.neutral400),
                ),
              ],
            ),
            SizedBox(height: Responsive.spacing(12)),
            if (topLeagues.isEmpty)
              Text(
                'No data available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Color(AppConfig.neutral400),
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
                              : Color(AppConfig.neutral200),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: index == 0
                                  ? Colors.white
                                  : Color(AppConfig.neutral600),
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
