import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/api_service.dart';

class AIEvaluationScreen extends ConsumerStatefulWidget {
  final String? patientId; // ID của bệnh nhân nếu là bác sĩ xem

  const AIEvaluationScreen({
    super.key,
    this.patientId,
  });

  @override
  ConsumerState<AIEvaluationScreen> createState() => _AIEvaluationScreenState();
}

class _AIEvaluationScreenState extends ConsumerState<AIEvaluationScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _evaluationData = {};
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHealthData();
  }

  Future<void> _fetchHealthData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final apiService = ref.read(apiServiceProvider);
      String baseEndpoint = '/medical-record';
      
      // Xác định endpoint dựa trên việc có patientId hay không
      String symptomsEndpoint = widget.patientId != null 
          ? '$baseEndpoint/symptoms/doctor/${widget.patientId}'
          : '$baseEndpoint/symptoms';
      String allergiesEndpoint = widget.patientId != null 
          ? '$baseEndpoint/allergies/doctor/${widget.patientId}'
          : '$baseEndpoint/allergies';
      String lifestyleEndpoint = widget.patientId != null 
          ? '$baseEndpoint/lifestyles/doctor/${widget.patientId}'
          : '$baseEndpoint/lifestyles';
      String healthDataEndpoint = widget.patientId != null 
          ? '$baseEndpoint/health-data/doctor/${widget.patientId}'
          : '$baseEndpoint/health-data';

      // Gọi các API song song
      final responses = await Future.wait([
        apiService.get(symptomsEndpoint),
        apiService.get(allergiesEndpoint),
        apiService.get(lifestyleEndpoint),
        apiService.get(healthDataEndpoint),
      ]);

      // Kiểm tra nếu tất cả đều rỗng
      bool isAllEmpty = responses.every((data) {
        return data == null || (data is List && data.isEmpty);
      });

      if (isAllEmpty) {
        setState(() {
          _errorMessage = 'Bạn cần nhập ít nhất một dữ liệu sức khỏe để AI có thể đánh giá!';
          _isLoading = false;
        });
        return;
      }

      // Gửi dữ liệu để đánh giá
      final evaluationData = {
        'symptoms': responses[0],
        'allergies': responses[1],
        'lifestyle': responses[2],
        'healthData': responses[3],
      };

      final evaluationResponse = await apiService.post(
        '/health-evaluation/evaluate',
        evaluationData,
      );

      setState(() {
        _evaluationData = evaluationResponse;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải đánh giá sức khỏe. Vui lòng thử lại sau.';
        _isLoading = false;
      });
      debugPrint('Error fetching health evaluation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đánh giá sức khỏe bằng AI'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Đang phân tích dữ liệu sức khỏe...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchHealthData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEvaluationSection(
                        title: 'Đánh giá chi tiết',
                        icon: Icons.checklist,
                        child: _buildDetailedEvaluation(),
                      ),
                      const SizedBox(height: 30),
                      _buildEvaluationSection(
                        title: 'Kết luận tình trạng',
                        icon: Icons.medical_services,
                        child: _buildConclusion(),
                      ),
                      const SizedBox(height: 30),
                      _buildEvaluationSection(
                        title: 'Lời khuyên',
                        icon: Icons.lightbulb,
                        child: _buildRecommendations(),
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
            Icon(icon, color: Colors.blue[400], size: 24),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2c3e50),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }

  Widget _buildDetailedEvaluation() {
    final detailedEvaluation = _evaluationData['detailedEvaluation'] ?? {};
    
    if (detailedEvaluation.isEmpty) {
      return Center(
        child: Text(
          'Không có dữ liệu đánh giá sức khỏe',
          style: TextStyle(
            color: Colors.red[400],
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: detailedEvaluation.entries.map<Widget>((entry) {
        return _buildMetricItem(
          title: entry.key,
          icon: _getIconForMetric(entry.key),
          content: entry.value,
        );
      }).toList(),
    );
  }

  Widget _buildMetricItem({
    required String title,
    required IconData icon,
    required dynamic content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFeee)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue[400], size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (content is Map)
            ...content.entries.map<Widget>((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF495057),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                )).toList()
          else
            Text(
              content.toString(),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF495057),
                height: 1.6,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConclusion() {
    final conclusion = _evaluationData['conclusion'] ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFeee)),
      ),
      child: Text(
        conclusion,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF495057),
          height: 1.8,
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = _evaluationData['recommendations'] ?? [];
    return Column(
      children: (recommendations as List).map<Widget>((recommendation) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFf8f9fa),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFeee)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2ecc71), size: 20),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  recommendation.toString(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF495057),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForMetric(String metric) {
    switch (metric) {
      case 'Triệu chứng':
        return Icons.thermostat;
      case 'Dị ứng':
        return Icons.warning;
      case 'Lối sống':
        return Icons.directions_run;
      case 'Dữ liệu sức khỏe':
        return Icons.favorite;
      case 'Thuốc men':
        return Icons.medication;
      case 'Điều trị':
        return Icons.healing;
      case 'Tiêm chủng':
        return Icons.vaccines;
      default:
        return Icons.info;
    }
  }
} 