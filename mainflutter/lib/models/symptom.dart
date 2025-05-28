import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'symptom.freezed.dart';
part 'symptom.g.dart';

@freezed
class Symptom with _$Symptom {
  const factory Symptom({
    String? id,
    String? userId,
    required String name,
    required String severity,
    required DateTime startDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Symptom;

  factory Symptom.fromJson(Map<String, dynamic> json) => _$SymptomFromJson(json);
} 