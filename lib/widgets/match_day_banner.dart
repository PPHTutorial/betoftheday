import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/responsive.dart';
import '../utils/logo_loader.dart';

/// Match Day Hero Banner matching the modern design
class MatchDayBanner extends StatelessWidget {
  final String? homeTeam;
  final String? awayTeam;
  final String? homeTeamLogo;
  final String? awayTeamLogo;
  final String? matchDate;
  final String? matchTime;
  final String? backgroundImageUrl;
  final VoidCallback? onTap;

  const MatchDayBanner({
    super.key,
    this.homeTeam,
    this.awayTeam,
    this.homeTeamLogo,
    this.awayTeamLogo,
    this.matchDate,
    this.matchTime,
    this.backgroundImageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.spacing(16),
        vertical: Responsive.spacing(12),
      ),
      height: Responsive.height(200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.radius(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.radius(20)),
        child: Stack(
          children: [
            // Background Image
            if (backgroundImageUrl != null)
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: backgroundImageUrl!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1E40AF), // Dark blue
                          const Color(0xFF7C3AED), // Purple
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1E40AF),
                      const Color(0xFF7C3AED),
                    ],
                  ),
                ),
              ),

            // Dark overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(Responsive.spacing(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(12),
                          vertical: Responsive.spacing(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(Responsive.radius(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: Responsive.fontSize(14),
                              color: Colors.white,
                            ),
                            SizedBox(width: Responsive.spacing(6)),
                            Text(
                              matchDate ?? 'Today',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.spacing(12),
                          vertical: Responsive.spacing(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(Responsive.radius(8)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: Responsive.fontSize(14),
                              color: Colors.white,
                            ),
                            SizedBox(width: Responsive.spacing(6)),
                            Text(
                              matchTime ?? '18:00',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: Responsive.fontSize(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // MATCH DAY Title
                  Text(
                    'MATCH DAY',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: Responsive.fontSize(32),
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: Responsive.spacing(20)),

                  // Teams
                  if (homeTeam != null && awayTeam != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Home Team
                        Column(
                          children: [
                            Container(
                              width: Responsive.width(60),
                              height: Responsive.width(60),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: homeTeam != null
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(Responsive.spacing(8)),
                                      child: ClipOval(
                                        child: LogoLoader.teamLogo(
                                          homeTeam!,
                                          size: Responsive.width(60),
                                          placeholderColor: Colors.black,
                                        ),
                                      ),
                                    )
                                  : (homeTeamLogo != null
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                              Responsive.spacing(8)),
                                          child: CachedNetworkImage(
                                            imageUrl: homeTeamLogo!,
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.sports_soccer,
                                              size: Responsive.fontSize(24),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.sports_soccer,
                                          size: Responsive.fontSize(24),
                                          color: Colors.black,
                                        )),
                            ),
                            SizedBox(height: Responsive.spacing(8)),
                            Text(
                              homeTeam!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(14),
                              ),
                            ),
                          ],
                        ),

                        // VS
                        Text(
                          'VS',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: Responsive.fontSize(16),
                          ),
                        ),

                        // Away Team
                        Column(
                          children: [
                            Container(
                              width: Responsive.width(60),
                              height: Responsive.width(60),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: awayTeam != null
                                  ? Padding(
                                      padding:
                                          EdgeInsets.all(Responsive.spacing(8)),
                                      child: ClipOval(
                                        child: LogoLoader.teamLogo(
                                          awayTeam!,
                                          size: Responsive.width(60),
                                          placeholderColor: Colors.black,
                                        ),
                                      ),
                                    )
                                  : (awayTeamLogo != null
                                      ? Padding(
                                          padding: EdgeInsets.all(
                                              Responsive.spacing(8)),
                                          child: CachedNetworkImage(
                                            imageUrl: awayTeamLogo!,
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.sports_soccer,
                                              size: Responsive.fontSize(24),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.sports_soccer,
                                          size: Responsive.fontSize(24),
                                          color: Colors.black,
                                        )),
                            ),
                            SizedBox(height: Responsive.spacing(8)),
                            Text(
                              awayTeam!,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.fontSize(14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
