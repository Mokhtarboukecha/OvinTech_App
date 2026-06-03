/*class AuthService {
  static String? token;
}*/
/*class AuthService {
  static String? token;
  static String? firstName;
  static String? lastName;
  static String? email;
}*/
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String? token;
  static String? firstName;
  static String? lastName;
  static String? email;

  // حفظ بيانات المستخدم
  static Future<void> saveUser({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('firstName', firstName);
    await prefs.setString('lastName', lastName);
    await prefs.setString('email', email);

    AuthService.token = token;
    AuthService.firstName = firstName;
    AuthService.lastName = lastName;
    AuthService.email = email;
  }

  // تحميل بيانات المستخدم
  static Future<bool> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    if (savedToken == null) return false;

    AuthService.token = savedToken;
    AuthService.firstName = prefs.getString('firstName');
    AuthService.lastName = prefs.getString('lastName');
    AuthService.email = prefs.getString('email');
    return true;
  }

  // حذف بيانات المستخدم عند الـ logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    token = null;
    firstName = null;
    lastName = null;
    email = null;
  }
}