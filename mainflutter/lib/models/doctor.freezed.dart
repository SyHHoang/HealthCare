// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'doctor.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Doctor _$DoctorFromJson(Map<String, dynamic> json) {
  return _Doctor.fromJson(json);
}

/// @nodoc
mixin _$Doctor {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get fullName => throw _privateConstructorUsedError;
  String? get specialty => throw _privateConstructorUsedError;
  String? get otherSpecialties => throw _privateConstructorUsedError;
  String? get education => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  int? get graduationYear => throw _privateConstructorUsedError;
  String? get licenseNumber => throw _privateConstructorUsedError;
  int? get experience => throw _privateConstructorUsedError;
  String? get currentWorkplace => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get verifiID => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  bool get isVerified => throw _privateConstructorUsedError;
  String? get avatar => throw _privateConstructorUsedError;
  Map<String, dynamic>? get schedule => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this Doctor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DoctorCopyWith<Doctor> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DoctorCopyWith<$Res> {
  factory $DoctorCopyWith(Doctor value, $Res Function(Doctor) then) =
      _$DoctorCopyWithImpl<$Res, Doctor>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String fullName,
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
    String status,
    bool isVerified,
    String? avatar,
    Map<String, dynamic>? schedule,
    String role,
  });
}

/// @nodoc
class _$DoctorCopyWithImpl<$Res, $Val extends Doctor>
    implements $DoctorCopyWith<$Res> {
  _$DoctorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? specialty = freezed,
    Object? otherSpecialties = freezed,
    Object? education = freezed,
    Object? email = freezed,
    Object? graduationYear = freezed,
    Object? licenseNumber = freezed,
    Object? experience = freezed,
    Object? currentWorkplace = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? verifiID = freezed,
    Object? status = null,
    Object? isVerified = null,
    Object? avatar = freezed,
    Object? schedule = freezed,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            fullName:
                null == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String,
            specialty:
                freezed == specialty
                    ? _value.specialty
                    : specialty // ignore: cast_nullable_to_non_nullable
                        as String?,
            otherSpecialties:
                freezed == otherSpecialties
                    ? _value.otherSpecialties
                    : otherSpecialties // ignore: cast_nullable_to_non_nullable
                        as String?,
            education:
                freezed == education
                    ? _value.education
                    : education // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            graduationYear:
                freezed == graduationYear
                    ? _value.graduationYear
                    : graduationYear // ignore: cast_nullable_to_non_nullable
                        as int?,
            licenseNumber:
                freezed == licenseNumber
                    ? _value.licenseNumber
                    : licenseNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            experience:
                freezed == experience
                    ? _value.experience
                    : experience // ignore: cast_nullable_to_non_nullable
                        as int?,
            currentWorkplace:
                freezed == currentWorkplace
                    ? _value.currentWorkplace
                    : currentWorkplace // ignore: cast_nullable_to_non_nullable
                        as String?,
            phone:
                freezed == phone
                    ? _value.phone
                    : phone // ignore: cast_nullable_to_non_nullable
                        as String?,
            address:
                freezed == address
                    ? _value.address
                    : address // ignore: cast_nullable_to_non_nullable
                        as String?,
            verifiID:
                freezed == verifiID
                    ? _value.verifiID
                    : verifiID // ignore: cast_nullable_to_non_nullable
                        as String?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            isVerified:
                null == isVerified
                    ? _value.isVerified
                    : isVerified // ignore: cast_nullable_to_non_nullable
                        as bool,
            avatar:
                freezed == avatar
                    ? _value.avatar
                    : avatar // ignore: cast_nullable_to_non_nullable
                        as String?,
            schedule:
                freezed == schedule
                    ? _value.schedule
                    : schedule // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>?,
            role:
                null == role
                    ? _value.role
                    : role // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DoctorImplCopyWith<$Res> implements $DoctorCopyWith<$Res> {
  factory _$$DoctorImplCopyWith(
    _$DoctorImpl value,
    $Res Function(_$DoctorImpl) then,
  ) = __$$DoctorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String fullName,
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
    String status,
    bool isVerified,
    String? avatar,
    Map<String, dynamic>? schedule,
    String role,
  });
}

