import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/news.dart';
import 'api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NewsService {
  final ApiService _apiService = ApiService();
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  Future<List<News>> getAllNews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news'));
      print('Response: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        // Nếu response trực tiếp là List (không có wrapper)
        if (jsonData is List) {
          return jsonData
              .map((json) => News.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        
        // Nếu response là Map (có wrapper với success và data)
        if (jsonData is Map<String, dynamic>) {
          if (jsonData['data'] is List) {
            final List<dynamic> newsList = jsonData['data'];
            return newsList
                .map((json) => News.fromJson(json as Map<String, dynamic>))
                .toList();
          }
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading news: $e'); // Debug log
      throw Exception('Failed to load news: $e');
    }
  }

  Future<News> getNewsById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/news/$id'));
      print('Response for news $id: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic>) {
          // Nếu response có wrapper
          if (jsonData['data'] is Map<String, dynamic>) {
            return News.fromJson(jsonData['data'] as Map<String, dynamic>);
          }
          // Nếu response trực tiếp là news data
          return News.fromJson(jsonData);
        }
        
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading news $id: $e'); // Debug log
      throw Exception('Failed to load news: $e');
    }
  }
} 