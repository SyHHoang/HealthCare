import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/symptom.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'symptom_provider.g.dart';

@riverpod
class SymptomNotifier extends _$SymptomNotifier {
  final storage = const FlutterSecureStorage();
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  @override
  FutureOr<List<Symptom>> build() async {
    return getAllSymptoms();
  }

  Future<List<Symptom>> getAllSymptoms() async {
    try {
      final token = await storage.read(key: 'token');
      if (token == null) throw Exception('Không có token!');

      final response = await http.get(
          Uri.parse('$apiUrl/medical-record/symptoms'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => Symptom.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lấy dữ liệu triệu chứng');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy dữ liệu triệu chứng: $e');
    }
  }

  Future<void> addSymptom(Symptom symptom) async {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('Không có token!');

    final response = await http.post(
      Uri.parse('$apiUrl/medical-record/symptoms'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(symptom.toJson()),
    );

    if (response.statusCode == 201) {
      ref.invalidateSelf();
    } else {
      throw Exception('Không thể thêm triệu chứng');
    }
  }

  Future<void> updateSymptom(Symptom symptom) async {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('Không có token!');

    final response = await http.put(
      Uri.parse('$apiUrl/medical-record/symptoms/${symptom.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(symptom.toJson()),
    );

    if (response.statusCode == 200) {
      ref.invalidateSelf();
    } else {
      throw Exception('Không thể cập nhật triệu chứng');
    }
  }

  Future<void> deleteSymptom(String id) async {
    final token = await storage.read(key: 'token');
    if (token == null) throw Exception('Không có token!');

    final response = await http.delete(
      Uri.parse('$apiUrl/medical-record/symptoms/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      ref.invalidateSelf();
    } else {
      throw Exception('Không thể xóa triệu chứng');
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
} 