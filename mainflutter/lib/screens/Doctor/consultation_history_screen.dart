import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConsultationHistoryScreen extends StatefulWidget {
  final Doctor doctor;
  const ConsultationHistoryScreen({super.key, required this.doctor});

  @override
  State<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends State<ConsultationHistoryScreen> {
  bool loading = false;
  String? error;
  Map<String, dynamic>? nextConsultation;
  List<dynamic> upcomingConsultations = [];
  List<dynamic> pastConsultations = [];

  @override
  void initState() {
    super.initState();
    loadConsultationHistory();
  }

  Future<void> loadConsultationHistory() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/consultationList/doctor/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            nextConsultation = data['data']['nextConsultation'];
            upcomingConsultations = data['data']['upcomingConsultations'] ?? [];
            pastConsultations = data['data']['pastConsultations'] ?? [];
          });
        } else {
          setState(() {
            error = data['message'] ?? 'Không thể tải lịch sử tư vấn.';
          });
        }
      } else {
        setState(() {
          error = 'Không thể tải lịch sử tư vấn. Vui lòng thử lại sau.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải lịch sử tư vấn: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  String formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final day = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return '$time - $day';
  }

  String formatCountdown(String dateString) {
    final now = DateTime.now();
    final target = DateTime.parse(dateString);
    final diff = target.difference(now);
    if (diff.inSeconds <= 0) return 'Đã đến giờ';
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    String result = '';
    if (days > 0) result += '$days ngày ';
    if (hours > 0) result += '$hours giờ ';
    if (minutes > 0) result += '$minutes phút';
    return result.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử tư vấn')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Next Consultation
                      if (nextConsultation != null) ...[
                        Text('Cuộc tư vấn sắp tới', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        _buildConsultationCard(nextConsultation!, isNext: true),
                        const SizedBox(height: 24),
                      ],
                      // Upcoming Consultations
                      if (upcomingConsultations.isNotEmpty) ...[
                        Text('Các cuộc tư vấn sắp tới', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ...upcomingConsultations.map((c) => _buildConsultationCard(c)).toList(),
                        const SizedBox(height: 24),
                      ],
                      // Past Consultations
                      if (pastConsultations.isNotEmpty) ...[
                        Text('Các cuộc tư vấn đã qua', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        ...pastConsultations.map((c) => _buildConsultationCard(c)).toList(),
                        const SizedBox(height: 24),
                      ],
                      // Empty State
                      if (nextConsultation == null && upcomingConsultations.isEmpty && pastConsultations.isEmpty)
                        const Center(
                          child: Column(
                            children: [
                              SizedBox(height: 40),
                              Text('Bạn chưa có cuộc tư vấn nào', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Chưa có bệnh nhân nào đặt lịch tư vấn với bạn', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation, {bool isNext = false}) {
    final user = consultation['userId'] ?? {};
    final avatar = user['avatar'] ?? '';
    final fullname = user['fullname'] ?? '';
    final gender = user['gender'] == 'male' ? 'Nam' : 'Nữ';
    final age = user['age']?.toString() ?? '';
    final phone = user['phone'] ?? '';
    final date = consultation['consultationDate'] ?? '';
    return Card(
      color: isNext ? Colors.blue[50] : null,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child: avatar.isEmpty ? const Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullname, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('$gender, $age tuổi'),
                  Text('SĐT: $phone'),
                  Text('Thời gian: ${formatDate(date)}'),
                  if (isNext)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Còn ${formatCountdown(date)}', style: const TextStyle(color: Colors.blue)),
                    ),
                ],
              ),
            ),
            if (isNext)
              IconButton(
                icon: const Icon(Icons.video_call, color: Colors.blue),
                onPressed: () {
                  // TODO: Thực hiện chức năng gọi video
                },
              ),
          ],
        ),
      ),
    );
  }
} 