import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/consultation.dart';
import '../services/consultation_service.dart';
import 'package:intl/intl.dart';
import 'video_call_screen.dart';

// Provider cho lịch sử cuộc hẹn
final consultationHistoryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final consultationService = ref.read(consultationServiceProvider);
  return consultationService.getConsultationHistory();
});

class ConsultationHistoryScreen extends ConsumerWidget {
  const ConsultationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        body: TabBarView(
          children: [
            _buildUpcomingConsultationsTab(ref),
            _buildPastConsultationsTab(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingConsultationsTab(WidgetRef ref) {
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
              return _buildConsultationCard(context, consultations[index], ref);
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

  Widget _buildPastConsultationsTab(WidgetRef ref) {
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
              return _buildConsultationCard(context, consultations[index], ref, isPast: true);
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

  Widget _buildConsultationCard(BuildContext context, Consultation consultation, WidgetRef ref, {bool isPast = false}) {
    final doctor = consultation.doctor;
    
    if (doctor == null) {
      return const SizedBox(); // Không hiển thị card nếu không có thông tin bác sĩ
    }
    
    final consultationDate = consultation.consultationDate;
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    
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
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Ngày',
                    formattedDate,
                    Icons.calendar_today,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    'Giờ',
                    formattedTime,
                    Icons.access_time,
                  ),
                ),
              ],
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
                    onPressed: () => _joinVideoCall(context, consultation, ref),
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

  Widget _buildInfoItem(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _canJoinVideoCall(Consultation consultation) {
    final now = DateTime.now();
    // Có thể vào phòng tư vấn trước 15 phút và sau 10 phút
    final start = consultation.consultationDate.subtract(const Duration(minutes: 15));
    final end = consultation.consultationDate.add(const Duration(minutes: 10));
    
    return now.isAfter(start) && now.isBefore(end);
  }

  void _joinVideoCall(BuildContext context, Consultation consultation, WidgetRef ref) {
    try {
      if (!_canJoinVideoCall(consultation)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chưa đến thời gian tư vấn hoặc đã quá thời gian cho phép'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            consultationId: consultation.id,
            isDoctor: false,
          ),
        ),
      ).then((_) {
        // Refresh lại danh sách khi quay lại màn hình
        ref.refresh(consultationHistoryProvider);
      });
    } catch (e) {
      debugPrint('Lỗi khi vào phòng tư vấn: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể vào phòng tư vấn: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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