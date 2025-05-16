import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_data.freezed.dart';
part 'health_data.g.dart';

@freezed
class HealthData with _$HealthData {
  const factory HealthData({
    @JsonKey(name: '_id') required String id,
    required String dataType,
    required double value,
    required String unit,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson) required DateTime measurementTime,
    String? measurementLocation,
    String? notes,
  }) = _HealthData;

  factory HealthData.fromJson(Map<String, dynamic> json) => _$HealthDataFromJson(json);
}

DateTime _dateTimeFromJson(String date) => DateTime.parse(date);

String _dateTimeToJson(DateTime date) => date.toIso8601String(); 