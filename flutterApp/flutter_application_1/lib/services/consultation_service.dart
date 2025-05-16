import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/doctor.dart';
import '../models/consultation_list.dart';
import 'token_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Provider cho ConsultationService
final consultationServiceProvider = Provider<ConsultationService>((ref) {
  return ConsultationService();
});

// Provider cho danh sách bác sĩ tư vấn với autoDispose để tự động xóa cache
final consultationListProvider = FutureProvider.autoDispose<List<Doctor>>((ref) async {
  debugPrint('consultationListProvider đang được gọi lại...');
  
  // Cải thiện cơ chế cache: Giữ cache trong 30 giây, đủ lâu để không liên tục gọi API
  // nhưng đủ ngắn để dữ liệu luôn được cập nhật khi cần
  ref.keepAlive();
  ref.onDispose(() {
    debugPrint('consultationListProvider đã được hủy');
  });
  
  // Thêm listener cache-invalidation để theo dõi khi nào cần làm mới dữ liệu
  ref.onCancel(() {
    debugPrint('consultationListProvider onCancel được gọi');
  });
  
  // Đặt thời gian hết hạn cache là 30 giây
  const cacheTime = Duration(seconds: 30);
  final timer = Timer(cacheTime, () {
    debugPrint('Thời gian cache đã hết, tự động làm mới dữ liệu');
    ref.invalidateSelf();
  });
  
  // Đảm bảo hủy timer khi provider bị hủy
  ref.onDispose(() {
    timer.cancel();
  });
  
  final service = ref.read(consultationServiceProvider);
  return service.getDoctorsWithConsultation();
});

// Thêm provider để theo dõi và kiểm soát việc làm mới dữ liệu theo cách thủ công
final refreshConsultationControllerProvider = StateNotifierProvider<RefreshController, bool>((ref) {
  return RefreshController(ref);
});

class RefreshController extends StateNotifier<bool> {
  final Ref ref;
  
  RefreshController(this.ref) : super(false);
  
  // Phương thức để làm mới dữ liệu từ bất kỳ đâu trong ứng dụng
  void refreshConsultationList() {
    ref.invalidate(consultationListProvider);
    state = !state; // Chuyển đổi trạng thái để kích hoạt rebuild
    debugPrint('Đã yêu cầu làm mới danh sách bác sĩ tư vấn');
  }
}

class ConsultationService {
  final apiUrl = dotenv.env['BASE_URL'] ?? 'Không có URL';

  // Cache schedule để không phải gọi API nhiều lần
  static final Map<String, Map<String, dynamic>> _scheduleCache = {};

  // Phương thức để lấy lịch làm việc của bác sĩ
  Map<String, dynamic>? getDoctorSchedule(String doctorId) {
    // Kiểm tra trong cache trước
    if (_scheduleCache.containsKey(doctorId)) {
      debugPrint('Lấy lịch làm việc từ cache cho bác sĩ $doctorId');
      return _scheduleCache[doctorId];
    }
    
    debugPrint('Không có lịch làm việc trong cache cho bác sĩ $doctorId');
    return null; // Trả về null để UI hiển thị thông báo phù hợp
  }

  // Lấy lịch làm việc từ API (cần gọi trong getDoctorsWithConsultation)
  Future<void> fetchAndCacheSchedule(String doctorId, Map<String, dynamic>? schedule) async {
    if (schedule != null) {
      _scheduleCache[doctorId] = schedule;
      debugPrint('Đã cache lịch làm việc cho bác sĩ $doctorId');
      
      // Debug log để kiểm tra lịch làm việc
      if (schedule.isNotEmpty) {
        debugPrint('Lịch làm việc của bác sĩ $doctorId:');
        for (var entry in schedule.entries) {
          if (entry.value is List) {
            debugPrint('${entry.key}: ${(entry.value as List).length} slot');
          }
        }
      } else {
        debugPrint('Bác sĩ $doctorId không có lịch làm việc');
      }
    }
  }

