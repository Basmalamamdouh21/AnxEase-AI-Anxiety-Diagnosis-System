import 'dart:convert';
import 'package:anxease/core/models/question_flow.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionsFlowService {
  static const _key = "questions_flow";

  Future<void> saveFlow(QuestionsFlow flow) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("${_key}_${flow.userId}", jsonEncode(flow.toJson()));
  }

  Future<QuestionsFlow> loadOrCreate(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("${_key}_$userId");

    if (data == null) {
      return QuestionsFlow(userId: userId);
    }

    return QuestionsFlow.fromJson(jsonDecode(data));
  }

  Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("${_key}_$userId");
  }
}
