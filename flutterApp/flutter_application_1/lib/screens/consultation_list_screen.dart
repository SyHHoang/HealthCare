import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor.dart';
import '../services/consultation_service.dart';
import '../providers/message_provider.dart';
//import 'chat_screen.dart';
import 'doctor_info_screen.dart';

class ConsultationListScreen extends ConsumerStatefulWidget {
  const ConsultationListScreen({super.key});

  @override
  ConsumerState<ConsultationListScreen> createState() => _ConsultationListScreenState();
}

class _ConsultationListScreenState extends ConsumerState<ConsultationListScreen> {
  @override
  void initState() {
    super.initState();
    // Làm mới dữ liệu khi màn hình được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(consultationListProvider);
      debugPrint('ConsultationListScreen: Đã làm mới dữ liệu');
    });
  }

  void _refreshData() {
    // Sử dụng provider mới để làm mới dữ liệu
    ref.read(refreshConsultationControllerProvider.notifier).refreshConsultationList();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang làm mới danh sách...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi trạng thái làm mới từ controller
    ref.watch(refreshConsultationControllerProvider);
    // Sử dụng consultationListProvider để lấy danh sách bác sĩ tư vấn
    final doctorsAsync = ref.watch(consultationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bác sĩ tư vấn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DoctorSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: doctorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (doctors) {
          if (doctors.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Bạn chưa có bác sĩ tư vấn nào',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy thêm bác sĩ vào danh sách tư vấn để bắt đầu nhận tư vấn từ bác sĩ',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorConsultationCard(doctor: doctor);
            },
          );
        },
      ),
    );
  }
}

class DoctorConsultationCard extends ConsumerWidget {
  final Doctor doctor;

  const DoctorConsultationCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isOnline = ref.watch(onlineDoctorsProvider.notifier).isDoctorOnline(doctor.id ?? '');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorInfoScreen(doctor: doctor),
            ),
          ).then((_) {
            // Làm mới dữ liệu khi quay lại từ DoctorInfoScreen sử dụng controller
            ref.read(refreshConsultationControllerProvider.notifier).refreshConsultationList();
            debugPrint('Quay lại từ DoctorInfoScreen, làm mới dữ liệu');
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: doctor.avatar != null
                    ? NetworkImage(doctor.avatar!)
                    : null,
                child: doctor.avatar == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty ?? 'Chuyên khoa: Chưa cập nhật',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (doctor.experience != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kinh nghiệm: ${doctor.experience} năm',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 12,
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class DoctorSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  DoctorSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Vui lòng nhập tên bác sĩ để tìm kiếm'),
      );
    }

    // Sử dụng dữ liệu từ provider đã có sẵn thay vì gọi lại API
    return Consumer(
      builder: (context, ref, child) {
        final doctorsAsync = ref.watch(consultationListProvider);
        
        return doctorsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Lỗi: $error')),
          data: (allDoctors) {
            // Lọc danh sách bác sĩ dựa trên từ khóa tìm kiếm
            final doctors = allDoctors.where((doctor) {
              final name = doctor.fullName.toLowerCase();
              final searchLower = query.toLowerCase();
              return name.contains(searchLower);
            }).toList();
            
            if (doctors.isEmpty) {
              return const Center(child: Text('Không tìm thấy bác sĩ tư vấn phù hợp'));
            }

            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                return DoctorConsultationCard(doctor: doctors[index]);
              },
            );
          }
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Nhập tên bác sĩ tư vấn để tìm kiếm'),
    );
  }
} 