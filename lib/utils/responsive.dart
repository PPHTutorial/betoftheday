import 'package:flutter/material.dart';

/// Responsive utility class for handling screen sizes and text scaling
class Responsive {
  static double _screenWidth = 0;
  static double _screenHeight = 0;
  static double _textScaleFactor = 1.0;
  static bool _initialized = false;

  // Base values for design (using iPhone 12 Pro as base)
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  /// Initialize responsive values
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _textScaleFactor = mediaQuery.textScaleFactor.clamp(0.8, 1.3);
    _initialized = true;
  }

  /// Get responsive width based on screen width
  static double width(double width) {
    if (!_initialized) return width;
    return (_screenWidth / _baseWidth) * width;
  }

  /// Get responsive height based on screen height
  static double height(double height) {
    if (!_initialized) return height;
    return (_screenHeight / _baseHeight) * height;
  }

  /// Get responsive font size with text scale factor consideration
  static double fontSize(double size) {
    if (!_initialized) return size;
    final scaleFactor = (_screenWidth / _baseWidth).clamp(0.8, 1.2);
    return size * scaleFactor * _textScaleFactor;
  }

  /// Get responsive spacing
  static double spacing(double spacing) {
    if (!_initialized) return spacing;
    return (_screenWidth / _baseWidth) * spacing;
  }

  /// Get responsive radius
  static double radius(double radius) {
    if (!_initialized) return radius;
    return (_screenWidth / _baseWidth) * radius;
  }

  /// Check if device is tablet
  static bool isTablet() {
    if (!_initialized) return false;
    return _screenWidth >= 600;
  }

  /// Check if device is mobile
  static bool isMobile() {
    if (!_initialized) return true;
    return _screenWidth < 600;
  }

  /// Get screen width
  static double get screenWidth => _screenWidth;

  /// Get screen height
  static double get screenHeight => _screenHeight;

  /// Get text scale factor
  static double get textScaleFactor => _textScaleFactor;

  /// Get responsive padding
  static EdgeInsets padding({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    if (all != null) {
      final value = spacing(all);
      return EdgeInsets.all(value);
    }
    return EdgeInsets.only(
      top: top != null ? spacing(top) : (vertical ?? 0),
      bottom: bottom != null ? spacing(bottom) : (vertical ?? 0),
      left: left != null ? spacing(left) : (horizontal ?? 0),
      right: right != null ? spacing(right) : (horizontal ?? 0),
    );
  }

  /// Get responsive margin
  static EdgeInsets margin({
    double? all,
    double? horizontal,
    double? vertical,
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return padding(
      all: all,
      horizontal: horizontal,
      vertical: vertical,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
    );
  }
}

/// Extension on BuildContext for easy access to responsive utilities
extension ResponsiveExtension on BuildContext {
  /// Get responsive width
  double rw(double width) => Responsive.width(width);

  /// Get responsive height
  double rh(double height) => Responsive.height(height);

  /// Get responsive font size
  double rfs(double size) => Responsive.fontSize(size);

  /// Get responsive spacing
  double rs(double spacing) => Responsive.spacing(spacing);

  /// Get responsive radius
  double rr(double radius) => Responsive.radius(radius);

  /// Check if tablet
  bool get isTablet => Responsive.isTablet();

  /// Check if mobile
  bool get isMobile => Responsive.isMobile();
}
