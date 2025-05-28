import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/feedback.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FeedbackService {
  static final String apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  static Future<List<Feedback>> getFeedbacks() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> feedbacks = data['data'];
        return feedbacks.map((json) => Feedback.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load feedbacks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load feedbacks: $e');
    }
  }

  static Future<void> submitFeedback(Feedback feedback) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token đăng nhập');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/feedback'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(feedback.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to submit feedback: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit feedback: $e');
    }
  }
} 