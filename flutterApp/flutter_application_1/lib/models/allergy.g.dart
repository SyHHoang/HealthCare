// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'allergy.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllergyImpl _$$AllergyImplFromJson(Map<String, dynamic> json) =>
    _$AllergyImpl(
      id: json['_id'] as String,
      allergen: json['allergen'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      symptoms:
          (json['symptoms'] as List<dynamic>).map((e) => e as String).toList(),
      firstOccurrence: _dateTimeFromJson(json['firstOccurrence'] as String?),
      lastOccurrence: _dateTimeFromJson(json['lastOccurrence'] as String?),
      treatment: json['treatment'] as String?,
      notes: json['notes'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$AllergyImplToJson(_$AllergyImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'allergen': instance.allergen,
      'type': instance.type,
      'severity': instance.severity,
      'symptoms': instance.symptoms,
      'firstOccurrence': _dateTimeToJson(instance.firstOccurrence),
      'lastOccurrence': _dateTimeToJson(instance.lastOccurrence),
      'treatment': instance.treatment,
      'notes': instance.notes,
      'isActive': instance.isActive,
    };
