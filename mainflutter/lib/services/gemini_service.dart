import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GeminiService {
  static String get baseUrl {
    final url = dotenv.env['BASE_URL'] ?? 'http://192.168.2.101:5000/api';
    debugPrint('GeminiService baseUrl: $url');
    return url;
  }

  // Khởi tạo chat session
  static Future<void> initializeChat() async {
    try {
      final url = baseUrl.endsWith('/api')
          ? '$baseUrl/gemini/initialize'
          : '$baseUrl/api/gemini/initialize';

      debugPrint('Initialize URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to initialize chat');
      }
      
      debugPrint('Chat session initialized successfully');
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn và nhận phản hồi
  static Future<String> generateResponse(String message, List<Map<String, dynamic>> chatHistory) async {
    try {
      // Chỉ lấy những tin nhắn trước đó, không bao gồm tin nhắn hiện tại
      final previousMessages = chatHistory.where((msg) => msg['text'] != message).toList();

      // Format chat history để phù hợp với yêu cầu của Gemini API
      final formattedHistory = previousMessages.map((msg) => {
        'role': msg['sender'] == 'user' ? 'user' : 'model',
        'parts': [{'text': msg['text']}]
      }).toList();

      final url = baseUrl.endsWith('/api')
          ? '$baseUrl/gemini/message'
          : '$baseUrl/api/gemini/message';

      debugPrint('=== GEMINI SERVICE ===');
      debugPrint('Base URL: $baseUrl');
      debugPrint('Message URL: $url');
      debugPrint('Sending message: $message');
      debugPrint('Previous messages count: ${previousMessages.length}');
      debugPrint('Formatted history: $formattedHistory');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'chatHistory': formattedHistory,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.';
        debugPrint('✅ Gemini response: $responseText');
        return responseText;
      } else {
        debugPrint('❌ Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Server returned ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Error generating response: $e');
      rethrow;
    }
  }
  
  // Xóa lịch sử chat
  static Future<void> clearChatHistory() async {
    try {
      final url = baseUrl.endsWith('/api')
          ? '$baseUrl/gemini/clear'
          : '$baseUrl/api/gemini/clear';

      debugPrint('Clear URL: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode != 200) {
        throw Exception('Failed to clear chat history');
      }
      
      debugPrint('Chat history cleared successfully');
    } catch (e) {
      debugPrint('Error clearing chat history: $e');
      rethrow;
    }
  }
}
