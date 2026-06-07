import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyLoggedIn = "is_logged_in";
  static const String _keyMssv = "user_mssv";

  // Lưu thông tin khi đăng nhập thành công
  static Future<void> setLoggedIn(String mssv) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyMssv, mssv);
  }

  // Kiểm tra trạng thái đăng nhập
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  // Lấy MSSV đã lưu
  static Future<String?> getMssv() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMssv);
  }

  // Xóa session khi đăng xuất
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}