import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/user_profile.dart';

class ProfileService {
  Future<void> saveProfile(UserProfile profile) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/profile/save"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(profile.toJson()),
    );

    final data = jsonDecode(res.body);

    if (!data["success"]) {
      throw Exception(data["error"] ?? "Profile save failed");
    }
  }

  Future<UserProfile?> getProfile(String userId) async {
    final res = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/profile/$userId"),
    );

    final data = jsonDecode(res.body);

    if (!data["success"]) {
      return null;
    }

    return UserProfile.fromJson(data["data"]);
  }

  Future<void> updateProfile(UserProfile profile) async {
    final res = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/profile/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(profile.toJson()),
    );

    final data = jsonDecode(res.body);

    if (!data["success"]) {
      throw Exception(data["error"] ?? "Profile update failed");
    }
  }
}
