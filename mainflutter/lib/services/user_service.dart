import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'token_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.22.80:5000/api'; //10.0.2.2

  Future<User> getUserProfile() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return User.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể lấy thông tin người dùng');
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<User> updateProfile({
    String? fullname,
    int? age,
    String? gender,
    String? phone,
    String? avatar,
    String? imageId,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'fullname': fullname,
          'age': age,
          'gender': gender,
          'phone': phone,
          'avatar': avatar,
          'imageId': imageId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['user'] != null) {
          return User.fromJson(data['user']);
        } else {
          throw Exception('Không thể cập nhật thông tin người dùng');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Không thể cập nhật thông tin người dùng');
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
} 