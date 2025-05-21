// services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeService() {
    _loadThemeFromPrefs();
  }

  // Load theme setting from shared preferences
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;

    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  // Save theme setting to shared preferences
  Future<void> _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', _themeMode.index);
  }

  // Toggle between light and dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    _saveThemeToPrefs();
    notifyListeners();
  }

  // Set theme mode
  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeToPrefs();
    notifyListeners();
  }
}
