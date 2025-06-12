// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialty.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpecialtyImpl _$$SpecialtyImplFromJson(Map<String, dynamic> json) =>
    _$SpecialtyImpl(
      id: json['_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String?,
      isSuggested: json['isSuggested'] as bool? ?? false,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SpecialtyImplToJson(_$SpecialtyImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'icon': instance.icon,
      'isSuggested': instance.isSuggested,
      'confidence': instance.confidence,
    };
