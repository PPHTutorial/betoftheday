import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../models/prediction_model.dart';
import '../../utils/responsive.dart';

class PredictionDetailScreen extends StatefulWidget {
  final MatchPrediction prediction;

  const PredictionDetailScreen({super.key, required this.prediction});

  @override
  State<PredictionDetailScreen> createState() => _PredictionDetailScreenState();
}

class _PredictionDetailScreenState extends State<PredictionDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _showWebView = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.prediction.matchUrl));

    // Auto-show webview if stats are missing
    if (widget.prediction.matchStats == null) {
      _showWebView = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final stats = widget.prediction.matchStats;
    final result = widget.prediction.matchResult;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.prediction.matchDisplay),
        actions: [
          IconButton(
            icon: Icon(_showWebView ? Icons.analytics : Icons.web),
            onPressed: () => setState(() => _showWebView = !_showWebView),
            tooltip: _showWebView ? 'View Stats' : 'View Website',
          ),
        ],
      ),
      body: _showWebView
          ? Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading) Center(child: CircularProgressIndicator()),
              ],
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(Responsive.spacing(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(theme),
                  SizedBox(height: Responsive.spacing(24)),
                  if (result != null) _buildProbabilities(theme, result),
                  if (stats != null) ...[
                    SizedBox(height: Responsive.spacing(24)),
                    _buildMatchInfo(theme, stats),
                    SizedBox(height: Responsive.spacing(24)),
                    _buildTeamStats(theme, stats),
                  ],
                  SizedBox(height: Responsive.spacing(40)),
                  _buildWebViewButton(theme),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(Responsive.spacing(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTeamHeader(
                widget.prediction.homeTeam, widget.prediction.homeLogo, theme),
            Column(
              children: [
                if (widget.prediction.score != null)
                  Text(
                    widget.prediction.score!,
                    style: theme.textTheme.headlineLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    widget.prediction.matchTime,
                    style: theme.textTheme.headlineSmall,
                  ),
                if (widget.prediction.isLive)
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4)),
                    child: Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            _buildTeamHeader(
                widget.prediction.awayTeam, widget.prediction.awayLogo, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamHeader(String name, String? logo, ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          child:
              logo != null ? Image.network(logo) : Icon(Icons.shield, size: 40),
        ),
        SizedBox(height: 8),
        Container(
          width: 80,
          child: Text(name,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 2),
        ),
      ],
    );
  }

  Widget _buildProbabilities(ThemeData theme, MatchResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Win Probabilities',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          children: [
            _probBar('Home', result.homeTeamProb, theme.colorScheme.primary),
            _probBar('Draw', result.drawProb, Colors.grey),
            _probBar('Away', result.awayTeamProb, theme.colorScheme.secondary),
          ],
        ),
      ],
    );
  }

  Widget _probBar(String label, String? prob, Color color) {
    final val = double.tryParse(prob?.replaceAll('%', '') ?? '0') ?? 0;
    return Expanded(
      flex: val.toInt().clamp(1, 100),
      child: Container(
        height: 40,
        color: color,
        child: Center(
            child: Text(prob ?? '',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))),
      ),
    );
  }

  Widget _buildMatchInfo(ThemeData theme, MatchStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Match Information',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        _infoRow('Competition', stats.competition),
        _infoRow('Round', stats.round),
        _infoRow('Stadium', stats.stadium ?? 'N/A'),
        _infoRow('Date', stats.matchDate),
        _infoRow('Referee', stats.referee ?? 'N/A'),
      ],
    );
  }

  Widget _buildTeamStats(ThemeData theme, MatchStats stats) {
    return Row(
      children: [
        Expanded(
            child: _teamStatCard('Home Strategy', stats.homeTeamForm,
                stats.homeTeamExpectedGoals, theme)),
        SizedBox(width: 16),
        Expanded(
            child: _teamStatCard('Away Strategy', stats.awayTeamForm,
                stats.awayTeamExpectedGoals, theme)),
      ],
    );
  }

  Widget _teamStatCard(
      String title, String? form, String? xg, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: theme.textTheme.labelMedium),
            SizedBox(height: 8),
            if (form != null)
              Text('Form: $form',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
            if (xg != null) ...[
              SizedBox(height: 8),
              Text('Expected Goals', style: theme.textTheme.bodySmall),
              Text(xg,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: theme.colorScheme.primary)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildWebViewButton(ThemeData theme) {
    return OutlinedButton.icon(
      onPressed: () => setState(() => _showWebView = true),
      icon: Icon(Icons.open_in_browser),
      label: Text('View Full Analysis on Predicd.com'),
      style: OutlinedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
    );
  }
}
