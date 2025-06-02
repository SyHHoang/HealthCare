import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor.dart';
import '../../services/token_service.dart';
import '../../widgets/video_call_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  final Doctor doctor;
  const ConsultationHistoryScreen({super.key, required this.doctor});

  @override
  ConsumerState<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends ConsumerState<ConsultationHistoryScreen> {
  bool loading = false;
  String? error;
  Map<String, dynamic>? nextConsultation;
  List<dynamic> upcomingConsultations = [];
  List<dynamic> pastConsultations = [];
  bool showVideoCall = false;
  String? currentConsultationId;
  String activeTab = 'upcoming';
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  bool isFirstParticipant = false;

  @override
  void initState() {
    super.initState();
    loadConsultationHistory();
  }

  @override
  void dispose() {
    _cleanupVideoCall();
    super.dispose();
  }

  void _cleanupVideoCall() {
    debugPrint('=== CLEANING UP VIDEO CALL ===');
    
    // Stop local stream
    if (localStream != null) {
      localStream!.getTracks().forEach((track) => track.stop());
      localStream = null;
    }

    // Close peer connection
    if (peerConnection != null) {
      peerConnection!.close();
      peerConnection = null;
    }

    // Reset state
    setState(() {
      showVideoCall = false;
      currentConsultationId = null;
      isFirstParticipant = false;
    });

    debugPrint('=== VIDEO CALL CLEANUP COMPLETED ===');
  }

  Future<void> loadConsultationHistory() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://10.0.54.25:5000/api/consultationList/doctor/history'),
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

  bool isConsultationTime(String dateString) {
    final now = DateTime.now();
    final consultationTime = DateTime.parse(dateString);
    final endTime = consultationTime.add(const Duration(minutes: 30));
    return now.isAfter(consultationTime) && now.isBefore(endTime);
  }

  Future<bool> _checkAndRequestPermissions() async {
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        return false;
      }
    }

    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        return false;
      }
    }

    return true;
  }

  void startVideoCall(String consultationId) async {
    try {
      debugPrint('=== DOCTOR STARTING VIDEO CALL ===');
      debugPrint('Consultation ID: $consultationId');

      if (!consultationId.isNotEmpty) {
        debugPrint('Consultation ID is empty');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy ID cuộc hẹn'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final consultation = nextConsultation ?? 
          upcomingConsultations.firstWhere((c) => c['_id'] == consultationId, orElse: () => null);

      if (consultation == null) {
        debugPrint('Không tìm thấy thông tin cuộc hẹn');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy thông tin cuộc hẹn'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!isConsultationTime(consultation['consultationDate'])) {
        debugPrint('Không đúng thời gian tư vấn');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa đến thời gian tư vấn hoặc đã quá thời gian cho phép'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) {
        debugPrint('Không có quyền truy cập camera/microphone');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cần cấp quyền truy cập camera và microphone để sử dụng tính năng này'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Đảm bảo cleanup trước khi bắt đầu cuộc gọi mới
      _cleanupVideoCall();

      setState(() {
        currentConsultationId = consultationId;
        showVideoCall = true;
      });
    } catch (e) {
      debugPrint('Lỗi khi bắt đầu cuộc gọi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể bắt đầu cuộc gọi video: $e'),
          backgroundColor: Colors.red,
        ),
      );
      _cleanupVideoCall();
    }
  }

  void endVideoCall() {
    _cleanupVideoCall();
  }

  @override
  Widget build(BuildContext context) {
    if (showVideoCall && currentConsultationId != null) {
      return VideoCallWidget(
        consultationId: currentConsultationId!,
        isDoctor: true,
        onCallEnd: endVideoCall,
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch hẹn tư vấn'),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                activeTab = index == 0 ? 'upcoming' : 'history';
              });
            },
            tabs: const [
              Tab(
                icon: Icon(Icons.upcoming),
                text: 'Cuộc hẹn sắp tới',
              ),
              Tab(
                icon: Icon(Icons.history),
                text: 'Lịch sử cuộc hẹn',
              ),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                : TabBarView(
                    children: [
                      _buildUpcomingTab(),
                      _buildHistoryTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildUpcomingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nextConsultation != null) ...[
            const Text(
              'Cuộc tư vấn sắp tới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildConsultationCard(nextConsultation!, isNext: true),
            const SizedBox(height: 24),
          ],
          if (upcomingConsultations.isNotEmpty) ...[
            const Text(
              'Danh sách tư vấn sắp tới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...upcomingConsultations.map((c) => _buildConsultationCard(c)).toList(),
          ],
          if (nextConsultation == null && upcomingConsultations.isEmpty)
            _buildEmptyState(
              'Bạn chưa có cuộc tư vấn nào sắp tới',
              'Chưa có bệnh nhân nào đặt lịch tư vấn với bạn',
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lịch sử tư vấn',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (pastConsultations.isEmpty)
            _buildEmptyState(
              'Chưa có lịch sử tư vấn',
              'Bạn chưa có cuộc tư vấn nào đã hoàn thành',
            )
          else
            ...pastConsultations.map((c) => _buildConsultationCard(c, isPast: true)).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_busy, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> consultation, {bool isNext = false, bool isPast = false}) {
    final user = consultation['userId'] ?? {};
    final avatar = user['avatar'] ?? '';
    final fullname = user['fullname'] ?? '';
    final gender = user['gender'] == 'male' ? 'Nam' : 'Nữ';
    final age = user['age']?.toString() ?? '';
    final phone = user['phone'] ?? '';
    final date = consultation['consultationDate'] ?? '';
    final consultationId = consultation['_id'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPast ? Colors.grey.shade300 : Colors.blue.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                  child: avatar.isEmpty ? const Icon(Icons.person, size: 30) : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$gender, $age tuổi'),
                      Text('SĐT: $phone'),
                      Text('Thời gian: ${formatDate(date)}'),
                      if (isNext)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Còn ${formatCountdown(date)}',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isNext && !isPast)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.video_call),
                    label: const Text('Gọi video'),
                    onPressed: isConsultationTime(date)
                        ? () => startVideoCall(consultationId)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 