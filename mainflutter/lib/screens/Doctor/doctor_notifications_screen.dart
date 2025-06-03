import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/notification_model.dart' as models;
import '../../providers/notification_provider.dart';
import '../../widgets/notification_item.dart';

class DoctorNotificationsScreen extends ConsumerStatefulWidget {
  const DoctorNotificationsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DoctorNotificationsScreen> createState() => _DoctorNotificationsScreenState();
}

class _DoctorNotificationsScreenState extends ConsumerState<DoctorNotificationsScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('vi_VN', null);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          notificationsAsync.when(
            data: (notifications) {
              final hasUnread = notifications.any((n) => !n.read);
              if (!hasUnread) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: () {
                  ref.read(notificationsProvider.notifier).markAllAsRead();
                },
                tooltip: 'Đánh dấu tất cả đã đọc',
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Không có thông báo nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(notificationsProvider.notifier).fetchNotifications(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    ref.read(notificationsProvider.notifier).markAsRead(notification.id);
                    _handleNotificationTap(context, notification);
                  },
                  onDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xóa thông báo'),
                        content: const Text('Bạn có chắc chắn muốn xóa thông báo này?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(notificationsProvider.notifier).deleteNotification(notification.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra: ${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(notificationsProvider.notifier).fetchNotifications();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, models.Notification notification) {
    if (notification.data == null) return;

    switch (notification.type) {
      case 'appointment':
        // Điều hướng đến trang chi tiết lịch hẹn
        // Navigator.pushNamed(context, '/doctor/appointment-details', arguments: notification.data);
        break;
      case 'message':
        // Điều hướng đến trang chat
        // Navigator.pushNamed(context, '/doctor/chat', arguments: notification.data);
        break;
      case 'feedback':
        // Điều hướng đến trang đánh giá
        // Navigator.pushNamed(context, '/doctor/feedback', arguments: notification.data);
        break;
      // Thêm các case khác tùy theo loại thông báo
    }
  }
} 