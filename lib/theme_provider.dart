import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // الحالات المتاحة: system, light, dark
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // تغيير الثيم وتحديث الواجهات وحفظ الخيار
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners(); // إشعار التطبيق بالكامل بالتحديث فوراً

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.toString());
  }

  // تحميل الثيم المحفوظ عند إقلاع التطبيق
  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? modeStr = prefs.getString('theme_mode');
    
    if (modeStr != null) {
      if (modeStr == ThemeMode.light.toString()) {
        _themeMode = ThemeMode.light;
      } else if (modeStr == ThemeMode.dark.toString()) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
      notifyListeners();
    }
  }
}