// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'symptom.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Symptom _$SymptomFromJson(Map<String, dynamic> json) {
  return _Symptom.fromJson(json);
}

/// @nodoc
mixin _$Symptom {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get severity => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Symptom to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Symptom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SymptomCopyWith<Symptom> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SymptomCopyWith<$Res> {
  factory $SymptomCopyWith(Symptom value, $Res Function(Symptom) then) =
      _$SymptomCopyWithImpl<$Res, Symptom>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? name,
      String? severity,
      DateTime? startDate,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$SymptomCopyWithImpl<$Res, $Val extends Symptom>
    implements $SymptomCopyWith<$Res> {
  _$SymptomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Symptom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? severity = freezed,
    Object? startDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SymptomImplCopyWith<$Res> implements $SymptomCopyWith<$Res> {
  factory _$$SymptomImplCopyWith(
          _$SymptomImpl value, $Res Function(_$SymptomImpl) then) =
      __$$SymptomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      String? name,
      String? severity,
      DateTime? startDate,
      String? notes,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$SymptomImplCopyWithImpl<$Res>
    extends _$SymptomCopyWithImpl<$Res, _$SymptomImpl>
    implements _$$SymptomImplCopyWith<$Res> {
  __$$SymptomImplCopyWithImpl(
      _$SymptomImpl _value, $Res Function(_$SymptomImpl) _then)
      : super(_value, _then);

  /// Create a copy of Symptom
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? name = freezed,
    Object? severity = freezed,
    Object? startDate = freezed,
    Object? notes = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$SymptomImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      severity: freezed == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SymptomImpl with DiagnosticableTreeMixin implements _Symptom {
  const _$SymptomImpl(
      {this.id,
      this.userId,
      this.name,
      this.severity,
      this.startDate,
      this.notes,
      this.createdAt,
      this.updatedAt});

  factory _$SymptomImpl.fromJson(Map<String, dynamic> json) =>
      _$$SymptomImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? name;
  @override
  final String? severity;
  @override
  final DateTime? startDate;
  @override
  final String? notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Symptom(id: $id, userId: $userId, name: $name, severity: $severity, startDate: $startDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Symptom'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('severity', severity))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SymptomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, name, severity,
      startDate, notes, createdAt, updatedAt);

  /// Create a copy of Symptom
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SymptomImplCopyWith<_$SymptomImpl> get copyWith =>
      __$$SymptomImplCopyWithImpl<_$SymptomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SymptomImplToJson(
      this,
    );
  }
}

abstract class _Symptom implements Symptom {
  const factory _Symptom(
      {final String? id,
      final String? userId,
      final String? name,
      final String? severity,
      final DateTime? startDate,
      final String? notes,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$SymptomImpl;

  factory _Symptom.fromJson(Map<String, dynamic> json) = _$SymptomImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get name;
  @override
  String? get severity;
  @override
  DateTime? get startDate;
  @override
  String? get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Symptom
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SymptomImplCopyWith<_$SymptomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
