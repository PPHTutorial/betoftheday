import 'package:flutter/material.dart';
import '../../models/prediction_model.dart';
import '../../widgets/match_card.dart';
import '../../utils/responsive.dart';

class MatchListScreen extends StatelessWidget {
  final String title;
  final List<MatchPrediction> matches;

  const MatchListScreen({
    super.key,
    required this.title,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: Responsive.fontSize(16),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: matches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer_rounded,
                      size: 60,
                      color:
                          theme.colorScheme.onSurface.withValues(alpha: 0.2)),
                  SizedBox(height: Responsive.spacing(16)),
                  Text(
                    'No matches found for this segment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(vertical: Responsive.spacing(16)),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return MatchCard(
                  prediction: matches[index],
                  showDate: true,
                );
              },
            ),
    );
  }
}
