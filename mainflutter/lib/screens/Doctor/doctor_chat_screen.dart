import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/doctor_chat_provider.dart';
import '../../models/message.dart';
import 'dart:async';
import '../../services/socket_service.dart';
import '../../services/token_service.dart';

class DoctorChatScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String? patientAvatar;
  final String chatId;

  const DoctorChatScreen({
    Key? key,
    required this.patientId,
    required this.patientName,
    this.patientAvatar,
    required this.chatId,
  }) : super(key: key);

  @override
  ConsumerState<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends ConsumerState<DoctorChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SocketService _socketService = SocketService.instance;
  bool _isLoading = true;
  bool _isTyping = false;
  bool _isPatientOnline = false;
  String _typingUserId = '';
  Timer? _typingTimer;
  Timer? _stopTypingTimer;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  Future<void> _setupChat() async {
    try {
      // Tham gia vào phòng chat
      _socketService.joinChat(widget.chatId);
      
      // Tải lịch sử chat
      await _loadChatHistory();
      
      // Thiết lập các listeners cho chat
      _setupChatListeners();
    } catch (e) {
      debugPrint('❌ Lỗi thiết lập chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi thiết lập chat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupChatListeners() {
    debugPrint('🔄 Đang thiết lập chat listeners...');
    debugPrint('  - Chat ID: ${widget.chatId}');
    debugPrint('  - Patient ID: ${widget.patientId}');
    
    // Thêm listener cho trạng thái online/offline của bệnh nhân
    _socketService.addUserOnlineListener((userId) {
      if (userId == widget.patientId) {
        setState(() {
          _isPatientOnline = true;
        });
      }
    });

    _socketService.addUserOfflineListener((userId) {
      if (userId == widget.patientId) {
        setState(() {
          _isPatientOnline = false;
        });
      }
    });

    // Thêm listener cho trạng thái đang nhập
    _socketService.addTypingListener((userId) {
      if (userId == widget.patientId) {
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
      if (userId == widget.patientId) {
        setState(() {
          _isTyping = false;
          _typingUserId = '';
        });
      }
    });
  }

  @override
  void dispose() {
    debugPrint('🛑 Đang cleanup DoctorChatScreen...');
    _messageController.dispose();
    _scrollController.dispose();
    
    // Rời khỏi chat room
    _socketService.leaveChat(widget.chatId);
    
    _typingTimer?.cancel();
    _stopTypingTimer?.cancel();
    super.dispose();
  }

  void _handleTyping() {
    // Gửi sự kiện đang nhập
    _socketService.emitTyping(widget.patientId);
    
    // Hủy timer cũ nếu có
    _stopTypingTimer?.cancel();
    
    // Tạo timer mới để gửi sự kiện dừng nhập sau 1 giây
    _stopTypingTimer = Timer(const Duration(seconds: 1), () {
      _socketService.emitStopTyping(widget.patientId);
    });
  }

  Future<void> _loadChatHistory() async {
    if (!mounted) return; // Kiểm tra widget còn mounted không
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      await ref.read(doctorChatMessagesProvider(widget.chatId).notifier).loadMessages();
      
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

    // Thêm tin nhắn tạm thời vào UI để hiển thị ngay lập tức
    final tempMessage = {
      '_id': 'temp-${DateTime.now().millisecondsSinceEpoch}',
      'sender': 'doctor-temp',
      'senderModel': 'Doctor',
      'receiver': widget.patientId,
      'receiverModel': 'User',
      'content': content,
      'createdAt': DateTime.now().toIso8601String(),
      'chatId': widget.chatId,
    };

    // Thêm tin nhắn tạm thời vào state
    ref.read(doctorChatMessagesProvider(widget.chatId).notifier).state.whenData((messages) {
      final updatedMessages = List<dynamic>.from(messages);
      updatedMessages.add(tempMessage);
      ref.read(doctorChatMessagesProvider(widget.chatId).notifier).state = AsyncValue.data(updatedMessages);
      
      // Xóa nội dung trong ô nhập và cuộn xuống dưới
      _messageController.clear();
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });

    try {
      // Gửi tin nhắn qua socket
      await ref.read(doctorChatMessagesProvider(widget.chatId).notifier).sendMessage(content);
      
      // Tin nhắn thực sẽ được cập nhật thông qua socket listener
    } catch (e) {
      // Hiển thị thông báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể gửi tin nhắn: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(doctorChatMessagesProvider(widget.chatId));
    
    // Lắng nghe thay đổi tin nhắn mới để cuộn xuống dưới nếu cần
    ref.listen(doctorChatMessagesProvider(widget.chatId), (previous, next) {
      if (previous != null && next is AsyncData && previous is AsyncData) {
        if ((next.value?.length ?? 0) > (previous.value?.length ?? 0)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
        }
      }
    });
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.patientAvatar != null 
                  ? NetworkImage(widget.patientAvatar!)
                  : null,
              child: widget.patientAvatar == null
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.patientName, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isPatientOnline ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isPatientOnline ? 'Đang trực tuyến' : 'Ngoại tuyến',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isPatientOnline ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (_isTyping && _typingUserId == widget.patientId)
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
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Có lỗi xảy ra: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadChatHistory,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _buildEmptyChat();
                } else {
                  return _buildMessageList(messages);
                }
              },
            ),
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
              _messageController.text = 'Xin chào, tôi là bác sĩ của bạn. Tôi có thể giúp gì cho bạn?';
              _sendMessage();
            },
            child: const Text('Bắt đầu trò chuyện'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<dynamic> messageData) {
    final messages = messageData.map((data) {
      // Nếu là tin nhắn tạm thời (vừa gửi)
      if (data['_id']?.toString().startsWith('temp-') == true) {
        return Message(
          id: data['_id'] ?? 'temp',
          sender: 'doctor-temp',
          senderModel: 'Doctor',
          receiver: widget.patientId,
          receiverModel: 'User',
          content: data['content'] ?? '',
          isRead: false,
          createdAt: data['createdAt'] != null 
              ? DateTime.parse(data['createdAt']) 
              : DateTime.now(),
        );
      }
      // Tin nhắn bình thường
      return Message.fromJson(data as Map<String, dynamic>);
    }).toList();
    
    final DateTime now = DateTime.now();
    String? currentDay;
    
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
      
      // Phân biệt tin nhắn của bệnh nhân và bác sĩ
      // Tin nhắn của bác sĩ (Doctor) là tin nhắn của mình
      final isMe = message.senderModel == 'Doctor';
      
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
      children: messageWidgets,
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
              onChanged: (_) => _handleTyping(),
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
                color: isMe 
                    ? Theme.of(context).primaryColor
                    : Colors.grey[300],
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