import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor.freezed.dart';
part 'doctor.g.dart';

@freezed
class Doctor with _$Doctor {
  const factory Doctor({
    @JsonKey(name: '_id') required String id,
    required String fullName,
    String? specialty,
    String? otherSpecialties,
    String? education,
    String? email,
    int? graduationYear,
    String? licenseNumber,
    int? experience,
    String? currentWorkplace,
    String? phone,
    String? address,
    String? verifiID,
    @Default('pending') String status,
    @Default(false) bool isVerified,
    String? avatar,
    Map<String, dynamic>? schedule,
    @Default('Doctor') String role,
  }) = _Doctor;

  factory Doctor.fromJson(Map<String, dynamic> json) => _$DoctorFromJson(json);
} 