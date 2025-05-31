import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/drug.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Phần này sẽ được tạo tự động bởi build_runner
part 'drug_provider.g.dart';

// Địa chỉ API, thay đổi tùy theo môi trường chạy


// Provider trạng thái để xác định liệu dữ liệu đã được tải hay chưa
@riverpod
class DrugLoaded extends _$DrugLoaded {
  @override
  bool build() => false;
  
  void setLoaded(bool value) {
    state = value;
  }
}

// Provider cho tìm kiếm thuốc
@Riverpod(keepAlive: true)
class DrugSearch extends _$DrugSearch {
  final storage = const FlutterSecureStorage();
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';
  @override
  FutureOr<List<Drug>> build() {
    // Tải danh sách thuốc mặc định khi khởi tạo
    return _fetchDrugs();
  }
  
  // Hàm private để tải danh sách thuốc
  Future<List<Drug>> _fetchDrugs() async {
    try {
      final baseUrl = apiUrl;
      final uri = Uri.parse('$baseUrl/drugs/search');
      
      // Hiển thị URL đang gọi
      debugPrint('Calling API: $uri');
      
      final response = await http.get(uri);
      
      // Debug response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        try {
          // Xử lý trường hợp response body rỗng
          if (response.body.isEmpty) {
            debugPrint('Empty response body');
            return [];
          }
          
          final data = json.decode(response.body);
          
          // Xử lý trường hợp data là Map (có wrapper) hoặc List
          if (data is List) {
            return data.map((item) => Drug.fromJson(item)).toList();
          } else if (data is Map<String, dynamic> && data['data'] is List) {
            final List<dynamic> drugList = data['data'];
            return drugList.map((item) => Drug.fromJson(item)).toList();
          } else {
            debugPrint('Unexpected data structure: $data');
            return [];
          }
        } catch (e) {
          debugPrint('Error parsing data: $e');
          return [];
        }
      } else {
        debugPrint('API error: ${response.statusCode} - ${response.body}');
        throw Exception('Không thể tìm kiếm thuốc - Lỗi: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception during drug search: $e');
      // Không ném lỗi, chỉ trả về list rỗng và log
      return [];
    }
  }
  
  Future<void> searchDrugs({
    String query = '',
    String? category,
    String? type,
  }) async {
    try {
      state = const AsyncLoading();
      
      final queryParams = {
        if (query.isNotEmpty) 'query': query,
        if (category != null) 'category': category,
        if (type != null) 'type': type,
      };

      final baseUrl = apiUrl;
      final uri = Uri.parse('$baseUrl/drugs/search').replace(queryParameters: queryParams);
      
      debugPrint('Searching drugs at: $uri');
      final response = await http.get(uri);
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint("Response body: ${response.body}");
      
      if (response.statusCode == 200) {
        try {
          // Xử lý trường hợp response body rỗng
          if (response.body.isEmpty) {
            state = const AsyncData([]);
            return;
          }
          
          final data = json.decode(response.body);
          
          // Xử lý trường hợp data là Map (có wrapper) hoặc List
          List<Drug> drugs = [];
          if (data is List) {
            drugs = data.map((item) => Drug.fromJson(item)).toList();
          } else if (data is Map<String, dynamic> && data['data'] is List) {
            final List<dynamic> drugList = data['data'];
            drugs = drugList.map((item) => Drug.fromJson(item)).toList();
          } else {
            debugPrint('Unexpected data structure: $data');
          }
          
          state = AsyncData(drugs);
        } catch (e) {
          debugPrint('Error parsing data: $e');
          state = AsyncError(Exception('Lỗi xử lý dữ liệu: $e'), StackTrace.current);
        }
      } else {
        state = AsyncError(
          Exception('Không thể tìm kiếm thuốc - Lỗi: ${response.statusCode}'),
          StackTrace.current
        );
      }
    } catch (e) {
      debugPrint('Exception during drug search: $e');
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<Drug?> getDrugById(String id) async {
    try {
        final baseUrl = apiUrl;
      final response = await http.get(Uri.parse('$baseUrl/drugs/$id'));

      if (response.statusCode == 200) {
        return Drug.fromJson(json.decode(response.body));
      } else {
        throw Exception('Không thể lấy thông tin thuốc');
      }
    } catch (e) {
      return null;
    }
  }
}

// Helper provider để truy cập danh sách thuốc hiện tại
@Riverpod(keepAlive: true)
List<Drug> drugs(DrugsRef ref) {
  final drugState = ref.watch(drugSearchProvider);
  return drugState.when(
    data: (drugs) => drugs,
    loading: () => [],
    error: (error, stack) {
      debugPrint('Error in drugs provider: $error');
      return [];
    },
  );
} 