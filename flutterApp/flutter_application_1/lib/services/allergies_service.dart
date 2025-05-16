import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/allergy.dart';
import 'api_service.dart';

final allergiesServiceProvider = Provider((ref) {
  return AllergiesService(ref.watch(apiServiceProvider));
});

class AllergiesService {
  final ApiService _apiService;

  AllergiesService(this._apiService);

  Future<List<Allergy>> getAllergies() async {
    final response = await _apiService.get('/api/medical-record/allergies');
    return (response['data'] as List)
        .map((json) => Allergy.fromJson(json))
        .toList();
  }

  Future<Allergy> addAllergy({
    required String allergen,
    required String type,
    required String severity,
    required List<String> symptoms,
    DateTime? firstOccurrence,
    DateTime? lastOccurrence,
    String? treatment,
    String? notes,
  }) async {
    final response = await _apiService.post('/api/medical-record/allergies', {
      'allergen': allergen,
      'type': type,
      'severity': severity,
      'symptoms': symptoms,
      if (firstOccurrence != null)
        'firstOccurrence': firstOccurrence.toIso8601String(),
      if (lastOccurrence != null)
        'lastOccurrence': lastOccurrence.toIso8601String(),
      if (treatment != null) 'treatment': treatment,
      if (notes != null) 'notes': notes,
    });
    return Allergy.fromJson(response['data']);
  }

  Future<Allergy> updateAllergy(Allergy allergy) async {
    final response = await _apiService.put(
      '/api/medical-record/allergies/${allergy.id}',
      {
        'allergen': allergy.allergen,
        'type': allergy.type,
        'severity': allergy.severity,
        'symptoms': allergy.symptoms,
        if (allergy.firstOccurrence != null)
          'firstOccurrence': allergy.firstOccurrence!.toIso8601String(),
        if (allergy.lastOccurrence != null)
          'lastOccurrence': allergy.lastOccurrence!.toIso8601String(),
        if (allergy.treatment != null) 'treatment': allergy.treatment,
        if (allergy.notes != null) 'notes': allergy.notes,
        'isActive': allergy.isActive,
      },
    );
    return Allergy.fromJson(response['data']);
  }

  Future<void> deleteAllergy(String id) async {
    await _apiService.delete('/api/medical-record/allergies/$id');
  }
} 