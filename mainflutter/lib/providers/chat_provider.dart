import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/chat_service.dart';
import '../services/socket_service.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final socketServiceProvider = Provider((ref) => SocketService.instance);

final chatListProvider = StateNotifierProvider<ChatListNotifier, AsyncValue<List<dynamic>>>((ref) {
  return ChatListNotifier(ref.watch(chatServiceProvider));
});

class ChatListNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final ChatService _chatService;

  ChatListNotifier(this._chatService) : super(const AsyncValue.loading()) {
    loadChats();
  }

  Future<void> loadChats() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _chatService.getUserChats());
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

final selectedChatProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final chatMessagesProvider = StateNotifierProvider.family<ChatMessagesNotifier, AsyncValue<List<dynamic>>, String>((ref, chatId) {
  return ChatMessagesNotifier(
    ref.watch(chatServiceProvider),
    ref.watch(socketServiceProvider),
    chatId,
  );
});

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  final ChatService _chatService;
  final SocketService _socketService;
  final String _chatId;

  ChatMessagesNotifier(this._chatService, this._socketService, this._chatId) : super(const AsyncValue.loading()) {
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
      await loadMessages();
    } catch (e) {
      rethrow;
    }
  }

  void _setupSocketListeners() {
    _socketService.joinChat(_chatId);
    _socketService.addMessageListener((message) {
      if (message['chatId'] == _chatId) {
        state.whenData((messages) {
          final updatedMessages = List<dynamic>.from(messages);
          updatedMessages.add(message);
          state = AsyncValue.data(updatedMessages);
        });
      }
    });
  }

  @override
  void dispose() {
    _socketService.leaveChat(_chatId);
    super.dispose();
  }
} 