  // Lấy danh sách bác sĩ tư vấn từ consultationList
  Future<List<Doctor>> getDoctorsWithConsultation() async {
    debugPrint('===> Đang gọi API lấy danh sách bác sĩ tư vấn...');
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/list');
      
      debugPrint('Đang kết nối đến API danh sách tư vấn: $uri');
      
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

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> doctorsList = responseData['data'];
          debugPrint('Số lượng bác sĩ tư vấn: ${doctorsList.length}');
          
          // Chuyển đổi dữ liệu trả về thành đối tượng Doctor
          return doctorsList.map((doctorData) {
            // Tạo đối tượng Doctor từ dữ liệu
            final doctor = Doctor(
              id: doctorData['_id'],
              fullName: doctorData['fullName'],
              specialty: doctorData['specialty'],
              otherSpecialties: doctorData['otherSpecialties'],
              experience: doctorData['experience'],
              avatar: doctorData['avatar'],
              currentWorkplace: doctorData['currentWorkplace'],
              schedule: doctorData['schedule'] != null 
                  ? Map<String, dynamic>.from(doctorData['schedule'])
                  : null,
            );
            
            // Lưu thông tin tư vấn vào extension của Doctor
            final consultation = ConsultationExtension(
              startDate: doctorData['StartDate'],
              endDate: doctorData['EndDate'],
              callRemaining: doctorData['call'],
            );
            
            // Thêm vào Object Cache để sử dụng ở nhiều nơi
            ConsultationExtensionCache.addExtension(doctor.id, consultation);
            
            // Cache lịch làm việc nếu có
            if (doctorData['schedule'] != null) {
              Map<String, dynamic> schedule = Map<String, dynamic>.from(doctorData['schedule']);
              fetchAndCacheSchedule(doctor.id, schedule);
              debugPrint('Đã cache lịch làm việc cho bác sĩ ${doctor.fullName}');
            } else {
              debugPrint('Bác sĩ ${doctor.fullName} không có lịch làm việc từ API');
            }
            
            return doctor;
          }).toList();
        } else {
          debugPrint('API trả về success=false hoặc không có data');
          return []; // Trả về danh sách trống nếu không có dữ liệu
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } on FormatException {
      debugPrint('Lỗi FormatException: Không thể parse JSON');
      throw Exception('Lỗi định dạng dữ liệu từ server');
    } on http.ClientException catch (e) {
      debugPrint('Lỗi ClientException: $e');
      throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
    } catch (e) {
      debugPrint('Lỗi không xác định: $e');
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  // Lấy thông tin về số lần gọi còn lại và thời hạn tư vấn
  Map<String, dynamic> getConsultationInfo(dynamic doctorData) {
    return {
      'startDate': doctorData['StartDate'] as String?,
      'endDate': doctorData['EndDate'] as String?,
      'callRemaining': doctorData['call'] as int?,
    };
  }

  // Thêm bác sĩ vào danh sách tư vấn
  Future<bool> addDoctor(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/add');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi thêm bác sĩ vào danh sách tư vấn: $e');
      throw Exception('Đã xảy ra lỗi khi thêm bác sĩ: $e');
    }
  }

  // Xóa bác sĩ khỏi danh sách tư vấn
  Future<bool> removeDoctor(String doctorId) async {
    try {
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/remove/$doctorId');
      
      final response = await http.delete(
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
        return responseData['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa bác sĩ khỏi danh sách tư vấn: $e');
      throw Exception('Đã xảy ra lỗi khi xóa bác sĩ: $e');
    }
  }

  // Đặt lịch tư vấn
  Future<bool> bookConsultation(String doctorId, DateTime consultationDate) async {
    try {
      debugPrint('===> Đang gọi API đặt lịch tư vấn...');
      debugPrint('DoctorId: $doctorId, ConsultationDate: ${consultationDate.toIso8601String()}');
      
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/book');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
          'consultationDate': consultationDate.toIso8601String(),
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi đặt lịch tư vấn: $e');
      throw Exception('Đã xảy ra lỗi khi đặt lịch: $e');
    }
  }

  // Kiểm tra các thời gian đã được đặt lịch
  Future<List<String>> checkDuplicateConsultation(String doctorId, String consultationDate) async {
    try {
      debugPrint('===> Đang kiểm tra lịch đã đặt...');
      debugPrint('DoctorId: $doctorId, Date: $consultationDate');
      
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/check-duplicate');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
          'consultationDate': consultationDate,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> bookedTimes = responseData['data'];
          return bookedTimes.map((time) => time.toString()).toList();
        }
        return [];
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi kiểm tra lịch đã đặt: $e');
      throw Exception('Đã xảy ra lỗi khi kiểm tra lịch đã đặt: $e');
    }
  }

  // Phương thức gia hạn lượt tư vấn hoặc gia hạn ngày
  Future<bool> extendConsultation(String doctorId, String type, int quantity) async {
    try {
      debugPrint('===> Đang gọi API gia hạn tư vấn...');
      debugPrint('DoctorId: $doctorId, Type: $type, Quantity: $quantity');
      
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/extend');
      
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'doctorId': doctorId,
          'type': type, // "Extend" để gia hạn ngày, "AddCallVideo" để thêm lượt
          'quantity': quantity,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng');
        },
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi gia hạn tư vấn: $e');
      throw Exception('Đã xảy ra lỗi khi gia hạn tư vấn: $e');
    }
  }

  // Lấy lịch sử cuộc hẹn của người dùng
  Future<Map<String, dynamic>> getConsultationHistory() async {
    try {
      debugPrint('===> Đang gọi API lấy lịch sử cuộc hẹn...');
      
      final token = await TokenService.getToken();
      if (token == null) {
        throw Exception('Không có token!');
      }

      final uri = Uri.parse('$apiUrl/consultationList/history');
      
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

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'];
        }
        return {
          'pastConsultations': [],
          'upcomingConsultations': [],
          'nextConsultation': null
        };
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi khi lấy lịch sử cuộc hẹn: $e');
      throw Exception('Đã xảy ra lỗi khi lấy lịch sử cuộc hẹn: $e');
    }
  }
}

// Lớp mở rộng để lưu thông tin tư vấn
class ConsultationExtension {
  final String? startDate;
  final String? endDate;
  final int? callRemaining;
  
  ConsultationExtension({
    this.startDate,
    this.endDate,
    this.callRemaining,
  });
}

// Lớp singleton để lưu cache thông tin tư vấn
class ConsultationExtensionCache {
  static final Map<String, ConsultationExtension> _cache = {};
  
  static void addExtension(String doctorId, ConsultationExtension extension) {
    _cache[doctorId] = extension;
  }
  
  static ConsultationExtension? getExtension(String doctorId) {
    return _cache[doctorId];
  }
  
  static void clear() {
    _cache.clear();
  }
}

// Extension cho Doctor để truy cập thông tin tư vấn dễ dàng
extension DoctorConsultationExtension on Doctor {
  String? get consultationStartDate {
    final extension = ConsultationExtensionCache.getExtension(id);
    return extension?.startDate;
  }
  
  String? get consultationEndDate {
    final extension = ConsultationExtensionCache.getExtension(id);
    return extension?.endDate;
  }
  
  int? get consultationCallRemaining {
    final extension = ConsultationExtensionCache.getExtension(id);
    return extension?.callRemaining;
  }
} 