import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api.dart';

class ChatResult {
  final String response;
  final String emotion;
  final bool crisis;

  ChatResult({
    required this.response,
    required this.emotion,
    required this.crisis,
  });
}

class ChatSession {
  final String chatId;
  final String title;

  ChatSession({required this.chatId, required this.title});
}

class ChatService {
  static const _lastChatKey = "last_chat_id";

  Future<ChatResult> sendMessage({
    required String userId,
    required String chatId,
    required String message,
  }) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/chat");

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "chatId": chatId,
        "message": message,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Chat error");
    }

    final data = jsonDecode(res.body);

    return ChatResult(
      response: data["response"] ?? "",
      emotion: data["emotion"] ?? "Stable",
      crisis: data["crisis"] ?? false,
    );
  }

  Future<String> createChat(String userId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/chat/new/$userId");

    final res = await http.post(uri);

    final data = jsonDecode(res.body);

    final chatId = data["chatId"];

    await saveLastChat(chatId);

    return chatId;
  }

  Future<List<ChatSession>> listChats(String userId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/chat/list/$userId");

    final res = await http.get(uri);

    final data = jsonDecode(res.body) as List;

    return data
        .map((e) => ChatSession(chatId: e["chatId"], title: e["title"]))
        .toList();
  }

  Future<List<Map<String, dynamic>>> loadMessages(
    String userId,
    String chatId,
  ) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/chat/messages/$userId/$chatId");

    final res = await http.get(uri);

    final data = jsonDecode(res.body) as List;

    return data.cast<Map<String, dynamic>>();
  }

  Future<void> deleteChat(String userId, String chatId) async {
    final uri = Uri.parse("${ApiConfig.baseUrl}/chat/delete/$userId/$chatId");

    final res = await http.delete(uri);

    if (res.statusCode != 200) {
      throw Exception("Delete chat failed");
    }
  }

  Future<void> saveLastChat(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastChatKey, chatId);
  }

  Future<String?> getLastChat() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastChatKey);
  }

  Future<void> clearLastChat() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastChatKey);
  }
}
