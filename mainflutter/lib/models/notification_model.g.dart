// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: json['_id'] as String,
  userId: json['userId'] as String,
  title: json['title'] as String,
  message: json['message'] as String,
  type: json['type'] as String,
  data: json['data'] as Map<String, dynamic>?,
  read: json['read'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'message': instance.message,
      'type': instance.type,
      'data': instance.data,
      'read': instance.read,
      'createdAt': instance.createdAt.toIso8601String(),
    };
