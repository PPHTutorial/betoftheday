import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/predictions_provider.dart';
import '../../widgets/match_card.dart';

class LiveMatchesScreen extends StatefulWidget {
  const LiveMatchesScreen({super.key});

  @override
  State<LiveMatchesScreen> createState() => _LiveMatchesScreenState();
}

class _LiveMatchesScreenState extends State<LiveMatchesScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLive();
      _startAutoRefresh();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (mounted) {
        _refreshLive();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshLive() async {
    // Live matches are fetched as part of today's matches
    await Provider.of<PredictionsProvider>(context, listen: false)
        .loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Live Now'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshLive,
          ),
        ],
      ),
      body: Consumer<PredictionsProvider>(
        builder: (context, provider, child) {
          final liveMatches = provider.liveMatches;

          if (provider.isLoading && liveMatches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (liveMatches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sensors_off,
                      size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  const Text('No live matches at the moment'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _refreshLive,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshLive,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: liveMatches.length,
              itemBuilder: (context, index) {
                final match = liveMatches[index];
                return MatchCard(
                  prediction: match,
                  showDate: false,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
