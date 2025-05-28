import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import 'appointment_screen.dart';
import 'AIChatScreen.dart';
class ChatOptionScreen extends ConsumerWidget {
  final User user;
  
  const ChatOptionScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        AppBar(
          title: const Text('Trò chuyện'),
          centerTitle: true,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Chọn đối tượng để trò chuyện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Ô Chat với AI
                _buildChatOption(
                  context: context,
                  title: 'Chat với AI',
                  description: 'Trợ lý thông minh hỗ trợ 24/7, trả lời các câu hỏi về sức khỏe của bạn',
                  icon: Icons.smart_toy,
                  color: Colors.blue.shade100,
                  onTap: () {
                    _openAIChat(context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Ô Chat với bác sĩ
                _buildChatOption(
                  context: context,
                  title: 'Chat với bác sĩ',
                  description: 'Kết nối trực tiếp với bác sĩ chuyên khoa để được tư vấn y tế',
                  icon: Icons.medical_services,
                  color: Colors.green.shade100,
                  onTap: () {
                    _openDoctorChat(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatOption({
    required BuildContext context, 
    required String title, 
    required String description, 
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 60,
                color: Colors.black87,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAIChat(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => AIChatScreen(user: user),
      ),
    );
  }

  void _openDoctorChat(BuildContext context) {
    // Tạm thời hiển thị thông bá
    // TODO: Chuyển đến màn hình chat với bác sĩ
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => const AppointmentScreen(),
      ),
    );
  }
} 