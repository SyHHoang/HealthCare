import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation.dart';
import '../services/consultation_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../widgets/video_call_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

// Provider cho lịch sử cuộc hẹn
final consultationHistoryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final consultationService = ref.read(consultationServiceProvider);
  return consultationService.getConsultationHistory();
});

class ConsultationHistoryScreen extends ConsumerStatefulWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  ConsumerState<ConsultationHistoryScreen> createState() => _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState extends ConsumerState<ConsultationHistoryScreen> {
  bool showVideoCall = false;
  String? currentConsultationId;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  bool isFirstParticipant = false;

  @override
  void initState() {
    super.initState();
    // Khởi tạo locale data cho DateFormat
    initializeDateFormatting('vi_VN', null);
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch hẹn tư vấn'),
          bottom: const TabBar(
            tabs: [
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
        body: showVideoCall && currentConsultationId != null
            ? VideoCallWidget(
                consultationId: currentConsultationId!,
                isDoctor: false,
                onCallEnd: () {
                  _cleanupVideoCall();
                },
              )
            : TabBarView(
                children: [
                  _buildUpcomingConsultationsTab(),
                  _buildPastConsultationsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildUpcomingConsultationsTab() {
    final consultationHistoryAsyncValue = ref.watch(consultationHistoryProvider);

    return consultationHistoryAsyncValue.when(
      data: (data) {
        final upcomingConsultations = data['upcomingConsultations'] as List<dynamic>;
        
        if (upcomingConsultations.isEmpty) {
          return _buildEmptyState('Không có cuộc hẹn sắp tới', 'Bạn chưa có lịch hẹn sắp tới nào');
        }
        
        // Chuyển đổi từ List<dynamic> sang List<Consultation>
        final consultations = upcomingConsultations
            .map((json) => Consultation.fromJson(json))
            .toList();
        
        return RefreshIndicator(
          onRefresh: () async {
            // Làm mới dữ liệu
            ref.refresh(consultationHistoryProvider);
          },
          child: ListView.builder(
            itemCount: consultations.length,
            itemBuilder: (context, index) {
              return _buildConsultationCard(context, consultations[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint('Lỗi khi lấy lịch sử cuộc hẹn: $error');
        debugPrint('Stack trace: $stackTrace');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(consultationHistoryProvider);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPastConsultationsTab() {
    final consultationHistoryAsyncValue = ref.watch(consultationHistoryProvider);

    return consultationHistoryAsyncValue.when(
      data: (data) {
        final pastConsultations = data['pastConsultations'] as List<dynamic>;
        
        if (pastConsultations.isEmpty) {
          return _buildEmptyState('Không có lịch sử cuộc hẹn', 'Bạn chưa có lịch sử cuộc hẹn nào');
        }
        
        // Chuyển đổi từ List<dynamic> sang List<Consultation>
        final consultations = pastConsultations
            .map((json) => Consultation.fromJson(json))
            .toList();
        
        return RefreshIndicator(
          onRefresh: () async {
            // Làm mới dữ liệu
            ref.refresh(consultationHistoryProvider);
          },
          child: ListView.builder(
            itemCount: consultations.length,
            itemBuilder: (context, index) {
              return _buildConsultationCard(context, consultations[index], isPast: true);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint('Lỗi khi lấy lịch sử cuộc hẹn: $error');
        debugPrint('Stack trace: $stackTrace');
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Đã xảy ra lỗi: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.refresh(consultationHistoryProvider);
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      },
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

  Widget _buildConsultationCard(BuildContext context, Consultation consultation, {bool isPast = false}) {
    final doctor = consultation.doctor;
    
    if (doctor == null) {
      return const SizedBox(); // Không hiển thị card nếu không có thông tin bác sĩ
    }
    
    final consultationDate = consultation.consultationDate.toLocal(); // Chuyển về múi giờ local
    final dateFormatter = DateFormat('dd/MM/yyyy', 'vi_VN');
    final timeFormatter = DateFormat('HH:mm', 'vi_VN');
    
    final formattedDate = dateFormatter.format(consultationDate);
    final formattedTime = timeFormatter.format(consultationDate);
    
    // Trạng thái và màu sắc
    final status = consultation.getStatus();
    final statusColor = consultation.getStatusColor();
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isPast ? Colors.grey.shade300 : statusColor.withOpacity(0.5),
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
                  radius: 24,
                  backgroundImage: doctor.avatar != null
                      ? NetworkImage(doctor.avatar!)
                      : null,
                  child: doctor.avatar == null
                      ? Text(
                          doctor.fullName[0],
                          style: const TextStyle(fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (doctor.specialty != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialty!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Thông tin thời gian
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$formattedDate lúc $formattedTime',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!isPast && _canJoinVideoCall(consultation))
                  OutlinedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('Vào phòng tư vấn'),
                    onPressed: () => _joinVideoCall(consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  )
                else if (isPast)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Đặt lại'),
                    onPressed: () => _rescheduleAppointment(context, consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _canJoinVideoCall(Consultation consultation) {
    final now = DateTime.now();
    final endTime = consultation.consultationDate.add(const Duration(minutes: 30));
    
    // Có thể vào phòng tư vấn trước 15 phút và trong khoảng thời gian tư vấn
    final start = consultation.consultationDate.subtract(const Duration(minutes: 15));
    
    return now.isAfter(start) && now.isBefore(endTime);
  }

  Future<bool> _checkAndRequestPermissions() async {
    // Kiểm tra quyền camera
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        return false;
      }
    }

    // Kiểm tra quyền microphone
    var microphoneStatus = await Permission.microphone.status;
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        return false;
      }
    }

    return true;
  }

  void _joinVideoCall(Consultation consultation) async {
    try {
      debugPrint('=== FLUTTER STARTING VIDEO CALL ===');
      debugPrint('Consultation ID: ${consultation.id}');
      
      if (!_canJoinVideoCall(consultation)) {
        debugPrint('Không đúng thời gian tư vấn');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa đến thời gian tư vấn hoặc đã quá thời gian cho phép'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Kiểm tra và yêu cầu quyền truy cập
      debugPrint('Đang kiểm tra quyền truy cập...');
      final hasPermissions = await _checkAndRequestPermissions();
      if (!hasPermissions) {
        debugPrint('Không có quyền truy cập camera/microphone');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cần cấp quyền truy cập camera và microphone để sử dụng tính năng này'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Đảm bảo cleanup trước khi bắt đầu cuộc gọi mới
      _cleanupVideoCall();

      debugPrint('Quyền truy cập đã được cấp, đang chuyển đến màn hình video call...');
      if (context.mounted) {
        setState(() {
          currentConsultationId = consultation.id;
          showVideoCall = true;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khi vào phòng tư vấn: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể vào phòng tư vấn: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _cleanupVideoCall();
    }
  }

  void _rescheduleAppointment(BuildContext context, Consultation consultation) {
    // TODO: Implement reschedule functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đặt lại lịch đang được phát triển'),
      ),
    );
  }
} 