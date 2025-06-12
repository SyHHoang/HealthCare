import 'package:flutter/material.dart';
import 'package:mainflutter/models/doctor.dart';
import 'package:mainflutter/services/auth_service.dart';
import '../login_screen.dart';
import 'doctor_profile_screen.dart';
import 'doctor_change_password_screen.dart';

class DoctorSettingsScreen extends StatelessWidget {
  final Doctor doctor;
  final _authService = AuthService();

  DoctorSettingsScreen({
    super.key,
    required this.doctor,
  });

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
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Phần thông tin cá nhân
          ListTile(
            leading: CircleAvatar(
              backgroundImage: doctor.avatar != null
                  ? NetworkImage(doctor.avatar!)
                  : null,
              child: doctor.avatar == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(
              doctor.fullName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(doctor.email ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfileScreen(
                    doctor: doctor,
                  ),
                ),
              );
            },
          ),
          const Divider(),

          // Phần cài đặt tài khoản
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

          // Tùy chọn hồ sơ cá nhân
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Hồ sơ cá nhân'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfileScreen(
                    doctor: doctor,
                  ),
                ),
              );
            },
          ),

          // Tùy chọn đổi mật khẩu
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Đổi mật khẩu'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorChangePasswordScreen(
                    doctor: doctor,
                  ),
                ),
              );
            },
          ),

          const Divider(),

          // Phần cài đặt ứng dụng
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ứng dụng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),

         

          const SizedBox(height: 20),

          // Nút đăng xuất
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 