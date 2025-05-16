import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'treatment.freezed.dart';
part 'treatment.g.dart';

@freezed
class Treatment with _$Treatment {
  const factory Treatment({
    @JsonKey(name: '_id') required String id,
    required String diagnosis,
    required String treatmentPlan,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required DateTime startDate,
    @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson) DateTime? endDate,
    required String status,
    @Default([]) List<Medication> medications,
    @Default([]) List<Procedure> procedures,
    FollowUp? followUp,
    String? notes,
  }) = _Treatment;

  factory Treatment.fromJson(Map<String, dynamic> json) => _$TreatmentFromJson(json);
}

@freezed
class Medication with _$Medication {
  const factory Medication({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
  }) = _Medication;

  factory Medication.fromJson(Map<String, dynamic> json) => _$MedicationFromJson(json);
}

@freezed
class Procedure with _$Procedure {
  const factory Procedure({
    required String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required DateTime date,
    String? notes,
  }) = _Procedure;

  factory Procedure.fromJson(Map<String, dynamic> json) => _$ProcedureFromJson(json);
}

@freezed
class FollowUp with _$FollowUp {
  const factory FollowUp({
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required DateTime date,
    String? notes,
  }) = _FollowUp;

  factory FollowUp.fromJson(Map<String, dynamic> json) => _$FollowUpFromJson(json);
}

DateTime _dateTimeFromJson(String date) => DateTime.parse(date);

String _dateTimeToJson(DateTime date) => date.toIso8601String();

DateTime? _nullableDateTimeFromJson(String? date) => date == null ? null : DateTime.parse(date);

String? _nullableDateTimeToJson(DateTime? date) => date?.toIso8601String(); 