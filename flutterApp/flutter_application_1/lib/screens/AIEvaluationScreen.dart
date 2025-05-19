import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/allergy.dart';
import '../models/health_data.dart';
import '../models/lifestyle.dart';
import '../models/prescription.dart';
import '../models/treatment.dart';
import '../models/vaccination.dart';

class AIEvaluationScreen extends ConsumerStatefulWidget {
  final dynamic user; // Có thể là User hoặc Doctor
  final String? patientId; // ID của bệnh nhân nếu là bác sĩ xem

  const AIEvaluationScreen({
    super.key,
    required this.user,
    this.patientId,
  });

  @override
  ConsumerState<AIEvaluationScreen> createState() => _AIEvaluationScreenState();
}

class _AIEvaluationScreenState extends ConsumerState<AIEvaluationScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _evaluationData = {};

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  Future<void> _fetchEvaluationData() async {
    // TODO: Gọi API để lấy dữ liệu đánh giá
    // Tạm thời sử dụng dữ liệu mẫu
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _evaluationData = {
        'allergies': {
          'status': 'warning',
          'message': 'Có 2 dị ứng đang hoạt động: Penicillin (Nặng) và Đậu phộng (Trung bình). Cần thận trọng khi sử dụng thuốc và thực phẩm.',
        },
        'healthData': {
          'status': 'good',
          'message': 'Huyết áp: 120/80 mmHg, Nhịp tim: 75 bpm, Đường huyết: 5.5 mmol/L. Các chỉ số đều trong giới hạn bình thường.',
        },
        'lifestyle': {
          'status': 'good',
          'message': 'Tập thể dục đều đặn 30 phút/ngày, chế độ ăn cân bằng. Cần cải thiện thời gian ngủ.',
        },
        'medications': {
          'status': 'warning',
          'message': 'Đang sử dụng 3 loại thuốc thường xuyên. Cần tuân thủ đúng liều lượng và thời gian.',
        },
        'symptoms': {
          'status': 'warning',
          'message': 'Có triệu chứng đau đầu và mệt mỏi kéo dài. Cần theo dõi và tái khám nếu không cải thiện.',
        },
        'treatment': {
          'status': 'good',
          'message': 'Đang trong quá trình điều trị viêm xoang. Tuân thủ tốt phác đồ điều trị.',
        },
        'vaccination': {
          'status': 'good',
          'message': 'Đã tiêm đầy đủ các mũi vắc xin cơ bản. Cần tiêm nhắc lại vắc xin cúm.',
        },
        'conclusion': {
          'message': 'Tình trạng sức khỏe chung đang ở mức tốt. Các chỉ số cơ bản đều trong giới hạn cho phép. Tuy nhiên, cần lưu ý:',
          'points': [
            'Quản lý tốt các dị ứng đang hoạt động',
            'Theo dõi các triệu chứng đau đầu và mệt mỏi',
            'Tuân thủ đúng phác đồ điều trị và lịch uống thuốc',
            'Cải thiện thời gian ngủ và chất lượng giấc ngủ',
          ],
        },
        'recommendations': [
          'Duy trì chế độ ăn uống lành mạnh, tránh các thực phẩm gây dị ứng',
          'Tiếp tục tập thể dục đều đặn 30 phút mỗi ngày',
          'Đặt lịch tái khám định kỳ sau 2 tuần',
          'Ghi chú lại các triệu chứng bất thường để báo cáo với bác sĩ',
          'Đặt lịch tiêm vắc xin cúm trong tháng tới',
        ],
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sức khỏe bằng AI'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEvaluationSection(
              title: 'Đánh giá chi tiết',
              icon: Icons.medical_services,
              child: Column(
                children: [
                  _buildMetricItem(
                    title: 'Dị ứng',
                    icon: Icons.warning_amber,
                    status: _evaluationData['allergies']['status'],
                    message: _evaluationData['allergies']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Chỉ số sức khỏe',
                    icon: Icons.monitor_heart,
                    status: _evaluationData['healthData']['status'],
                    message: _evaluationData['healthData']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Lối sống',
                    icon: Icons.directions_run,
                    status: _evaluationData['lifestyle']['status'],
                    message: _evaluationData['lifestyle']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Thuốc men',
                    icon: Icons.medication,
                    status: _evaluationData['medications']['status'],
                    message: _evaluationData['medications']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Triệu chứng',
                    icon: Icons.sick,
                    status: _evaluationData['symptoms']['status'],
                    message: _evaluationData['symptoms']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Điều trị',
                    icon: Icons.healing,
                    status: _evaluationData['treatment']['status'],
                    message: _evaluationData['treatment']['message'],
                  ),
                  _buildMetricItem(
                    title: 'Tiêm chủng',
                    icon: Icons.vaccines,
                    status: _evaluationData['vaccination']['status'],
                    message: _evaluationData['vaccination']['message'],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildEvaluationSection(
              title: 'Kết luận tình trạng',
              icon: Icons.assignment_turned_in,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _evaluationData['conclusion']['message'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ...List<Widget>.from(
                      (_evaluationData['conclusion']['points'] as List).map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.arrow_right, size: 20),
                              const SizedBox(width: 8),
                              Expanded(child: Text(point.toString())),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildEvaluationSection(
              title: 'Lời khuyên',
              icon: Icons.lightbulb,
              child: Column(
                children: List<Widget>.from(
                  (_evaluationData['recommendations'] as List).map(
                    (recommendation) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(child: Text(recommendation.toString())),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildMetricItem({
    required String title,
    required IconData icon,
    required String status,
    required String message,
  }) {
    Color statusColor;
    switch (status) {
      case 'good':
        statusColor = Colors.green;
        break;
      case 'warning':
        statusColor = Colors.orange;
        break;
      case 'bad':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'good' ? 'Tốt' : status == 'warning' ? 'Cần lưu ý' : 'Không tốt',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
} 