import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor.dart';
import '../../widgets/doctor_bottom_nav_bar.dart';
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
        return DoctorConsultationHistoryScreen(doctor: widget.doctor);
      case 2:
        return DoctorPatientsScreen(doctor: widget.doctor);
      case 3:
        return const NewsListScreen();
      case 4:
        return DoctorChatOptionScreen(doctor: widget.doctor);
      case 5:
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