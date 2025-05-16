import 'package:freezed_annotation/freezed_annotation.dart';

part 'vaccination.freezed.dart';
part 'vaccination.g.dart';

@freezed
class SideEffect with _$SideEffect {
  const factory SideEffect({
    required String description,
    required String severity,
    String? duration,
  }) = _SideEffect;

  factory SideEffect.fromJson(Map<String, dynamic> json) => _$SideEffectFromJson(json);
}

@freezed
class Vaccination with _$Vaccination {
  const factory Vaccination({
    @JsonKey(name: '_id') required String id,
    required String vaccineName,
    required String vaccineType,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime? dateAdministered,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime? nextDoseDate,
    String? batchNumber,
    String? manufacturer,
    List<SideEffect>? sideEffects,
    String? notes,
    String? status,
  }) = _Vaccination;

  factory Vaccination.fromJson(Map<String, dynamic> json) => _$VaccinationFromJson(json);
}

DateTime? _dateTimeFromJson(String? date) {
  if (date == null) return null;
  return DateTime.tryParse(date);
}

String? _dateTimeToJson(DateTime? date) {
  if (date == null) return null;
  return date.toIso8601String();
}