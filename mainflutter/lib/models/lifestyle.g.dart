// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lifestyle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LifestyleImpl _$$LifestyleImplFromJson(Map<String, dynamic> json) =>
    _$LifestyleImpl(
      id: json['_id'] as String,
      activityType: json['activityType'] as String,
      description: json['description'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String?,
      startDate: _dateTimeFromJson(json['startDate'] as String?),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$LifestyleImplToJson(_$LifestyleImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'activityType': instance.activityType,
      'description': instance.description,
      'frequency': instance.frequency,
      'duration': instance.duration,
      'startDate': _dateTimeToJson(instance.startDate),
      'notes': instance.notes,
    };
