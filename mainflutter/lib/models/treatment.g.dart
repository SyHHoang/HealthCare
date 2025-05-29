// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'treatment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TreatmentImpl _$$TreatmentImplFromJson(Map<String, dynamic> json) =>
    _$TreatmentImpl(
      id: json['_id'] as String,
      diagnosis: json['diagnosis'] as String,
      treatmentPlan: json['treatmentPlan'] as String,
      startDate: _dateTimeFromJson(json['startDate'] as String),
      endDate: _nullableDateTimeFromJson(json['endDate'] as String?),
      status: json['status'] as String,
      medications:
          (json['medications'] as List<dynamic>?)
              ?.map((e) => Medication.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      procedures:
          (json['procedures'] as List<dynamic>?)
              ?.map((e) => Procedure.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      followUp:
          json['followUp'] == null
              ? null
              : FollowUp.fromJson(json['followUp'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TreatmentImplToJson(_$TreatmentImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'diagnosis': instance.diagnosis,
      'treatmentPlan': instance.treatmentPlan,
      'startDate': _dateTimeToJson(instance.startDate),
      'endDate': _nullableDateTimeToJson(instance.endDate),
      'status': instance.status,
      'medications': instance.medications,
      'procedures': instance.procedures,
      'followUp': instance.followUp,
      'notes': instance.notes,
    };

_$MedicationImpl _$$MedicationImplFromJson(Map<String, dynamic> json) =>
    _$MedicationImpl(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );

Map<String, dynamic> _$$MedicationImplToJson(_$MedicationImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dosage': instance.dosage,
      'frequency': instance.frequency,
      'duration': instance.duration,
    };

_$ProcedureImpl _$$ProcedureImplFromJson(Map<String, dynamic> json) =>
    _$ProcedureImpl(
      name: json['name'] as String,
      date: _dateTimeFromJson(json['date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ProcedureImplToJson(_$ProcedureImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'date': _dateTimeToJson(instance.date),
      'notes': instance.notes,
    };

_$FollowUpImpl _$$FollowUpImplFromJson(Map<String, dynamic> json) =>
    _$FollowUpImpl(
      date: _dateTimeFromJson(json['date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$FollowUpImplToJson(_$FollowUpImpl instance) =>
    <String, dynamic>{
      'date': _dateTimeToJson(instance.date),
      'notes': instance.notes,
    };
