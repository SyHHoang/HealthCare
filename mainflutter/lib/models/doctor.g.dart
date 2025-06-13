// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DoctorImpl _$$DoctorImplFromJson(Map<String, dynamic> json) => _$DoctorImpl(
      id: json['_id'] as String,
      fullName: json['fullName'] as String,
      specialty: json['specialty'] as String?,
      otherSpecialties: json['otherSpecialties'] as String?,
      education: json['education'] as String?,
      email: json['email'] as String?,
      graduationYear: (json['graduationYear'] as num?)?.toInt(),
      licenseNumber: json['licenseNumber'] as String?,
      experience: (json['experience'] as num?)?.toInt(),
      currentWorkplace: json['currentWorkplace'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      verifiID: json['verifiID'] as String?,
      status: json['status'] as String? ?? 'pending',
      isVerified: json['isVerified'] as bool? ?? false,
      avatar: json['avatar'] as String?,
      schedule: json['schedule'] as Map<String, dynamic>?,
      role: json['role'] as String? ?? 'Doctor',
      licenseImageUrl: json['licenseImageUrl'] as String?,
      idCardFrontUrl: json['idCardFrontUrl'] as String?,
      idCardBackUrl: json['idCardBackUrl'] as String?,
    );

Map<String, dynamic> _$$DoctorImplToJson(_$DoctorImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fullName': instance.fullName,
      'specialty': instance.specialty,
      'otherSpecialties': instance.otherSpecialties,
      'education': instance.education,
      'email': instance.email,
      'graduationYear': instance.graduationYear,
      'licenseNumber': instance.licenseNumber,
      'experience': instance.experience,
      'currentWorkplace': instance.currentWorkplace,
      'phone': instance.phone,
      'address': instance.address,
      'verifiID': instance.verifiID,
      'status': instance.status,
      'isVerified': instance.isVerified,
      'avatar': instance.avatar,
      'schedule': instance.schedule,
      'role': instance.role,
      'licenseImageUrl': instance.licenseImageUrl,
      'idCardFrontUrl': instance.idCardFrontUrl,
      'idCardBackUrl': instance.idCardBackUrl,
    };
