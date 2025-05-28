// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consultation_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConsultationListImpl _$$ConsultationListImplFromJson(
        Map<String, dynamic> json) =>
    _$ConsultationListImpl(
      id: json['_id'] as String,
      userId: json['userId'] as String,
      doctorId: json['doctorId'] as String,
      doctorFullName: json['doctorFullName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String?,
      doctorAvatar: json['doctorAvatar'] as String?,
      doctorExperience: (json['doctorExperience'] as num?)?.toInt(),
      doctorCurrentWorkplace: json['doctorCurrentWorkplace'] as String?,
      startDate: json['StartDate'] as String,
      endDate: json['EndDate'] as String,
      callRemaining: (json['call'] as num).toInt(),
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$$ConsultationListImplToJson(
        _$ConsultationListImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'doctorId': instance.doctorId,
      'doctorFullName': instance.doctorFullName,
      'doctorSpecialty': instance.doctorSpecialty,
      'doctorAvatar': instance.doctorAvatar,
      'doctorExperience': instance.doctorExperience,
      'doctorCurrentWorkplace': instance.doctorCurrentWorkplace,
      'StartDate': instance.startDate,
      'EndDate': instance.endDate,
      'call': instance.callRemaining,
      'createdAt': instance.createdAt,
    };
