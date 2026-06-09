import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
<<<<<<< HEAD
  
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
=======
  bool get isDarkMode => _isDarkMode;
>>>>>>> 272fdd21827b89b258f95986e8ddc9720b355623

  // Constructor tự động tải cài đặt khi Provider được khởi tạo
  ThemeProvider() {
    loadTheme();
  }

<<<<<<< HEAD
  void toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    notifyListeners();
    
=======
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
>>>>>>> 272fdd21827b89b258f95986e8ddc9720b355623
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}