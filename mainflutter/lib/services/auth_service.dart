import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class AuthService {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  Future<dynamic> loginUser(String email, String password) async {
    try {
      debugPrint('Đang đăng nhập user...');
      debugPrint('Email: $email');
      debugPrint('apiUrl: $apiUrl');
      final response = await http.post(
        Uri.parse('$apiUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'user',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Kết nối quá thời gian chờ');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Lưu token
        await TokenService.saveToken(token, 'user', user.id);

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }
    } on TimeoutException {
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } catch (e) {
      debugPrint('Lỗi chi tiết: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<dynamic> loginDoctor(String email, String password) async {
    try {
      debugPrint('Đang đăng nhập doctor...');
      debugPrint('Email: $email');

      final response = await http.post(
        Uri.parse('$apiUrl/doctors/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'doctor',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Kết nối quá thời gian chờ');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final doctor = Doctor.fromJson(data['doctor']);

        // Lưu token
        await TokenService.saveToken(token, 'doctor', doctor.id ?? '');

        return doctor;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng nhập thất bại');
      }
    } on TimeoutException {
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } catch (e) {
      debugPrint('Lỗi chi tiết: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('Đang đăng xuất...');
      await TokenService.clearToken();
      debugPrint('Đã đăng xuất thành công');
    } catch (e) {
      debugPrint('Lỗi khi đăng xuất: $e');
      rethrow;
    }
  }

  Future<User> registerUser({
    required String email,
    required String password,
    required String fullname,
    required String phone,
  }) async {
    try {
      debugPrint('Đang đăng ký user...');
      debugPrint('Email: $email');

      final response = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullname': fullname,
          'phone': phone,
          'role': 'user',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Kết nối quá thời gian chờ');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);

        // Lưu token
        await TokenService.saveToken(token, 'user', user.id);

        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
      }
    } on TimeoutException {
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } catch (e) {
      debugPrint('Lỗi chi tiết: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }

  Future<Doctor> registerDoctor({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
    required String specialty,
    required String otherSpecialties,
    required String education,
    required int? graduationYear,
    required String licenseNumber,
    required int? experience,
    required String currentWorkplace,
  }) async {
    try {
      debugPrint('Đang đăng ký doctor...');
      debugPrint('Email: $email');

      final response = await http.post(
        Uri.parse('$apiUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'fullname': fullName,
          'phone': phone,
          'role': 'doctor',
          'address': address,
          'specialty': specialty,
          'otherSpecialties': otherSpecialties,
          'education': education,
          'graduationYear': graduationYear,
          'licenseNumber': licenseNumber,
          'experience': experience,
          'currentWorkplace': currentWorkplace,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Kết nối quá thời gian chờ');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final doctor = Doctor.fromJson(data['doctor']);

        // Lưu token
        await TokenService.saveToken(token, 'doctor', doctor.id ?? '');

        return doctor;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Đăng ký thất bại');
      }
    } on TimeoutException {
      throw Exception('Kết nối quá thời gian chờ. Vui lòng thử lại.');
    } on FormatException {
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException {
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.');
    } catch (e) {
      debugPrint('Lỗi chi tiết: $e');
      throw Exception('Lỗi không xác định: $e');
    }
  }
   Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
          await http.post(
        Uri.parse('$apiUrl/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );
    } catch (e) {
      throw Exception('Đổi mật khẩu thất bại: $e');
    }
  }
} 