import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/allergy.dart';
import '../services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
part 'allergies_provider.g.dart';

@riverpod
class AllergiesNotifier extends _$AllergiesNotifier {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';
 
  @override
  Future<List<Allergy>> build() async {
    return getAllergies();
  }

  Future<List<Allergy>> getAllergies() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không có token!');

      final response = await http.get(
        Uri.parse('$apiUrl/medical-record/allergies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      debugPrint('apiUrl allegre  : $apiUrl');
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Allergy.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy danh sách dị ứng');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách dị ứng: $e');
    }
  }

  Future<void> addAllergy(Allergy allergy) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không có token!');

      final response = await http.post(
        Uri.parse('$apiUrl/medical-record/allergies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(allergy.toJson()),
      );

      if (response.statusCode == 201) {
        state = AsyncValue.data([...state.value ?? [], allergy]);
      } else {
        throw Exception('Không thể thêm dị ứng');
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm dị ứng: $e');
    }
  }

  Future<void> updateAllergy(Allergy allergy) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không có token!');

      final response = await http.put(
        Uri.parse('$apiUrl/medical-record/allergies/${allergy.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(allergy.toJson()),
      );

      if (response.statusCode == 200) {
        state = AsyncValue.data(
          state.value?.map((a) => a.id == allergy.id ? allergy : a).toList() ?? [],
        );
      } else {
        throw Exception('Không thể cập nhật dị ứng');
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật dị ứng: $e');
    }
  }

  Future<void> deleteAllergy(String id) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) throw Exception('Không có token!');

      final response = await http.delete(
        Uri.parse('$apiUrl/medical-record/allergies/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        state = AsyncValue.data(
          state.value?.where((a) => a.id != id).toList() ?? [],
        );
      } else {
        throw Exception('Không thể xóa dị ứng');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa dị ứng: $e');
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getAllergies());
  }
} 