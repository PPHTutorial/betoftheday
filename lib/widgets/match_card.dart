import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../utils/logo_loader.dart';
import '../utils/odds_calculator.dart';
import '../utils/paywall_guard.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/ad_service.dart'; // Added AdService import
import '../screens/highlights/highlights_screen.dart';
import 'match_analysis_view.dart';

/// Simplified Match Card showing core info. Details moved to Analysis View.
class MatchCard extends StatefulWidget {
  final MatchPrediction prediction;
  final VoidCallback? onTap;
  final bool showDate;
  final bool isPremium;

  const MatchCard({
    super.key,
    required this.prediction,
    this.onTap,
    this.showDate = true,
    this.isPremium = false,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isBookmarked = false;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _preloadStatus();
  }

  /// Single async call on mount â€” replaces 3 per-build FutureBuilder widgets.
  Future<void> _preloadStatus() async {
    final storage = StorageService();
    final results = await Future.wait([
      storage.isBookmarked(widget.prediction.id),
      storage.isMatchUnlocked(widget.prediction.id),
    ]);
    if (mounted) {
      setState(() {
        _isBookmarked = results[0];
        _isUnlocked = results[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final prediction = widget.prediction;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(16),
        vertical: Responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(Responsive.radius(24)),
        boxShadow: [
          BoxShadow(
            color: theme.cardTheme.shadowColor ??
                theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.onTap != null) {
              widget.onTap!();
            } else {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (_, scrollController) => ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                    child: MatchAnalysisView(
                      prediction: prediction,
                      isPremium: widget.isPremium,
                    ),
                  ),
                ),
              ).then((_) {
                if (mounted) setState(() {});
              });
            }
          },
          borderRadius: BorderRadius.circular(Responsive.radius(20)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.spacing(16)),
            child: Column(
              children: [
                // Header (League & Time/Live)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        prediction.league.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                          fontSize: Responsive.fontSize(9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () async {
                              // Paywall gate - bookmarking is a premium feature
                              if (!PaywallGuard.isSubscribed(context)) {
                                PaywallGuard.showPaywall(context);
                                return;
                              }
                              // Optimistic toggle
                              setState(() => _isBookmarked = !_isBookmarked);
                              await StorageService()
                                  .toggleBookmark(prediction.id);
                              if (_isBookmarked) {
                                NotificationService()
                                    .showBookmarkNotification(prediction);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'ðŸ“Œ Bookmarked ${prediction.homeTeam} vs ${prediction.awayTeam}! Alerts enabled.'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Padding(
                              padding:
                                  EdgeInsets.all(Responsive.spacing(4)),
                              child: Icon(
                                _isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: theme.colorScheme.primary,
                                size: Responsive.fontSize(20),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Responsive.spacing(8)),
                        if (prediction.isFinished || prediction.isLive)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => HighlightsScreen(
                                      homeTeam: prediction.homeTeam,
                                      awayTeam: prediction.awayTeam,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(Responsive.spacing(4)),
                                child: Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Colors.red,
                                  size: Responsive.fontSize(20),
                                ),
                              ),
                            ),
                          ),
                        if (prediction.isFinished || prediction.isLive)
                          SizedBox(width: Responsive.spacing(8)),
                        if (prediction.isLive)
                          _LiveBadge(playTime: prediction.matchTime)
                        else if (prediction.isFinished)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: Responsive.spacing(8),
                                vertical: Responsive.spacing(4)),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(Responsive.radius(6)),
                            ),
                            child: Text(
                              'PLAYED',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                fontSize: Responsive.fontSize(10),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          )
                        else if (widget.showDate)
                          Text(
                            (() {
                              final dateStr = DateFormat('MMM dd')
                                  .format(prediction.matchDate);
                              final timeStr = prediction.matchTime.isNotEmpty
                                  ? prediction.matchTime
                                  : DateFormat('HH:mm')
                                      .format(prediction.matchDate);
                              return '$dateStr â€¢ $timeStr';
                            })(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: Responsive.spacing(16)),

                // Teams and Score
                Row(
                  children: [
                    Expanded(
                        child: _TeamInfo(
                            name: prediction.homeTeam,
                            logo: prediction.homeLogo,
                            isHome: true)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(12)),
                      child: Column(
                        children: [
                          if (prediction.score != null)
                            Text(
                              prediction.score!,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            )
                          else
                            Text(
                              'VS',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                        child: _TeamInfo(
                            name: prediction.awayTeam,
                            logo: prediction.awayLogo,
                            isHome: false)),
                  ],
                ),
                SizedBox(height: Responsive.spacing(16)),

                if (prediction.prediction != null)
                  Builder(builder: (context) {
                    final canView = _isUnlocked || prediction.isFinished;

                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(12),
                        vertical: Responsive.spacing(10),
                      ),
                      decoration: BoxDecoration(
                        color: prediction.isFinished
                            ? (prediction.isPredictionHit == true
                                ? Colors.green.withValues(alpha: 0.05)
                                : Colors.red.withValues(alpha: 0.05))
                            : theme.colorScheme.primary
                                .withValues(alpha: 0.05),
                        borderRadius:
                            BorderRadius.circular(Responsive.radius(12)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                              prediction.isFinished
                                  ? (prediction.isPredictionHit == true
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded)
                                  : (canView
                                      ? Icons.auto_graph_rounded
                                      : Icons.lock_rounded),
                              size: 16,
                              color: theme.colorScheme.primary),
                          SizedBox(width: Responsive.spacing(8)),
                          Expanded(
                            child: Text(
                              canView
                                  ? (prediction.isFinished
                                      ? (prediction.isPredictionHit == true
                                          ? 'PREDICTION HIT'
                                          : 'PREDICTION MISS')
                                      : 'PREDICTED SCORE: ${prediction.prediction}')
                                  : 'Unlock to view prediction',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: prediction.isFinished && canView
                                    ? (prediction.isPredictionHit == true
                                        ? Colors.green
                                        : Colors.red)
                                    : theme.colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!prediction.isFinished && _isUnlocked) ...[
                            SizedBox(width: Responsive.spacing(8)),
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {
                                  AdService.instance.showInterstitialAd(
                                    onAdClosed: () {
                                      _showOddsBottomSheet(
                                          context, prediction, theme);
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      theme.colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Responsive.spacing(12)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                child: const Text('GET ODDS ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  }),
                /* if (prediction.matchResult != null)
                  Padding(
                    padding: EdgeInsets.only(top: Responsive.spacing(12)),
                    child: Builder(
                      builder: (context) {
                        final res = prediction.matchResult!;
                        final hp = double.tryParse(
                                res.homeTeamProb?.replaceAll('%', '') ?? '0') ??
                            0;
                        final dp = double.tryParse(
                                res.drawProb?.replaceAll('%', '') ?? '0') ??
                            0;
                        final ap = double.tryParse(
                                res.awayTeamProb?.replaceAll('%', '') ?? '0') ??
                            0;

                        if (hp == 0 && ap == 0) return const SizedBox.shrink();

                        final hOdds = OddsCalculator.format(
                            OddsCalculator.calculateFairOdds(hp / 100));
                        final dOdds = OddsCalculator.format(
                            OddsCalculator.calculateFairOdds(dp / 100));
                        final aOdds = OddsCalculator.format(
                            OddsCalculator.calculateFairOdds(ap / 100));

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _OddsBox(label: '1', odds: hOdds),
                            _OddsBox(label: 'X', odds: dOdds),
                            _OddsBox(label: '2', odds: aOdds),
                          ],
                        );
                      },
                    ),
                  ), */
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOddsBottomSheet(
      BuildContext context, MatchPrediction prediction, ThemeData theme) {
    final res = prediction.matchResult;
    final hp =
        double.tryParse(res?.homeTeamProb?.replaceAll('%', '') ?? '0') ?? 0;
    final dp = double.tryParse(res?.drawProb?.replaceAll('%', '') ?? '0') ?? 0;
    final ap =
        double.tryParse(res?.awayTeamProb?.replaceAll('%', '') ?? '0') ?? 0;

    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(Responsive.spacing(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FAIR ODDS',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              SizedBox(height: Responsive.spacing(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOddItem(theme, '1',
                      OddsCalculator.calculateFairOdds(hp / 100), isDark),
                  _buildOddItem(theme, 'X',
                      OddsCalculator.calculateFairOdds(dp / 100), isDark),
                  _buildOddItem(theme, '2',
                      OddsCalculator.calculateFairOdds(ap / 100), isDark),
                ],
              ),
              SizedBox(height: Responsive.spacing(32)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding:
                        EdgeInsets.symmetric(vertical: Responsive.spacing(16)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('DISMISS',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOddItem(
      ThemeData theme, String label, double value, bool isDark) {
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold)),
        SizedBox(height: Responsive.spacing(8)),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: Responsive.spacing(20),
              vertical: Responsive.spacing(12)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value.toStringAsFixed(2),
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}

class _TeamInfo extends StatefulWidget {
  final String name;
  final String? logo;
  final bool isHome;

  const _TeamInfo({required this.name, this.logo, required this.isHome});

  @override
  State<_TeamInfo> createState() => _TeamInfoState();
}

class _TeamInfoState extends State<_TeamInfo> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  void didUpdateWidget(_TeamInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.name != widget.name) {
      _checkFavorite();
    }
  }

  Future<void> _checkFavorite() async {
    final isFav = await StorageService().isFavoriteTeam(widget.name);
    if (mounted) setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    final nowFav = await StorageService().toggleFavoriteTeam(widget.name);
    if (mounted) {
      setState(() => _isFavorite = nowFav);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowFav
                ? 'â­ Added ${widget.name} to favorite clubs! Alerts enabled.'
                : 'Removed ${widget.name} from favorite clubs.',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: () {
        // Paywall gate â€” favourite teams is a premium feature
        if (!PaywallGuard.isSubscribed(context)) {
          PaywallGuard.showPaywall(context);
          return;
        }
        _toggleFavorite();
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Responsive.width(44),
                height: Responsive.width(44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: _isFavorite
                      ? Border.all(color: Colors.amber, width: 2)
                      : null,
                ),
                child: Padding(
                  padding: EdgeInsets.all(Responsive.spacing(6)),
                  child: widget.logo != null
                      ? Image.network(
                          widget.logo!,
                          cacheWidth: 100,
                          cacheHeight: 100,
                          errorBuilder: (_, __, ___) =>
                              LogoLoader.teamLogo(widget.name, size: 30),
                        )
                      : LogoLoader.teamLogo(widget.name, size: 30),
                ),
              ),
              if (_isFavorite)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      size: 12,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: Responsive.spacing(8)),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: _isFavorite ? FontWeight.w900 : FontWeight.w700,
                    fontSize: Responsive.fontSize(12),
                    color: _isFavorite ? Colors.amber : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isFavorite) ...[
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final String playTime;
  const _LiveBadge({required this.playTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(8), vertical: Responsive.spacing(4)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Responsive.radius(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          SizedBox(width: Responsive.spacing(6)),
          Text(
            playTime.isNotEmpty ? playTime : 'LIVE',
            style: TextStyle(
              color: Colors.red,
              fontSize: Responsive.fontSize(10),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
