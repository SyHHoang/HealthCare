import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/doctor.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

part 'doctor_service.g.dart';

@riverpod
class DoctorService extends _$DoctorService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  @override
  Future<List<Doctor>> build({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  }) async {
    return getDoctors(
      specialty: specialty,
      searchQuery: searchQuery,
      page: page,
      limit: limit,
    );
  }

  Future<List<Doctor>> getDoctors({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final queryParams = <String, String>{};
      if (specialty != null) queryParams['specialty'] = specialty;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$baseUrl/doctors/active/isActive').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          final Map<String, dynamic> data = responseData['data'];
          final List<dynamic> doctorsList = data['doctors'];
          return doctorsList.map((doctorData) => Doctor.fromJson(doctorData)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Không thể lấy danh sách bác sĩ');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<Doctor> getDoctorProfile() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/doctors/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return Doctor.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Không thể lấy thông tin bác sĩ');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<Doctor> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/doctors/profile'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Doctor.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Không thể cập nhật thông tin bác sĩ');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<Map<String, dynamic>> getVerificationDetails() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/verification/doctor/verification-details'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        } else {
          throw Exception(responseData['message'] ?? 'Không thể lấy thông tin xác thực');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<void> requestVerification(Map<String, dynamic> data) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }
      final response = await http.post(
        Uri.parse('$baseUrl/verification/request'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Lỗi khi gửi yêu cầu xác thực');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  // Lấy danh sách bác sĩ tư vấn từ consultationList
  Future<List<Doctor>> getConsultationDoctors() async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$baseUrl/consultationList/list');
      
      print('Đang kết nối đến API danh sách tư vấn: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> doctorsList = responseData['data'];
          return doctorsList.map((doctorData) {
            // Chuyển đổi dữ liệu bác sĩ từ API consultationList
            // Lưu ý: Format dữ liệu trả về có thể khác với API /doctors
            return Doctor.fromJson({
              '_id': doctorData['_id'],
              'fullName': doctorData['fullName'],
              'specialty': doctorData['specialty'],
              'otherSpecialties': doctorData['otherSpecialties'],
              'experience': doctorData['experience'],
              'avatar': doctorData['avatar'],
              'currentWorkplace': doctorData['currentWorkplace'],
              // Thông tin bổ sung từ ConsultationList
              'consultationStartDate': doctorData['StartDate'],
              'consultationEndDate': doctorData['EndDate'],
              'consultationCallRemaining': doctorData['call'],
            });
          }).toList();
        } else {
          return []; // Trả về danh sách trống nếu không có dữ liệu
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } on FormatException {
      print('Lỗi FormatException: Không thể parse JSON');
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException catch (e) {
      print('Lỗi ClientException: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
    } catch (e) {
      print('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<Doctor> getDoctorById(String id) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$baseUrl/$id');
      
      print('Đang kết nối đến: $uri');
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' && responseData['data'] != null) {
          return Doctor.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Không thể lấy thông tin bác sĩ');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } on FormatException {
      print('Lỗi FormatException: Không thể parse JSON');
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException catch (e) {
      print('Lỗi ClientException: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
    } catch (e) {
      print('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  Future<void> refreshDoctors({
    String? specialty,
    String? searchQuery,
    int? page,
    int? limit,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getDoctors(
          specialty: specialty,
          searchQuery: searchQuery,
          page: page,
          limit: limit,
        ));
  }
  
  // Refresh danh sách bác sĩ tư vấn
  Future<void> refreshConsultationDoctors() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => getConsultationDoctors());
  }

  Future<Map<String, List<Map<String, String>>>> getSchedule(String doctorId) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Không có token!');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/doctors/schedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final raw = data['schedule'] as Map<String, dynamic>;
        final result = <String, List<Map<String, String>>>{};
        raw.forEach((key, value) {
          result[key] = (value as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        });
        return result;
      }
      throw Exception(data['message']);
    }
    throw Exception('Không thể lấy lịch làm việc');
  }

  Future<void> addWorkingTime(String doctorId, String day, String startTime) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Không có token!');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/doctors/schedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'day': day,
        'startTime': startTime,
      }),
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Lỗi khi thêm lịch làm việc');
    }
  }

  Future<void> deleteWorkingTime(String doctorId, String day, String index) async {
    final token = await TokenService.getToken();
    if (token == null) {
      throw Exception('Không có token!');
    }

    final response = await http.delete(
      Uri.parse('$baseUrl/doctors/schedule/$day/$index'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Lỗi khi xóa lịch làm việc');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/change-password'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }
} 