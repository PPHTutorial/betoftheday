import 'package:flutter/material.dart';

class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static double safeBlockHorizontal = 0;
  static double safeBlockVertical = 0;

  // Design guide dimensions (e.g., iPhone 13)
  static const double _designWidth = 390;
  static const double _designHeight = 844;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  /// Get scaled height based on screen height
  static double height(double inputHeight) {
    // Calculate ratio from design height
    double ratio = inputHeight / _designHeight;
    return screenHeight * ratio;
  }

  /// Get scaled width based on screen width
  static double width(double inputWidth) {
    // Calculate ratio from design width
    double ratio = inputWidth / _designWidth;
    return screenWidth * ratio;
  }

  /// Get scaled font size (can use width or height, usually width)
  static double fontSize(double inputSize) {
    double ratio = inputSize / _designWidth;
    return screenWidth * ratio;
  }

  /// Get scaled spacing (alias for width)
  static double spacing(double inputSpacing) {
    return width(inputSpacing);
  }

  /// Get scaled radius
  static double radius(double inputRadius) {
    return width(inputRadius); // Usually scaling radius by width is safe
  }

  /// Get scaled padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(width(all));
    }
    return EdgeInsets.only(
      left: width(left ?? horizontal ?? 0),
      right: width(right ?? horizontal ?? 0),
      top: height(top ?? vertical ?? 0),
      bottom: height(bottom ?? vertical ?? 0),
    );
  }
}
