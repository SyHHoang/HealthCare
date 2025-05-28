import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ChatService {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  Future<List<dynamic>> getUserChats() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi lấy danh sách chat');
      }
    } catch (e) {
      debugPrint('Lỗi lấy danh sách chat: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getChatMessages(String chatId, {int limit = 10}) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/messages/$chatId?limit=$limit'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi lấy tin nhắn');
      }
    } catch (e) {
      debugPrint('Lỗi lấy tin nhắn: $e');
      rethrow;
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/chat/sendmessage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'chatId': chatId,
          'content': content,
        }),
      );

      if (response.statusCode != 201) {
        throw Exception('Lỗi gửi tin nhắn');
      }
    } catch (e) {
      debugPrint('Lỗi gửi tin nhắn: $e');
      rethrow;
    }
  }
} 