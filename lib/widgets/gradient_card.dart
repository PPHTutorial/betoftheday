import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../config/app_config.dart';

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
    final defaultColors = colors ??
        [
          const Color(AppConfig.primary500), // Orange 500
          const Color(AppConfig.primary600), // Orange 600
        ];

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
            color: defaultColors.first.withOpacity(0.3),
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
