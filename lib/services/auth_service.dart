import '../fake_user_db.dart';

class AuthService {
  static Map<String, dynamic>? login(String mssv, String pass) {
    try {
      return FakeUserDB.users.firstWhere(
        (u) => u["mssv"] == mssv && u["pass"] == pass,
      );
    } catch (e) {
      return null;
    }
  }
}