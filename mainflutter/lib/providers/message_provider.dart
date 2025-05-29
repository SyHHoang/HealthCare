import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/message.dart';
import '../services/message_service.dart';
import '../services/token_service.dart';
import '../services/socket_service.dart';

// Provider mock tin nhắn để test, set true để bật chế độ test không cần server
final mockMessagesProvider = StateProvider<bool>((ref) => false);

final messageServiceProvider = Provider((ref) => MessageService());

final socketProvider = Provider<SocketService>((ref) {
  return SocketService.instance;
});

// Provider riêng để lưu trữ chatId hiện tại
final currentChatIdProvider = StateProvider<String?>((ref) => null);

// Provider lưu trữ thông tin chat đang được chọn
final selectedChatInfoProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

// Provider lưu trạng thái online của các bác sĩ
final onlineDoctorsProvider = StateNotifierProvider<OnlineDoctorsNotifier, Set<String>>((ref) {
  return OnlineDoctorsNotifier(ref.watch(socketProvider));
});

// Provider lưu trạng thái "đang nhập" của bác sĩ
final doctorTypingProvider = StateNotifierProvider<DoctorTypingNotifier, Map<String, bool>>((ref) {
  return DoctorTypingNotifier();
});

class DoctorTypingNotifier extends StateNotifier<Map<String, bool>> {
  DoctorTypingNotifier() : super({});
  
  void setDoctorTyping(String doctorId, bool isTyping) {
    state = {...state, doctorId: isTyping};
  }
  
  bool isDoctorTyping(String doctorId) {
    return state[doctorId] == true;
  }
}

class OnlineDoctorsNotifier extends StateNotifier<Set<String>> {
  final SocketService _socketService;

  OnlineDoctorsNotifier(this._socketService) : super({}) {
    _setupListeners();
    

  }

  void _setupListeners() {
    _socketService.connect().catchError((error) {
      debugPrint('Không thể kết nối socket, sử dụng chế độ offline: $error');
      // Chạy chế độ mạo dữ liệu

    });
    
    // Lắng nghe sự kiện bác sĩ online
    _socketService.addDoctorOnlineListener((doctorId) {
      state = {...state, doctorId};
      debugPrint('Bác sĩ $doctorId đã online');
    });
    
    // Lắng nghe sự kiện bác sĩ offline
    _socketService.addDoctorOfflineListener((doctorId) {
      final newState = {...state};
      newState.remove(doctorId);
      state = newState;
      debugPrint('Bác sĩ $doctorId đã offline');
    });
  }


  bool isDoctorOnline(String doctorId) {
    return state.contains(doctorId);
  }

  // Chuyển đổi trạng thái online của bác sĩ (for testing)
  void toggleDoctorOnline(String doctorId) {
    if (state.contains(doctorId)) {
      final newState = {...state};
      newState.remove(doctorId);
      state = newState;
    } else {
      state = {...state, doctorId};
    }
  }

  @override
  void dispose() {
    _socketService.removeDoctorOnlineListener((doctorId) {});
    _socketService.removeDoctorOfflineListener((doctorId) {});
    super.dispose();
  }
}

// ChatMessagesNotifier là một lớp kế thừa StateNotifier để quản lý trạng thái tin nhắn
class ChatMessagesNotifier extends StateNotifier<List<Message>> {
  final MessageService _messageService;
  final SocketService _socketService;
  String? _currentChatId;
  String? _currentDoctorId;
  bool _isInitialized = false;
  Timer? _mockMessageTimer;
  final bool _useMockMessages ;

