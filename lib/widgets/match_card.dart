import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/prediction_model.dart';
import '../utils/responsive.dart';
import '../utils/logo_loader.dart';
import '../config/app_config.dart';

/// Modern Match Card widget matching the betting app design
class MatchCard extends StatelessWidget {
  final PredictionModel prediction;
  final VoidCallback? onTap;
  final bool showDate;

  const MatchCard({
    super.key,
    required this.prediction,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(16),
        vertical: Responsive.spacing(8),
      ),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(Responsive.radius(16)),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.radius(16)),
          child: Padding(
            padding: EdgeInsets.all(Responsive.spacing(16)),
            child: Column(
              children: [
                // Teams Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home Team
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: Responsive.width(50),
                            height: Responsive.width(50),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: LogoLoader.teamLogo(
                                prediction.homeTeam,
                                size: Responsive.width(50),
                                placeholderColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(8)),
                          Text(
                            prediction.homeTeam,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.fontSize(14),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Date/Time
                    if (showDate)
                      Column(
                        children: [
                          Text(
                            DateFormat('d MMM').format(prediction.publishedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: Responsive.fontSize(12),
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(4)),
                          Text(
                            DateFormat('HH:mm').format(prediction.publishedAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: Responsive.fontSize(12),
                            ),
                          ),
                        ],
                      ),

                    // Away Team
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: Responsive.width(50),
                            height: Responsive.width(50),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: LogoLoader.teamLogo(
                                prediction.awayTeam,
                                size: Responsive.width(50),
                                placeholderColor: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(8)),
                          Text(
                            prediction.awayTeam,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.fontSize(14),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.spacing(16)),

                // League Name with Logo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: Responsive.width(20),
                      height: Responsive.width(20),
                      child: LogoLoader.leagueLogo(
                        prediction.league,
                        size: Responsive.width(20),
                        placeholderColor: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: Responsive.spacing(8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.spacing(12),
                        vertical: Responsive.spacing(6),
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius:
                            BorderRadius.circular(Responsive.radius(8)),
                      ),
                      child: Text(
                        prediction.league,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: Responsive.fontSize(12),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Responsive.spacing(16)),

                // Prediction and Odds
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prediction
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Prediction',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                              fontSize: Responsive.fontSize(11),
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(4)),
                          Text(
                            prediction.tip,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: Responsive.fontSize(14),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Odds
                    if (prediction.odds != null) ...[
                      SizedBox(width: Responsive.spacing(12)),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(16),
                          vertical: Responsive.spacing(8),
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius:
                              BorderRadius.circular(Responsive.radius(8)),
                        ),
                        child: Text(
                          prediction.odds!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(14),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: Responsive.spacing(12)),

                // Result Badge
                _ResultBadge(result: prediction.result),
              ],
            ),
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
    Responsive.init(context);
    final theme = Theme.of(context);

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    final isDark = theme.brightness == Brightness.dark;
    switch (result) {
      case PredictionResult.won:
        backgroundColor = isDark
            ? Color(AppConfig.success800).withOpacity(0.3)
            : Color(AppConfig.success100);
        textColor =
            isDark ? Color(AppConfig.success200) : Color(AppConfig.success800);
        icon = Icons.check_circle;
        label = 'WON';
        break;
      case PredictionResult.lost:
        backgroundColor = isDark
            ? Color(AppConfig.error800).withOpacity(0.3)
            : Color(AppConfig.error100);
        textColor =
            isDark ? Color(AppConfig.error200) : Color(AppConfig.error800);
        icon = Icons.cancel;
        label = 'LOST';
        break;
      case PredictionResult.pending:
        backgroundColor = isDark
            ? Color(AppConfig.warning800).withOpacity(0.3)
            : Color(AppConfig.warning100);
        textColor =
            isDark ? Color(AppConfig.warning200) : Color(AppConfig.warning800);
        icon = Icons.schedule;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(12),
        vertical: Responsive.spacing(6),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(Responsive.radius(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Responsive.fontSize(16), color: textColor),
          SizedBox(width: Responsive.spacing(6)),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: Responsive.fontSize(12),
            ),
          ),
        ],
      ),
    );
  }
}
