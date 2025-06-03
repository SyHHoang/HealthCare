import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';

final notificationServiceProvider = Provider((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NotificationService(apiService);
});

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<Notification>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends AsyncNotifier<List<Notification>> {
  @override
  Future<List<Notification>> build() async {
    return _fetchNotifications();
  }

  Future<List<Notification>> _fetchNotifications() async {
    final role = await TokenService.getRole();
    final notificationService = ref.read(notificationServiceProvider);
    
    if (role == 'doctor') {
      return notificationService.getDoctorNotifications();
    } else {
      return notificationService.getNotifications();
    }
  }

  Future<void> fetchNotifications() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchNotifications());
  }

  Future<void> markAsRead(String id) async {
    final role = await TokenService.getRole();
    final notificationService = ref.read(notificationServiceProvider);
    
    try {
      Notification updatedNotification;
      if (role == 'doctor') {
        updatedNotification = await notificationService.markDoctorNotificationAsRead(id);
      } else {
        updatedNotification = await notificationService.markAsRead(id);
      }

      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.map((n) => n.id == id ? updatedNotification : n).toList(),
        );
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> markAllAsRead() async {
    final role = await TokenService.getRole();
    final notificationService = ref.read(notificationServiceProvider);
    
    try {
      if (role == 'doctor') {
        await notificationService.markAllDoctorNotificationsAsRead();
      } else {
        await notificationService.markAllAsRead();
      }

      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.map((n) => Notification(
            id: n.id,
            userId: n.userId,
            title: n.title,
            message: n.message,
            type: n.type,
            data: n.data,
            read: true,
            createdAt: n.createdAt,
          )).toList(),
        );
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }

  Future<void> deleteNotification(String id) async {
    final role = await TokenService.getRole();
    final notificationService = ref.read(notificationServiceProvider);
    
    try {
      if (role == 'doctor') {
        await notificationService.deleteDoctorNotification(id);
      } else {
        await notificationService.deleteNotification(id);
      }

      state.whenData((notifications) {
        state = AsyncValue.data(
          notifications.where((n) => n.id != id).toList(),
        );
      });
    } catch (e) {
      // Xử lý lỗi nếu cần
    }
  }
} 