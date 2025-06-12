import 'package:freezed_annotation/freezed_annotation.dart';

part 'specialty.freezed.dart';
part 'specialty.g.dart';

@freezed
class Specialty with _$Specialty {
  const factory Specialty({
    @JsonKey(name: '_id') String? id,
    required String name,
    required String description,
    String? icon,
    @Default(false) bool isSuggested,
    double? confidence,
  }) = _Specialty;

  factory Specialty.fromJson(Map<String, dynamic> json) => _$SpecialtyFromJson(json);
} 