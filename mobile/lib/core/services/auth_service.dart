import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class AuthService {
  static const _currentUserKey = 'current_user_id';
  static const _lastEmailKey = 'last_email';

  Future<String?> register(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/register"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);

      if (!data["success"]) {
        throw Exception(data["error"] ?? "Registration failed");
      }

      final userId = data["data"]["userId"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, userId);
      await prefs.setString(_lastEmailKey, email);

      return userId;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/login"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body);

      if (!data["success"]) {
        throw Exception(data["error"] ?? "Login failed");
      }

      final userId = data["data"]["userId"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, userId);
      await prefs.setString(_lastEmailKey, email);

      return userId;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<String?> getLastEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastEmailKey);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_currentUserKey);
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
}
