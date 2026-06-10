import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mood_entry.dart';

class MoodService {
  static const _key = "mood_entries";

  Future<void> saveEntry(MoodEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_key, list);
  }

  Future<List<MoodEntry>> getUserEntries(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    return list
        .map((e) => MoodEntry.fromJson(jsonDecode(e)))
        .where((e) => e.userId == userId)
        .toList();
  }
}
