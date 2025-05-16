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
class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  ChatMessagesNotifier() : super(const AsyncValue.loading()) {
    _loadMessages();
  }

  final MessageService _messageService = MessageService();
  final SocketService _socketService = SocketService.instance;

  Future<void> _loadMessages() async {
    try {
      final messages = await _messageService.getMessages();
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadChatHistory(String partnerId) async {
    try {
      state = const AsyncValue.loading();
      final messages = await _messageService.getChatHistory(partnerId);
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String content, {Map<String, dynamic>? image}) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không tìm thấy token');

      final message = await _messageService.sendMessageWithImage(content, image: image);
      
      state.whenData((messages) {
        state = AsyncValue.data([...messages, message]);
      });

      _socketService.emit('sendMessage', {
        'content': content,
        'image': image,
        'token': token,
      });
    } catch (e) {
      rethrow;
    }
  }

  void addMessage(Message message) {
    state.whenData((messages) {
      if (!messages.any((m) => m.id == message.id)) {
        state = AsyncValue.data([...messages, message]);
      }
    });
  }

  void updateMessageReadStatus(String messageId) {
    state.whenData((messages) {
      final updatedMessages = messages.map((message) {
        if (message.id == messageId) {
          return Message(
            id: message.id,
            sender: message.sender,
            senderModel: message.senderModel,
            receiver: message.receiver,
            receiverModel: message.receiverModel,
            content: message.content,
            isRead: true,
            createdAt: message.createdAt,
            image: message.image,
          );
        }
        return message;
      }).toList();
      state = AsyncValue.data(updatedMessages);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Provider để truy cập trình quản lý tin nhắn
final chatMessagesProvider = StateNotifierProvider<ChatMessagesNotifier, AsyncValue<List<Message>>>((ref) {
  return ChatMessagesNotifier();
});