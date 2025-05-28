import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/doctor.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'news_list_screen.dart';
import 'chat_option_screen.dart';
import 'settings_screen.dart';
import '../services/socket_service.dart';

class MainScreen extends ConsumerStatefulWidget {
  final User user;
  final Doctor? doctor;

  const MainScreen({
    super.key,
    required this.user,
    this.doctor,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  final SocketService _socketService = SocketService.instance;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  Future<void> _connectSocket() async {
    try {
      debugPrint('🔄 Đang kết nối socket từ MainScreen...');
      await _socketService.connect();
      debugPrint('✅ Kết nối socket thành công');
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

  @override
  void dispose() {
    // Không ngắt kết nối socket ở đây vì có thể cần cho các màn hình khác
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavBar(
        user: widget.user,
        doctor: widget.doctor,
        onIndexChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedIndex: _selectedIndex,
      ),
    );
  }
  
  Widget _buildBody() {
    // Chỉ hiển thị màn hình hiện tại thay vì sử dụng IndexedStack
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(user: widget.user);
      case 1:
        return const NewsListScreen();
      case 2:
        return ChatOptionScreen(user: widget.user);
      case 3:
        return const SettingsScreen();
      default:
        return HomeScreen(user: widget.user);
    }
  }
} 