  ChatMessagesNotifier(this._messageService, this._socketService, this._useMockMessages) : super([]) {
    // Khi khởi tạo, mở kết nối socket và đăng ký lắng nghe
  }


  
  
  
  void _processNewMessage(Map<String, dynamic> messageData) {
    try {
      // Xác định xem tin nhắn thuộc chat hiện tại không
      final chatId = messageData['chatId'];
      if (_currentChatId != null && chatId == _currentChatId) {
        // Kiểm tra xem tin nhắn đã tồn tại trong state chưa
        final messageId = messageData['_id'] ?? messageData['id'];
        final existingIndex = state.indexWhere((m) => m.id == messageId);
        
        if (existingIndex == -1) {  // Tin nhắn chưa tồn tại
          // Kiểm tra và xây dựng cấu trúc tin nhắn phù hợp
          Message newMessage;
          
          try {
            // Xử lý trường hợp sender là một object
            if (messageData.containsKey('sender') && messageData['sender'] is Map) {
              // Tạo bản sao để không ảnh hưởng đến dữ liệu gốc
              final Map<String, dynamic> formattedData = Map<String, dynamic>.from(messageData);
              
              // Trích xuất thông tin từ sender object
              final senderData = messageData['sender'] as Map<String, dynamic>;
              formattedData['sender'] = senderData['id'] ?? '';
              formattedData['senderModel'] = senderData['model'] ?? '';
              
              // Trích xuất thông tin từ receiver object nếu cần
              if (messageData.containsKey('receiver') && messageData['receiver'] is Map) {
                final receiverData = messageData['receiver'] as Map<String, dynamic>;
                formattedData['receiver'] = receiverData['id'] ?? '';
                formattedData['receiverModel'] = receiverData['model'] ?? '';
              }
              
              // Đảm bảo có ID tin nhắn
              if (!formattedData.containsKey('_id') && formattedData.containsKey('id')) {
                formattedData['_id'] = formattedData['id'];
              }
              
              debugPrint('Đã chuyển đổi dữ liệu tin nhắn: $formattedData');
              newMessage = Message.fromJson(formattedData);
            } else {
              // Cố gắng tạo tin nhắn từ dữ liệu nhận được
              newMessage = Message.fromJson(messageData);
            }
          } catch (e) {
            // Nếu có lỗi, tự tạo đối tượng tin nhắn với dữ liệu có sẵn
            debugPrint('Lỗi khi chuyển đổi dữ liệu tin nhắn: $e');
            
            // Xử lý trường sender có thể là object hoặc string
            String sender = '';
            String senderModel = '';
            
            if (messageData['sender'] is Map) {
              sender = messageData['sender']['id'] ?? '';
              senderModel = messageData['sender']['model'] ?? '';
            } else {
              sender = messageData['sender']?.toString() ?? '';
              senderModel = messageData['senderModel']?.toString() ?? '';
            }
            
            // Xử lý tương tự cho receiver
            String receiver = '';
            String receiverModel = '';
            
            if (messageData['receiver'] is Map) {
              receiver = messageData['receiver']['id'] ?? '';
              receiverModel = messageData['receiver']['model'] ?? '';
            } else {
              receiver = messageData['receiver']?.toString() ?? '';
              receiverModel = messageData['receiverModel']?.toString() ?? '';
            }
            
            newMessage = Message(
              id: messageData['_id']?.toString() ?? messageData['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
              sender: sender,
              senderModel: senderModel,
              receiver: receiver,
              receiverModel: receiverModel,
              content: messageData['content']?.toString() ?? '',
              isRead: messageData['isRead'] == true,
              createdAt: messageData['createdAt'] != null 
                ? DateTime.parse(messageData['createdAt'].toString()) 
                : DateTime.now(),
            );
          }
          
          // Cập nhật state với tin nhắn mới
          state = [newMessage, ...state];
          debugPrint('Đã thêm tin nhắn mới vào state: ${newMessage.content}');
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi xử lý tin nhắn mới: $e');
    }
  }
  
  
  // Hàm gửi tin nhắn giả cho chế độ demo
  void _startMockMessageResponses() {
    if (_mockMessageTimer != null) {
      _mockMessageTimer!.cancel();
    }
    
    // Tạo timer để gửi phản hồi giả sau 2-5 giây
    _mockMessageTimer = Timer(Duration(seconds: 2 + (DateTime.now().second % 4)), () {
      if (_currentChatId != null && _currentDoctorId != null) {
        final responses = [
          'Vâng, tôi hiểu vấn đề của bạn.',
          'Bạn cần uống thuốc đều đặn nhé.',
          'Hãy nghỉ ngơi nhiều và uống đủ nước.',
          'Tôi sẽ kê đơn thuốc cho bạn.',
          'Bạn cần đến khám trực tiếp để có chẩn đoán chính xác hơn.',
          'Đây có thể là triệu chứng của bệnh mãn tính.',
          'Không có gì đáng lo ngại, bạn chỉ cần nghỉ ngơi.',
          'Tình trạng của bạn cần theo dõi thêm.',
        ];
        
        // Chọn ngẫu nhiên một câu trả lời
        final response = responses[DateTime.now().millisecond % responses.length];
        
        // Tạo tin nhắn giả
        final mockMessage = {
          '_id': DateTime.now().millisecondsSinceEpoch.toString(),
          'chatId': _currentChatId,
          'sender': _currentDoctorId,
          'senderModel': 'Doctor',
          'receiver': 'user-id',
          'receiverModel': 'User',
          'content': response,
          'createdAt': DateTime.now().toIso8601String(),
          'isRead': false,
        };
        
        // Xử lý tin nhắn giả
        _processNewMessage(mockMessage);
      }
    });
  }
  
  // Tải lịch sử chat với bác sĩ
  Future<void> loadChatHistory(String doctorId) async {
    debugPrint('Bắt đầu tải lịch sử chat với bác sĩ: $doctorId');
    try {
      // Lưu ID bác sĩ hiện tại
      _currentDoctorId = doctorId;
      
      // Nếu đang trong một chat khác, rời khỏi phòng chat đó
      if (!_useMockMessages && _currentChatId != null) {
        _socketService.leaveChat(_currentChatId!);
      }
      
      if (_useMockMessages) {
        // Dùng dữ liệu mẫu cho chế độ demo
        _currentChatId = 'mock-chat-$doctorId';
        
        // Tạo một số tin nhắn mẫu
        final now = DateTime.now();
        state = [
          Message(
            id: '1',
            sender: 'user-id',
            senderModel: 'User',
            receiver: doctorId,
            receiverModel: 'Doctor',
            content: 'Xin chào bác sĩ!',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1, hours: 2)),
          ),
          Message(
            id: '2',
            sender: doctorId,
            senderModel: 'Doctor', 
            receiver: 'user-id',
            receiverModel: 'User',
            content: 'Chào bạn, tôi có thể giúp gì cho bạn?',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
          ),
          Message(
            id: '3',
            sender: 'user-id',
            senderModel: 'User',
            receiver: doctorId,
            receiverModel: 'Doctor',
            content: 'Tôi đang bị đau đầu và sốt.',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 40)),
          ),
          Message(
            id: '4',
            sender: doctorId,
            senderModel: 'Doctor',
            receiver: 'user-id',
            receiverModel: 'User',
            content: 'Bạn bị từ khi nào? Nhiệt độ là bao nhiêu?',
            isRead: true,
            createdAt: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
          ),
        ];
        
        return;
      }
      
      // Kiểm tra xem chat đã tồn tại chưa
      final existingChat = await _messageService.getChatByDoctorId(doctorId);
      
      if (existingChat != null) {
        debugPrint('Tìm thấy chat với ID: ${existingChat['_id']}');
        _currentChatId = existingChat['_id'];
        
        // Tham gia phòng chat qua socket
        _socketService.joinChat(_currentChatId!);
        
        // Tải tin nhắn từ chat đã có
        final messages = await _messageService.getMessagesByChatId(_currentChatId!);
        
        // Đảo ngược danh sách tin nhắn để hiển thị tin nhắn cũ ở trên, mới ở dưới
        state = messages.reversed.toList();
        
        // Đánh dấu tất cả tin nhắn là đã đọc
        await _messageService.markMessagesAsRead(_currentChatId!);
      } else {
        debugPrint('Không tìm thấy chat, tạo chat mới');
        // Tạo chat mới
        final newChat = await _messageService.createChat(doctorId);
        if (newChat != null) {
          _currentChatId = newChat['_id'];
          debugPrint('Đã tạo chat mới với ID: $_currentChatId');
          
          // Tham gia phòng chat qua socket
          _socketService.joinChat(_currentChatId!);
          
          state = [];
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi tải lịch sử chat: $e');
      rethrow;
    }
  }

  // Gửi tin nhắn đến bác sĩ
  Future<void> sendMessage(String content) async {
    if (_currentChatId == null || _currentDoctorId == null) {
      debugPrint('Không thể gửi tin nhắn: Không có chat hoặc bác sĩ hiện tại');
      throw Exception('Không thể gửi tin nhắn: Chưa kết nối với bác sĩ');
    }
    
    // Tạo tin nhắn của người dùng
    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: 'user-id',
      senderModel: 'User',
      receiver: _currentDoctorId!,
      receiverModel: 'Doctor',
      content: content,
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    // Thêm tin nhắn của người dùng vào state ngay lập tức để UI hiển thị nhanh
    state = [...state, userMessage];
    
    try {
      if (_useMockMessages) {
        // Trong chế độ demo, sau khi gửi tin nhắn, tạo phản hồi giả sau một vài giây
        _startMockMessageResponses();
        return;
      }
      
      debugPrint('Gửi tin nhắn qua socket đến chat: $_currentChatId');
      
      // Gửi tin nhắn qua socket thay vì API
      _socketService.emit('send_message', {
        'chatId': _currentChatId,
        'content': content
      });
      
      debugPrint('Đã gửi tin nhắn qua socket thành công');
    } catch (e) {
      // Nếu có lỗi, giữ nguyên tin nhắn tạm thời trong UI nhưng đánh dấu là đang gửi lại
      debugPrint('Lỗi khi gửi tin nhắn qua socket: $e');
      throw Exception('Không thể gửi tin nhắn: $e');
    }
  }

  // Đánh dấu tin nhắn là đã đọc
  
  @override
  void dispose() {
    // Rời khỏi phòng chat hiện tại nếu có
    if (!_useMockMessages && _currentChatId != null) {
      _socketService.leaveChat(_currentChatId!);
    }
    super.dispose();
  }
}

// Provider để truy cập trình quản lý tin nhắn
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, List<Message>>((ref) {
  final messageService = ref.watch(messageServiceProvider);
  final socketService = ref.watch(socketProvider);
  final useMockMessages = ref.watch(mockMessagesProvider);
  
  return ChatMessagesNotifier(messageService, socketService, useMockMessages);
});