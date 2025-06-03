import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class Notification {
  @JsonKey(name: '_id')
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.data,
    required this.read,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);
} 