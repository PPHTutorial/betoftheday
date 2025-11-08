import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../utils/logo_loader.dart';
import '../config/app_config.dart';

/// League Selector Widget (horizontal scrollable icons)
class LeagueSelector extends StatelessWidget {
  final String selectedLeague;
  final List<String> leagues;
  final Function(String) onLeagueSelected;

  const LeagueSelector({
    super.key,
    required this.selectedLeague,
    required this.leagues,
    required this.onLeagueSelected,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return SizedBox(
      height: Responsive.height(80),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(16)),
        itemCount: leagues.length,
        itemBuilder: (context, index) {
          final league = leagues[index];
          final isSelected = league == selectedLeague;

          return GestureDetector(
            onTap: () => onLeagueSelected(league),
            child: Container(
              width: Responsive.width(70),
              margin: EdgeInsets.only(right: Responsive.spacing(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Responsive.width(60),
                    height: Responsive.width(60),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(AppConfig.primary600)
                          : Color(AppConfig.neutral200),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Color(AppConfig.primary600),
                              width: 3,
                            )
                          : null,
                    ),
                    child: ClipOval(
                      child: LogoLoader.leagueLogo(
                        league,
                        size: Responsive.width(60),
                        placeholderColor: isSelected
                            ? Colors.white
                            : Color(AppConfig.neutral600),
                      ),
                    ),
                  ),
                  SizedBox(height: Responsive.spacing(4)),
                  Text(
                    league,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? Color(AppConfig.primary600)
                          : Color(AppConfig.neutral600),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: Responsive.fontSize(10),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
