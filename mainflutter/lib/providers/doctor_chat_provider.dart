import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/doctor_chat_service.dart';
import '../services/socket_service.dart';
import 'package:flutter/foundation.dart';

final doctorChatServiceProvider = Provider((ref) => DoctorChatService());

final socketServiceProvider = Provider((ref) => SocketService.instance);

final doctorChatListProvider = StateNotifierProvider<DoctorChatListNotifier, AsyncValue<List<dynamic>>>((ref) {
  return DoctorChatListNotifier(ref.watch(doctorChatServiceProvider));
});

class DoctorChatListNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final DoctorChatService _chatService;

  DoctorChatListNotifier(this._chatService) : super(const AsyncValue.loading()) {
    loadChats();
  }

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _chatService.getDoctorChats());
  }

  Future<void> refresh() async {
    await loadChats();
  }

  void updateLastMessage(String chatId, Map<String, dynamic> message) {
    state.whenData((chats) {
      final index = chats.indexWhere((chat) => chat['_id'] == chatId);
      if (index != -1) {
        final updatedChats = List<dynamic>.from(chats);
        updatedChats[index] = {
          ...updatedChats[index],
          'lastMessage': {
            'content': message['content'],
            'timestamp': message['createdAt'],
          },
        };
        state = AsyncValue.data(updatedChats);
      }
    });
  }
}

final selectedDoctorChatProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final doctorChatMessagesProvider = StateNotifierProvider.family<DoctorChatMessagesNotifier, AsyncValue<List<dynamic>>, String>((ref, chatId) {
  return DoctorChatMessagesNotifier(
    ref.watch(doctorChatServiceProvider),
    ref.watch(socketServiceProvider),
    chatId,
  );
});

class DoctorChatMessagesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final DoctorChatService _chatService;
  final SocketService _socketService;
  final String _chatId;

  DoctorChatMessagesNotifier(this._chatService, this._socketService, this._chatId) : super(const AsyncValue.loading()) {
    loadMessages();
    _setupSocketListeners();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _chatService.getChatMessages(_chatId));
  }

  Future<void> sendMessage(String content) async {
    try {
      await _chatService.sendMessage(_chatId, content);
    } catch (e) {
      debugPrint('Lỗi khi gửi tin nhắn: $e');
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socketService.joinChat(_chatId);
    _socketService.addMessageListener(_handleNewMessage);
  }
  
  void _handleNewMessage(dynamic data) {
    try {
      if (data['chatId'] == _chatId) {
        final Map<String, dynamic> messageData = data is Map 
            ? Map<String, dynamic>.from(data) 
            : {};
            
        debugPrint('===================================================================================');
        debugPrint('Nhận tin nhắn mới qua socket trong chat $_chatId');
        debugPrint('Nội dung tin nhắn: ${messageData['content']}');
        debugPrint('Người gửi: ${messageData['sender']}');
        debugPrint('Model người gửi: ${messageData['sender']['role']}');
        
        state.whenData((messages) {
          final messageExists = messages.any((msg) {
            final msgId = msg['_id'] ?? msg['id'];
            final newMsgId = messageData['_id'] ?? messageData['id'];
            return msgId == newMsgId;
          });
          
          if (!messageExists) {
            final updatedMessages = List<dynamic>.from(messages);
            updatedMessages.add(messageData);
            
            updatedMessages.sort((a, b) {
              final timeA = DateTime.parse(a['createdAt']);
              final timeB = DateTime.parse(b['createdAt']);
              return timeA.compareTo(timeB);
            });
            
            state = AsyncValue.data(updatedMessages);
            debugPrint('Đã thêm tin nhắn mới, tổng số tin nhắn: ${updatedMessages.length}');
          } else {
            debugPrint('Tin nhắn đã tồn tại, bỏ qua');
          }
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi xử lý tin nhắn mới: $e');
    }
  }

  @override
  void dispose() {
    _socketService.leaveChat(_chatId);
    _socketService.removeMessageListener(_handleNewMessage);
    super.dispose();
  }
} 