import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor.dart';
import '../../widgets/doctor_bottom_nav_bar.dart';
import '../../services/socket_service.dart';
import '../../services/token_service.dart';
import 'doctor_home_screen.dart';
import 'doctor_consultation_history_screen.dart';
import 'doctor_patients_screen.dart';
import '../news_list_screen.dart';
import 'doctor_chat_option_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorMainScreen extends ConsumerStatefulWidget {
  final Doctor doctor;

  const DoctorMainScreen({
    super.key,
    required this.doctor,
  });

  @override
  ConsumerState<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends ConsumerState<DoctorMainScreen> {
  int _selectedIndex = 0;
  final SocketService _socketService = SocketService.instance;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    try {
      // Lấy token trước khi kết nối
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token');
      }
      
      debugPrint('🔑 Token hiện tại: ${token.substring(0, 15)}...');
      
      // Kết nối socket
      await _socketService.connect();
      
      // Thiết lập các listeners cơ bản
      _setupSocketListeners();
    } catch (e) {
      debugPrint('❌ Lỗi kết nối socket: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setupSocketListeners() {
    debugPrint('🔄 Đang thiết lập socket listeners...');
    
    // Thêm listener cho trạng thái online/offline của bệnh nhân
    _socketService.addUserOnlineListener((userId) {
      debugPrint('🟢 Bệnh nhân online: $userId');
    });

    _socketService.addUserOfflineListener((userId) {
      debugPrint('🔴 Bệnh nhân offline: $userId');
    });

    // Thêm listener cho trạng thái đang nhập
    _socketService.addTypingListener((userId) {
      debugPrint('⌨️ Bệnh nhân đang nhập: $userId');
    });

    _socketService.addStopTypingListener((userId) {
      debugPrint('⏹️ Bệnh nhân dừng nhập: $userId');
    });
  }

  @override
  void dispose() {
    // Không disconnect socket ở đây vì chúng ta muốn duy trì kết nối
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return DoctorHomeScreen(doctor: widget.doctor);
      case 1:
        return DoctorPatientsScreen(doctor: widget.doctor);
      case 2:
        return const NewsListScreen();
      case 3:
        return DoctorChatOptionScreen(doctor: widget.doctor);
      case 4:
        return DoctorProfileScreen(doctor: widget.doctor);
      default:
        return DoctorHomeScreen(doctor: widget.doctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getScreen(_selectedIndex),
      bottomNavigationBar: DoctorBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
} 