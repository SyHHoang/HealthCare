import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart' as models;

class NotificationItem extends StatelessWidget {
  final models.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_today;
      case 'message':
        return Icons.message;
      case 'system':
        return Icons.info;
      case 'prescription':
        return Icons.medical_services;
      case 'cancel':
        return Icons.cancel;
      case 'reminder':
        return Icons.notifications;
      case 'feedback':
        return Icons.star;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hôm nay, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Hôm qua, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE, HH:mm', 'vi_VN').format(date);
    } else {
      return DateFormat('dd/MM/yyyy, HH:mm', 'vi_VN').format(date);
    }
  }

  String _formatDataValue(dynamic value) {
    if (value is num) {
      return NumberFormat.currency(
        locale: 'vi_VN',
        symbol: '₫',
      ).format(value);
    }
    if (value is DateTime) {
      return DateFormat('dd/MM/yyyy HH:mm').format(value);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.read ? 0 : 2,
      color: notification.read ? Colors.white : Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.read
            ? BorderSide.none
            : BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: notification.read
                                      ? Colors.black87
                                      : Colors.blue.shade900,
                                ),
                              ),
                            ),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey.shade600,
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              if (notification.data != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: notification.data!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${entry.key}: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                _formatDataValue(entry.value),
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 