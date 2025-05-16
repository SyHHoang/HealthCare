import 'package:flutter/material.dart';

class VerificationStatusBadge extends StatelessWidget {
  final String status;

  const VerificationStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status.toLowerCase()) {
      case 'verified':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        label = 'Đã xác thực';
        break;
      case 'pending':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        label = 'Đang chờ xác thực';
        break;
      case 'rejected':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        label = 'Từ chối xác thực';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        label = 'Chưa xác thực';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
} 