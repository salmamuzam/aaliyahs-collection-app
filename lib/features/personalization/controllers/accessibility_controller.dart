
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityController with ChangeNotifier {
  bool _reduceMotion = false;
  bool _highContrast = false;
  bool _showSemanticsDebugger = false;
  ThemeMode _themeMode = ThemeMode.system;

  Locale? _locale;

  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;
  bool get showSemanticsDebugger => _showSemanticsDebugger;
  ThemeMode get themeMode => _themeMode;
  Locale? get locale => _locale;

  AccessibilityController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _reduceMotion = prefs.getBool('reduce_motion') ?? false;
    _highContrast = prefs.getBool('high_contrast') ?? false;
    
    // Load ThemeMode
    final int themeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    final String? langCode = prefs.getString('app_locale');
    if (langCode != null) {
      _locale = Locale(langCode);
    }
    
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale != null) {
      await prefs.setString('app_locale', locale.languageCode);
    } else {
      await prefs.remove('app_locale');
    }
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _reduceMotion = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', value);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  void toggleSemanticsDebugger() {
    _showSemanticsDebugger = !_showSemanticsDebugger;
    notifyListeners();
  }
}
