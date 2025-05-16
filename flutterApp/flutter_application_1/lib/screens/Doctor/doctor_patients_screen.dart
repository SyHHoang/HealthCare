import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patient_medical_record_screen.dart';

class DoctorPatientsScreen extends StatefulWidget {
  final Doctor doctor;
  const DoctorPatientsScreen({super.key, required this.doctor});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  bool loading = false;
  String? error;
  List<Map<String, dynamic>> patients = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadPatients();
  }

  Future<void> loadPatients() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/consultationList/list/user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          setState(() {
            patients = data.map<Map<String, dynamic>>((consultation) => {
              'id': consultation['_id'],
              'fullname': consultation['userId']['fullname'],
              'age': consultation['userId']['age'],
              'gender': consultation['userId']['gender'],
              'phone': consultation['userId']['phone'],
              'avatar': consultation['userId']['avatar'] ?? '',
              'createdAt': consultation['createdAt'],
              'userId': consultation['userId']['_id'],
            }).toList();
          });
        } else {
          setState(() {
            patients = [];
          });
        }
      } else {
        setState(() {
          error = 'Không thể tải danh sách bệnh nhân.';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải danh sách bệnh nhân: $e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredPatients {
    if (searchQuery.isEmpty) return patients;
    return patients.where((p) =>
      (p['fullname'] ?? '').toLowerCase().contains(searchQuery.toLowerCase()) ||
      (p['phone'] ?? '').contains(searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý bệnh nhân')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Tìm kiếm bệnh nhân theo tên hoặc số điện thoại...'
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: filteredPatients.isEmpty
                          ? const Center(child: Text('Không có bệnh nhân nào'))
                          : ListView.builder(
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                final patient = filteredPatients[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: (patient['avatar'] as String).isNotEmpty
                                              ? NetworkImage(patient['avatar'])
                                              : null,
                                          child: (patient['avatar'] as String).isEmpty
                                              ? const Icon(Icons.person, size: 28)
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(patient['fullname'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(height: 4),
                                              Text('${patient['gender'] == 'male' ? 'Nam' : 'Nữ'}, ${patient['age']} tuổi'),
                                              Text('SĐT: ${patient['phone']}'),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text('Thông tin bệnh nhân'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 32,
                                                            backgroundImage: (patient['avatar'] as String).isNotEmpty
                                                                ? NetworkImage(patient['avatar'])
                                                                : null,
                                                            child: (patient['avatar'] as String).isEmpty
                                                                ? const Icon(Icons.person, size: 32)
                                                                : null,
                                                          ),
                                                          const SizedBox(width: 16),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(patient['fullname'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                                                const SizedBox(height: 4),
                                                                Text('${patient['gender'] == 'male' ? 'Nam' : 'Nữ'}, ${patient['age']} tuổi'),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 16),
                                                      Text('Số điện thoại: ${patient['phone']}'),
                                                      // Có thể bổ sung thêm các trường khác nếu cần
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('Đóng'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.green),
                                          onPressed: () {
                                            // TODO: Thêm đơn thuốc
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.assignment_ind, color: Colors.deepPurple),
                                          tooltip: 'Xem hồ sơ sức khỏe',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PatientMedicalRecordScreen(
                                                  patientId: patient['userId'],
                                                  patientName: patient['fullname'] ?? '',
                                                  avatarUrl: patient['avatar'] ?? '',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
} 