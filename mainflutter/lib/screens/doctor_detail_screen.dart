import 'package:flutter/material.dart';
import '../models/doctor.dart';
import '../services/vnpay_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DoctorDetailScreen extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor});

  Future<void> _registerConsultation(BuildContext context) async {
    try {
      // Tạo giao dịch thanh toán
      final vnpUrl = await VnpayService.createPaymentUrl(
        bankCode: 'NCB', // Ngân hàng NCB
        doctorId: doctor.id ?? '',
        language: 'vn',  // Ngôn ngữ
        orderType: 'consultation',
        quantity: 1
      );

      // Mở URL thanh toán trong trình duyệt
      final uri = Uri.parse(vnpUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở trang thanh toán'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.fullName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: doctor.avatar != null
                              ? NetworkImage(doctor.avatar!)
                              : null,
                          child: doctor.avatar == null
                              ? Text(
                                  doctor.fullName[0],
                                  style: const TextStyle(fontSize: 32),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.fullName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              if (doctor.specialty != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialty!,
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                              if (doctor.isVerified) ...[
                                const SizedBox(height: 4),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Đã xác thực',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Thông tin chi tiết
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin chi tiết',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (doctor.otherSpecialties != null) ...[
                      _buildInfoRow(
                        context,
                        'Chuyên khoa khác',
                        doctor.otherSpecialties!,
                        Icons.medical_services_outlined,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.education != null) ...[
                      _buildInfoRow(
                        context,
                        'Học vấn',
                        doctor.education!,
                        Icons.school,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.graduationYear != null) ...[
                      _buildInfoRow(
                        context,
                        'Năm tốt nghiệp',
                        doctor.graduationYear.toString(),
                        Icons.calendar_today,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.licenseNumber != null) ...[
                      _buildInfoRow(
                        context,
                        'Số giấy phép hành nghề',
                        doctor.licenseNumber!,
                        Icons.badge,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.experience != null) ...[
                      _buildInfoRow(
                        context,
                        'Số năm kinh nghiệm',
                        '${doctor.experience} năm',
                        Icons.work,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.currentWorkplace != null) ...[
                      _buildInfoRow(
                        context,
                        'Nơi làm việc hiện tại',
                        doctor.currentWorkplace!,
                        Icons.business,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.phone != null) ...[
                      _buildInfoRow(
                        context,
                        'Số điện thoại',
                        doctor.phone!,
                        Icons.phone,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (doctor.address != null) ...[
                      _buildInfoRow(
                        context,
                        'Địa chỉ',
                        doctor.address!,
                        Icons.location_on,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Nút đăng ký tư vấn
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => _registerConsultation(context),
                child: const Text('Đăng ký tư vấn'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
} 