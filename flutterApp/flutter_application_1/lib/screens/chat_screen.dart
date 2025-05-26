import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/message_provider.dart';
import '../models/message.dart';
import 'dart:async';
import 'dart:math';
import '../services/socket_service.dart';
import '../services/message_service.dart';
import '../services/token_service.dart';
import '../providers/auth_provider.dart';

// Provider để lưu trữ userId hiện tại
final userIdProvider = StateProvider<String?>((ref) => null);

class ChatScreen extends ConsumerStatefulWidget {
  final String partnerId;
  final String partnerName;
  final String? partnerAvatar;

  const ChatScreen({
    Key? key,
    required this.partnerId,
    required this.partnerName,
    this.partnerAvatar,
  }) : super(key: key);

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService.instance;
  final MessageService _messageService = MessageService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isDoctorOnline = false;
  String _typingUserId = '';
  Timer? _typingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    _loadChatAndSetupListeners();
  }

  Future<void> _loadChatAndSetupListeners() async {
    try {
      // Tham gia chat và tải lịch sử
      _socketService.joinChat(widget.partnerId);
      await _loadChatHistory();
      _setupSocketListeners();
    } catch (e) {
      debugPrint('❌ Lỗi khi tải chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupSocketListeners() {
    debugPrint('🔄 Đang thiết lập socket listeners...');
    debugPrint('  - Partner ID: ${widget.partnerId}');
    
    // Thêm listener cho tin nhắn mới
    _socketService.addMessageListener((data) {
      debugPrint('📩 Nhận tin nhắn mới trong ChatScreen:');
      debugPrint('  - Dữ liệu: $data');
      debugPrint('  - Chat ID: ${data['chatId']}');
      debugPrint('  - Partner ID: ${widget.partnerId}');
      debugPrint('  - Sender: ${data['sender']}');
      debugPrint('  - Content: ${data['content']}');
      
      try {
        // Chuyển đổi dữ liệu thành Map để xử lý
        final Map<String, dynamic> messageData = data is Map 
            ? Map<String, dynamic>.from(data) 
            : {};
        
        // Kiểm tra xem tin nhắn có thuộc chat hiện tại không
        if (messageData['chatId'] == widget.partnerId || 
            messageData['sender'] == widget.partnerId || 
            messageData['receiver'] == widget.partnerId) {
          debugPrint('✅ Tin nhắn thuộc chat hiện tại');
          setState(() {
            _messages.add(messageData);
          });
          _scrollToBottom();
        } else {
          debugPrint('❌ Tin nhắn không thuộc chat hiện tại');
        }
      } catch (e) {
        debugPrint('❌ Lỗi khi xử lý tin nhắn trong ChatScreen: $e');
        debugPrint('  - Dữ liệu gốc: $data');
      }
    });
    
    // Thêm listener cho trạng thái online/offline của bác sĩ
    _socketService.addDoctorOnlineListener((doctorId) {
      if (doctorId == widget.partnerId) {
        setState(() {
          _isDoctorOnline = true;
        });
      }
    });

    _socketService.addDoctorOfflineListener((doctorId) {
      if (doctorId == widget.partnerId) {
        setState(() {
          _isDoctorOnline = false;
        });
      }
    });

    // Thêm listener cho trạng thái đang nhập
    _socketService.addTypingListener((userId) {
      if (userId == widget.partnerId) {
        setState(() {
          _isTyping = true;
          _typingUserId = userId;
        });
        // Tự động tắt trạng thái đang nhập sau 3 giây
        _typingTimer?.cancel();
        _typingTimer = Timer(const Duration(seconds: 3), () {
          setState(() {
            _isTyping = false;
            _typingUserId = '';
          });
        });
      }
    });

    _socketService.addStopTypingListener((userId) {
      if (userId == widget.partnerId) {
        setState(() {
          _isTyping = false;
          _typingUserId = '';
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🛑 Đang cleanup ChatScreen...');
    _messageController.dispose();
    _scrollController.dispose();
    
    // Xóa message listener
    _socketService.removeMessageListener((data) {
      debugPrint('📩 Xóa message listener');
      try {
        final Map<String, dynamic> messageData = data is Map 
            ? Map<String, dynamic>.from(data) 
            : {};
        
        if (messageData['chatId'] == widget.partnerId) {
          setState(() {
            _messages.remove(messageData);
          });
          _scrollToBottom();
        }
      } catch (e) {
        debugPrint('❌ Lỗi khi xử lý tin nhắn trong dispose: $e');
      }
    });
    
    _typingTimer?.cancel();
    _stopTypingTimer?.cancel();
    super.dispose();
  }

  void _handleTyping() {
    // Gửi sự kiện đang nhập
    _socketService.emitTyping(widget.partnerId);
    
    // Hủy timer cũ nếu có
    _stopTypingTimer?.cancel();
    
    // Tạo timer mới để gửi sự kiện dừng nhập sau 1 giây
    _stopTypingTimer = Timer(const Duration(seconds: 1), () {
      _socketService.emitStopTyping(widget.partnerId);
    });
  }

  Future<void> _loadChatHistory() async {
    if (!mounted) return; // Kiểm tra widget còn mounted không
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Bọc trong Future.microtask để tránh lỗi cập nhật state trong build
      await Future.microtask(() async {
        return await ref.read(chatMessagesProvider.notifier).loadChatHistory(widget.partnerId);
      });
      
      // Cuộn xuống dưới sau khi tải tin nhắn
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear();
    
    try {
      await ref.read(chatMessagesProvider.notifier).sendMessage(content);
      
      // Cuộn xuống dưới sau khi gửi tin nhắn
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể gửi tin nhắn: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider);
    final isDoctorOnline = ref.watch(onlineDoctorsProvider.notifier).isDoctorOnline(widget.partnerId);
    
    // Thêm các điều khiển debug khi ở chế độ phát triển
    const bool isDevMode = false; // Đặt thành true để bật chế độ phát triển
    
    // Cuộn xuống khi có tin nhắn mới, sử dụng addPostFrameCallback để tránh lỗi
  
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.partnerAvatar != null 
                  ? NetworkImage(widget.partnerAvatar!)
                  : null,
              child: widget.partnerAvatar == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.partnerName, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDoctorOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isDoctorOnline ? 'Đang trực tuyến' : 'Ngoại tuyến',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDoctorOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (_isTyping && _typingUserId != widget.partnerId)
                  const Text(
                    'Đang nhập...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          // Thêm nút chuyển đổi chế độ demo khi ở chế độ phát triển
          if (isDevMode)
            IconButton(
              icon: Icon(
                ref.watch(mockMessagesProvider) ? Icons.cloud_off : Icons.cloud_done,
                color: ref.watch(mockMessagesProvider) ? Colors.red : Colors.green,
              ),
              onPressed: () {
                ref.read(mockMessagesProvider.notifier).state = !ref.watch(mockMessagesProvider);
                // Tải lại lịch sử chat sau khi chuyển đổi chế độ
                _loadChatHistory();
              },
              tooltip: ref.watch(mockMessagesProvider) ? 'Đang sử dụng dữ liệu mẫu' : 'Đang sử dụng server thật',
            ),
          
          // Thêm nút mô phỏng bác sĩ đang nhập khi ở chế độ phát triển
          if (isDevMode)
            IconButton(
              icon: const Icon(Icons.keyboard),
              onPressed: () {
                final isTyping = ref.read(doctorTypingProvider.notifier).isDoctorTyping(widget.partnerId);
                ref.read(doctorTypingProvider.notifier).setDoctorTyping(widget.partnerId, !isTyping);
              },
            ),
            
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Khu vực tin nhắn
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMessageList(messages),
          ),

          // Khung nhập tin nhắn
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có tin nhắn nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _messageController.text = 'Xin chào bác sĩ, tôi cần tư vấn!';
              _sendMessage();
            },
            child: const Text('Bắt đầu trò chuyện'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    final DateTime now = DateTime.now();
    String? currentDay;
    
    // Lấy userId hiện tại để so sánh
    final currentUserId = ref.read(userIdProvider);
    debugPrint('Current User ID: $currentUserId'); // Debug để kiểm tra
    
    // Xây dựng danh sách tin nhắn có phân nhóm theo ngày
    List<Widget> messageWidgets = [];
    
    for (int i = 0; i < messages.length; i++) {
      final message = messages[i];
      final messageDay = '${message.createdAt.day}/${message.createdAt.month}/${message.createdAt.year}';
      
      // Thêm separator hiển thị ngày nếu khác ngày hiện tại hoặc tin nhắn đầu tiên
      if (currentDay != messageDay) {
        currentDay = messageDay;
        
        // Xác định nhãn thời gian phù hợp (Hôm nay, Hôm qua, hoặc ngày cụ thể)
        String dayLabel;
        if (message.createdAt.day == now.day && 
            message.createdAt.month == now.month && 
            message.createdAt.year == now.year) {
          dayLabel = 'Hôm nay';
        } else if (message.createdAt.day == now.day - 1 && 
                   message.createdAt.month == now.month && 
                   message.createdAt.year == now.year) {
          dayLabel = 'Hôm qua';
        } else {
          dayLabel = messageDay;
        }
        
        messageWidgets.add(_buildDaySeparator(dayLabel));
      }
      
      // Debug thông tin tin nhắn
      // debugPrint('Message Info: ${message.content}');
      // debugPrint('Sender Model: ${message.senderModel}');
      // debugPrint('Sender ID: ${message.sender}');
      // debugPrint('Current User ID: $currentUserId');
      
      // Phân biệt tin nhắn của user và doctor
      // Nếu senderModel là 'User' và sender trùng với currentUserId thì là tin nhắn của mình (user)
      // Ngược lại là tin nhắn của doctor
      final isMe = message.senderModel== 'User' ;
      //debugPrint('Is Me: $isMe');
      // Kiểm tra nếu cần hiển thị thời gian giữa các tin nhắn
      bool showTime = true;
      if (i < messages.length - 1) {
        final nextMessage = messages[i + 1];
        final timeDiff = nextMessage.createdAt.difference(message.createdAt).inMinutes;
        if (timeDiff < 5 && nextMessage.senderModel == message.senderModel && nextMessage.sender == message.sender) {
          showTime = false;
        }
      }
      
      messageWidgets.add(
        _MessageBubble(
          message: message,
          isMe: isMe,
          showTime: showTime,
        ),
      );
    }
    
    return ListView(
      
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      children: messageWidgets.reversed.toList(), // Đảo ngược danh sách để hiển thị mới nhất ở dưới cùng
    );
  }

  Widget _buildDaySeparator(String day) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final authState = ref.watch(authProvider);
    final isCurrentUser = message['senderId'] == authState.userId;
    
    // debugPrint('Message: $message');
    // debugPrint('Message Sender ID: ${message['senderId']}');
    // debugPrint('Current User ID: ${authState.userId}');
    // debugPrint('Is Current User: $isCurrentUser');

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isCurrentUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message['content'] ?? '',
          style: TextStyle(
            color: isCurrentUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final bool showTime;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showTime = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? Theme.of(context).primaryColor : Colors.grey[300],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomRight: isMe ? const Radius.circular(0) : null,
                  bottomLeft: !isMe ? const Radius.circular(0) : null,
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (showTime)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({Key? key}) : super(key: key);

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.33;
            final offset = sin((_controller.value - delay) * 2 * 3.14);
            return Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                shape: BoxShape.circle,
              ),
              transform: Matrix4.translationValues(0, offset * 4, 0),
            );
          }),
        );
      },
    );
  }
} 