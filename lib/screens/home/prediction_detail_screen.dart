import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/prediction_model.dart';

class PredictionDetailScreen extends StatelessWidget {
  final PredictionModel prediction;

  const PredictionDetailScreen({
    super.key,
    required this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.league,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prediction.matchDisplay,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('MMMM dd, yyyy • hh:mm a').format(
                        prediction.publishedAt,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Prediction Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      prediction.tip,
                      style: theme.textTheme.bodyLarge,
                    ),
                    if (prediction.odds != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: theme.colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Odds: ${prediction.odds}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Analysis Card
            if (prediction.analysis != null && prediction.analysis!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        prediction.analysis!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Result Status
            const SizedBox(height: 16),
            Card(
              color: _getResultColor(prediction.result).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _getResultIcon(prediction.result),
                      color: _getResultColor(prediction.result),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Status: ${prediction.result.value}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(prediction.result),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultColor(PredictionResult result) {
    switch (result) {
      case PredictionResult.won:
        return Colors.green;
      case PredictionResult.lost:
        return Colors.red;
      case PredictionResult.pending:
        return Colors.orange;
    }
  }

  IconData _getResultIcon(PredictionResult result) {
    switch (result) {
      case PredictionResult.won:
        return Icons.check_circle;
      case PredictionResult.lost:
        return Icons.cancel;
      case PredictionResult.pending:
        return Icons.schedule;
    }
  }
}

