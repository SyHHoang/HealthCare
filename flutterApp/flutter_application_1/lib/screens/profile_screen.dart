import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  final bool isChangingPassword;

  const ProfileScreen({
    super.key,
    this.isEditing = false,
    this.isChangingPassword = false,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userService = UserService();
  final _authService = AuthService();
  late Future<User> _userFuture;
  late bool _isEditing;
  late bool _isChangingPassword;

  // Form controllers
  final _fullnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile();
    _isEditing = widget.isEditing;
    _isChangingPassword = widget.isChangingPassword;
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startEditing(User user) {
    setState(() {
      _isEditing = true;
      _fullnameController.text = user.fullname;
      _ageController.text = user.age?.toString() ?? '';
      _phoneController.text = user.phone ?? '';
      _selectedGender = user.gender;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final updatedUser = await _userService.updateProfile(
          fullname: _fullnameController.text,
          age: int.tryParse(_ageController.text),
          gender: _selectedGender,
          phone: _phoneController.text,
        );
        setState(() {
          _isEditing = false;
          _userFuture = Future.value(updatedUser);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật thông tin thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.changePassword(
          _oldPasswordController.text,
          _newPasswordController.text,
        );
        setState(() {
          _isChangingPassword = false;
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

            final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: user.avatar != null && user.avatar!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              user.avatar!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                    radius: 50,
                                  child: Icon(Icons.person, size: 50),
                                );
                              },
                            ),
                          )
                        : const CircleAvatar(
                            radius: 50,
                            child: Icon(Icons.person, size: 50),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Thông tin cá nhân',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              if (!_isEditing)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _startEditing(user),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _fullnameController,
                            decoration: const InputDecoration(
                              labelText: 'Họ và tên',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập họ và tên';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Tuổi',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final age = int.tryParse(value);
                                if (age == null || age < 0) {
                                  return 'Tuổi không hợp lệ';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Giới tính',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Nam')),
                              DropdownMenuItem(value: 'female', child: Text('Nữ')),
                              DropdownMenuItem(value: 'other', child: Text('Khác')),
                            ],
                            onChanged: _isEditing
                                ? (value) {
                                    setState(() {
                                      _selectedGender = value;
                                    });
                                  }
                        : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Số điện thoại',
                              border: OutlineInputBorder(),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                                  return 'Số điện thoại không hợp lệ';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          if (_isEditing)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isEditing = false;
                                    });
                                  },
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _saveProfile,
                                  child: const Text('Lưu'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Đổi mật khẩu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const Spacer(),
                              if (!_isChangingPassword)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _isChangingPassword = true;
                                    });
                                  },
                                ),
                            ],
                          ),
                          if (_isChangingPassword) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _oldPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu cũ',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu cũ';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _newPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Mật khẩu mới',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu mới';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmPasswordController,
                              decoration: const InputDecoration(
                                labelText: 'Xác nhận mật khẩu mới',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu mới';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Mật khẩu không khớp';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isChangingPassword = false;
                                      _oldPasswordController.clear();
                                      _newPasswordController.clear();
                                      _confirmPasswordController.clear();
                                    });
                                  },
                                  child: const Text('Hủy'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _changePassword,
                                  child: const Text('Đổi mật khẩu'),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 