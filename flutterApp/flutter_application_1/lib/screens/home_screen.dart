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

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.jpeg',  // Ảnh nền bạn thêm vào assets
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.7),
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Có thể thêm widget chào hoặc tên người dùng nếu muốn
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xin chào,',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          fullName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  // Xử lý nhấn thông báo
                  print('Nhấn chuông thông báo');
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    // Xử lý nhấn avatar (ví dụ: mở profile)
                    print('Nhấn avatar người dùng');
                  },
                  child: Padding(
  padding: const EdgeInsets.only(right: 12.0),
  child: GestureDetector(
    onTap: () {
      // Xử lý khi nhấn vào avatar (ví dụ mở profile)
      print('Nhấn avatar người dùng');
    },
    child: const CircleAvatar(
      radius: 18,
      backgroundImage: AssetImage('assets/images/default_avatar.png'),
    ),
  ),
),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () => _logout(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chức năng chính',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (isDoctor) ...[
                    _MainFunctionCard(
                      color: Colors.blue,
                      icon: Icons.calendar_today,
                      title: 'Quản lý lịch hẹn',
                      description: 'Xem và quản lý lịch hẹn khám bệnh',
                      onTap: () => _navigateToScreen(context, const AppointmentScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MainFunctionCard(
                      color: Colors.orange,
                      icon: Icons.folder,
                      title: 'Hồ sơ bệnh án',
                      description: 'Quản lý hồ sơ bệnh án của bệnh nhân',
                      onTap: () => _navigateToScreen(context, const SettingsScreen()),
                    ),
                  ] else ...[
                    _MainFunctionCard(
                      color: Colors.green,
                      icon: Icons.medical_services,
                      title: 'Danh sách bác sỹ tư vấn',
                      description: 'Xem danh sách các bác sĩ tư vấn',
                      onTap: () => _navigateToScreen(context, const ConsultationListScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MainFunctionCard(
                      color: Colors.blue,
                      icon: Icons.search,
                      title: 'Tìm bác sĩ',
                      description: 'Tìm kiếm bác sĩ theo chuyên khoa',
                      onTap: () => _navigateToScreen(context, const DoctorSearchScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MainFunctionCard(
                      color: Colors.orange,
                      icon: Icons.calendar_today,
                      title: 'Quản lý lịch hẹn',
                      description: 'Xem và quản lý lịch hẹn khám bệnh',
                      onTap: () => _navigateToScreen(context, const ConsultationHistoryScreen()),
                    ),
                    const SizedBox(height: 16),
                    _MainFunctionCard(
                      color: Colors.teal,
                      icon: Icons.feedback,
                      title: 'Gửi phản hồi',
                      description: 'Gửi phản hồi về dịch vụ',
                      onTap: () => _navigateToScreen(context, const FeedbackScreen()),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MainFunctionCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _MainFunctionCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 28),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
