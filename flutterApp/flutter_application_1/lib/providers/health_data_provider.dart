import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/health_data.dart';
import '../services/token_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
part 'health_data_provider.g.dart';

@riverpod
class HealthDataNotifier extends _$HealthDataNotifier {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';
    @override
  Future<List<HealthData>> build() async {
    return _fetchHealthData();
  }

  Future<List<HealthData>> _fetchHealthData() async {
    try {
      final token = await TokenService.getToken();
      final response = await http.get(
        Uri.parse('$apiUrl/medical-record/health-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => HealthData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load health data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> addHealthData(HealthData healthData) async {
    try {
      final token = await TokenService.getToken();
      final response = await http.post(
        Uri.parse('$apiUrl/medical-record/health-data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(healthData.toJson()),
      );

      if (response.statusCode == 201) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _fetchHealthData());
      } else {
        throw Exception('Failed to add health data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateHealthData(HealthData healthData) async {
    try {
      final token = await TokenService.getToken();
      final response = await http.put(
        Uri.parse('$apiUrl/medical-record/health-data/${healthData.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(healthData.toJson()),
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _fetchHealthData());
      } else {
        throw Exception('Failed to update health data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> deleteHealthData(String id) async {
    try {
      final token = await TokenService.getToken();
      final response = await http.delete(
        Uri.parse('$apiUrl/medical-record/health-data/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() => _fetchHealthData());
      } else {
        throw Exception('Failed to delete health data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
} 