import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static const Color primaryGreen = Color.fromARGB(255, 120, 173, 80);
  static const Color primaryBrown = Color(0xFF7D746C);

  Color get primaryColor => _isDarkMode ? primaryBrown : primaryGreen;
  Color get backgroundColor => _isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
  Color get cardColor => _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white;
  Color get textColor => _isDarkMode ? Colors.white : Colors.black87;
}