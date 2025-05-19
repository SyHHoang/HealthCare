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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Theme.of(context).primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/background.jpeg',
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
                  Positioned(
                    left: 16,
                    bottom: 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: doctor.avatar != null && doctor.avatar!.isNotEmpty
                              ? NetworkImage(doctor.avatar!)
                              : null,
                          child: doctor.avatar == null || doctor.avatar!.isEmpty
                              ? const Icon(Icons.person, size: 36)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bác sĩ',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            if (doctor.experience != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Kinh nghiệm: ${doctor.experience} năm',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
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
                  // Xử lý nhấn chuông thông báo
                  print('Nhấn chuông thông báo');
                },
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
                  // Thống kê nhanh
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        value: '5',
                        label: 'Lịch hẹn hôm nay',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.person_add,
                        color: Colors.green,
                        value: '3',
                        label: 'Bệnh nhân mới',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.star,
                        color: Colors.amber,
                        value: '4.8',
                        label: 'Đánh giá',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.attach_money,
                        color: Colors.purple,
                        value: '2.5M',
                        label: 'Doanh thu',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Chức năng chính',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MainFunctionCard(
                    color: Colors.blue,
                    icon: Icons.calendar_today,
                    title: 'Quản lý lịch hẹn',
                    description: 'Xem và quản lý lịch hẹn khám bệnh',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConsultationHistoryScreen(doctor: doctor),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _MainFunctionCard(
                    color: Colors.green,
                    icon: Icons.schedule,
                    title: 'Lịch làm việc',
                    description: 'Xem và cập nhật lịch làm việc',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleScreen(doctor: doctor),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _MainFunctionCard(
                    color: Colors.orange,
                    icon: Icons.folder,
                    title: 'Hồ sơ bệnh án',
                    description: 'Quản lý hồ sơ bệnh án của bệnh nhân',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  _MainFunctionCard(
                    color: Colors.purple,
                    icon: Icons.chat,
                    title: 'Chat với bệnh nhân',
                    description: 'Trò chuyện, tư vấn trực tuyến',
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ],
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