// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vaccination.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SideEffect _$SideEffectFromJson(Map<String, dynamic> json) {
  return _SideEffect.fromJson(json);
}

/// @nodoc
mixin _$SideEffect {
  String get description => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;

  /// Serializes this SideEffect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SideEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SideEffectCopyWith<SideEffect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SideEffectCopyWith<$Res> {
  factory $SideEffectCopyWith(
          SideEffect value, $Res Function(SideEffect) then) =
      _$SideEffectCopyWithImpl<$Res, SideEffect>;
  @useResult
  $Res call({String description, String severity, String? duration});
}

/// @nodoc
class _$SideEffectCopyWithImpl<$Res, $Val extends SideEffect>
    implements $SideEffectCopyWith<$Res> {
  _$SideEffectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SideEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? severity = null,
    Object? duration = freezed,
  }) {
    return _then(_value.copyWith(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SideEffectImplCopyWith<$Res>
    implements $SideEffectCopyWith<$Res> {
  factory _$$SideEffectImplCopyWith(
          _$SideEffectImpl value, $Res Function(_$SideEffectImpl) then) =
      __$$SideEffectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String description, String severity, String? duration});
}

/// @nodoc
class __$$SideEffectImplCopyWithImpl<$Res>
    extends _$SideEffectCopyWithImpl<$Res, _$SideEffectImpl>
    implements _$$SideEffectImplCopyWith<$Res> {
  __$$SideEffectImplCopyWithImpl(
      _$SideEffectImpl _value, $Res Function(_$SideEffectImpl) _then)
      : super(_value, _then);

  /// Create a copy of SideEffect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = null,
    Object? severity = null,
    Object? duration = freezed,
  }) {
    return _then(_$SideEffectImpl(
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SideEffectImpl implements _SideEffect {
  const _$SideEffectImpl(
      {required this.description, required this.severity, this.duration});

  factory _$SideEffectImpl.fromJson(Map<String, dynamic> json) =>
      _$$SideEffectImplFromJson(json);

  @override
  final String description;
  @override
  final String severity;
  @override
  final String? duration;

  @override
  String toString() {
    return 'SideEffect(description: $description, severity: $severity, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SideEffectImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, description, severity, duration);

  /// Create a copy of SideEffect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SideEffectImplCopyWith<_$SideEffectImpl> get copyWith =>
      __$$SideEffectImplCopyWithImpl<_$SideEffectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SideEffectImplToJson(
      this,
    );
  }
}

abstract class _SideEffect implements SideEffect {
  const factory _SideEffect(
      {required final String description,
      required final String severity,
      final String? duration}) = _$SideEffectImpl;

  factory _SideEffect.fromJson(Map<String, dynamic> json) =
      _$SideEffectImpl.fromJson;

  @override
  String get description;
  @override
  String get severity;
  @override
  String? get duration;

  /// Create a copy of SideEffect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SideEffectImplCopyWith<_$SideEffectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Vaccination _$VaccinationFromJson(Map<String, dynamic> json) {
  return _Vaccination.fromJson(json);
}

/// @nodoc
mixin _$Vaccination {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get vaccineName => throw _privateConstructorUsedError;
  String get vaccineType => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get dateAdministered => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get nextDoseDate => throw _privateConstructorUsedError;
  String? get batchNumber => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  List<SideEffect>? get sideEffects => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this Vaccination to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Vaccination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VaccinationCopyWith<Vaccination> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VaccinationCopyWith<$Res> {
  factory $VaccinationCopyWith(
          Vaccination value, $Res Function(Vaccination) then) =
      _$VaccinationCopyWithImpl<$Res, Vaccination>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String vaccineName,
      String vaccineType,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? dateAdministered,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? nextDoseDate,
      String? batchNumber,
      String? manufacturer,
      List<SideEffect>? sideEffects,
      String? notes,
      String? status});
}

/// @nodoc
class _$VaccinationCopyWithImpl<$Res, $Val extends Vaccination>
    implements $VaccinationCopyWith<$Res> {
  _$VaccinationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Vaccination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vaccineName = null,
    Object? vaccineType = null,
    Object? dateAdministered = freezed,
    Object? nextDoseDate = freezed,
    Object? batchNumber = freezed,
    Object? manufacturer = freezed,
    Object? sideEffects = freezed,
    Object? notes = freezed,
    Object? status = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vaccineName: null == vaccineName
          ? _value.vaccineName
          : vaccineName // ignore: cast_nullable_to_non_nullable
              as String,
      vaccineType: null == vaccineType
          ? _value.vaccineType
          : vaccineType // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdministered: freezed == dateAdministered
          ? _value.dateAdministered
          : dateAdministered // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDoseDate: freezed == nextDoseDate
          ? _value.nextDoseDate
          : nextDoseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batchNumber: freezed == batchNumber
          ? _value.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value.sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as List<SideEffect>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VaccinationImplCopyWith<$Res>
    implements $VaccinationCopyWith<$Res> {
  factory _$$VaccinationImplCopyWith(
          _$VaccinationImpl value, $Res Function(_$VaccinationImpl) then) =
      __$$VaccinationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String vaccineName,
      String vaccineType,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? dateAdministered,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? nextDoseDate,
      String? batchNumber,
      String? manufacturer,
      List<SideEffect>? sideEffects,
      String? notes,
      String? status});
}

/// @nodoc
class __$$VaccinationImplCopyWithImpl<$Res>
    extends _$VaccinationCopyWithImpl<$Res, _$VaccinationImpl>
    implements _$$VaccinationImplCopyWith<$Res> {
  __$$VaccinationImplCopyWithImpl(
      _$VaccinationImpl _value, $Res Function(_$VaccinationImpl) _then)
      : super(_value, _then);

  /// Create a copy of Vaccination
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? vaccineName = null,
    Object? vaccineType = null,
    Object? dateAdministered = freezed,
    Object? nextDoseDate = freezed,
    Object? batchNumber = freezed,
    Object? manufacturer = freezed,
    Object? sideEffects = freezed,
    Object? notes = freezed,
    Object? status = freezed,
  }) {
    return _then(_$VaccinationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      vaccineName: null == vaccineName
          ? _value.vaccineName
          : vaccineName // ignore: cast_nullable_to_non_nullable
              as String,
      vaccineType: null == vaccineType
          ? _value.vaccineType
          : vaccineType // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdministered: freezed == dateAdministered
          ? _value.dateAdministered
          : dateAdministered // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      nextDoseDate: freezed == nextDoseDate
          ? _value.nextDoseDate
          : nextDoseDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      batchNumber: freezed == batchNumber
          ? _value.batchNumber
          : batchNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value._sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as List<SideEffect>?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VaccinationImpl implements _Vaccination {
  const _$VaccinationImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.vaccineName,
      required this.vaccineType,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      this.dateAdministered,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      this.nextDoseDate,
      this.batchNumber,
      this.manufacturer,
      final List<SideEffect>? sideEffects,
      this.notes,
      this.status})
      : _sideEffects = sideEffects;

  factory _$VaccinationImpl.fromJson(Map<String, dynamic> json) =>
      _$$VaccinationImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String vaccineName;
  @override
  final String vaccineType;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? dateAdministered;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? nextDoseDate;
  @override
  final String? batchNumber;
  @override
  final String? manufacturer;
  final List<SideEffect>? _sideEffects;
  @override
  List<SideEffect>? get sideEffects {
    final value = _sideEffects;
    if (value == null) return null;
    if (_sideEffects is EqualUnmodifiableListView) return _sideEffects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? notes;
  @override
  final String? status;

  @override
  String toString() {
    return 'Vaccination(id: $id, vaccineName: $vaccineName, vaccineType: $vaccineType, dateAdministered: $dateAdministered, nextDoseDate: $nextDoseDate, batchNumber: $batchNumber, manufacturer: $manufacturer, sideEffects: $sideEffects, notes: $notes, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VaccinationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.vaccineName, vaccineName) ||
                other.vaccineName == vaccineName) &&
            (identical(other.vaccineType, vaccineType) ||
                other.vaccineType == vaccineType) &&
            (identical(other.dateAdministered, dateAdministered) ||
                other.dateAdministered == dateAdministered) &&
            (identical(other.nextDoseDate, nextDoseDate) ||
                other.nextDoseDate == nextDoseDate) &&
            (identical(other.batchNumber, batchNumber) ||
                other.batchNumber == batchNumber) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            const DeepCollectionEquality()
                .equals(other._sideEffects, _sideEffects) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      vaccineName,
      vaccineType,
      dateAdministered,
      nextDoseDate,
      batchNumber,
      manufacturer,
      const DeepCollectionEquality().hash(_sideEffects),
      notes,
      status);

  /// Create a copy of Vaccination
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VaccinationImplCopyWith<_$VaccinationImpl> get copyWith =>
      __$$VaccinationImplCopyWithImpl<_$VaccinationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VaccinationImplToJson(
      this,
    );
  }
}

abstract class _Vaccination implements Vaccination {
  const factory _Vaccination(
      {@JsonKey(name: '_id') required final String id,
      required final String vaccineName,
      required final String vaccineType,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      final DateTime? dateAdministered,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      final DateTime? nextDoseDate,
      final String? batchNumber,
      final String? manufacturer,
      final List<SideEffect>? sideEffects,
      final String? notes,
      final String? status}) = _$VaccinationImpl;

  factory _Vaccination.fromJson(Map<String, dynamic> json) =
      _$VaccinationImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get vaccineName;
  @override
  String get vaccineType;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get dateAdministered;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get nextDoseDate;
  @override
  String? get batchNumber;
  @override
  String? get manufacturer;
  @override
  List<SideEffect>? get sideEffects;
  @override
  String? get notes;
  @override
  String? get status;

  /// Create a copy of Vaccination
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VaccinationImplCopyWith<_$VaccinationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
