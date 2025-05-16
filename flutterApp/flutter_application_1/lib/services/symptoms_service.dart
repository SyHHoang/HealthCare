import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/symptom.dart';
import 'api_service.dart';

final symptomsServiceProvider = Provider((ref) {
  return SymptomsService(ref.watch(apiServiceProvider));
});

class SymptomsService {
  final ApiService _apiService;

  SymptomsService(this._apiService);

  Future<List<Symptom>> getSymptoms() async {
    final response = await _apiService.get('/api/medical-record/symptoms');
    return (response['data'] as List)
        .map((json) => Symptom.fromJson(json))
        .toList();
  }

  Future<Symptom> addSymptom({
    required String name,
    required String severity,
    required DateTime startDate,
    String? notes,
  }) async {
    final response = await _apiService.post('/api/medical-record/symptoms', {
      'name': name,
      'severity': severity,
      'startDate': startDate.toIso8601String(),
      if (notes != null) 'notes': notes,
    });
    return Symptom.fromJson(response['data']);
  }

  Future<Symptom> updateSymptom(Symptom symptom) async {
    final response = await _apiService.put(
      '/api/medical-record/symptoms/${symptom.id}',
      symptom.toJson(),
    );
    return Symptom.fromJson(response['data']);
  }

  Future<void> deleteSymptom(String id) async {
    await _apiService.delete('/api/medical-record/symptoms/$id');
  }
} 