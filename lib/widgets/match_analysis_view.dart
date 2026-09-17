import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../utils/logo_loader.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';
import '../utils/odds_calculator.dart';
import 'first_unlock_dialog.dart';

class MatchAnalysisView extends StatefulWidget {
  final MatchPrediction prediction;
  final bool isPremium;

  const MatchAnalysisView({
    super.key,
    required this.prediction,
    this.isPremium = false, // Set to false to show paywall
  });

  @override
  State<MatchAnalysisView> createState() => _MatchAnalysisViewState();
}

class _MatchAnalysisViewState extends State<MatchAnalysisView> {
  bool _isUnlocked = false;
  int _activeSlots = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final storage = StorageService();
    // 1. Cleanup old slots first (rolling logic)
    final matches = await storage.getCachedMatches();
    await storage.cleanupExpiredUnlockedMatches(matches);

    // 2. Check if this specific match is unlocked
    final isUnlocked = await storage.isMatchUnlocked(widget.prediction.id);

    // 3. Get active slots count
    final unlockedIds = await storage.getUnlockedMatchIds();

    if (mounted) {
      setState(() {
        _isUnlocked = isUnlocked || widget.isPremium;
        _activeSlots = unlockedIds.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _unlockForFree() async {
    if (_activeSlots >= AppConfig.maxDailyFreeUnlocks) return;

    setState(() => _isLoading = true);
    final storage = StorageService();
    final idsBefore = await storage.getUnlockedMatchIds();
    final wasFirstUnlock = idsBefore.isEmpty;

    await storage.unlockMatch(widget.prediction.id);
    await _checkStatus();

    // Check if this was the user's first unlock (1/2) and prompt for review & share
    final alreadyPrompted = await storage.hasPromptedFirstUnlockReview();
    if ((wasFirstUnlock || !alreadyPrompted) && mounted) {
      await storage.setPromptedFirstUnlockReview(true);
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await FirstUnlockDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final showContent =
        _isUnlocked || widget.isPremium || widget.prediction.isFinished;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(Responsive.spacing(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMatchHeader(theme),
                  SizedBox(height: Responsive.spacing(30)),
                  if (showContent) ...[
                    _buildSectionTitle(theme, 'MATCH DETAILS'),
                    _buildMatchDetailsSection(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'WIN PROBABILITY'),
                    _buildProbabilitySection(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'TEAM ANALYSIS'),
                    _buildTeamAnalysis(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'HEAD-TO-HEAD STATS'),
                    _buildHeadToHeadStats(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'GOAL PROBABILITY'),
                    _buildGoalProbabilityGrid(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'ODDS ANALYSIS'),
                    _buildOddsAnalysis(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'BEST BETS & MARKET ANALYSIS'),
                    _buildMarketAnalysis(theme),
                    SizedBox(height: Responsive.spacing(30)),
                    _buildSectionTitle(theme, 'PREDICTION ANALYSIS'),
                    _buildPredictionAnalysis(theme),
                  ] else ...[
                    _buildPremiumPaywall(theme),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAnalysis(ThemeData theme) {
    final recs = widget.prediction.recommendations;
    if (recs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text('Calculating advanced market analysis...',
              style: theme.textTheme.bodySmall),
        ),
      );
    }

    // Sort: Safe first, then by probability
    final sortedRecs = List<BetRecommendation>.from(recs)
      ..sort((a, b) {
        if (a.confidence == 'Safe' && b.confidence != 'Safe') return -1;
        if (a.confidence != 'Safe' && b.confidence == 'Safe') return 1;
        return b.probability.compareTo(a.probability);
      });

    return Column(
      children: sortedRecs.take(6).map((rec) {
        final isSafe = rec.confidence == 'Safe';
        final color = isSafe ? Colors.green : theme.colorScheme.primary;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSafe
                ? Colors.green.withValues(alpha: 0.05)
                : theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSafe
                  ? Colors.green.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isSafe ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(rec.type.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          )),
                      const SizedBox(height: 4),
                      Text(rec.prediction,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          )),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isSafe ? '🔥 SAFE BET' : rec.confidence.toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rec.probability,
                        backgroundColor: color.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(rec.probability * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: theme.colorScheme.surface,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Match Analysis',
        style:
            theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget _buildMatchDetailsSection(ThemeData theme) {
    final stats = widget.prediction.matchStats;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildDetailRow(
              theme,
              'Competition',
              stats?.competition.isNotEmpty == true
                  ? stats!.competition
                  : widget.prediction.league.toUpperCase()),
          _buildDetailRow(
              theme,
              'Season',
              widget.prediction.season.isNotEmpty
                  ? widget.prediction.season
                  : '-'),
          _buildDetailRow(theme, 'Stadium', stats?.stadium ?? '-'),
          _buildDetailRow(
              theme, 'Prediction Weight', widget.prediction.weight ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              )),
          Text(value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
              )),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(Responsive.spacing(24)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(Responsive.radius(30)),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.prediction.league.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(24)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildHeaderTeam(theme, widget.prediction.homeTeam,
                  widget.prediction.homeLogo),
              _buildScoreColumn(theme),
              _buildHeaderTeam(theme, widget.prediction.awayTeam,
                  widget.prediction.awayLogo),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTeam(ThemeData theme, String name, String? logo) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: Responsive.width(64),
            height: Responsive.width(64),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Padding(
              padding: EdgeInsets.all(Responsive.spacing(10)),
              child: logo != null
                  ? Image.network(logo,
                      errorBuilder: (_, __, ___) =>
                          LogoLoader.teamLogo(name, size: 40))
                  : LogoLoader.teamLogo(name, size: 40),
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),
          Text(
            name,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn(ThemeData theme) {
    if (widget.prediction.score != null) {
      return Column(
        children: [
          Text(
            widget.prediction.score!,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: Responsive.spacing(8)),
          if (widget.prediction.isLive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                widget.prediction.matchTime.isNotEmpty
                    ? widget.prediction.matchTime
                    : 'LIVE',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          'VS',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.spacing(16)),
      child: Text(
        title,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildProbabilitySection(ThemeData theme) {
    final res = widget.prediction.matchResult!;
    double h =
        double.tryParse(res.homeTeamProb?.replaceAll('%', '') ?? '33.3') ??
            33.3;
    double d =
        double.tryParse(res.drawProb?.replaceAll('%', '') ?? '33.3') ?? 33.3;
    double a =
        double.tryParse(res.awayTeamProb?.replaceAll('%', '') ?? '33.4') ??
            33.4;

    return Column(
      children: [
        _buildProbRow(theme, 'Home Win', res.homeTeamProb ?? '33%',
            theme.colorScheme.primary, h / 100),
        SizedBox(height: 12),
        _buildProbRow(
            theme, 'Draw', res.drawProb ?? '33%', Colors.grey, d / 100),
        SizedBox(height: 12),
        _buildProbRow(theme, 'Away Win', res.awayTeamProb ?? '34%',
            theme.colorScheme.secondary, a / 100),
      ],
    );
  }

  Widget _buildProbRow(ThemeData theme, String label, String value, Color color,
      double percent) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w900, color: color)),
          ],
        ),
        SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: color.withValues(alpha: 0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildTeamAnalysis(ThemeData theme) {
    final stats = widget.prediction.matchStats;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildStatRow(
            theme,
            'Recent Form (Overall)',
            stats?.homeTeamForm ?? '-',
            stats?.awayTeamForm ?? '-',
            isForm: true,
          ),
          Divider(height: 30),
          _buildStatRow(
            theme,
            'Form (Home / Away)',
            stats?.homeTeamHomeForm ?? '-',
            stats?.awayTeamAwayForm ?? '-',
            isForm: true,
          ),
          Divider(height: 30),
          _buildStatRow(
            theme,
            'Expected Goals (xG)',
            stats?.homeTeamExpectedGoals ?? '-',
            stats?.awayTeamExpectedGoals ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, String label, String home, String away,
      {bool isForm = false}) {
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: isForm
                  ? _buildFormCircles(theme, home)
                  : Text(home,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.start),
            ),
            Expanded(
              child: isForm
                  ? _buildFormCircles(theme, away, reverse: true)
                  : Text(away,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                      textAlign: TextAlign.end),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormCircles(ThemeData theme, String form,
      {bool reverse = false}) {
    final chars = form.split('');
    final widgets = chars.take(5).map((c) {
      Color color = Colors.grey;
      if (c == 'W') color = Colors.green;
      if (c == 'L') color = Colors.red;
      return Container(
        margin: EdgeInsets.only(right: reverse ? 0 : 4, left: reverse ? 4 : 0),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Center(
          child: Text(c,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
      );
    }).toList();

    return Row(
      mainAxisAlignment:
          reverse ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: reverse ? widgets.reversed.toList() : widgets,
    );
  }

  Widget _buildPredictionAnalysis(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('EXPERT TIP',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
            ],
          ),
          SizedBox(height: 16),
          Text(
            (widget.prediction.prediction?.isNotEmpty == true)
                ? widget.prediction.prediction!
                : (widget.prediction.recommendations.isNotEmpty
                    ? widget.prediction.recommendations.first.prediction
                    : 'Analysis unavailable'),
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8),
          Text(
            'Based on recent performance, defensive metrics, and expected goals analysis.',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumPaywall(ThemeData theme) {
    final remainingSlots = AppConfig.maxDailyFreeUnlocks - _activeSlots;
    final canUnlockFree = remainingSlots > 0;

    return Container(
      padding: EdgeInsets.all(Responsive.spacing(24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Responsive.radius(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.workspace_premium_rounded,
                size: 40, color: theme.colorScheme.primary),
          ),
          SizedBox(height: Responsive.spacing(20)),
          Text(
            canUnlockFree
                ? 'Free Discovery Available'
                : 'Unlock Expert Analysis',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),
          Text(
            canUnlockFree
                ? 'You have $remainingSlots free slots remaining. Unlock this match analysis for free!'
                : AppConfig.premiumBenefit,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
          SizedBox(height: Responsive.spacing(30)),
          if (canUnlockFree) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _unlockForFree,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
                child: const Text(
                  'Unlock for Free',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: 1),
                ),
              ),
            ),
            SizedBox(height: Responsive.spacing(16)),
            Text(
              'Slots are cleared once matches are played.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: Responsive.spacing(24)),
            const Divider(),
            SizedBox(height: Responsive.spacing(24)),
          ],
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {}, // Trigger IAP flow
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              child: Text(
                'Yearly Access for ${AppConfig.yearlyPrice}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(12)),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () {}, // Trigger IAP flow
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Monthly Access for ${AppConfig.monthlyPrice}',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: Responsive.spacing(16)),
          TextButton(
            onPressed: () {}, // Trigger restore
            child: Text(
              'Already a member? Restore Purchase',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOddsAnalysis(ThemeData theme) {
    if (widget.prediction.matchResult == null) return const SizedBox.shrink();

    final res = widget.prediction.matchResult!;
    double hp =
        double.tryParse(res.homeTeamProb?.replaceAll('%', '') ?? '0') ?? 0;
    double dp = double.tryParse(res.drawProb?.replaceAll('%', '') ?? '0') ?? 0;
    double ap =
        double.tryParse(res.awayTeamProb?.replaceAll('%', '') ?? '0') ?? 0;

    if (hp == 0 && ap == 0) return const SizedBox.shrink();

    final homeOdds = OddsCalculator.calculateFairOdds(hp / 100);
    final drawOdds = OddsCalculator.calculateFairOdds(dp / 100);
    final awayOdds = OddsCalculator.calculateFairOdds(ap / 100);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOddsItem(
                  theme, '1 (Home)', OddsCalculator.format(homeOdds)),
              _buildOddsItem(
                  theme, 'X (Draw)', OddsCalculator.format(drawOdds)),
              _buildOddsItem(
                  theme, '2 (Away)', OddsCalculator.format(awayOdds)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Accurate fair odds calculated based on expert win probabilities.',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOddsItem(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(label,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            )),
        const SizedBox(height: 8),
        Text(value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            )),
      ],
    );
  }

  // ========== MICRO ANALYTICS: HEAD-TO-HEAD ==========

  Widget _buildHeadToHeadStats(ThemeData theme) {
    final stats = widget.prediction.matchStats;
    final res = widget.prediction.matchResult;

    // Build comparison items from available data
    final items = <_ComparisonItem>[];

    // xG comparison
    if (stats != null) {
      final homeXG = double.tryParse(stats.homeTeamExpectedGoals ?? '');
      final awayXG = double.tryParse(stats.awayTeamExpectedGoals ?? '');
      if (homeXG != null && awayXG != null) {
        items.add(_ComparisonItem('Expected Goals (xG)', homeXG, awayXG));
      }
    }

    // Win probability comparison
    if (res != null) {
      final hp = double.tryParse(res.homeTeamProb?.replaceAll('%', '') ?? '');
      final ap = double.tryParse(res.awayTeamProb?.replaceAll('%', '') ?? '');
      if (hp != null && ap != null) {
        items.add(_ComparisonItem('Win Probability', hp, ap));
      }
    }

    // Form score (count W's from form string)
    if (stats != null) {
      final homeForm = stats.homeTeamForm ?? '';
      final awayForm = stats.awayTeamForm ?? '';
      if (homeForm.isNotEmpty && awayForm.isNotEmpty) {
        final homeWins =
            homeForm.split('').where((c) => c == 'W').length.toDouble();
        final awayWins =
            awayForm.split('').where((c) => c == 'W').length.toDouble();
        items.add(_ComparisonItem('Recent Wins (last 5)', homeWins, awayWins));
      }
    }

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            'No head-to-head data available for this match.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Team name header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.prediction.homeTeam,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                widget.prediction.awayTeam,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) => _buildComparisonBar(theme, item)),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(ThemeData theme, _ComparisonItem item) {
    final total = item.home + item.away;
    final homeFrac = total > 0 ? item.home / total : 0.5;
    final awayFrac = total > 0 ? item.away / total : 0.5;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.home % 1 == 0
                    ? item.home.toInt().toString()
                    : item.home.toStringAsFixed(2),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              Text(
                item.label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                item.away % 1 == 0
                    ? item.away.toInt().toString()
                    : item.away.toStringAsFixed(2),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: (homeFrac * 100).toInt().clamp(1, 99),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  flex: (awayFrac * 100).toInt().clamp(1, 99),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== MICRO ANALYTICS: GOAL PROBABILITY ==========

  Widget _buildGoalProbabilityGrid(ThemeData theme) {
    final goalProbs = widget.prediction.matchResult?.goalProbabilities;
    if (goalProbs == null || goalProbs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Center(
          child: Text(
            'No goal probability data available.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    // Sort by probability descending
    final sorted = goalProbs.entries.toList()
      ..sort((a, b) {
        final av = double.tryParse(a.value.replaceAll('%', '')) ?? 0;
        final bv = double.tryParse(b.value.replaceAll('%', '')) ?? 0;
        return bv.compareTo(av);
      });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most likely scorelines based on statistical analysis:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sorted.take(6).map((entry) {
              final prob =
                  double.tryParse(entry.value.replaceAll('%', '')) ?? 0;
              final isHighest = entry == sorted.first;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isHighest
                      ? theme.colorScheme.primary.withValues(alpha: 0.15)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isHighest
                        ? theme.colorScheme.primary.withValues(alpha: 0.3)
                        : theme.colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: isHighest ? theme.colorScheme.primary : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${prob.toStringAsFixed(1)}%',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Simple data holder for comparison bars
class _ComparisonItem {
  final String label;
  final double home;
  final double away;
  _ComparisonItem(this.label, this.home, this.away);
}
