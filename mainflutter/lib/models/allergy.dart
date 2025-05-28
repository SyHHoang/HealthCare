import 'package:freezed_annotation/freezed_annotation.dart';

part 'allergy.freezed.dart';
part 'allergy.g.dart';

@freezed
class Allergy with _$Allergy {
  const factory Allergy({
    @JsonKey(name: '_id') required String id,
    required String allergen,
    required String type,
    required String severity,
    required List<String> symptoms,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime? firstOccurrence,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime? lastOccurrence,
    String? treatment,
    String? notes,
    @Default(true) bool isActive,
  }) = _Allergy;

  factory Allergy.fromJson(Map<String, dynamic> json) => _$AllergyFromJson(json);
}

DateTime? _dateTimeFromJson(String? date) {
  if (date == null) return null;
  return DateTime.tryParse(date);
}

String? _dateTimeToJson(DateTime? date) {
  if (date == null) return null;
  return date.toIso8601String();
} 