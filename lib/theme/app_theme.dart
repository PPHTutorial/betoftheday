import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import '../utils/responsive.dart';

class AppTheme {
  // Primary Colors (Orange from Next.js app)
  static const Color primary = Color(AppConfig.primary600);
  static const Color primaryLight = Color(AppConfig.primary400);
  static const Color primaryDark = Color(AppConfig.primary700);

  // Status Colors
  static const Color success = Color(AppConfig.success500);
  static const Color error = Color(AppConfig.error500);
  static const Color warning = Color(AppConfig.warning500);

  /// Get responsive text style
  static TextStyle _textStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData lightTheme(BuildContext context) {
    // Safely get MediaQuery, with fallback values
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? 390.0;
    final textScaleFactor =
        (mediaQuery?.textScaleFactor ?? 1.0).clamp(0.8, 1.3);
    final scaleFactor = (screenWidth / 390.0).clamp(0.8, 1.2);

    // Initialize Responsive if context is available
    try {
      Responsive.init(context);
    } catch (e) {
      // Context might not have MediaQuery yet, that's okay
    }

    // Light theme colors
    const backgroundLight = Color(0xFFFFFFFF);
    const surfaceLight = Color(AppConfig.neutral50);
    const textLight = Color(AppConfig.neutral900);
    const textSecondaryLight = Color(AppConfig.neutral600);

    // Create Material 3 ColorScheme
    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary,
      onSecondary: Colors.white,
      tertiary: Color(AppConfig.primary300),
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: textLight,
      onSurfaceVariant: textSecondaryLight,
      background: backgroundLight,
      onBackground: textLight,
      surfaceContainerHighest: Color(AppConfig.neutral200),
      primaryContainer: Color(AppConfig.primary50),
      onPrimaryContainer: primary,
      secondaryContainer: Color(AppConfig.primary100),
      onSecondaryContainer: primary,
      errorContainer: Color(AppConfig.error100),
      onErrorContainer: Color(AppConfig.error800),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withOpacity(0.12),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: _textStyle(
          fontSize: 18 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(8 * scaleFactor),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scaleFactor),
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scaleFactor,
            vertical: 8 * scaleFactor,
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scaleFactor),
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 12 * scaleFactor,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: _textStyle(
          fontSize: 32 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: _textStyle(
          fontSize: 28 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: _textStyle(
          fontSize: 24 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineLarge: _textStyle(
          fontSize: 22 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: _textStyle(
          fontSize: 20 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineSmall: _textStyle(
          fontSize: 18 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: _textStyle(
          fontSize: 16 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleSmall: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: _textStyle(
          fontSize: 16 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodySmall: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        labelLarge: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: _textStyle(
          fontSize: 10 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.12),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24 * scaleFactor,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scaleFactor),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    // Safely get MediaQuery, with fallback values
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? 390.0;
    final textScaleFactor =
        (mediaQuery?.textScaleFactor ?? 1.0).clamp(0.8, 1.3);
    final scaleFactor = (screenWidth / 390.0).clamp(0.8, 1.2);

    // Initialize Responsive if context is available
    try {
      Responsive.init(context);
    } catch (e) {
      // Context might not have MediaQuery yet, that's okay
    }

    // Dark theme colors
    const backgroundDark = Color(AppConfig.neutral900);
    const surfaceDark = Color(AppConfig.neutral800);
    const textDark = Color(0xFFFFFFFF);
    const textSecondaryDark = Color(AppConfig.neutral400);

    // Create Material 3 ColorScheme
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary,
      onSecondary: Colors.white,
      tertiary: Color(AppConfig.primary700),
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surfaceDark,
      onSurface: textDark,
      onSurfaceVariant: textSecondaryDark,
      background: backgroundDark,
      onBackground: textDark,
      surfaceContainerHighest: Color(AppConfig.neutral700),
      primaryContainer: Color(AppConfig.primary900),
      onPrimaryContainer: Color(AppConfig.primary200),
      secondaryContainer: Color(AppConfig.primary800),
      onSecondaryContainer: Color(AppConfig.primary200),
      errorContainer: Color(AppConfig.error800),
      onErrorContainer: Color(AppConfig.error200),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      cardColor: colorScheme.surface,
      dividerColor: colorScheme.onSurface.withOpacity(0.12),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: _textStyle(
          fontSize: 18 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),

      // Card
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12 * scaleFactor),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: EdgeInsets.all(8 * scaleFactor),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scaleFactor),
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.onPrimary,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scaleFactor,
            vertical: 8 * scaleFactor,
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: 24 * scaleFactor,
            vertical: 12 * scaleFactor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * scaleFactor),
          ),
          textStyle: _textStyle(
            fontSize: 16 * scaleFactor * textScaleFactor,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 12 * scaleFactor,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: _textStyle(
          fontSize: 32 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: _textStyle(
          fontSize: 28 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: _textStyle(
          fontSize: 24 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineLarge: _textStyle(
          fontSize: 22 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: _textStyle(
          fontSize: 20 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineSmall: _textStyle(
          fontSize: 18 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: _textStyle(
          fontSize: 16 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleSmall: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: _textStyle(
          fontSize: 16 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodySmall: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        labelLarge: _textStyle(
          fontSize: 14 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: _textStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: _textStyle(
          fontSize: 10 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withOpacity(0.12),
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: colorScheme.onSurface,
        size: 24 * scaleFactor,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        labelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scaleFactor),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor * textScaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        tileColor: colorScheme.surface,
        textColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
      ),
    );
  }
}
