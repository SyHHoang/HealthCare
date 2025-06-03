import '../models/notification_model.dart';
import 'api_service.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService(this._apiService);

  // Lấy danh sách thông báo cho user
  Future<List<Notification>> getNotifications() async {
    final response = await _apiService.get('/notifications');
    return (response as List)
        .map((json) => Notification.fromJson(json))
        .toList();
  }

  // Lấy danh sách thông báo cho bác sĩ
  Future<List<Notification>> getDoctorNotifications() async {
    final response = await _apiService.get('/notifications/doctor');
    return (response as List)
        .map((json) => Notification.fromJson(json))
        .toList();
  }

  // Đánh dấu thông báo đã đọc cho user
  Future<Notification> markAsRead(String id) async {
    final response = await _apiService.put('/notifications/$id/read', {});
    return Notification.fromJson(response);
  }

  // Đánh dấu thông báo đã đọc cho bác sĩ
  Future<Notification> markDoctorNotificationAsRead(String id) async {
    final response = await _apiService.put('/notifications/doctor/$id/read', {});
    return Notification.fromJson(response);
  }

  // Đánh dấu tất cả thông báo đã đọc cho user
  Future<void> markAllAsRead() async {
    await _apiService.put('/notifications/read-all', {});
  }

  // Đánh dấu tất cả thông báo đã đọc cho bác sĩ
  Future<void> markAllDoctorNotificationsAsRead() async {
    await _apiService.put('/notifications/doctor/read-all', {});
  }

  // Xóa thông báo cho user
  Future<void> deleteNotification(String id) async {
    await _apiService.delete('/notifications/$id');
  }

  // Xóa thông báo cho bác sĩ
  Future<void> deleteDoctorNotification(String id) async {
    await _apiService.delete('/notifications/doctor/$id');
  }
} 