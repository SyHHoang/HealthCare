import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'token_service.dart';
import 'socket_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DoctorChatService {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';
  final SocketService _socketService = SocketService.instance;

  // Đảm bảo socket đã kết nối
  Future<void> ensureSocketConnected() async {
    if (!_socketService.isConnected()) {
      await _socketService.connect();
    }
  }

  Future<List<dynamic>> getDoctorChats() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/doctor'),
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

  Future<List<dynamic>> getChatMessages(String chatId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/doctor/messages/$chatId?limit=10&page=1&sort=desc'),
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

  Future<List<dynamic>> getOlderMessages(String chatId, String beforeId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      debugPrint('chatId: $chatId');
      debugPrint('beforeId: $beforeId');
      final response = await http.get(
        Uri.parse('$apiUrl/chat/doctor/messages/$chatId/older?beforeId=$beforeId&limit=10'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Lỗi lấy tin nhắn cũ');
      }
    } catch (e) {
      debugPrint('Lỗi lấy tin nhắn cũ: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn qua socket thay vì HTTP
  Future<void> sendMessage(String chatId, String content) async {
    try {
      // Gửi tin nhắn qua socket
      _socketService.emit('send_message', {
        'chatId': chatId,
        'content': content
      });
      
      debugPrint('Đã gửi tin nhắn qua socket: $content');
    } catch (e) {
      debugPrint('Lỗi gửi tin nhắn: $e');
      rethrow;
    }
  }
} 