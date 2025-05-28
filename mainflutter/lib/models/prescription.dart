import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'prescription.freezed.dart';
part 'prescription.g.dart';

@freezed
class Medicine with _$Medicine {
  const factory Medicine({
    required String name,
    required String dosage,
    required String frequency,
    required String duration,
    String? notes,
  }) = _Medicine;

  factory Medicine.fromJson(Map<String, dynamic> json) => _$MedicineFromJson(json);
}

@freezed
class Prescription with _$Prescription {
  const factory Prescription({
    String? id,
    String? userId,
    String? doctorId,
    required String diagnosis,
    required List<Medicine> medicines,
    String? notes,
    required DateTime date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Prescription;

  factory Prescription.fromJson(Map<String, dynamic> json) => _$PrescriptionFromJson(json);
} 