import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/doctor.dart';
import '../../models/user.dart';
import '../../providers/doctor_chat_provider.dart';
import 'doctor_chat_screen.dart';

class DoctorPatientListScreen extends ConsumerWidget {
  final Doctor doctor;

  const DoctorPatientListScreen({
    super.key,
    required this.doctor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsync = ref.watch(doctorChatListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bệnh nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(doctorChatListProvider),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PatientSearchDelegate(ref),
              );
            },
          ),
        ],
      ),
      body: patientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(doctorChatListProvider),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
        data: (patients) {
          if (patients.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Bạn chưa có bệnh nhân nào',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bệnh nhân sẽ xuất hiện ở đây khi họ liên hệ với bạn',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patientChat = patients[index];
              // Từ dữ liệu chat, tạo đối tượng User cho bệnh nhân
              final patientData = patientChat['userId'] ?? {};
              final patient = User(
                id: patientData['_id'] ?? '',
                email: patientData['email'] ?? '',
                fullname: patientData['fullname'] ?? 'Bệnh nhân',
                avatar: patientData['avatar'],
              );
              
              return PatientCard(
                patient: patient,
                lastMessage: patientChat['lastMessage'] != null 
                    ? patientChat['lastMessage']['content'] ?? ''
                    : '',
                lastMessageTime: patientChat['lastMessage'] != null && patientChat['lastMessage']['timestamp'] != null
                    ? DateTime.parse(patientChat['lastMessage']['timestamp'])
                    : null,
                chatId: patientChat['_id'] ?? '',
              );
            },
          );
        },
      ),
    );
  }
}

class PatientCard extends ConsumerWidget {
  final User patient;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String chatId;

  const PatientCard({
    super.key, 
    required this.patient,
    this.lastMessage = '',
    this.lastMessageTime,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorChatScreen(
                patientId: patient.id ?? '',
                patientName: patient.fullname,
                patientAvatar: patient.avatar,
                chatId: chatId,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: patient.avatar != null
                    ? NetworkImage(patient.avatar!)
                    : null,
                child: patient.avatar == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.fullname,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (lastMessage.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        lastMessage,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (lastMessageTime != null)
                    Text(
                      _formatTime(lastMessageTime!),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Hôm qua';
    } else {
      return '${time.day}/${time.month}';
    }
  }
}

class PatientSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  PatientSearchDelegate(this.ref);

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
        child: Text('Vui lòng nhập tên bệnh nhân để tìm kiếm'),
      );
    }

    final patientList = ref.watch(doctorChatListProvider);
    
    return patientList.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
      data: (patients) {
        final filteredPatients = patients.where((chat) {
          final patientData = chat['userId'] ?? {};
          final name = patientData['fullname']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return name.contains(searchLower);
        }).toList();
        
        if (filteredPatients.isEmpty) {
          return const Center(child: Text('Không tìm thấy bệnh nhân phù hợp'));
        }

        return ListView.builder(
          itemCount: filteredPatients.length,
          itemBuilder: (context, index) {
            final patientChat = filteredPatients[index];
            final patientData = patientChat['userId'] ?? {};
            final patient = User(
              id: patientData['_id'] ?? '',
              email: patientData['email'] ?? '',
              fullname: patientData['fullname'] ?? 'Bệnh nhân',
              avatar: patientData['avatar'],
            );
            
            return PatientCard(
              patient: patient,
              lastMessage: patientChat['lastMessage'] != null 
                  ? patientChat['lastMessage']['content'] ?? ''
                  : '',
              lastMessageTime: patientChat['lastMessage'] != null && patientChat['lastMessage']['timestamp'] != null
                  ? DateTime.parse(patientChat['lastMessage']['timestamp'])
                  : null,
              chatId: patientChat['_id'] ?? '',
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(
      child: Text('Nhập tên bệnh nhân để tìm kiếm'),
    );
  }
} 