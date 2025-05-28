import 'package:freezed_annotation/freezed_annotation.dart';

part 'lifestyle.freezed.dart';
part 'lifestyle.g.dart';

@freezed
class Lifestyle with _$Lifestyle {
  const factory Lifestyle({
    @JsonKey(name: '_id') required String id,
    required String activityType,
    required String description,
    required String frequency,
    String? duration,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) DateTime? startDate,
    String? notes,
  }) = _Lifestyle;

  factory Lifestyle.fromJson(Map<String, dynamic> json) => _$LifestyleFromJson(json);
}

DateTime? _dateTimeFromJson(String? date) => date == null ? null : DateTime.parse(date);

String? _dateTimeToJson(DateTime? date) => date?.toIso8601String(); 