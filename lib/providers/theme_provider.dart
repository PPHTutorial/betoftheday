import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark; // Default to dark mode

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(AppConfig.themeModeKey);
      if (savedMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () =>
              ThemeMode.dark, // Default to dark mode if saved mode is invalid
        );
        notifyListeners();
      } else {
        // No saved preference, use dark mode as default
        notifyListeners();
      }
    } catch (e) {
      // Use default theme mode (dark)
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.themeModeKey, mode.toString());
    } catch (e) {
      // Ignore storage errors
    }
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
