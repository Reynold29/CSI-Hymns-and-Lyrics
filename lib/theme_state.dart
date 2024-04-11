import 'package:flutter/material.dart';

class ThemeState with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _blackThemeEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get blackThemeEnabled => _blackThemeEnabled;

  void setThemeMode(ThemeMode themeMode) {
    _themeMode = themeMode;
    notifyListeners();
  }

  void setBlackThemeEnabled(bool enabled) {
    _blackThemeEnabled = enabled;
    notifyListeners();
  }

  ThemeData getTheme() {
    if (_blackThemeEnabled) {
      return ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      );
    } else {
      return ThemeData();
    }
  }
}