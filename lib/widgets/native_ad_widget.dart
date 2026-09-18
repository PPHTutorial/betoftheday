import 'package:flutter/material.dart';

/// Disabled NativeAdWidget — native ads have been removed.
class NativeAdWidget extends StatelessWidget {
  final double? height;
  final EdgeInsets? margin;

  const NativeAdWidget({
    super.key,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
