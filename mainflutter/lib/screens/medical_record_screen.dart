import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'allergy_screen.dart';
import 'health_data_screen.dart';
import 'lifestyle_screen.dart';
import 'vaccination_screen.dart';
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AIEvaluationScreen(user: null),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Dị ứng',
            icon: Icons.warning_amber,
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
            title: 'Lịch sử tiêm chủng',
            icon: Icons.vaccines,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VaccinationScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Chỉ số sức khỏe',
            icon: Icons.monitor_heart,
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LifestyleScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Đơn thuốc',
            icon: Icons.receipt_long,
            onTap: () {
              // TODO: Navigate to prescriptions screen
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrescriptionScreen(),
                ),
              );
            },
          ),
          _buildSection(
            title: 'Điều trị',
            icon: Icons.healing,
            onTap: () {
              // TODO: Navigate to treatments screen
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TreatmentScreen(),
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
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 