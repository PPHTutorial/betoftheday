import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/prediction_model.dart';
import '../prediction_detail_screen.dart';

class PredictionSection extends StatelessWidget {
  final String title;
  final List<PredictionModel> predictions;

  const PredictionSection({
    super.key,
    required this.title,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: predictions.length > 10 ? 10 : predictions.length,
          itemBuilder: (context, index) {
            final prediction = predictions[index];
            return _PredictionCard(prediction: prediction);
          },
        ),
      ],
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final PredictionModel prediction;

  const _PredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PredictionDetailScreen(prediction: prediction),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // League and Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      prediction.league,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(prediction.publishedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Match
              Text(
                prediction.matchDisplay,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Prediction and Odds Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prediction',
                          style: theme.textTheme.labelSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prediction.tip,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (prediction.odds != null) ...[
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        prediction.odds!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Result Badge
              Row(
                children: [
                  _ResultBadge(result: prediction.result),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final PredictionResult result;

  const _ResultBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color color;
    IconData icon;
    String label;

    switch (result) {
      case PredictionResult.won:
        color = Colors.green;
        icon = Icons.check_circle;
        label = 'WON';
        break;
      case PredictionResult.lost:
        color = Colors.red;
        icon = Icons.cancel;
        label = 'LOST';
        break;
      case PredictionResult.pending:
        color = Colors.orange;
        icon = Icons.schedule;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
