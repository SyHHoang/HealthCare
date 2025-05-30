import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/message.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MessageService {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  // Lấy thông tin chat dựa trên ID của bác sĩ
  Future<Map<String, dynamic>?> getChatByDoctorId(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      // Lấy danh sách chat của người dùng
      final userChatsResponse = await http.get(
        Uri.parse('$apiUrl/chat/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userChatsResponse.statusCode == 200) {
        final List<dynamic> chats = json.decode(userChatsResponse.body);
        debugPrint('Danh sách chat: ${chats.length} chats');
        
        // Tìm chat với bác sĩ cụ thể
        Map<String, dynamic>? targetChat;
        for (var chat in chats) {
          if (chat['doctorId'] != null && 
              chat['doctorId'] is Map && 
              chat['doctorId']['_id'] == doctorId) {
            targetChat = Map<String, dynamic>.from(chat);
            break;
          }
        }
        
        if (targetChat != null) {
          debugPrint('Đã tìm thấy chat với bác sĩ: $doctorId');
          return targetChat;
        } else {
          debugPrint('Không tìm thấy chat với bác sĩ: $doctorId');
        }
      } else {
        debugPrint('Lỗi khi lấy danh sách chat: ${userChatsResponse.statusCode}');
        debugPrint('Nội dung phản hồi: ${userChatsResponse.body}');
      }
      
      return null;
    } catch (e) {
      debugPrint('Lỗi khi tìm chat với bác sĩ: $e');
      return null;
    }
  }

  // Lấy tin nhắn dựa trên ID của chat
  Future<List<Message>> getMessagesByChatId(String chatId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final messagesResponse = await http.get(
        Uri.parse('$apiUrl/chat/messages/$chatId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (messagesResponse.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(messagesResponse.body);
        return messagesData.map((json) => Message.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy tin nhắn: $e');
      return [];
    }
  }

  // Tạo chat mới với bác sĩ
  Future<Map<String, dynamic>?> createChat(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.post(
        Uri.parse('$apiUrl/chat/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
        }),
      );

      if (response.statusCode == 201) {
        return Map<String, dynamic>.from(json.decode(response.body));
      }
      
      return null;
    } catch (e) {
      debugPrint('Lỗi khi tạo chat: $e');
      return null;
    }
  }

  // Đổi tên phương thức sendMessage đầu tiên thành sendMessageToChat
  Future<Message?> sendMessageToChat(String chatId, String content) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }
      
      // Gửi tin nhắn
      final response = await http.post(
        Uri.parse('$apiUrl/chat/Sendmessage'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'chatId': chatId,
          'content': content,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        // Kiểm tra và xử lý trường hợp data có thể là Map hoặc có cấu trúc khác
        if (data is Map<String, dynamic>) {
          return Message.fromJson(data);
        } else {
          debugPrint('Dữ liệu trả về không đúng định dạng: $data');
          throw Exception('Dữ liệu trả về không đúng định dạng');
        }
      } else {
        throw Exception('Không thể gửi tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi gửi tin nhắn: $e');
      throw Exception('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Đánh dấu tất cả tin nhắn trong chat là đã đọc
  Future<bool> markMessagesAsRead(String chatId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.put(
        Uri.parse('$apiUrl/chat/messages/read-all/$chatId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
      return false;
    }
  }

  Future<List<Message>> getChatHistory(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      debugPrint('Đang tải lịch sử chat với bác sĩ: $doctorId');
      
      // Kiểm tra xem có chat với bác sĩ này chưa, nếu chưa thì tạo mới
      await _createChatIfNotExists(doctorId);

      // Lấy danh sách chat của người dùng
      final userChatsResponse = await http.get(
        Uri.parse('$apiUrl/chat/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (userChatsResponse.statusCode == 200) {
        final List<dynamic> chats = json.decode(userChatsResponse.body);
        debugPrint('Tìm thấy ${chats.length} cuộc trò chuyện');
        
        // Tìm chat với bác sĩ cụ thể
        Map<String, dynamic>? targetChat;
        for (var chat in chats) {
          if (chat['doctorId'] != null && 
              chat['doctorId'] is Map && 
              chat['doctorId']['_id'] == doctorId) {
            targetChat = Map<String, dynamic>.from(chat);
            break;
          }
        }

        if (targetChat == null) {
          debugPrint('Không tìm thấy chat với bác sĩ ID: $doctorId');
          return [];
        }

        // Lấy tin nhắn từ chat
        final chatId = targetChat['_id'];
        debugPrint('Lấy tin nhắn từ chat ID: $chatId');
        
        final messagesResponse = await http.get(
          Uri.parse('$apiUrl/chat/messages/$chatId'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (messagesResponse.statusCode == 200) {
          final List<dynamic> messagesData = json.decode(messagesResponse.body);
          //debugPrint('tin nhắn: ${messagesData}');
          debugPrint('Tìm thấy ${messagesData.length} tin nhắn');
          try {
            return messagesData.map((json) => Message.fromJson(json)).toList();
          } catch (parseError) {
            debugPrint('Lỗi khi phân tích dữ liệu tin nhắn: $parseError');
            debugPrint('Dữ liệu tin nhắn đầu tiên: ${messagesData.isNotEmpty ? messagesData.first : "không có"}');
            return [];
          }
        } else {
          debugPrint('Lỗi khi lấy tin nhắn: ${messagesResponse.statusCode}');
          debugPrint('Nội dung phản hồi: ${messagesResponse.body}');
        }
      } else {
        debugPrint('Lỗi khi lấy danh sách chat: ${userChatsResponse.statusCode}');
        debugPrint('Nội dung phản hồi: ${userChatsResponse.body}');
      }
      
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy lịch sử chat: $e');
      throw Exception('Không thể tải lịch sử chat: $e');
    }
  }

  Future<void> _createChatIfNotExists(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      await http.post(
        Uri.parse('$apiUrl/chat/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
        }),
      );
    } catch (e) {
      debugPrint('Lỗi khi tạo chat: $e');
    }
  }

  // Đổi tên phương thức markAsRead đầu tiên thành markMessageAsRead
  Future<Message> markMessageAsRead(String messageId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.put(
        Uri.parse('$apiUrl/chat/messages/read/$messageId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return Message.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không thể đánh dấu tin nhắn đã đọc');
      }
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
      throw Exception('Không thể đánh dấu tin nhắn đã đọc: $e');
    }
  }

  Future<List<Message>> getUnreadMessages() async {
    final response = await http.get(
      Uri.parse('$apiUrl/messages/unread'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_TOKEN_HERE', // Thay thế bằng token thực tế
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load unread messages');
    }
  }

  Future<List<Map<String, dynamic>>> getUserChats() async {
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
        final List<dynamic> chats = json.decode(response.body);
        return List<Map<String, dynamic>>.from(chats);
      } else {
        debugPrint('Lỗi khi lấy danh sách chat: ${response.statusCode}');
        throw Exception('Không thể lấy danh sách chat');
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy danh sách chat: $e');
      throw Exception('Không thể lấy danh sách chat: $e');
    }
  }

  Future<List<Message>> getMessages() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không tìm thấy token');

      final response = await http.get(
        Uri.parse('$apiUrl/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('tin nhắn: ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi khi lấy tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy tin nhắn: $e');
    }
  }

  // Đổi tên phương thức sendMessage thứ hai thành sendMessageWithImage
  Future<Message> sendMessageWithImage(String content, {Map<String, dynamic>? image}) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không tìm thấy token');

      final response = await http.post(
        Uri.parse('$apiUrl/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'content': content,
          'image': image,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Message.fromJson(data);
      } else {
        throw Exception('Lỗi khi gửi tin nhắn: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gửi tin nhắn: $e');
    }
  }

  // Đổi tên phương thức markAsRead thứ hai thành markMessageAsReadById
  Future<void> markMessageAsReadById(String messageId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không tìm thấy token');

      final response = await http.patch(
        Uri.parse('$apiUrl/messages/$messageId/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Lỗi khi đánh dấu tin nhắn đã đọc: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi đánh dấu tin nhắn đã đọc: $e');
    }
  }

  Future<List<Message>> getOlderMessages(String chatId, String oldestMessageId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token! Vui lòng đăng nhập lại.');
      }

      final response = await http.get(
        Uri.parse('$apiUrl/chat/messages/$chatId/older?beforeId=$oldestMessageId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesData = json.decode(response.body);
        return messagesData.map((json) => Message.fromJson(json)).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Lỗi khi lấy tin nhắn cũ: $e');
      return [];
    }
  }
} 