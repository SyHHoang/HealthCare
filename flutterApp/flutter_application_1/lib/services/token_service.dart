import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
// import 'dart:html' as html;

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';

  static Future<void> saveToken(String token, String role, String userId) async {
    try {
      // if (kIsWeb) {
      //   // Sử dụng localStorage cho web
      //   html.window.localStorage[_tokenKey] = token;
      //   html.window.localStorage[_roleKey] = role;
      //   html.window.localStorage[_userIdKey] = userId;
      // } else {
        // Sử dụng SharedPreferences cho mobile
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_roleKey, role);
        await prefs.setString(_userIdKey, userId);
      // }
      
      debugPrint('Đã lưu token: $token');
      debugPrint('Role: $role');
      debugPrint('User ID: $userId');
    } catch (e) {
      debugPrint('Lỗi khi lưu token: $e');
      rethrow;
    }
  }

  static Future<String?> getToken() async {
    try {
      // if (kIsWeb) {
      //   return html.window.localStorage[_tokenKey];
      // } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_tokenKey);
      // }
    } catch (e) {
      debugPrint('Lỗi khi lấy token: $e');
      return null;
    }
  }

  static Future<String?> getRole() async {
    try {
      // if (kIsWeb) {
      //   return html.window.localStorage[_roleKey];
      // } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_roleKey);
      // }
    } catch (e) {
      debugPrint('Lỗi khi lấy role: $e');
      return null;
    }
  }

  static Future<String?> getUserId() async {
    try {
      // if (kIsWeb) {
      //   return html.window.localStorage[_userIdKey];
      // } else {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_userIdKey);
      // }
    } catch (e) {
      debugPrint('Lỗi khi lấy user ID: $e');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      // if (kIsWeb) {
      //   html.window.localStorage.remove(_tokenKey);
      //   html.window.localStorage.remove(_roleKey);
      //   html.window.localStorage.remove(_userIdKey);
      // } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        await prefs.remove(_roleKey);
        await prefs.remove(_userIdKey);
      // }
      debugPrint('Đã xóa token');
    } catch (e) {
      debugPrint('Lỗi khi xóa token: $e');
      rethrow;
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
} 