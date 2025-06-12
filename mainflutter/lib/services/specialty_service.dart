import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SpecialtyNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  SpecialtyNotifier() : super(const AsyncValue.loading()) {
    refreshSpecialties();
  }

  final String baseUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  Future<void> refreshSpecialties() async {
    try {
      state = const AsyncValue.loading();
      final response = await http.get(Uri.parse('$baseUrl/specialties'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        state = AsyncValue.data(data.cast<Map<String, dynamic>>());
      } else {
        state = AsyncValue.error('Failed to load specialties', StackTrace.current);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>?> predictSpecialty(String description) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/specialties/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'description': description}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error predicting specialty: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllSpecialties() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/specialties'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error getting all specialties: $e');
      return [];
    }
  }
}

final specialtyServiceProvider = StateNotifierProvider<SpecialtyNotifier, AsyncValue<List<Map<String, dynamic>>>>(
  (ref) => SpecialtyNotifier(),
); 