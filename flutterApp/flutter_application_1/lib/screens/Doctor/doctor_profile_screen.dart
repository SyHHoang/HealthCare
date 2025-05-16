import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/doctor.dart';
import 'package:flutter_application_1/services/doctor_service.dart';
import 'package:flutter_application_1/widgets/verification_status_badge.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'doctor_change_password_screen.dart';
import 'doctor_profile_edit_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final DoctorService _doctorService = DoctorService();
  bool _isLoading = false;
  Map<String, dynamic>? _verificationDetails;
  final ImagePicker _picker = ImagePicker();
  late Doctor _currentDoctor;

  @override
  void initState() {
    super.initState();
    _currentDoctor = widget.doctor;
    _loadVerificationDetails();
  }

  Future<void> _loadVerificationDetails() async {
    try {
      final details = await _doctorService.getVerificationDetails();
      if (mounted) {
        setState(() {
          _verificationDetails = details;
        });
      }
    } catch (e) {
      debugPrint('Error loading verification details: $e');
    }
  }

  Future<void> _handleAvatarChange() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() => _isLoading = true);

      // Upload image to server
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://localhost:5000/api/doctors/avatar'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'avatar',
          image.path,
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 200 && mounted) {
        // Update local doctor data
        setState(() {
          _currentDoctor = _currentDoctor.copyWith(
            avatar: jsonData['data']['avatar'],
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật ảnh đại diện thành công')),
        );
      } else {
        throw Exception(jsonData['message'] ?? 'Lỗi khi cập nhật ảnh');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorProfileEditScreen(
                    doctor: _currentDoctor,
                  ),
                ),
              ).then((updatedDoctor) {
                if (updatedDoctor != null) {
                  setState(() {
                    _currentDoctor = updatedDoctor;
                  });
                }
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withAlpha(204), // 0.8 opacity
                  ],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _currentDoctor.avatar != null
                            ? NetworkImage(_currentDoctor.avatar!)
                            : null,
                        child: _currentDoctor.avatar == null
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(51), // 0.2 opacity
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt),
                            onPressed: _isLoading ? null : _handleAvatarChange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentDoctor.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VerificationStatusBadge(status: _currentDoctor.status ?? 'unverified'),
                  if (_currentDoctor.verifiID != null)
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Show verification details modal
                      },
                      icon: const Icon(Icons.description, color: Colors.white),
                      label: const Text(
                        'Xem đơn xác thực',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileEditScreen(
                              doctor: _currentDoctor,
                            ),
                          ),
                        ).then((updatedDoctor) {
                          if (updatedDoctor != null) {
                            setState(() {
                              _currentDoctor = updatedDoctor;
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Chỉnh sửa thông tin'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorChangePasswordScreen(
                              doctor: _currentDoctor,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Đổi mật khẩu'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contact Information
            _buildSection(
              title: 'Thông tin liên hệ',
              icon: Icons.contact_mail,
              children: [
                _buildInfoItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: _currentDoctor.email ?? 'Chưa cập nhật',
                ),
                _buildInfoItem(
                  icon: Icons.phone,
                  label: 'Số điện thoại',
                  value: _currentDoctor.phone ?? 'Chưa cập nhật',
                ),
              ],
            ),

            // Professional Information
            _buildSection(
              title: 'Thông tin chuyên môn',
              icon: Icons.medical_services,
              children: [
                _buildInfoItem(
                  icon: Icons.work,
                  label: 'Chuyên khoa chính',
                  value: _currentDoctor.specialty ?? 'Chưa cập nhật',
                ),
                _buildInfoItem(
                  icon: Icons.category,
                  label: 'Các chuyên khoa khác',
                  value: _currentDoctor.otherSpecialties ?? 'Không có',
                ),
                _buildInfoItem(
                  icon: Icons.timeline,
                  label: 'Kinh nghiệm',
                  value: '${_currentDoctor.experience ?? 0} năm',
                ),
                _buildInfoItem(
                  icon: Icons.business,
                  label: 'Nơi làm việc',
                  value: _currentDoctor.currentWorkplace ?? 'Chưa cập nhật',
                ),
              ],
            ),

            // Education Information
            _buildSection(
              title: 'Thông tin học vấn',
              icon: Icons.school,
              children: [
                _buildInfoItem(
                  icon: Icons.account_balance,
                  label: 'Trường đại học',
                  value: _currentDoctor.education ?? 'Chưa cập nhật',
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Năm tốt nghiệp',
                  value: _currentDoctor.graduationYear?.toString() ?? 'Chưa cập nhật',
                ),
                _buildInfoItem(
                  icon: Icons.badge,
                  label: 'Số giấy phép hành nghề',
                  value: _currentDoctor.licenseNumber ?? 'Chưa cập nhật',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 