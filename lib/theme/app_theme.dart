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

  static ThemeData lightTheme(BuildContext context, {Color? accentColor}) {
    // Safely get MediaQuery, with fallback values
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? 390.0;

    final scaleFactor = (screenWidth / 390.0).clamp(0.8, 1.2);

    // Initialize Responsive if context is available
    try {
      Responsive.init(context);
    } catch (e) {
      // Context might not have MediaQuery yet, that's okay
    }

    final actualPrimary = accentColor ?? primary;

    // Light theme colors
    const surfaceLight = Color(0xFFF8FAFC); // Clean crisp slate-50
    const cardLight = Color(0xFFFFFFFF);
    const textLight = Color(0xFF090D1A); // Deep contrast slate-950
    const textSecondaryLight =
        Color(0xFF475569); // Slate 600 (better contrast)

    // Create Material 3 ColorScheme for Light
    final colorScheme = ColorScheme.light(
      primary: actualPrimary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF4F46E5), // Indigo 600 (better contrast)
      onSecondary: Colors.white,
      tertiary: const Color(0xFF059669), // Emerald 600
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: textLight,
      onSurfaceVariant: textSecondaryLight,
      surfaceContainerHighest:
          const Color(0xFFF1F5F9), // Slate 100
      primaryContainer: actualPrimary.withValues(alpha: 0.1),
      onPrimaryContainer: actualPrimary,
      secondaryContainer: const Color(0xFFEEF2FF), // Indigo 50
      onSecondaryContainer: const Color(0xFF4F46E5), // Indigo 600
      outline: const Color(0xFFCBD5E1), // Slate 300 (better contrast)
      outlineVariant: const Color(0xFFE2E8F0), // Slate 200
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: cardLight,
      dividerColor: colorScheme.outline.withValues(alpha: 0.2),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: _textStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w900, // Thicker for premium feel
          color: textLight,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textLight, size: 24),
      ),

      // Card - Clean, premium, borderless design
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20 * scaleFactor),
          side: BorderSide.none, // Strip card borders per design polish
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
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
            fontSize: 16 * scaleFactor,
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
            fontSize: 16 * scaleFactor,
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
            fontSize: 16 * scaleFactor,
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
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
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
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14 * scaleFactor,
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
          fontSize: 32 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: _textStyle(
          fontSize: 28 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: _textStyle(
          fontSize: 24 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineLarge: _textStyle(
          fontSize: 22 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: _textStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineSmall: _textStyle(
          fontSize: 18 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: _textStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleSmall: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: _textStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodySmall: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        labelLarge: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: _textStyle(
          fontSize: 10 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
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
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor,
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
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedLabelStyle: _textStyle(
          fontSize: 11 * scaleFactor,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: _textStyle(
          fontSize: 11 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
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

  static ThemeData darkTheme(BuildContext context, {Color? accentColor}) {
    // Safely get MediaQuery, with fallback values
    final mediaQuery = MediaQuery.maybeOf(context);
    final screenWidth = mediaQuery?.size.width ?? 390.0;

    final scaleFactor = (screenWidth / 390.0).clamp(0.8, 1.2);

    // Initialize Responsive
    try {
      Responsive.init(context);
    } catch (e) {
      // Context might not have MediaQuery yet, that's okay
    }

    final actualPrimary = accentColor ?? primary;

    // Dark theme colors (Pitch obsidian slate with rich contrast)
    const surfaceDark = Color(0xFF090D16); // Deep obsidian canvas
    const cardDark = Color(0xFF131B2E); // Deep rich card surface
    const textDark = Color(0xFFFFFFFF); // Pure white high contrast
    const textSecondaryDark = Color(0xFF94A3B8); // Slate 400

    // Create Material 3 ColorScheme
    final colorScheme = ColorScheme.dark(
      primary: actualPrimary,
      onPrimary: Colors.white,
      secondary: const Color(0xFF818CF8), // Indigo 400
      onSecondary: Colors.white,
      tertiary: const Color(0xFF10B981), // Emerald 500
      onTertiary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surfaceDark,
      onSurface: textDark,
      onSurfaceVariant: textSecondaryDark,
      surfaceContainerHighest: const Color(0xFF1E293B), // Sleek deep slate
      primaryContainer: actualPrimary.withValues(alpha: 0.15),
      onPrimaryContainer: Colors.white,
      secondaryContainer: const Color(0xFF1E293B),
      onSecondaryContainer: const Color(0xFF818CF8),
      errorContainer: Color(AppConfig.error800),
      onErrorContainer: Color(AppConfig.error200),
      outline: const Color(0xFF334155),
      outlineVariant: const Color(0xFF1E293B),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardColor: cardDark,
      dividerColor: colorScheme.onSurface.withValues(alpha: 0.1),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: _textStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textDark, size: 24),
      ),

      // Card - Clean, premium, borderless design
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20 * scaleFactor),
          side: BorderSide.none, // Strip card borders per design polish
        ),
        margin: EdgeInsets.symmetric(
          horizontal: 16 * scaleFactor,
          vertical: 8 * scaleFactor,
        ),
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
            fontSize: 16 * scaleFactor,
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
            fontSize: 16 * scaleFactor,
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
            fontSize: 16 * scaleFactor,
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
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8 * scaleFactor),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
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
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: TextStyle(
          fontSize: 14 * scaleFactor,
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
          fontSize: 32 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displayMedium: _textStyle(
          fontSize: 28 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        displaySmall: _textStyle(
          fontSize: 24 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineLarge: _textStyle(
          fontSize: 22 * scaleFactor,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        headlineMedium: _textStyle(
          fontSize: 20 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        headlineSmall: _textStyle(
          fontSize: 18 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleLarge: _textStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleMedium: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        titleSmall: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        bodyLarge: _textStyle(
          fontSize: 16 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodyMedium: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
          height: 1.5,
        ),
        bodySmall: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
        labelLarge: _textStyle(
          fontSize: 14 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        labelMedium: _textStyle(
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
        labelSmall: _textStyle(
          fontSize: 10 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.12),
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
          fontSize: 12 * scaleFactor,
          fontWeight: FontWeight.normal,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 12 * scaleFactor,
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
        backgroundColor: surfaceDark,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textSecondaryDark,
        selectedLabelStyle: _textStyle(
          fontSize: 11 * scaleFactor,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: _textStyle(
          fontSize: 11 * scaleFactor,
          fontWeight: FontWeight.w500,
          color: textSecondaryDark,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
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
