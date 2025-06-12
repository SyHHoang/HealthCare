import 'package:flutter/material.dart';
import 'package:mainflutter/models/doctor.dart';
import 'package:mainflutter/services/doctor_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class DoctorProfileEditScreen extends StatefulWidget {
  final Doctor doctor;

  const DoctorProfileEditScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorProfileEditScreen> createState() => _DoctorProfileEditScreenState();
}

class _DoctorProfileEditScreenState extends State<DoctorProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final DoctorService _doctorService = DoctorService();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Controllers cho các trường thông tin
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _specialtyController;
  late TextEditingController _otherSpecialtiesController;
  late TextEditingController _experienceController;
  late TextEditingController _currentWorkplaceController;
  late TextEditingController _educationController;
  late TextEditingController _graduationYearController;
  late TextEditingController _licenseNumberController;

  @override
  void initState() {
    super.initState();
    // Khởi tạo các controller với giá trị hiện tại
    _fullNameController = TextEditingController(text: widget.doctor.fullName);
    _emailController = TextEditingController(text: widget.doctor.email);
    _phoneController = TextEditingController(text: widget.doctor.phone);
    _specialtyController = TextEditingController(text: widget.doctor.specialty);
    _otherSpecialtiesController = TextEditingController(text: widget.doctor.otherSpecialties);
    _experienceController = TextEditingController(text: widget.doctor.experience?.toString());
    _currentWorkplaceController = TextEditingController(text: widget.doctor.currentWorkplace);
    _educationController = TextEditingController(text: widget.doctor.education);
    _graduationYearController = TextEditingController(text: widget.doctor.graduationYear?.toString());
    _licenseNumberController = TextEditingController(text: widget.doctor.licenseNumber);
  }

  @override
  void dispose() {
    // Giải phóng các controller
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _otherSpecialtiesController.dispose();
    _experienceController.dispose();
    _currentWorkplaceController.dispose();
    _educationController.dispose();
    _graduationYearController.dispose();
    _licenseNumberController.dispose();
    super.dispose();
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
        Uri.parse('${dotenv.env['BASE_URL']}/api/doctors/avatar'),
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

  Future<void> _handleVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Kiểm tra ảnh đại diện
      if (widget.doctor.avatar == null || widget.doctor.avatar!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng cập nhật ảnh đại diện trước khi xác thực tài khoản')),
        );
        return;
      }

      // Gửi yêu cầu xác thực
      await _doctorService.requestVerification({
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'specialty': _specialtyController.text,
        'otherSpecialties': _otherSpecialtiesController.text,
        'experience': int.parse(_experienceController.text),
        'currentWorkplace': _currentWorkplaceController.text,
        'education': _educationController.text,
        'graduationYear': int.parse(_graduationYearController.text),
        'licenseNumber': _licenseNumberController.text,
        'avatar': widget.doctor.avatar,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gửi yêu cầu xác thực thành công')),
        );
        Navigator.pop(context);
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
        title: const Text('Gửi yêu cầu xác thực'),
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : _handleVerification,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: widget.doctor.avatar != null
                          ? NetworkImage(widget.doctor.avatar!)
                          : null,
                      child: widget.doctor.avatar == null
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
                              color: Colors.black.withAlpha(51),
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
              ),
              const SizedBox(height: 24),

              // Basic Information
              const Text(
                'Thông tin cơ bản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!value.contains('@')) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (value.length != 10) {
                    return 'Số điện thoại phải có 10 chữ số';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Professional Information
              const Text(
                'Thông tin chuyên môn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specialtyController,
                decoration: const InputDecoration(
                  labelText: 'Chuyên khoa chính *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập chuyên khoa chính';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _otherSpecialtiesController,
                decoration: const InputDecoration(
                  labelText: 'Các chuyên khoa khác',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(
                  labelText: 'Kinh nghiệm (năm) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số năm kinh nghiệm';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Vui lòng nhập số hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentWorkplaceController,
                decoration: const InputDecoration(
                  labelText: 'Nơi làm việc hiện tại *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nơi làm việc';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Education Information
              const Text(
                'Thông tin học vấn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(
                  labelText: 'Trường đại học *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập trường đại học';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _graduationYearController,
                decoration: const InputDecoration(
                  labelText: 'Năm tốt nghiệp *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập năm tốt nghiệp';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Vui lòng nhập năm hợp lệ';
                  }
                  if (year < 1900 || year > DateTime.now().year) {
                    return 'Năm tốt nghiệp không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licenseNumberController,
                decoration: const InputDecoration(
                  labelText: 'Số giấy phép hành nghề *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số giấy phép hành nghề';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerification,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Gửi yêu cầu xác thực',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 