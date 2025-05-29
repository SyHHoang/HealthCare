// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'consultation_list.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConsultationList _$ConsultationListFromJson(Map<String, dynamic> json) {
  return _ConsultationList.fromJson(json);
}

/// @nodoc
mixin _$ConsultationList {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get doctorId => throw _privateConstructorUsedError;
  String get doctorFullName => throw _privateConstructorUsedError;
  String? get doctorSpecialty => throw _privateConstructorUsedError;
  String? get doctorAvatar => throw _privateConstructorUsedError;
  int? get doctorExperience => throw _privateConstructorUsedError;
  String? get doctorCurrentWorkplace => throw _privateConstructorUsedError;
  @JsonKey(name: 'StartDate')
  String get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'EndDate')
  String get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'call')
  int get callRemaining => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ConsultationList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConsultationList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConsultationListCopyWith<ConsultationList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConsultationListCopyWith<$Res> {
  factory $ConsultationListCopyWith(
    ConsultationList value,
    $Res Function(ConsultationList) then,
  ) = _$ConsultationListCopyWithImpl<$Res, ConsultationList>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String userId,
    String doctorId,
    String doctorFullName,
    String? doctorSpecialty,
    String? doctorAvatar,
    int? doctorExperience,
    String? doctorCurrentWorkplace,
    @JsonKey(name: 'StartDate') String startDate,
    @JsonKey(name: 'EndDate') String endDate,
    @JsonKey(name: 'call') int callRemaining,
    String? createdAt,
  });
}

/// @nodoc
class _$ConsultationListCopyWithImpl<$Res, $Val extends ConsultationList>
    implements $ConsultationListCopyWith<$Res> {
  _$ConsultationListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConsultationList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? doctorId = null,
    Object? doctorFullName = null,
    Object? doctorSpecialty = freezed,
    Object? doctorAvatar = freezed,
    Object? doctorExperience = freezed,
    Object? doctorCurrentWorkplace = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? callRemaining = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            doctorId:
                null == doctorId
                    ? _value.doctorId
                    : doctorId // ignore: cast_nullable_to_non_nullable
                        as String,
            doctorFullName:
                null == doctorFullName
                    ? _value.doctorFullName
                    : doctorFullName // ignore: cast_nullable_to_non_nullable
                        as String,
            doctorSpecialty:
                freezed == doctorSpecialty
                    ? _value.doctorSpecialty
                    : doctorSpecialty // ignore: cast_nullable_to_non_nullable
                        as String?,
            doctorAvatar:
                freezed == doctorAvatar
                    ? _value.doctorAvatar
                    : doctorAvatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            doctorExperience:
                freezed == doctorExperience
                    ? _value.doctorExperience
                    : doctorExperience // ignore: cast_nullable_to_non_nullable
                        as int?,
            doctorCurrentWorkplace:
                freezed == doctorCurrentWorkplace
                    ? _value.doctorCurrentWorkplace
                    : doctorCurrentWorkplace // ignore: cast_nullable_to_non_nullable
                        as String?,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as String,
            endDate:
                null == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as String,
            callRemaining:
                null == callRemaining
                    ? _value.callRemaining
                    : callRemaining // ignore: cast_nullable_to_non_nullable
                        as int,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConsultationListImplCopyWith<$Res>
    implements $ConsultationListCopyWith<$Res> {
  factory _$$ConsultationListImplCopyWith(
    _$ConsultationListImpl value,
    $Res Function(_$ConsultationListImpl) then,
  ) = __$$ConsultationListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String userId,
    String doctorId,
    String doctorFullName,
    String? doctorSpecialty,
    String? doctorAvatar,
    int? doctorExperience,
    String? doctorCurrentWorkplace,
    @JsonKey(name: 'StartDate') String startDate,
    @JsonKey(name: 'EndDate') String endDate,
    @JsonKey(name: 'call') int callRemaining,
    String? createdAt,
  });
}

