import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/lifestyle.dart';
import '../services/api_service.dart';

part 'lifestyle_provider.g.dart';

@riverpod
class LifestyleNotifier extends _$LifestyleNotifier {
  static const String _baseEndpoint = '/medical-record/lifestyles';

  @override
  FutureOr<List<Lifestyle>> build() async {
    return getAllLifestyles();
  }

  Future<List<Lifestyle>> getAllLifestyles() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(_baseEndpoint);
      
      final List<dynamic> data = response is List ? response : (response['data'] ?? []);
      return data.map((json) => Lifestyle.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu lối sống: $e');
    }
  }

  Future<void> addLifestyle(Lifestyle lifestyle) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.post(_baseEndpoint, lifestyle.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể thêm thông tin lối sống: $e');
    }
  }

  Future<void> updateLifestyle(Lifestyle lifestyle) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('$_baseEndpoint/${lifestyle.id}', lifestyle.toJson());
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin lối sống: $e');
    }
  }

  Future<void> deleteLifestyle(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('$_baseEndpoint/$id');
      ref.invalidateSelf();
    } catch (e) {
      throw Exception('Không thể xóa thông tin lối sống: $e');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
} 