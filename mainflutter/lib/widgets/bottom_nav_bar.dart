import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/doctor.dart';

class BottomNavBar extends ConsumerWidget {
  final User user;
  final Doctor? doctor;
  final Function(int) onIndexChanged;
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.user,
    this.doctor,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onIndexChanged,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: 'Trang chủ',
          backgroundColor: Theme.of(context).primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.newspaper),
          label: 'Tin tức',
          backgroundColor: Theme.of(context).primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat),
          label: 'Nhắn tin',
          backgroundColor: Theme.of(context).primaryColor,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'Cài đặt',
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
} 