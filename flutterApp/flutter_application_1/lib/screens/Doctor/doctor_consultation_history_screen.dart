import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/consultation.dart';
import '../../models/doctor.dart';
import '../../models/user.dart';
import 'package:intl/intl.dart';

// Provider cho lịch sử cuộc hẹn của bác sĩ
final doctorConsultationHistoryProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  // Gọi API để lấy lịch sử cuộc hẹn của bác sĩ
  // TODO: Implement doctorConsultationService
  final doctorConsultationService = ref.read(doctorConsultationServiceProvider);
  return doctorConsultationService.getDoctorConsultationHistory();
});

// Provider cho service
final doctorConsultationServiceProvider = Provider<DoctorConsultationService>((ref) {
  return DoctorConsultationService();
});

class DoctorConsultationService {
  static const String _baseUrl = 'http://localhost:5000/api';

  Future<Map<String, dynamic>> getDoctorConsultationHistory() async {
    try {
      // TODO: Implement real API call
      // Đây là dữ liệu mẫu, cần được thay thế bằng API thực tế
      return {
        'pastConsultations': [],
        'upcomingConsultations': [],
        'nextConsultation': null
      };
    } catch (e) {
      debugPrint('Lỗi khi lấy lịch sử cuộc hẹn của bác sĩ: $e');
      throw Exception('Đã xảy ra lỗi khi lấy lịch sử cuộc hẹn: $e');
    }
  }
}

class DoctorConsultationHistoryScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorConsultationHistoryScreen({super.key, required this.doctor});

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
    final consultationHistoryAsyncValue = ref.watch(doctorConsultationHistoryProvider);

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
            ref.refresh(doctorConsultationHistoryProvider);
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
                  ref.refresh(doctorConsultationHistoryProvider);
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
    final consultationHistoryAsyncValue = ref.watch(doctorConsultationHistoryProvider);

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
            ref.refresh(doctorConsultationHistoryProvider);
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
                  ref.refresh(doctorConsultationHistoryProvider);
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
    // Đối với bác sĩ, hiển thị thông tin bệnh nhân thay vì bác sĩ
    final patientInfo = consultation.patientInfo;
    
    // Nếu không có thông tin bệnh nhân, hiển thị thông tin cơ bản từ userId
    if (patientInfo == null) {
      return _buildSimplePatientCard(context, consultation, isPast);
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
                  backgroundImage: patientInfo.avatar != null
                      ? NetworkImage(patientInfo.avatar!)
                      : null,
                  child: patientInfo.avatar == null
                      ? Text(
                          patientInfo.fullname[0],
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
                        patientInfo.fullname,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (patientInfo.age != null) ...[
                            Icon(Icons.cake, size: 14, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '${patientInfo.age} tuổi',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          if (patientInfo.gender != null) ...[
                            Icon(
                              patientInfo.gender == 'Male' ? Icons.male : Icons.female,
                              size: 14,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              patientInfo.gender == 'Male' ? 'Nam' : 'Nữ',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
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
                if (patientInfo.phone != null)
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Điện thoại',
                      patientInfo.phone!,
                      Icons.phone,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Actions
            if (!isPast) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('Vào phòng tư vấn'),
                    onPressed: _canJoinVideoCall(consultation) 
                        ? () => _joinVideoCall(context, consultation)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('Nhắn tin'),
                    onPressed: () => _chatWithPatient(context, consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text('Nhắn tin'),
                    onPressed: () => _chatWithPatient(context, consultation),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Card đơn giản khi không có thông tin chi tiết về bệnh nhân
  Widget _buildSimplePatientCard(BuildContext context, Consultation consultation, bool isPast) {
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
                  backgroundColor: Colors.grey.shade200,
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bệnh nhân #${consultation.userId.substring(0, 6)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${consultation.userId}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
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
            if (!isPast) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('Vào phòng tư vấn'),
                    onPressed: _canJoinVideoCall(consultation) 
                        ? () => _joinVideoCall(context, consultation)
                        : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
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

  void _joinVideoCall(BuildContext context, Consultation consultation) {
    // TODO: Implement video call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang được phát triển'),
      ),
    );
  }

  void _chatWithPatient(BuildContext context, Consultation consultation) {
    // TODO: Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang được phát triển'),
      ),
    );
  }
}

// Mở rộng Consultation để chứa thông tin bệnh nhân
extension PatientInfoExtension on Consultation {
  User? get patientInfo {
    // Khi API trả về thông tin bệnh nhân, đoạn này sẽ truy cập vào thông tin đó
    // Hiện tại trả về null, cần cập nhật khi tích hợp API thực tế
    return null;
  }
} 