import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  Color _accentColor = const Color(AppConfig.primary600);

  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final savedMode = await StorageService().getThemePreference();
      if (savedMode != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () => ThemeMode.dark,
        );
      }
      final savedColor = await StorageService().getAccentColor();
      if (savedColor != null) {
        _accentColor = Color(int.parse(savedColor, radix: 16));
      }
      notifyListeners();
    } catch (e) {
      // Use defaults
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    try {
      await StorageService().saveThemePreference(mode.toString());
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    try {
      await StorageService().saveAccentColor(color.value.toRadixString(16));
    } catch (e) {}
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
