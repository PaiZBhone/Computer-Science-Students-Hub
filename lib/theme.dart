import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Default to following the phone's system settings
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners(); // Tells the app to instantly rebuild with new colors
  }
}
