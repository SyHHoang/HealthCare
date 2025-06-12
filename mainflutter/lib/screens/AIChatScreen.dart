import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/gemini_service.dart';

class AIChatScreen extends ConsumerStatefulWidget {
  final dynamic user; // Có thể là User hoặc Doctor

  const AIChatScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      debugPrint('=== INITIALIZING CHAT ===');

      // Kiểm tra .env file
      _checkEnvFile();

      await GeminiService.initializeChat();
      debugPrint('✅ Chat initialized successfully');

      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin chào! Tôi là trợ lý y tế AI. Tôi có thể giúp bạn tìm hiểu thông tin về sức khỏe, bệnh tật và các vấn đề y tế khác. Bạn cần tôi giúp gì không?',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });
    } catch (e) {
      debugPrint('❌ Error initializing chat: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: 'Xin chào! Tôi là trợ lý y tế AI. Hiện tại có một số vấn đề kết nối, nhưng tôi vẫn sẽ cố gắng trả lời câu hỏi của bạn. Bạn cần tôi giúp gì không?\n\n(Lỗi kết nối: $e)\n\nNhấn icon 🐛 để test kết nối.',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });
    }
  }

  void _checkEnvFile() {
    debugPrint('=== CHECKING ENV FILE ===');
    final baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      debugPrint('❌ BASE_URL not found in .env file');
      debugPrint('Available env vars: ${dotenv.env.keys.toList()}');
    } else {
      debugPrint('✅ BASE_URL found: $baseUrl');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Clear chat history khi đóng screen
    GeminiService.clearChatHistory().catchError((e) {
      debugPrint('Error clearing chat history: $e');
    });
    super.dispose();
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
    if (_messageController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Lấy chat history trước khi thêm tin nhắn mới
    final chatHistory = _messages.map((msg) => msg.toMap()).toList();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        sender: 'user',
        time: DateTime.now(),
      ));
      _isLoading = true;
    });

    // Scroll xuống sau khi thêm tin nhắn user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      debugPrint('=== SENDING MESSAGE ===');
      debugPrint('User message: $userMessage');
      debugPrint('Chat history length: ${chatHistory.length}');

      final response = await GeminiService.generateResponse(userMessage, chatHistory);

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            sender: 'bot',
            time: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      debugPrint('❌ Error sending message: $e');
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Xin lỗi, đã xảy ra lỗi khi kết nối với trợ lý AI. Vui lòng thử lại sau.\n\nLỗi: $e',
            sender: 'bot',
            time: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Scroll xuống sau khi có phản hồi
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trợ lý Y tế AI'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _checkEnvFile();
              setState(() {
                _messages.add(ChatMessage(
                  text: 'Debug Info:\n'
                      'BASE_URL: ${dotenv.env['BASE_URL'] ?? 'Not found'}\n'
                      'GeminiService URL: ${GeminiService.baseUrl}\n'
                      'Available env vars: ${dotenv.env.keys.toList()}',
                  sender: 'bot',
                  time: DateTime.now(),
                ));
              });
            },
            tooltip: 'Debug Info',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testConnection,
            tooltip: 'Test kết nối',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              try {
                setState(() {
                  _isLoading = true;
                });
                await GeminiService.initializeChat();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('Kết nối lại thành công!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Lỗi kết nối: $e'),
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
            },
            tooltip: 'Kết nối lại',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildTypingIndicator();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: 'Nhập câu hỏi của bạn...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: _isLoading ? Colors.grey.shade100 : Colors.white,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _isLoading ? Colors.grey.shade400 : const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? const Color(0xFF4CAF50) : Colors.white,
                borderRadius: BorderRadius.circular(15).copyWith(
                  bottomRight: message.isUser ? const Radius.circular(5) : const Radius.circular(15),
                  bottomLeft: message.isUser ? const Radius.circular(15) : const Radius.circular(5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xFF333333),
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                _formatTime(message.time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15).copyWith(
              bottomLeft: const Radius.circular(5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTypingDot(0),
              const SizedBox(width: 4),
              _buildTypingDot(200),
              const SizedBox(width: 4),
              _buildTypingDot(400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFF4CAF50),
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Method để test kết nối
  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('=== TESTING CONNECTION ===');

      // Test 1: Kiểm tra BASE_URL
      final baseUrl = GeminiService.baseUrl;
      debugPrint('Base URL: $baseUrl');

      setState(() {
        _messages.add(ChatMessage(
          text: 'Đang test kết nối...\nBase URL: $baseUrl',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });

      // Test 2: Test initialize
      await GeminiService.initializeChat();

      setState(() {
        _messages.add(ChatMessage(
          text: '✅ Initialize thành công!',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });

      // Test 3: Test gửi tin nhắn đơn giản
      final response = await GeminiService.generateResponse('Xin chào', []);

      setState(() {
        _messages.add(ChatMessage(
          text: '✅ Test kết nối thành công!\nPhản hồi: $response',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });
    } catch (e) {
      debugPrint('❌ Test connection failed: $e');
      setState(() {
        _messages.add(ChatMessage(
          text: '❌ Test kết nối thất bại:\n$e\n\nVui lòng kiểm tra:\n1. Server có đang chạy?\n2. IP address có đúng?\n3. Kết nối mạng có ổn định?',
          sender: 'bot',
          time: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }
}

class ChatMessage {
  final String text;
  final String sender; // 'user' hoặc 'bot'
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.time,
  });

  bool get isUser => sender == 'user';

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'time': time.toIso8601String(),
    };
  }
}