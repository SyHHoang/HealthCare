import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'allergy_screen.dart';
import 'health_data_screen.dart';
import 'lifestyle_screen.dart';
import 'prescription_screen.dart';
import 'treatment_screen.dart';
import 'AIEvaluationScreen.dart';

class MedicalRecordScreen extends ConsumerStatefulWidget {
  const MedicalRecordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends ConsumerState<MedicalRecordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ sức khỏe'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Đánh giá sức khỏe bằng AI',
            icon: Icons.psychology,
            description: 'Phân tích và đánh giá tình trạng sức khỏe của bạn bằng trí tuệ nhân tạo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIEvaluationScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Dị ứng',
            icon: Icons.warning_amber,
            description: 'Quản lý thông tin về các dị ứng của bạn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllergyScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Triệu chứng',
            icon: Icons.medical_information,
            description: 'Ghi nhận và theo dõi các triệu chứng bệnh',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AllergyScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Chỉ số sức khỏe',
            icon: Icons.monitor_heart,
            description: 'Theo dõi các chỉ số sức khỏe quan trọng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HealthDataScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Lối sống',
            icon: Icons.directions_run,
            description: 'Quản lý thông tin về lối sống và thói quen sinh hoạt',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LifestyleScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 