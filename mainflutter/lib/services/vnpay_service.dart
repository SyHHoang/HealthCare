import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class VnpayService {
  static final String _baseUrl = '${dotenv.env['BASE_URL'] ?? ''}/api/vnpay';
  static final String _returnUrl = '${dotenv.env['BASE_URL'] ?? ''}/api/vnpay/vnpay_return';
  static final String _ipnUrl = '${dotenv.env['BASE_URL'] ?? ''}/api/vnpay/vnpay_ipn';

  static Future<String> createPaymentUrl({
    required String bankCode,
    required String doctorId,
    required String orderType,
    required int quantity,
    required String language,
  }) async {
    try {
      // Lấy token từ TokenService
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/create_payment_url'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'bankCode': bankCode,
          'doctorId': doctorId,
          'orderType': orderType,
          'quantity': quantity,
          'language': language,
          'returnUrl': _returnUrl,
          'ipnUrl': _ipnUrl,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['vnpUrl'];
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi tạo URL thanh toán: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi tạo URL thanh toán: $e');
      throw Exception('Lỗi tạo URL thanh toán: $e');
    }
  }

  static Future<bool> checkPaymentStatus(String orderId) async {
    try {
      // Lấy token từ TokenService
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/querydr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'orderId': orderId,
          'transDate': DateTime.now().toString(),
        }),
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['RspCode'] == '00';
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi kiểm tra trạng thái thanh toán: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi kiểm tra trạng thái thanh toán: $e');
      throw Exception('Lỗi kiểm tra trạng thái thanh toán: $e');
    }
  }

  // Phương thức mở cổng thanh toán VNPAY
  static Future<void> openVnpayPayment({
    required String paymentUrl,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      // Sử dụng url_launcher để mở URL
      final uri = Uri.parse(paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Không thể mở URL thanh toán');
      }
    } catch (e) {
      debugPrint('Lỗi mở cổng thanh toán: $e');
      throw Exception('Lỗi mở cổng thanh toán: $e');
    }
  }
} 