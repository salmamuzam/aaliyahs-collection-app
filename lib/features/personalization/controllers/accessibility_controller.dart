
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityController with ChangeNotifier {
  bool _reduceMotion = false;
  bool _highContrast = false;
  bool _showSemanticsDebugger = false;

  Locale? _locale;

  bool get reduceMotion => _reduceMotion;
  bool get highContrast => _highContrast;
  bool get showSemanticsDebugger => _showSemanticsDebugger;
  Locale? get locale => _locale;

  AccessibilityController() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _reduceMotion = prefs.getBool('reduce_motion') ?? false;
    _highContrast = prefs.getBool('high_contrast') ?? false;
    
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

  void toggleSemanticsDebugger() {
    _showSemanticsDebugger = !_showSemanticsDebugger;
    notifyListeners();
  }
}
