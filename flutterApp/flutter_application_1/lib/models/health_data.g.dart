// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthDataImpl _$$HealthDataImplFromJson(Map<String, dynamic> json) =>
    _$HealthDataImpl(
      id: json['_id'] as String,
      dataType: json['dataType'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      measurementTime: _dateTimeFromJson(json['measurementTime'] as String),
      measurementLocation: json['measurementLocation'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$HealthDataImplToJson(_$HealthDataImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'dataType': instance.dataType,
      'value': instance.value,
      'unit': instance.unit,
      'measurementTime': _dateTimeToJson(instance.measurementTime),
      'measurementLocation': instance.measurementLocation,
      'notes': instance.notes,
    };
