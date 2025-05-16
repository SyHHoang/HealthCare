import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/prescription.dart';
import '../services/api_service.dart';

part 'prescription_provider.g.dart';

@riverpod
class PrescriptionNotifier extends _$PrescriptionNotifier {
  static const String _baseEndpoint = '/api/medical-record/prescriptions';

  @override
  FutureOr<List<Prescription>> build() async {
    return getAllPrescriptions();
  }

  Future<List<Prescription>> getAllPrescriptions() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(_baseEndpoint);
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      return data.map((json) => Prescription.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu đơn thuốc: $e');
    }
  }

  Future<void> addPrescription(Prescription prescription) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post(_baseEndpoint, prescription.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể thêm đơn thuốc: $e');
    }
  }

  Future<void> updatePrescription(Prescription prescription) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('$_baseEndpoint/${prescription.id}', prescription.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể cập nhật đơn thuốc: $e');
    }
  }

  Future<void> deletePrescription(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('$_baseEndpoint/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể xóa đơn thuốc: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}