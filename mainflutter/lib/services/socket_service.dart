import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'token_service.dart';
import 'dart:convert';

typedef MessageListener = Function(Map<String, dynamic> data);

class SocketService {
  static final SocketService _instance = SocketService._internal();
  static SocketService get instance => _instance;
  
  IO.Socket? _socket;
  bool _isConnected = false;
  final List<MessageListener> _messageListeners = [];
  final List<Function(String)> _doctorOnlineListeners = [];
  final List<Function(String)> _doctorOfflineListeners = [];
  final List<Function(String)> _userOnlineListeners = [];
  final List<Function(String)> _userOfflineListeners = [];
  final List<Function(String)> _typingListeners = [];
  final List<Function(String)> _stopTypingListeners = [];

  SocketService._internal();

  bool isConnected() => _isConnected && _socket != null && _socket!.connected;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('Socket đã kết nối sẵn');
      return;
    }

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        debugPrint('❌ Không thể kết nối socket: Token không tồn tại');
        return;
      }
      
      final role = await TokenService.getRole() ?? 'user';
      debugPrint('🔄 Đang kết nối socket với:');
      debugPrint('  - Token: ${token.substring(0, 15)}...');
      debugPrint('  - Role: $role');
      debugPrint('  - URL: http://192.168.2.101:5000');

      _socket = IO.io('http://localhost:5000', <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': true,
        'auth': {
          'token': token,
          'role': role
        },
        'reconnection': true,
        'reconnectionAttempts': 5,
        'reconnectionDelay': 1000,
        'reconnectionDelayMax': 5000,
        'timeout': 20000,
      });

      _socket!.onConnect((_) {
        debugPrint('🟢 Socket đã kết nối thành công');
        _isConnected = true;
      });

      _socket!.onDisconnect((_) {
        debugPrint('🔴 Socket đã ngắt kết nối');
        _isConnected = false;
      });

      _socket!.onConnectError((error) {
        debugPrint('❌ Lỗi kết nối socket: $error');
        _isConnected = false;
      });

      _socket!.onError((error) {
        debugPrint('❌ Socket error: $error');
      });

      // Đăng ký sự kiện nhận tin nhắn mới
      _socket!.on('new_message', (data) {
        debugPrint('📩 Nhận tin nhắn mới từ socket:');
        debugPrint('  - Kiểu dữ liệu: ${data.runtimeType}');
        debugPrint('  - Dữ liệu gốc: $data');
        
        try {
          // Chuyển đổi dữ liệu thành Map để xử lý
          Map<String, dynamic> messageData;
          
          if (data is Map) {
            messageData = Map<String, dynamic>.from(data);
            debugPrint('  - Đã chuyển đổi thành Map: $messageData');
          } else if (data is String) {
            // Nếu data là string, thử parse JSON
            messageData = json.decode(data);
            debugPrint('  - Đã parse JSON: $messageData');
          } else {
            messageData = {};
            debugPrint('  - Không thể chuyển đổi dữ liệu');
          }
          
          // Đảm bảo có các trường cần thiết
          if (!messageData.containsKey('chatId') && messageData.containsKey('_id')) {
            messageData['chatId'] = messageData['_id'];
            debugPrint('  - Đã thêm chatId từ _id: ${messageData['_id']}');
          }
          
          // Thông báo cho tất cả các listeners
          debugPrint('  - Số lượng listeners: ${_messageListeners.length}');
          for (var listener in _messageListeners) {
            listener(messageData);
          }
        } catch (e) {
          debugPrint('❌ Lỗi khi xử lý tin nhắn socket: $e');
          debugPrint('  - Dữ liệu gốc: $data');
        }
      });
      
      // Theo dõi sự kiện mới: tin nhắn đã đọc
      _socket!.on('messageRead', (data) {
        debugPrint('👁️ Tin nhắn đã được đánh dấu đã đọc: $data');
      });
      
      // Sự kiện user online
      _socket!.on('user_online', (data) {
        debugPrint('🟢 User online: $data');
        if (data is String) {
          for (var listener in _userOnlineListeners) {
            listener(data);
          }
        }
      });

      // Sự kiện user offline
      _socket!.on('user_offline', (data) {
        debugPrint('🔴 User offline: $data');
        if (data is String) {
          for (var listener in _userOfflineListeners) {
            listener(data);
          }
        }
      });

      // Sự kiện đang nhập
      _socket!.on('typing', (data) {
        debugPrint('⌨️ User đang nhập: $data');
        if (data is String) {
          for (var listener in _typingListeners) {
            listener(data);
          }
        }
      });

      // Sự kiện dừng nhập
      _socket!.on('stop_typing', (data) {
        debugPrint('⏹️ User dừng nhập: $data');
        if (data is String) {
          for (var listener in _stopTypingListeners) {
            listener(data);
          }
        }
      });
      
      // Debug tất cả sự kiện socket
      _socket!.onAny((event, data) {
        debugPrint('🔄 Socket event: $event');
        debugPrint('  - Data: $data');
      });
    } catch (e) {
      debugPrint('❌ Lỗi khi khởi tạo socket: $e');
    }
  }

  void joinChat(String chatId) {
    if (!isConnected()) {
      debugPrint('Không thể tham gia chat: Socket chưa kết nối');
      connect().then((_) {
        if (isConnected()) {
          _emitJoinChat(chatId);
        }
      });
    } else {
      _emitJoinChat(chatId);
    }
  }
  
  void _emitJoinChat(String chatId) {
  if (!isConnected()) {
    debugPrint('❌ Không thể tham gia phòng: Socket chưa kết nối');
    return;
  }
  
  debugPrint('🔵 Đang tham gia phòng chat: $chatId');
  _socket!.emit('join_chat', chatId);
  
  // Kiểm tra xem đã join thành công chư
  }

  void leaveChat(String chatId) {
    if (isConnected()) {
      debugPrint('🟠 Rời khỏi phòng chat: $chatId');
      _socket!.emit('leaveChat', {'chatId': chatId});
    }
  }

  void addMessageListener(MessageListener listener) {
    if (!_messageListeners.contains(listener)) {
      _messageListeners.add(listener);
      debugPrint('🎧 Đã thêm message listener (total: ${_messageListeners.length})');
    }
  }

  void removeMessageListener(MessageListener listener) {
    _messageListeners.remove(listener);
    debugPrint('🛑 Đã xóa message listener (remaining: ${_messageListeners.length})');
  }

  void addDoctorOnlineListener(Function(String) listener) {
    _doctorOnlineListeners.add(listener);
  }

  void removeDoctorOnlineListener(Function(String) listener) {
    _doctorOnlineListeners.remove(listener);
  }

  void addDoctorOfflineListener(Function(String) listener) {
    _doctorOfflineListeners.add(listener);
  }

  void removeDoctorOfflineListener(Function(String) listener) {
    _doctorOfflineListeners.remove(listener);
  }

  void addUserOnlineListener(Function(String) listener) {
    _userOnlineListeners.add(listener);
  }

  void removeUserOnlineListener(Function(String) listener) {
    _userOnlineListeners.remove(listener);
  }

  void addUserOfflineListener(Function(String) listener) {
    _userOfflineListeners.add(listener);
  }

  void removeUserOfflineListener(Function(String) listener) {
    _userOfflineListeners.remove(listener);
  }

  void addTypingListener(Function(String) listener) {
    _typingListeners.add(listener);
  }

  void removeTypingListener(Function(String) listener) {
    _typingListeners.remove(listener);
  }

  void addStopTypingListener(Function(String) listener) {
    _stopTypingListeners.add(listener);
  }

  void removeStopTypingListener(Function(String) listener) {
    _stopTypingListeners.remove(listener);
  }

  // Phương thức gửi sự kiện đang nhập
  void emitTyping(String chatId) {
    if (isConnected()) {
      _socket!.emit('typing', {'chatId': chatId});
    }
  }

  // Phương thức gửi sự kiện dừng nhập
  void emitStopTyping(String chatId) {
    if (isConnected()) {
      _socket!.emit('stop_typing', {'chatId': chatId});
    }
  }

  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Ngắt kết nối socket');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _messageListeners.clear();
      _doctorOnlineListeners.clear();
      _doctorOfflineListeners.clear();
      _userOnlineListeners.clear();
      _userOfflineListeners.clear();
      _typingListeners.clear();
      _stopTypingListeners.clear();
    }
  }

  void emit(String event, dynamic data) {
    if (!isConnected()) {
      debugPrint('Không thể gửi tin nhắn: Socket chưa kết nối');
      throw Exception('Socket chưa kết nối');
    }
    
    debugPrint('Gửi sự kiện $event qua socket: $data');
    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    if (_socket != null) {
      _socket!.on(event, handler);
    }
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (_socket != null) {
      if (handler != null) {
        _socket!.off(event, handler);
      } else {
        _socket!.off(event);
      }
    }
  }
} 