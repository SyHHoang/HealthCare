import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/symptom.dart';
import '../../models/prescription.dart';
import '../../models/allergy.dart';
import '../../models/vaccination.dart';
import '../../models/treatment.dart';
import '../../models/lifestyle.dart';
import '../../models/health_data.dart';
import '../../services/api_service.dart';
import '../AIEvaluationScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PatientMedicalRecordScreen extends ConsumerStatefulWidget {
  final String patientId;
  final String patientName;
  final String avatarUrl;
  const PatientMedicalRecordScreen({super.key, required this.patientId, required this.patientName, required this.avatarUrl});

  @override
  ConsumerState<PatientMedicalRecordScreen> createState() => _PatientMedicalRecordScreenState();
}

class _PatientMedicalRecordScreenState extends ConsumerState<PatientMedicalRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Tab> _tabs = const [
    Tab(text: 'Thông tin'),
    Tab(text: 'Triệu chứng'),
    Tab(text: 'Dị ứng'),
    Tab(text: 'Lối sống'),
    Tab(text: 'Dữ liệu sức khỏe'),
  ];

  // State cho tab Triệu chứng
  bool loadingSymptoms = false;
  String? errorSymptoms;
  List<Symptom> symptoms = [];

  // State cho tab Dị ứng
  bool loadingAllergies = false;
  String? errorAllergies;
  List<Allergy> allergies = [];

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
      if (_tabController.index == 2 && allergies.isEmpty && !loadingAllergies) {
        fetchAllergies();
      }
      if (_tabController.index == 3 && lifestyles.isEmpty && !loadingLifestyles) {
        fetchLifestyles();
      }
      if (_tabController.index == 4 && healthDataList.isEmpty && !loadingHealthData) {
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
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/medical-record/symptoms/doctor/${widget.patientId}');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      setState(() {
        symptoms = data.map((e) => Symptom.fromJson(e)).toList();
      });
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

  Future<void> fetchAllergies() async {
    setState(() {
      loadingAllergies = true;
      errorAllergies = null;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/medical-record/allergies/doctor/${widget.patientId}');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      setState(() {
        allergies = data.map((e) => Allergy.fromJson(e)).toList();
      });
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

  Future<void> fetchLifestyles() async {
    setState(() {
      loadingLifestyles = true;
      errorLifestyles = null;
    });
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/medical-record/lifestyles/doctor/${widget.patientId}');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      setState(() {
        lifestyles = data.map((e) => Lifestyle.fromJson(e)).toList();
      });
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
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/medical-record/health-data/doctor/${widget.patientId}');
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      setState(() {
        healthDataList = data.map((e) => HealthData.fromJson(e)).toList();
      });
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
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology),
            tooltip: 'Đánh giá sức khỏe bằng AI',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AIEvaluationScreen(
                    patientId: widget.patientId,
                  ),
                ),
              );
            },
          ),
        ],
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
          _buildAllergiesTab(),
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
            title: Text(s.name ?? 'Không có tên', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (s.severity != null) Text('Mức độ: ${s.severity}'),
                if (s.startDate != null) Text('Bắt đầu: ${_formatDate(s.startDate)}'),
                if (s.notes != null && s.notes!.isNotEmpty) Text('Ghi chú: ${s.notes}'),
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