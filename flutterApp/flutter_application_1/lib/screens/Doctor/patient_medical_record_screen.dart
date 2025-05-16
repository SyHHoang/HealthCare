import 'package:flutter/material.dart';
import '../../models/symptom.dart';
import '../../models/prescription.dart';
import '../../models/allergy.dart';
import '../../models/vaccination.dart';
import '../../models/treatment.dart';
import '../../models/lifestyle.dart';
import '../../models/health_data.dart';
import '../../services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String avatarUrl;
  const PatientMedicalRecordScreen({super.key, required this.patientId, required this.patientName, required this.avatarUrl});

  @override
  State<PatientMedicalRecordScreen> createState() => _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState extends State<PatientMedicalRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _tabs = const [
    Tab(text: 'Thông tin'),
    Tab(text: 'Triệu chứng'),
    Tab(text: 'Đơn thuốc'),
    Tab(text: 'Dị ứng'),
    Tab(text: 'Tiêm chủng'),
    Tab(text: 'Điều trị'),
    Tab(text: 'Lối sống'),
    Tab(text: 'Dữ liệu sức khỏe'),
  ];

  // State cho tab Triệu chứng
  bool loadingSymptoms = false;
  String? errorSymptoms;
  List<Symptom> symptoms = [];

  // State cho tab Đơn thuốc
  bool loadingPrescriptions = false;
  String? errorPrescriptions;
  List<Prescription> prescriptions = [];

  // State cho tab Dị ứng
  bool loadingAllergies = false;
  String? errorAllergies;
  List<Allergy> allergies = [];

  // State cho tab Tiêm chủng
  bool loadingVaccinations = false;
  String? errorVaccinations;
  List<Vaccination> vaccinations = [];

  // State cho tab Điều trị
  bool loadingTreatments = false;
  String? errorTreatments;
  List<Treatment> treatments = [];

  // State cho tab Lối sống
  bool loadingLifestyles = false;
  String? errorLifestyles;
  List<Lifestyle> lifestyles = [];

  // State cho tab Dữ liệu sức khỏe
  bool loadingHealthData = false;
  String? errorHealthData;
  List<HealthData> healthDataList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && symptoms.isEmpty && !loadingSymptoms) {
        fetchSymptoms();
      }
      if (_tabController.index == 2 && prescriptions.isEmpty && !loadingPrescriptions) {
        fetchPrescriptions();
      }
      if (_tabController.index == 3 && allergies.isEmpty && !loadingAllergies) {
        fetchAllergies();
      }
      if (_tabController.index == 4 && vaccinations.isEmpty && !loadingVaccinations) {
        fetchVaccinations();
      }
      if (_tabController.index == 5 && treatments.isEmpty && !loadingTreatments) {
        fetchTreatments();
      }
      if (_tabController.index == 6 && lifestyles.isEmpty && !loadingLifestyles) {
        fetchLifestyles();
      }
      if (_tabController.index == 7 && healthDataList.isEmpty && !loadingHealthData) {
        fetchHealthData();
      }
    });
  }

  Future<void> fetchSymptoms() async {
    setState(() {
      loadingSymptoms = true;
      errorSymptoms = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/symptoms/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          symptoms = (data as List).map((e) => Symptom.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorSymptoms = 'Không thể tải dữ liệu triệu chứng.';
        });
      }
    } catch (e) {
      setState(() {
        errorSymptoms = 'Lỗi khi tải dữ liệu triệu chứng: $e';
      });
    } finally {
      setState(() {
        loadingSymptoms = false;
      });
    }
  }

  Future<void> fetchPrescriptions() async {
    setState(() {
      loadingPrescriptions = true;
      errorPrescriptions = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/prescriptions/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          prescriptions = (data as List).map((e) => Prescription.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorPrescriptions = 'Không thể tải dữ liệu đơn thuốc.';
        });
      }
    } catch (e) {
      setState(() {
        errorPrescriptions = 'Lỗi khi tải dữ liệu đơn thuốc: $e';
      });
    } finally {
      setState(() {
        loadingPrescriptions = false;
      });
    }
  }

  Future<void> fetchAllergies() async {
    setState(() {
      loadingAllergies = true;
      errorAllergies = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/allergies/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          allergies = (data as List).map((e) => Allergy.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorAllergies = 'Không thể tải dữ liệu dị ứng.';
        });
      }
    } catch (e) {
      setState(() {
        errorAllergies = 'Lỗi khi tải dữ liệu dị ứng: $e';
      });
    } finally {
      setState(() {
        loadingAllergies = false;
      });
    }
  }

  Future<void> fetchVaccinations() async {
    setState(() {
      loadingVaccinations = true;
      errorVaccinations = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/vaccinations/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          vaccinations = (data as List).map((e) => Vaccination.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorVaccinations = 'Không thể tải dữ liệu tiêm chủng.';
        });
      }
    } catch (e) {
      setState(() {
        errorVaccinations = 'Lỗi khi tải dữ liệu tiêm chủng: $e';
      });
    } finally {
      setState(() {
        loadingVaccinations = false;
      });
    }
  }

  Future<void> fetchTreatments() async {
    setState(() {
      loadingTreatments = true;
      errorTreatments = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/treatments/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          treatments = (data as List).map((e) => Treatment.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorTreatments = 'Không thể tải dữ liệu điều trị.';
        });
      }
    } catch (e) {
      setState(() {
        errorTreatments = 'Lỗi khi tải dữ liệu điều trị: $e';
      });
    } finally {
      setState(() {
        loadingTreatments = false;
      });
    }
  }

  Future<void> fetchLifestyles() async {
    setState(() {
      loadingLifestyles = true;
      errorLifestyles = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/lifestyles/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          lifestyles = (data as List).map((e) => Lifestyle.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorLifestyles = 'Không thể tải dữ liệu lối sống.';
        });
      }
    } catch (e) {
      setState(() {
        errorLifestyles = 'Lỗi khi tải dữ liệu lối sống: $e';
      });
    } finally {
      setState(() {
        loadingLifestyles = false;
      });
    }
  }

  Future<void> fetchHealthData() async {
    setState(() {
      loadingHealthData = true;
      errorHealthData = null;
    });
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('http://localhost:5000/api/medical-record/health-data/doctor/${widget.patientId}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          healthDataList = (data as List).map((e) => HealthData.fromJson(e)).toList();
        });
      } else {
        setState(() {
          errorHealthData = 'Không thể tải dữ liệu sức khỏe.';
        });
      }
    } catch (e) {
      setState(() {
        errorHealthData = 'Lỗi khi tải dữ liệu sức khỏe: $e';
      });
    } finally {
      setState(() {
        loadingHealthData = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hồ sơ sức khỏe: ${widget.patientName}'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildSymptomsTab(),
          _buildPrescriptionsTab(),
          _buildAllergiesTab(),
          _buildVaccinationsTab(),
          _buildTreatmentsTab(),
          _buildLifestylesTab(),
          _buildHealthDataTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundImage: widget.avatarUrl.isNotEmpty ? NetworkImage(widget.avatarUrl) : null,
            child: widget.avatarUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
          ),
          const SizedBox(height: 16),
          Text(widget.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          const SizedBox(height: 8),
          Text('ID: ${widget.patientId}', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSymptomsTab() {
    if (loadingSymptoms) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorSymptoms != null) {
      return Center(child: Text(errorSymptoms!, style: const TextStyle(color: Colors.red)));
    }
    if (symptoms.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu triệu chứng'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final s = symptoms[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mức độ: ${s.severity}'),
                Text('Bắt đầu: ${_formatDate(s.startDate)}'),
                if (s.notes != null && s.notes!.isNotEmpty) Text('Ghi chú: ${s.notes}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsTab() {
    if (loadingPrescriptions) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorPrescriptions != null) {
      return Center(child: Text(errorPrescriptions!, style: const TextStyle(color: Colors.red)));
    }
    if (prescriptions.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu đơn thuốc'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final p = prescriptions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chẩn đoán: ${p.diagnosis}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Ngày: ${_formatDate(p.date)}'),
                if (p.medicines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Thuốc:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...p.medicines.map((m) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text('- ${m.name}, ${m.dosage}, ${m.frequency}, ${m.duration}${m.notes != null && m.notes!.isNotEmpty ? ', ghi chú: ${m.notes}' : ''}'),
                      )),
                ],
                if (p.notes != null && p.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Ghi chú: ${p.notes}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllergiesTab() {
    if (loadingAllergies) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorAllergies != null) {
      return Center(child: Text(errorAllergies!, style: const TextStyle(color: Colors.red)));
    }
    if (allergies.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu dị ứng'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allergies.length,
      itemBuilder: (context, index) {
        final a = allergies[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tác nhân: ${a.allergen}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Loại: ${a.type}'),
                Text('Mức độ: ${a.severity}'),
                if (a.symptoms.isNotEmpty) Text('Triệu chứng: ${a.symptoms.join(", ")}'),
                if (a.firstOccurrence != null) Text('Lần đầu: ${_formatDate(a.firstOccurrence)}'),
                if (a.lastOccurrence != null) Text('Lần gần nhất: ${_formatDate(a.lastOccurrence)}'),
                if (a.treatment != null && a.treatment!.isNotEmpty) Text('Điều trị: ${a.treatment}'),
                if (a.notes != null && a.notes!.isNotEmpty) Text('Ghi chú: ${a.notes}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    if (loadingVaccinations) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorVaccinations != null) {
      return Center(child: Text(errorVaccinations!, style: const TextStyle(color: Colors.red)));
    }
    if (vaccinations.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu tiêm chủng'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vaccinations.length,
      itemBuilder: (context, index) {
        final v = vaccinations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tên vắc xin: ${v.vaccineName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Loại: ${v.vaccineType}'),
                Text('Ngày tiêm: ${_formatDate(v.dateAdministered)}'),
                if (v.nextDoseDate != null) Text('Ngày tiêm tiếp: ${_formatDate(v.nextDoseDate)}'),
                if (v.batchNumber != null && v.batchNumber!.isNotEmpty) Text('Số lô: ${v.batchNumber}'),
                if (v.manufacturer != null && v.manufacturer!.isNotEmpty) Text('Nhà sản xuất: ${v.manufacturer}'),
                if (v.sideEffects != null && v.sideEffects!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Tác dụng phụ:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...v.sideEffects!.map((e) => Text('- ${e.description} (${e.severity})')), 
                ],
                if (v.notes != null && v.notes!.isNotEmpty) Text('Ghi chú: ${v.notes}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreatmentsTab() {
    if (loadingTreatments) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorTreatments != null) {
      return Center(child: Text(errorTreatments!, style: const TextStyle(color: Colors.red)));
    }
    if (treatments.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu điều trị'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: treatments.length,
      itemBuilder: (context, index) {
        final t = treatments[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chẩn đoán: ${t.diagnosis}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Kế hoạch điều trị: ${t.treatmentPlan}'),
                Text('Ngày bắt đầu: ${_formatDate(t.startDate)}'),
                if (t.endDate != null) Text('Ngày kết thúc: ${_formatDate(t.endDate)}'),
                if (t.status.isNotEmpty) Text('Trạng thái: ${t.status}'),
                if (t.medications.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Thuốc:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...t.medications.map((med) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- ${med.name}, ${med.dosage}, ${med.frequency}, ${med.duration}'),
                  )),
                ],
                if (t.procedures.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Thủ thuật:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...t.procedures.map((proc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text('- ${proc.name}, ngày: ${_formatDate(proc.date)}${proc.notes != null && proc.notes!.isNotEmpty ? ', ghi chú: ${proc.notes}' : ''}'),
                  )),
                ],
                if (t.followUp != null) ...[
                  const SizedBox(height: 8),
                  const Text('Lịch tái khám:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Ngày: ${_formatDate(t.followUp!.date)}${t.followUp!.notes != null && t.followUp!.notes!.isNotEmpty ? ', ghi chú: ${t.followUp!.notes}' : ''}'),
                ],
                if (t.notes != null && t.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Ghi chú: ${t.notes}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLifestylesTab() {
    if (loadingLifestyles) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorLifestyles != null) {
      return Center(child: Text(errorLifestyles!, style: const TextStyle(color: Colors.red)));
    }
    if (lifestyles.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu lối sống'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: lifestyles.length,
      itemBuilder: (context, index) {
        final l = lifestyles[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loại hoạt động: ${l.activityType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Mô tả: ${l.description}'),
                Text('Tần suất: ${l.frequency}'),
                if (l.duration != null && l.duration!.isNotEmpty) Text('Thời gian: ${l.duration}'),
                if (l.startDate != null) Text('Ngày bắt đầu: ${_formatDate(l.startDate)}'),
                if (l.notes != null && l.notes!.isNotEmpty) Text('Ghi chú: ${l.notes}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthDataTab() {
    if (loadingHealthData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorHealthData != null) {
      return Center(child: Text(errorHealthData!, style: const TextStyle(color: Colors.red)));
    }
    if (healthDataList.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu sức khỏe'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: healthDataList.length,
      itemBuilder: (context, index) {
        final data = healthDataList[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loại dữ liệu: ${data.dataType}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Giá trị: ${data.value} ${data.unit}'),
                Text('Thời gian đo: ${_formatDate(data.measurementTime)}'),
                if (data.measurementLocation != null && data.measurementLocation!.isNotEmpty)
                  Text('Nơi đo: ${data.measurementLocation}'),
                if (data.notes != null && data.notes!.isNotEmpty)
                  Text('Ghi chú: ${data.notes}'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildPlaceholder(String label) {
    return Center(
      child: Text('Chức năng $label đang phát triển', style: const TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
} 