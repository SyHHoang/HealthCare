// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SideEffectImpl _$$SideEffectImplFromJson(Map<String, dynamic> json) =>
    _$SideEffectImpl(
      description: json['description'] as String,
      severity: json['severity'] as String,
      duration: json['duration'] as String?,
    );

Map<String, dynamic> _$$SideEffectImplToJson(_$SideEffectImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'severity': instance.severity,
      'duration': instance.duration,
    };

_$VaccinationImpl _$$VaccinationImplFromJson(Map<String, dynamic> json) =>
    _$VaccinationImpl(
      id: json['_id'] as String,
      vaccineName: json['vaccineName'] as String,
      vaccineType: json['vaccineType'] as String,
      dateAdministered: _dateTimeFromJson(json['dateAdministered'] as String?),
      nextDoseDate: _dateTimeFromJson(json['nextDoseDate'] as String?),
      batchNumber: json['batchNumber'] as String?,
      manufacturer: json['manufacturer'] as String?,
      sideEffects:
          (json['sideEffects'] as List<dynamic>?)
              ?.map((e) => SideEffect.fromJson(e as Map<String, dynamic>))
              .toList(),
      notes: json['notes'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$VaccinationImplToJson(_$VaccinationImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'vaccineName': instance.vaccineName,
      'vaccineType': instance.vaccineType,
      'dateAdministered': _dateTimeToJson(instance.dateAdministered),
      'nextDoseDate': _dateTimeToJson(instance.nextDoseDate),
      'batchNumber': instance.batchNumber,
      'manufacturer': instance.manufacturer,
      'sideEffects': instance.sideEffects,
      'notes': instance.notes,
      'status': instance.status,
    };
