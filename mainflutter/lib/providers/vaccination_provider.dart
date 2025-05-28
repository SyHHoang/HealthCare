import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/vaccination.dart';
import '../services/api_service.dart';

part 'vaccination_provider.g.dart';

@riverpod
class VaccinationNotifier extends _$VaccinationNotifier {
  static const String _baseEndpoint = '/api/medical-record/vaccinations';

  @override
  FutureOr<List<Vaccination>> build() async {
    return getAllVaccinations();
  }

  Future<List<Vaccination>> getAllVaccinations() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(_baseEndpoint);
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      return data.map((json) => Vaccination.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu tiêm chủng: $e');
    }
  }

  Future<void> addVaccination(Vaccination vaccination) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post(_baseEndpoint, vaccination.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể thêm thông tin tiêm chủng: $e');
    }
  }

  Future<void> updateVaccination(Vaccination vaccination) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('$_baseEndpoint/${vaccination.id}', vaccination.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin tiêm chủng: $e');
    }
  }

  Future<void> deleteVaccination(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('$_baseEndpoint/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể xóa thông tin tiêm chủng: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
} 