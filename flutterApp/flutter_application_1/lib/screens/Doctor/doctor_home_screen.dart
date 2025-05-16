import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'schedule_screen.dart';
import 'consultation_history_screen.dart';

class DoctorHomeScreen extends StatelessWidget {
  final Doctor doctor;
  final _authService = AuthService();

  DoctorHomeScreen({super.key, required this.doctor});

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ bác sĩ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin bác sĩ
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
                          backgroundImage: doctor.avatar != null && doctor.avatar!.isNotEmpty
                              ? NetworkImage(doctor.avatar!)
                              : null,
                          child: doctor.avatar == null || doctor.avatar!.isEmpty
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor.fullName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              // Text(
                              //   doctor.specialty,
                              //   style: Theme.of(context).textTheme.titleMedium,
                              // ),
                              if (doctor.experience != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Kinh nghiệm: ${doctor.experience} năm',
                                  style: Theme.of(context).textTheme.bodyMedium,
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
            const SizedBox(height: 24),
            // Thống kê nhanh
            Text(
              'Thống kê nhanh',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Lịch hẹn hôm nay',
                    '5',
                    Icons.calendar_today,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Bệnh nhân mới',
                    '3',
                    Icons.person_add,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Đánh giá',
                    '4.8',
                    Icons.star,
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Doanh thu',
                    '2.5M',
                    Icons.attach_money,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Các chức năng chính
            Text(
              'Chức năng chính',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildFunctionCard(
                  context,
                  'Quản lý lịch hẹn',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildFunctionCard(
                  context,
                  'Lịch làm việc',
                  Icons.schedule,
                  Colors.green,
                ),
                _buildFunctionCard(
                  context,
                  'Hồ sơ bệnh án',
                  Icons.folder,
                  Colors.orange,
                ),
                _buildFunctionCard(
                  context,
                  'Chat với bệnh nhân',
                  Icons.chat,
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: InkWell(
        onTap: () {
          if (title == 'Lịch làm việc') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduleScreen(doctor: doctor),
              ),
            );
          } else if (title == 'Quản lý lịch hẹn') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ConsultationHistoryScreen(doctor: doctor),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 