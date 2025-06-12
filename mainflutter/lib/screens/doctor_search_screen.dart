import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/doctor_service.dart';
import '../services/specialty_service.dart';
import '../models/specialty.dart';
import 'doctor_detail_screen.dart';

class DoctorSearchScreen extends ConsumerStatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  ConsumerState<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends ConsumerState<DoctorSearchScreen> {
  final _searchController = TextEditingController();
  final _smartSearchController = TextEditingController();
  bool _isSmartSearchLoading = false;
  List<Specialty> _smartSearchResults = [];
  String? _selectedSmartSpecialty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctors();
    });
  }

  Future<void> _loadDoctors() async {
    try {
      print('Đang tải danh sách bác sĩ...');
      await ref.read(doctorServiceProvider(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      ).notifier).refreshDoctors();
      print('Đã tải xong danh sách bác sĩ');
    } catch (e) {
      print('Lỗi khi tải danh sách bác sĩ: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách bác sĩ: $e')),
        );
      }
    }
  }

  Future<void> _handleSmartSearch() async {
    if (_smartSearchController.text.isEmpty) return;

    setState(() {
      _isSmartSearchLoading = true;
    });

    try {
      print('Bắt đầu tìm kiếm thông minh với từ khóa: ${_smartSearchController.text}');
      final specialtyService = ref.read(specialtyServiceProvider.notifier);
      final result = await specialtyService.predictSpecialty(_smartSearchController.text);
      print('Kết quả thô từ API predictSpecialty: $result');
      
      List<Specialty> specialties = [];
      
      if (result != null) {
        print('Xử lý kết quả tìm kiếm thông minh...');
        
        // Kiểm tra cấu trúc dữ liệu
        if (result is Map<String, dynamic>) {
          print('Cấu trúc dữ liệu: ${result.keys.toList()}');
          
          // Kiểm tra xem có phải là kết quả từ model không
          if (result.containsKey('specialties') && result.containsKey('confidences')) {
            print('Phát hiện kết quả từ model AI');
            final List<dynamic> specialtiesList = result['specialties'] ?? [];
            final Map<String, dynamic> confidences = result['confidences'] ?? {};
            
            print('Danh sách chuyên khoa: $specialtiesList');
            print('Độ tin cậy: $confidences');
            
            // Chuyển đổi thành danh sách Specialty
            specialties = specialtiesList.map((name) {
              final confidence = confidences[name]?.toDouble() ?? 0.0;
              return Specialty(
                name: name.toString(),
                description: 'Chuyên khoa được đề xuất dựa trên mô tả của bạn',
                isSuggested: true,
                confidence: confidence,
              );
            }).toList();
          } else {
            // Xử lý kết quả đơn lẻ
            print('Xử lý kết quả đơn lẻ');
            final Map<String, dynamic> safeData = {
              'name': result['name']?.toString() ?? 'Chưa có tên',
              'description': result['description']?.toString() ?? 'Chưa có mô tả',
              'icon': result['icon']?.toString(),
              'isSuggested': result['isSuggested'] ?? false,
              'confidence': result['confidence']?.toDouble(),
            };

            if (result['_id'] != null) {
              safeData['_id'] = result['_id'].toString();
            }

            print('Dữ liệu đã được chuẩn bị: $safeData');
            
            try {
              final specialty = Specialty.fromJson(safeData);
              print('Đã chuyển đổi kết quả thành Specialty: ${specialty.name}');
              specialties = [specialty];
            } catch (e) {
              print('Lỗi khi chuyển đổi kết quả thành Specialty: $e');
              specialties = [Specialty(
                name: safeData['name'] as String,
                description: safeData['description'] as String,
                icon: safeData['icon'] as String?,
                isSuggested: safeData['isSuggested'] as bool,
                confidence: safeData['confidence'] as double?,
              )];
            }
          }
        } else {
          print('Kết quả không phải là Map: ${result.runtimeType}');
        }
      } else {
        print('Kết quả từ API là null');
      }

      print('Kết quả cuối cùng: ${specialties.length} chuyên khoa được tìm thấy');
      if (specialties.isNotEmpty) {
        print('Chi tiết các chuyên khoa:');
        for (var specialty in specialties) {
          print('- ${specialty.name} (Mô tả: ${specialty.description})');
        }
      }
      
      setState(() {
        _smartSearchResults = specialties;
        _isSmartSearchLoading = false;
      });
    } catch (e) {
      print('Lỗi trong quá trình tìm kiếm thông minh: $e');
      setState(() {
        _isSmartSearchLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _handleSmartSpecialtyClick(Specialty specialty) async {
    print('Đã chọn chuyên khoa: ${specialty.name}');
    setState(() {
      _selectedSmartSpecialty = specialty.id ?? specialty.name;
    });

    try {
      final doctorService = ref.read(doctorServiceProvider(
        searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
      ).notifier);

      print('Đang tải danh sách bác sĩ cho chuyên khoa: ${specialty.name}');
      
      // Nếu là chuyên khoa được đề xuất (không có trong hệ thống)
      if (specialty.isSuggested) {
        print('Đây là chuyên khoa được đề xuất, tìm kiếm theo tên chuyên khoa');
        await doctorService.refreshDoctors(specialty: specialty.name);
      } else {
        // Nếu là chuyên khoa có trong hệ thống
        print('Đây là chuyên khoa có trong hệ thống, tìm kiếm theo ID: ${specialty.id}');
        await doctorService.refreshDoctors(specialty: specialty.id);
      }

      print('Đã tải xong danh sách bác sĩ cho chuyên khoa: ${specialty.name}');
      
      // Hiển thị thông báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã tìm thấy các bác sĩ thuộc chuyên khoa ${specialty.name}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Lỗi khi tải danh sách bác sĩ cho chuyên khoa ${specialty.name}: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách bác sĩ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorsAsync = ref.watch(doctorServiceProvider(
      searchQuery: _searchController.text.isEmpty ? null : _searchController.text,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm bác sĩ'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tìm kiếm thông thường
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm bác sĩ...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadDoctors();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (_) => _loadDoctors(),
                ),
                const SizedBox(height: 16),
                // Tìm kiếm thông minh
                TextField(
                  controller: _smartSearchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm chuyên khoa dựa vào mô tả...',
                    prefixIcon: const Icon(Icons.psychology),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isSmartSearchLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _handleSmartSearch,
                          ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _smartSearchController.clear();
                            setState(() {
                              _smartSearchResults = [];
                              _selectedSmartSpecialty = null;
                            });
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onSubmitted: (_) => _handleSmartSearch(),
                ),
              ],
            ),
          ),
          // Hiển thị kết quả tìm kiếm thông minh
          if (_smartSearchResults.isNotEmpty)
            Expanded(
              flex: 2,
              child: ListView.builder(
                itemCount: _smartSearchResults.length,
                itemBuilder: (context, index) {
                  final specialty = _smartSearchResults[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      specialty.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      specialty.description,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (specialty.isSuggested)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Đề xuất',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _handleSmartSpecialtyClick(specialty),
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Xem bác sĩ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedSmartSpecialty == (specialty.id ?? specialty.name)
                                    ? Theme.of(context).primaryColor
                                    : null,
                                foregroundColor: _selectedSmartSpecialty == (specialty.id ?? specialty.name)
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          // Hiển thị danh sách bác sĩ
          Expanded(
            flex: 3,
            child: doctorsAsync.when(
              data: (doctors) {
                if (doctors.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy bác sĩ nào'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _loadDoctors,
                  child: ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: doctor.avatar != null
                                ? NetworkImage(doctor.avatar!)
                                : null,
                            child: doctor.avatar == null
                                ? Text(
                                    doctor.fullName[0],
                                    style: const TextStyle(fontSize: 20),
                                  )
                                : null,
                          ),
                          title: Text(doctor.fullName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (doctor.specialty != null)
                                Text('Chuyên khoa: ${doctor.specialty}'),
                              if (doctor.experience != null)
                                Text('Kinh nghiệm: ${doctor.experience} năm'),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailScreen(doctor: doctor),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Đã xảy ra lỗi: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDoctors,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _smartSearchController.dispose();
    super.dispose();
  }
} 