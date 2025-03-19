import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'karanlik_mod';
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Color(0xFF1A1A1A),
    primaryColor: Colors.green,
    colorScheme: ColorScheme.dark(
      primary: Colors.green,
      secondary: Colors.greenAccent,
      background: Color(0xFF1A1A1A),
      surface: Color(0xFF2C2C2C),
    ),
    cardColor: Color(0xFF2C2C2C),
    dividerColor: Colors.white10,
    fontFamily: 'Tektur-Regular',
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.green,
    colorScheme: ColorScheme.light(
      primary: Colors.green,
      secondary: Colors.greenAccent,
      background: Colors.white,
      surface: Colors.grey[100]!,
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey[300]!,
    fontFamily: 'Tektur-Regular',
  );
}