/// @nodoc
class __$$DoctorImplCopyWithImpl<$Res>
    extends _$DoctorCopyWithImpl<$Res, _$DoctorImpl>
    implements _$$DoctorImplCopyWith<$Res> {
  __$$DoctorImplCopyWithImpl(
    _$DoctorImpl _value,
    $Res Function(_$DoctorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fullName = null,
    Object? specialty = freezed,
    Object? otherSpecialties = freezed,
    Object? education = freezed,
    Object? email = freezed,
    Object? graduationYear = freezed,
    Object? licenseNumber = freezed,
    Object? experience = freezed,
    Object? currentWorkplace = freezed,
    Object? phone = freezed,
    Object? address = freezed,
    Object? verifiID = freezed,
    Object? status = null,
    Object? isVerified = null,
    Object? avatar = freezed,
    Object? schedule = freezed,
    Object? role = null,
  }) {
    return _then(
      _$DoctorImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        fullName:
            null == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String,
        specialty:
            freezed == specialty
                ? _value.specialty
                : specialty // ignore: cast_nullable_to_non_nullable
                    as String?,
        otherSpecialties:
            freezed == otherSpecialties
                ? _value.otherSpecialties
                : otherSpecialties // ignore: cast_nullable_to_non_nullable
                    as String?,
        education:
            freezed == education
                ? _value.education
                : education // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        graduationYear:
            freezed == graduationYear
                ? _value.graduationYear
                : graduationYear // ignore: cast_nullable_to_non_nullable
                    as int?,
        licenseNumber:
            freezed == licenseNumber
                ? _value.licenseNumber
                : licenseNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        experience:
            freezed == experience
                ? _value.experience
                : experience // ignore: cast_nullable_to_non_nullable
                    as int?,
        currentWorkplace:
            freezed == currentWorkplace
                ? _value.currentWorkplace
                : currentWorkplace // ignore: cast_nullable_to_non_nullable
                    as String?,
        phone:
            freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                    as String?,
        address:
            freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                    as String?,
        verifiID:
            freezed == verifiID
                ? _value.verifiID
                : verifiID // ignore: cast_nullable_to_non_nullable
                    as String?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        isVerified:
            null == isVerified
                ? _value.isVerified
                : isVerified // ignore: cast_nullable_to_non_nullable
                    as bool,
        avatar:
            freezed == avatar
                ? _value.avatar
                : avatar // ignore: cast_nullable_to_non_nullable
                    as String?,
        schedule:
            freezed == schedule
                ? _value._schedule
                : schedule // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>?,
        role:
            null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DoctorImpl implements _Doctor {
  const _$DoctorImpl({
    @JsonKey(name: '_id') required this.id,
    required this.fullName,
    this.specialty,
    this.otherSpecialties,
    this.education,
    this.email,
    this.graduationYear,
    this.licenseNumber,
    this.experience,
    this.currentWorkplace,
    this.phone,
    this.address,
    this.verifiID,
    this.status = 'pending',
    this.isVerified = false,
    this.avatar,
    final Map<String, dynamic>? schedule,
    this.role = 'Doctor',
  }) : _schedule = schedule;

  factory _$DoctorImpl.fromJson(Map<String, dynamic> json) =>
      _$$DoctorImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String fullName;
  @override
  final String? specialty;
  @override
  final String? otherSpecialties;
  @override
  final String? education;
  @override
  final String? email;
  @override
  final int? graduationYear;
  @override
  final String? licenseNumber;
  @override
  final int? experience;
  @override
  final String? currentWorkplace;
  @override
  final String? phone;
  @override
  final String? address;
  @override
  final String? verifiID;
  @override
  @JsonKey()
  final String status;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  final String? avatar;
  final Map<String, dynamic>? _schedule;
  @override
  Map<String, dynamic>? get schedule {
    final value = _schedule;
    if (value == null) return null;
    if (_schedule is EqualUnmodifiableMapView) return _schedule;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final String role;

  @override
  String toString() {
    return 'Doctor(id: $id, fullName: $fullName, specialty: $specialty, otherSpecialties: $otherSpecialties, education: $education, email: $email, graduationYear: $graduationYear, licenseNumber: $licenseNumber, experience: $experience, currentWorkplace: $currentWorkplace, phone: $phone, address: $address, verifiID: $verifiID, status: $status, isVerified: $isVerified, avatar: $avatar, schedule: $schedule, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DoctorImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.otherSpecialties, otherSpecialties) ||
                other.otherSpecialties == otherSpecialties) &&
            (identical(other.education, education) ||
                other.education == education) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.graduationYear, graduationYear) ||
                other.graduationYear == graduationYear) &&
            (identical(other.licenseNumber, licenseNumber) ||
                other.licenseNumber == licenseNumber) &&
            (identical(other.experience, experience) ||
                other.experience == experience) &&
            (identical(other.currentWorkplace, currentWorkplace) ||
                other.currentWorkplace == currentWorkplace) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.verifiID, verifiID) ||
                other.verifiID == verifiID) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.avatar, avatar) || other.avatar == avatar) &&
            const DeepCollectionEquality().equals(other._schedule, _schedule) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    fullName,
    specialty,
    otherSpecialties,
    education,
    email,
    graduationYear,
    licenseNumber,
    experience,
    currentWorkplace,
    phone,
    address,
    verifiID,
    status,
    isVerified,
    avatar,
    const DeepCollectionEquality().hash(_schedule),
    role,
  );

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DoctorImplCopyWith<_$DoctorImpl> get copyWith =>
      __$$DoctorImplCopyWithImpl<_$DoctorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DoctorImplToJson(this);
  }
}

abstract class _Doctor implements Doctor {
  const factory _Doctor({
    @JsonKey(name: '_id') required final String id,
    required final String fullName,
    final String? specialty,
    final String? otherSpecialties,
    final String? education,
    final String? email,
    final int? graduationYear,
    final String? licenseNumber,
    final int? experience,
    final String? currentWorkplace,
    final String? phone,
    final String? address,
    final String? verifiID,
    final String status,
    final bool isVerified,
    final String? avatar,
    final Map<String, dynamic>? schedule,
    final String role,
  }) = _$DoctorImpl;

  factory _Doctor.fromJson(Map<String, dynamic> json) = _$DoctorImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get fullName;
  @override
  String? get specialty;
  @override
  String? get otherSpecialties;
  @override
  String? get education;
  @override
  String? get email;
  @override
  int? get graduationYear;
  @override
  String? get licenseNumber;
  @override
  int? get experience;
  @override
  String? get currentWorkplace;
  @override
  String? get phone;
  @override
  String? get address;
  @override
  String? get verifiID;
  @override
  String get status;
  @override
  bool get isVerified;
  @override
  String? get avatar;
  @override
  Map<String, dynamic>? get schedule;
  @override
  String get role;

  /// Create a copy of Doctor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DoctorImplCopyWith<_$DoctorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
