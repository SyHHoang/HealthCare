// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedbackImpl _$$FeedbackImplFromJson(Map<String, dynamic> json) =>
    _$FeedbackImpl(
      id: json['id'] as String?,
      rating: (json['rating'] as num).toDouble(),
      service: json['service'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      pros: json['pros'] as String?,
      cons: json['cons'] as String?,
      suggestions: json['suggestions'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      userId: json['userId'] as String?,
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$FeedbackImplToJson(_$FeedbackImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rating': instance.rating,
      'service': instance.service,
      'title': instance.title,
      'content': instance.content,
      'pros': instance.pros,
      'cons': instance.cons,
      'suggestions': instance.suggestions,
      'email': instance.email,
      'phone': instance.phone,
      'images': instance.images,
      'userId': instance.userId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };
