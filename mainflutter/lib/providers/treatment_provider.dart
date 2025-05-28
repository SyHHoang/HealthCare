import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/treatment.dart';
import '../services/api_service.dart';

part 'treatment_provider.g.dart';

@riverpod
class TreatmentNotifier extends _$TreatmentNotifier {
  static const String _baseEndpoint = '/api/medical-record/treatments';

  @override
  FutureOr<List<Treatment>> build() async {
    return getAllTreatments();
  }

  Future<List<Treatment>> getAllTreatments() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(_baseEndpoint);
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      return data.map((json) => Treatment.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu điều trị: $e');
    }
  }

  Future<void> addTreatment(Treatment treatment) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post(_baseEndpoint, treatment.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể thêm thông tin điều trị: $e');
    }
  }

  Future<void> updateTreatment(Treatment treatment) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('$_baseEndpoint/${treatment.id}', treatment.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin điều trị: $e');
    }
  }

  Future<void> deleteTreatment(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('$_baseEndpoint/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể xóa thông tin điều trị: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
} 