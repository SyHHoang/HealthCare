import 'package:freezed_annotation/freezed_annotation.dart';

part 'consultation_list.freezed.dart';
part 'consultation_list.g.dart';

@freezed
class ConsultationList with _$ConsultationList {
  const factory ConsultationList({
    @JsonKey(name: '_id') required String id,
    required String userId,
    required String doctorId,
    required String doctorFullName,
    String? doctorSpecialty,
    String? doctorAvatar,
    int? doctorExperience,
    String? doctorCurrentWorkplace,
    @JsonKey(name: 'StartDate') required String startDate,
    @JsonKey(name: 'EndDate') required String endDate,
    @JsonKey(name: 'call') required int callRemaining,
    String? createdAt,
  }) = _ConsultationList;

  factory ConsultationList.fromJson(Map<String, dynamic> json) => _$ConsultationListFromJson(json);
} 