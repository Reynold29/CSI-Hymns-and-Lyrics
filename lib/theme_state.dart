import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _blackThemeEnabled = false;
  Color _seedColor = Colors.blue; // Provide a default non-null seed color

  ThemeMode get themeMode => _themeMode;
  bool get blackThemeEnabled => _blackThemeEnabled;
  Color get seedColor => _seedColor;

  static const String _themeModeKey = 'themeMode';
  static const String _blackThemeEnabledKey = 'blackThemeEnabled';
  static const String _seedColorKey = 'seedColor';

  ThemeState() {
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    _blackThemeEnabled = prefs.getBool(_blackThemeEnabledKey) ?? false;
    final colorValue = prefs.getInt(_seedColorKey) ?? Colors.blue.value;
    _seedColor = Color(colorValue);
    notifyListeners();
  }

  Future<void> _saveThemeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, _themeMode.index);
    await prefs.setBool(_blackThemeEnabledKey, _blackThemeEnabled);
    await prefs.setInt(_seedColorKey, _seedColor.value);
  }

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    _saveThemeSettings();
    notifyListeners();
  }

  void setBlackThemeEnabled(bool enabled) {
    _blackThemeEnabled = enabled;
    _saveThemeSettings();
    notifyListeners();
  }

  void setSeedColor(Color color) {
    _seedColor = color;
    _saveThemeSettings();
    notifyListeners();
  }

  // ThemeData getTheme() is removed as MaterialApp will construct themes directly
  // based on themeMode, seedColor, and blackThemeEnabled.
  // The logic for black theme will be in main.dart's darkTheme.
}