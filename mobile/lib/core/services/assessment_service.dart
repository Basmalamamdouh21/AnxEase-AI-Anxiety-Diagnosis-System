import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_result.dart';
import '../config/api.dart';

class AssessmentService {
  static const _key = "assessments";

  Duration get _timeout => const Duration(seconds: 240);

  // =========================================
  // GENERIC NETWORK REQUEST
  // =========================================

  Future<dynamic> _request(Future<http.Response> Function() call) async {
    try {
      final res = await call().timeout(_timeout);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (res.body.isEmpty) return null;
        return jsonDecode(res.body);
      }

      throw Exception("Server error (${res.statusCode})");
    } catch (e) {
      throw Exception("Network error: $e");
    }
  }

  // =========================================
  // ANALYZE ASSESSMENT
  // =========================================

  Future<Map<String, dynamic>> analyze(AssessmentResult result) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/assessment/analyze");

    final response = await _request(
      () => http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(result.toJson()),
      ),
    );

    await saveAssessment(result);

    return Map<String, dynamic>.from(response);
  }

  // =========================================
  // REGENERATE AI ANALYSIS
  // =========================================

  Future<void> regenerateAnalysis(String userId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/assessment/analyze/$userId");
    await _request(() => http.post(uri));
  }

  // =========================================
  // GET LATEST ASSESSMENT
  // =========================================

  Future<Map<String, dynamic>?> getLatestAssessmentFromServer(
    String userId,
  ) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/assessment/latest/$userId");

    final data = await _request(() => http.get(uri));

    if (data == null) return null;

    return Map<String, dynamic>.from(data);
  }

  // =========================================
  // GET THERAPY PLAN (FIXED)
  // =========================================

  Future<Map<String, dynamic>> getTherapyPlan(String userId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/treatment/therapy/$userId");

    final data = await _request(() => http.get(uri));

    if (data == null) return {};

    final map = Map<String, dynamic>.from(data);

    if (map.containsKey("therapyPlan")) {
      return Map<String, dynamic>.from(map["therapyPlan"]);
    }

    return map;
  }

  // =========================================
  // GET MEDICATION PLAN (FIXED)
  // =========================================

  Future<Map<String, dynamic>> getMedicationPlan(String userId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/treatment/medication/$userId");

    final data = await _request(() => http.get(uri));

    if (data == null) return {};

    final map = Map<String, dynamic>.from(data);

    if (map.containsKey("medicationPlan")) {
      return Map<String, dynamic>.from(map["medicationPlan"]);
    }

    return map;
  }

  // =========================================
  // SAVE LOCAL CACHE
  // =========================================

  Future<void> saveAssessment(AssessmentResult result) async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_key) ?? [];

    list.add(jsonEncode(result.toJson()));

    await prefs.setStringList(_key, list);
  }

  // =========================================
  // GET LOCAL ASSESSMENT
  // =========================================

  Future<AssessmentResult?> getLatestLocalAssessment(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_key) ?? [];

    for (int i = list.length - 1; i >= 0; i--) {
      final decoded = AssessmentResult.fromJson(jsonDecode(list[i]));

      if (decoded.userId == userId) {
        return decoded;
      }
    }

    return null;
  }

  // =========================================
  // CHECK IF USER HAS ASSESSMENT
  // =========================================

  Future<bool> hasAssessment(String userId) async {
    try {
      final latest = await getLatestAssessmentFromServer(userId);

      if (latest != null) return true;

      final local = await getLatestLocalAssessment(userId);

      return local != null;
    } catch (_) {
      final local = await getLatestLocalAssessment(userId);
      return local != null;
    }
  }

  // =========================================
  // CLEAR CACHE
  // =========================================

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