/// @nodoc
class __$$ConsultationListImplCopyWithImpl<$Res>
    extends _$ConsultationListCopyWithImpl<$Res, _$ConsultationListImpl>
    implements _$$ConsultationListImplCopyWith<$Res> {
  __$$ConsultationListImplCopyWithImpl(
    _$ConsultationListImpl _value,
    $Res Function(_$ConsultationListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConsultationList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? doctorId = null,
    Object? doctorFullName = null,
    Object? doctorSpecialty = freezed,
    Object? doctorAvatar = freezed,
    Object? doctorExperience = freezed,
    Object? doctorCurrentWorkplace = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? callRemaining = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$ConsultationListImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        doctorId:
            null == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                    as String,
        doctorFullName:
            null == doctorFullName
                ? _value.doctorFullName
                : doctorFullName // ignore: cast_nullable_to_non_nullable
                    as String,
        doctorSpecialty:
            freezed == doctorSpecialty
                ? _value.doctorSpecialty
                : doctorSpecialty // ignore: cast_nullable_to_non_nullable
                    as String?,
        doctorAvatar:
            freezed == doctorAvatar
                ? _value.doctorAvatar
                : doctorAvatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        doctorExperience:
            freezed == doctorExperience
                ? _value.doctorExperience
                : doctorExperience // ignore: cast_nullable_to_non_nullable
                    as int?,
        doctorCurrentWorkplace:
            freezed == doctorCurrentWorkplace
                ? _value.doctorCurrentWorkplace
                : doctorCurrentWorkplace // ignore: cast_nullable_to_non_nullable
                    as String?,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as String,
        endDate:
            null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as String,
        callRemaining:
            null == callRemaining
                ? _value.callRemaining
                : callRemaining // ignore: cast_nullable_to_non_nullable
                    as int,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConsultationListImpl implements _ConsultationList {
  const _$ConsultationListImpl({
    @JsonKey(name: '_id') required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorFullName,
    this.doctorSpecialty,
    this.doctorAvatar,
    this.doctorExperience,
    this.doctorCurrentWorkplace,
    @JsonKey(name: 'StartDate') required this.startDate,
    @JsonKey(name: 'EndDate') required this.endDate,
    @JsonKey(name: 'call') required this.callRemaining,
    this.createdAt,
  });

  factory _$ConsultationListImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConsultationListImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String userId;
  @override
  final String doctorId;
  @override
  final String doctorFullName;
  @override
  final String? doctorSpecialty;
  @override
  final String? doctorAvatar;
  @override
  final int? doctorExperience;
  @override
  final String? doctorCurrentWorkplace;
  @override
  @JsonKey(name: 'StartDate')
  final String startDate;
  @override
  @JsonKey(name: 'EndDate')
  final String endDate;
  @override
  @JsonKey(name: 'call')
  final int callRemaining;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'ConsultationList(id: $id, userId: $userId, doctorId: $doctorId, doctorFullName: $doctorFullName, doctorSpecialty: $doctorSpecialty, doctorAvatar: $doctorAvatar, doctorExperience: $doctorExperience, doctorCurrentWorkplace: $doctorCurrentWorkplace, startDate: $startDate, endDate: $endDate, callRemaining: $callRemaining, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConsultationListImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.doctorFullName, doctorFullName) ||
                other.doctorFullName == doctorFullName) &&
            (identical(other.doctorSpecialty, doctorSpecialty) ||
                other.doctorSpecialty == doctorSpecialty) &&
            (identical(other.doctorAvatar, doctorAvatar) ||
                other.doctorAvatar == doctorAvatar) &&
            (identical(other.doctorExperience, doctorExperience) ||
                other.doctorExperience == doctorExperience) &&
            (identical(other.doctorCurrentWorkplace, doctorCurrentWorkplace) ||
                other.doctorCurrentWorkplace == doctorCurrentWorkplace) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.callRemaining, callRemaining) ||
                other.callRemaining == callRemaining) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    doctorId,
    doctorFullName,
    doctorSpecialty,
    doctorAvatar,
    doctorExperience,
    doctorCurrentWorkplace,
    startDate,
    endDate,
    callRemaining,
    createdAt,
  );

  /// Create a copy of ConsultationList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConsultationListImplCopyWith<_$ConsultationListImpl> get copyWith =>
      __$$ConsultationListImplCopyWithImpl<_$ConsultationListImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConsultationListImplToJson(this);
  }
}

abstract class _ConsultationList implements ConsultationList {
  const factory _ConsultationList({
    @JsonKey(name: '_id') required final String id,
    required final String userId,
    required final String doctorId,
    required final String doctorFullName,
    final String? doctorSpecialty,
    final String? doctorAvatar,
    final int? doctorExperience,
    final String? doctorCurrentWorkplace,
    @JsonKey(name: 'StartDate') required final String startDate,
    @JsonKey(name: 'EndDate') required final String endDate,
    @JsonKey(name: 'call') required final int callRemaining,
    final String? createdAt,
  }) = _$ConsultationListImpl;

  factory _ConsultationList.fromJson(Map<String, dynamic> json) =
      _$ConsultationListImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get userId;
  @override
  String get doctorId;
  @override
  String get doctorFullName;
  @override
  String? get doctorSpecialty;
  @override
  String? get doctorAvatar;
  @override
  int? get doctorExperience;
  @override
  String? get doctorCurrentWorkplace;
  @override
  @JsonKey(name: 'StartDate')
  String get startDate;
  @override
  @JsonKey(name: 'EndDate')
  String get endDate;
  @override
  @JsonKey(name: 'call')
  int get callRemaining;
  @override
  String? get createdAt;

  /// Create a copy of ConsultationList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConsultationListImplCopyWith<_$ConsultationListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
