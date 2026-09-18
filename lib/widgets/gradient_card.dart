import 'package:flutter/material.dart';
import '../utils/responsive.dart';

/// Modern gradient card widget matching the betting app design
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;

  const GradientCard({
    super.key,
    required this.child,
    this.colors,
    this.borderRadius,
    this.padding,
    this.margin,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hsl = HSLColor.fromColor(primary);
    final darkAccent = hsl
        .withLightness((hsl.lightness * 0.4).clamp(0.12, 0.32))
        .toColor();

    final defaultColors = colors ?? [primary, darkAccent];

    return Container(
      height: height,
      width: width,
      margin: margin ?? Responsive.padding(all: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: defaultColors,
        ),
        borderRadius:
            borderRadius ?? BorderRadius.circular(Responsive.radius(16)),
        boxShadow: [
          BoxShadow(
            color: defaultColors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius:
            borderRadius ?? BorderRadius.circular(Responsive.radius(16)),
        child: Padding(
          padding: padding ?? Responsive.padding(all: 16),
          child: child,
        ),
      ),
    );
  }
}
