import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';
import 'match_card.dart';
import '../screens/home/prediction_detail_screen.dart';

/// Dialog for showing extended feature details
class FeatureDetailDialog extends StatelessWidget {
  final String title;
  final List<PredictionModel> predictions;
  final String? description;

  const FeatureDetailDialog({
    super.key,
    required this.title,
    required this.predictions,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.radius(20)),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: Responsive.height(600),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: Responsive.padding(all: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(AppConfig.primary500),
                    Color(AppConfig.primary600),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Responsive.radius(20)),
                  topRight: Radius.circular(Responsive.radius(20)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Responsive.fontSize(18),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: Responsive.fontSize(24),
                    ),
                  ),
                ],
              ),
            ),

            // Description
            if (description != null) ...[
              Padding(
                padding: Responsive.padding(all: 16),
                child: Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],

            // Predictions List
            Expanded(
              child: predictions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: Responsive.padding(all: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sports_soccer_outlined,
                              size: Responsive.fontSize(48),
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            SizedBox(height: Responsive.spacing(16)),
                            Text(
                              'No predictions available',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: Responsive.padding(horizontal: 16, vertical: 8),
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        return MatchCard(
                          prediction: predictions[index],
                          showDate: true,
                          onTap: () {
                            Navigator.of(context).pop(); // Close dialog first
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PredictionDetailScreen(
                                  prediction: predictions[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Footer
            Container(
              padding: Responsive.padding(all: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(Responsive.radius(20)),
                  bottomRight: Radius.circular(Responsive.radius(20)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ${predictions.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String title,
    required List<PredictionModel> predictions,
    String? description,
  }) {
    showDialog(
      context: context,
      builder: (context) => FeatureDetailDialog(
        title: title,
        predictions: predictions,
        description: description,
      ),
    );
  }
}
