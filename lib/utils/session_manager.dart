import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyMssv = 'studentMssv';
  static const _keyUid = 'uid';

  static Future<void> setLoggedIn(String mssv, {String? uid}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyMssv, mssv.trim().toUpperCase());
    if (uid != null) {
      await prefs.setString(_keyUid, uid);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getMssv() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyMssv);
  }

  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyMssv);
    await prefs.remove(_keyUid);
  }
}
