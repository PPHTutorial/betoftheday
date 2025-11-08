import 'package:flutter/material.dart';
import '../../../models/prediction_model.dart';
import '../prediction_detail_screen.dart';

class VipPredictionsSection extends StatelessWidget {
  final String title;
  final List<PredictionModel> predictions;

  const VipPredictionsSection({
    super.key,
    required this.title,
    required this.predictions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.secondary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: predictions.length > 10 ? 10 : predictions.length,
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _VipPredictionCard(prediction: prediction),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VipPredictionCard extends StatelessWidget {
  final PredictionModel prediction;

  const _VipPredictionCard({required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
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
              Text(
                prediction.matchDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Prediction: ${prediction.tip}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (prediction.odds != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Odds: ${prediction.odds}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
