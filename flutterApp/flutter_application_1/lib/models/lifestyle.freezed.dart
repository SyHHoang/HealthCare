// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lifestyle.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Lifestyle _$LifestyleFromJson(Map<String, dynamic> json) {
  return _Lifestyle.fromJson(json);
}

/// @nodoc
mixin _$Lifestyle {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get activityType => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  String? get duration => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get startDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Lifestyle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Lifestyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LifestyleCopyWith<Lifestyle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LifestyleCopyWith<$Res> {
  factory $LifestyleCopyWith(Lifestyle value, $Res Function(Lifestyle) then) =
      _$LifestyleCopyWithImpl<$Res, Lifestyle>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String activityType,
      String description,
      String frequency,
      String? duration,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? startDate,
      String? notes});
}

/// @nodoc
class _$LifestyleCopyWithImpl<$Res, $Val extends Lifestyle>
    implements $LifestyleCopyWith<$Res> {
  _$LifestyleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Lifestyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityType = null,
    Object? description = null,
    Object? frequency = null,
    Object? duration = freezed,
    Object? startDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LifestyleImplCopyWith<$Res>
    implements $LifestyleCopyWith<$Res> {
  factory _$$LifestyleImplCopyWith(
          _$LifestyleImpl value, $Res Function(_$LifestyleImpl) then) =
      __$$LifestyleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String activityType,
      String description,
      String frequency,
      String? duration,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? startDate,
      String? notes});
}

/// @nodoc
class __$$LifestyleImplCopyWithImpl<$Res>
    extends _$LifestyleCopyWithImpl<$Res, _$LifestyleImpl>
    implements _$$LifestyleImplCopyWith<$Res> {
  __$$LifestyleImplCopyWithImpl(
      _$LifestyleImpl _value, $Res Function(_$LifestyleImpl) _then)
      : super(_value, _then);

  /// Create a copy of Lifestyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? activityType = null,
    Object? description = null,
    Object? frequency = null,
    Object? duration = freezed,
    Object? startDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$LifestyleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      activityType: null == activityType
          ? _value.activityType
          : activityType // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LifestyleImpl implements _Lifestyle {
  const _$LifestyleImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.activityType,
      required this.description,
      required this.frequency,
      this.duration,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      this.startDate,
      this.notes});

  factory _$LifestyleImpl.fromJson(Map<String, dynamic> json) =>
      _$$LifestyleImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String activityType;
  @override
  final String description;
  @override
  final String frequency;
  @override
  final String? duration;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? startDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'Lifestyle(id: $id, activityType: $activityType, description: $description, frequency: $frequency, duration: $duration, startDate: $startDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LifestyleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.activityType, activityType) ||
                other.activityType == activityType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, activityType, description,
      frequency, duration, startDate, notes);

  /// Create a copy of Lifestyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LifestyleImplCopyWith<_$LifestyleImpl> get copyWith =>
      __$$LifestyleImplCopyWithImpl<_$LifestyleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LifestyleImplToJson(
      this,
    );
  }
}

abstract class _Lifestyle implements Lifestyle {
  const factory _Lifestyle(
      {@JsonKey(name: '_id') required final String id,
      required final String activityType,
      required final String description,
      required final String frequency,
      final String? duration,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      final DateTime? startDate,
      final String? notes}) = _$LifestyleImpl;

  factory _Lifestyle.fromJson(Map<String, dynamic> json) =
      _$LifestyleImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get activityType;
  @override
  String get description;
  @override
  String get frequency;
  @override
  String? get duration;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get startDate;
  @override
  String? get notes;

  /// Create a copy of Lifestyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LifestyleImplCopyWith<_$LifestyleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
