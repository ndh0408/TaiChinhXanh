import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  AppThemeMode _themeMode = AppThemeMode.system;
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  AppThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // Get effective theme based on system settings
  ThemeMode get effectiveThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  // Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    switch (_themeMode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return Theme.of(context).brightness == Brightness.dark;
    }
  }

  // Initialize theme provider
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemeMode();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Initializing theme provider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final savedThemeIndex = _prefs.getInt(_themeKey);
    if (savedThemeIndex != null &&
        savedThemeIndex < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[savedThemeIndex];
    } else {
      _themeMode = AppThemeMode.system; // Default
    }
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    await _prefs.setInt(_themeKey, _themeMode.index);
    debugPrint('Theme saved to SharedPreferences');
  }

  // Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _saveThemeMode();
      notifyListeners();
    }
  }

  // Toggle between light and dark
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case AppThemeMode.light:
        await setThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
        await setThemeMode(AppThemeMode.light);
        break;
      case AppThemeMode.system:
        // If system, toggle to opposite of current system theme
        await setThemeMode(AppThemeMode.light);
        break;
    }
  }

  // Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(AppThemeMode.light);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(AppThemeMode.dark);
  }

  // Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(AppThemeMode.system);
  }

  // Get theme mode display name
  String getThemeModeDisplayName() {
    switch (_themeMode) {
      case AppThemeMode.light:
        return 'SÃ¡ng';
      case AppThemeMode.dark:
        return 'Tá»‘i';
      case AppThemeMode.system:
        return 'Theo há»‡ thá»‘ng';
    }
  }

  // Get theme mode icon
  IconData getThemeModeIcon() {
    switch (_themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  // Get all available theme modes
  List<AppThemeMode> getAvailableThemeModes() {
    return AppThemeMode.values;
  }

  // Get theme analytics
  Map<String, dynamic> getThemeAnalytics() {
    return {
      'currentThemeMode': _themeMode.toString(),
      'isInitialized': _isInitialized,
      'effectiveThemeMode': effectiveThemeMode.toString(),
    };
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await setThemeMode(AppThemeMode.system);
  }
}

