import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor.dart';
import 'doctor_patient_list_screen.dart';

class DoctorChatOptionScreen extends ConsumerWidget {
  final Doctor doctor;
  
  const DoctorChatOptionScreen({
    super.key,
    required this.doctor,
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
                  description: 'Trợ lý thông minh hỗ trợ 24/7, trả lời các câu hỏi y tế và dùng để tra cứu',
                  icon: Icons.smart_toy,
                  color: Colors.blue.shade100,
                  onTap: () {
                    _openAIChat(context);
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Ô Chat với bệnh nhân
                _buildChatOption(
                  context: context,
                  title: 'Chat với bệnh nhân',
                  description: 'Xem danh sách các bệnh nhân của bạn và trò chuyện trực tiếp với họ',
                  icon: Icons.people,
                  color: Colors.green.shade100,
                  onTap: () {
                    _openPatientChat(context);
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
    // Tạm thời hiển thị thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chat với AI đang được phát triển'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // TODO: Chuyển đến màn hình chat AI cho bác sĩ
    // Navigator.push(
    //   context, 
    //   MaterialPageRoute(
    //     builder: (context) => DoctorAIChatScreen(doctor: doctor),
    //   ),
    // );
  }

  void _openPatientChat(BuildContext context) {
    Navigator.push(
      context, 
      MaterialPageRoute(
        builder: (context) => DoctorPatientListScreen(doctor: doctor),
      ),
    );
  }
} 