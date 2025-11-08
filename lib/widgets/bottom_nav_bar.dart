import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Modern Bottom Navigation Bar matching the design
class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor ??
            theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: Responsive.height(70),
          padding: EdgeInsets.symmetric(horizontal: Responsive.spacing(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'HOME',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.bolt_outlined,
                selectedIcon: Icons.bolt,
                label: 'LIVE',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                selectedIcon: Icons.calendar_today,
                label: 'SPORT',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'MY BETS',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'PROFILE',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.spacing(12),
          vertical: Responsive.spacing(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.bottomNavigationBarTheme.unselectedItemColor ??
                      theme.colorScheme.onSurface.withOpacity(0.6),
              size: Responsive.fontSize(24),
            ),
            SizedBox(height: Responsive.spacing(4)),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.bottomNavigationBarTheme.unselectedItemColor ??
                        theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: Responsive.fontSize(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
