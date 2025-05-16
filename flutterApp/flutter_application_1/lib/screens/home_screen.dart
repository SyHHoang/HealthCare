import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'doctor_search_screen.dart';
import 'appointment_screen.dart';
import 'settings_screen.dart';
import 'drug_search_screen.dart';
import 'consultation_list_screen.dart';
import 'consultation_history_screen.dart';
import 'feedback_screen.dart';

class HomeScreen extends StatefulWidget {
  final dynamic user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  Future<void> _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDoctor = widget.user is Doctor;
    final String fullName = isDoctor ? (widget.user as Doctor).fullName : (widget.user as User).fullname;
    final String role = isDoctor ? 'Bác sĩ' : 'Người dùng';

    return Column(
      children: [
        AppBar(
          title: Text('Trang chủ ${widget.user is Doctor ? 'Bác sĩ' : 'Người dùng'}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
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
                        Text(
                          'Xin chào, $fullName',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vai trò: $role',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (widget.user is User) ...[
                          if ((widget.user as User).phone != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Số điện thoại: ${(widget.user as User).phone}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                          if ((widget.user as User).gender != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Giới tính: ${(widget.user as User).gender}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ],
                        if (widget.user is Doctor) ...[
                          if ((widget.user as Doctor).specialty != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Chuyên khoa: ${(widget.user as Doctor).specialty}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                          if ((widget.user as Doctor).phone != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Số điện thoại: ${(widget.user as Doctor).phone}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                          if ((widget.user as Doctor).address != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Địa chỉ: ${(widget.user as Doctor).address}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                          if ((widget.user as Doctor).currentWorkplace != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Nơi làm việc: ${(widget.user as Doctor).currentWorkplace}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                          if ((widget.user as Doctor).experience != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Kinh nghiệm: ${(widget.user as Doctor).experience} năm',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (isDoctor) ...[
                  _buildFunctionCard(
                    'Quản lý lịch hẹn',
                    Icons.calendar_today,
                    () => _navigateToScreen(context, const AppointmentScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildFunctionCard(
                    'Hồ sơ bệnh án',
                    Icons.folder,
                    () => _navigateToScreen(context, const SettingsScreen()),
                  ),
                ] else ...[
                  _buildFunctionCard(
                    'Danh sách bác sỹ tư vấn',
                    Icons.medical_services,
                    () => _navigateToScreen(context, const ConsultationListScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildFunctionCard(
                    'Tìm bác sĩ',
                    Icons.search,
                    () => _navigateToScreen(context, const DoctorSearchScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildFunctionCard(
                    'Tra cứu thuốc',
                    Icons.medication,
                    () => _navigateToScreen(context, const DrugSearchScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildFunctionCard(
                    'Quản lý lịch hẹn',
                    Icons.calendar_today,
                    () => _navigateToScreen(context, const ConsultationHistoryScreen()),
                  ),
                  const SizedBox(height: 16),
                  _buildFunctionCard(
                    'Gửi phản hồi',
                    Icons.feedback,
                    () => _navigateToScreen(context, const FeedbackScreen()),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
} 