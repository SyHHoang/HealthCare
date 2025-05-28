import 'package:flutter/material.dart';
import 'doctor.dart';

class Consultation {
  final String id;
  final String userId;
  final Doctor? doctor;
  final DateTime consultationDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Consultation({
    required this.id,
    required this.userId,
    this.doctor,
    required this.consultationDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      doctor: json['doctorId'] != null 
          ? Doctor.fromJson(json['doctorId']) 
          : null,
      consultationDate: json['consultationDate'] != null 
          ? DateTime.parse(json['consultationDate']) 
          : DateTime.now(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  // Kiểm tra xem cuộc hẹn đã qua hay chưa
  bool isPast() {
    return DateTime.now().isAfter(consultationDate);
  }

  // Lấy ra thông tin thời gian cuộc hẹn ở định dạng dễ đọc
  String getFormattedTime() {
    return '${consultationDate.hour.toString().padLeft(2, '0')}:${consultationDate.minute.toString().padLeft(2, '0')}';
  }

  // Lấy ra thông tin ngày của cuộc hẹn ở định dạng dễ đọc
  String getFormattedDate() {
    return '${consultationDate.day}/${consultationDate.month}/${consultationDate.year}';
  }

  // Lấy ra thông tin ngày giờ đầy đủ
  String getFullFormattedDateTime() {
    return '${getFormattedDate()} ${getFormattedTime()}';
  }

  // Lấy ra trạng thái của cuộc hẹn
  String getStatus() {
    final now = DateTime.now();
    
    if (now.isAfter(consultationDate)) {
      return 'Đã hoàn thành';
    } else {
      // Tính số ngày còn lại
      final difference = consultationDate.difference(now).inDays;
      
      if (difference == 0) {
        // Kiểm tra nếu là ngày hôm nay
        if (consultationDate.day == now.day && 
            consultationDate.month == now.month && 
            consultationDate.year == now.year) {
          // Tính số giờ còn lại
          final hourDifference = consultationDate.difference(now).inHours;
          
          if (hourDifference < 1) {
            return 'Sắp diễn ra';
          } else {
            return 'Hôm nay, còn $hourDifference giờ';
          }
        }
        return 'Sắp diễn ra';
      } else if (difference < 7) {
        return 'Còn $difference ngày';
      } else {
        return 'Lịch hẹn sắp tới';
      }
    }
  }

  // Lấy màu tương ứng với trạng thái
  Color getStatusColor() {
    final now = DateTime.now();
    
    if (now.isAfter(consultationDate)) {
      return Colors.grey;
    } else {
      // Tính số ngày còn lại
      final difference = consultationDate.difference(now).inDays;
      
      if (difference == 0) {
        // Nếu là ngày hôm nay
        return Colors.orange;
      } else if (difference < 3) {
        return Colors.orange;
      } else {
        return Colors.green;
      }
    }
  }
} 