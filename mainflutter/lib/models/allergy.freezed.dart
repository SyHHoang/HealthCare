// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'allergy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Allergy _$AllergyFromJson(Map<String, dynamic> json) {
  return _Allergy.fromJson(json);
}

/// @nodoc
mixin _$Allergy {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get allergen => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get severity => throw _privateConstructorUsedError;
  List<String> get symptoms => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get firstOccurrence => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get lastOccurrence => throw _privateConstructorUsedError;
  String? get treatment => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this Allergy to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Allergy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllergyCopyWith<Allergy> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllergyCopyWith<$Res> {
  factory $AllergyCopyWith(Allergy value, $Res Function(Allergy) then) =
      _$AllergyCopyWithImpl<$Res, Allergy>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String allergen,
      String type,
      String severity,
      List<String> symptoms,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? firstOccurrence,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? lastOccurrence,
      String? treatment,
      String? notes,
      bool isActive});
}

/// @nodoc
class _$AllergyCopyWithImpl<$Res, $Val extends Allergy>
    implements $AllergyCopyWith<$Res> {
  _$AllergyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Allergy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? allergen = null,
    Object? type = null,
    Object? severity = null,
    Object? symptoms = null,
    Object? firstOccurrence = freezed,
    Object? lastOccurrence = freezed,
    Object? treatment = freezed,
    Object? notes = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      allergen: null == allergen
          ? _value.allergen
          : allergen // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      symptoms: null == symptoms
          ? _value.symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstOccurrence: freezed == firstOccurrence
          ? _value.firstOccurrence
          : firstOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastOccurrence: freezed == lastOccurrence
          ? _value.lastOccurrence
          : lastOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      treatment: freezed == treatment
          ? _value.treatment
          : treatment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AllergyImplCopyWith<$Res> implements $AllergyCopyWith<$Res> {
  factory _$$AllergyImplCopyWith(
          _$AllergyImpl value, $Res Function(_$AllergyImpl) then) =
      __$$AllergyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String id,
      String allergen,
      String type,
      String severity,
      List<String> symptoms,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? firstOccurrence,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      DateTime? lastOccurrence,
      String? treatment,
      String? notes,
      bool isActive});
}

/// @nodoc
class __$$AllergyImplCopyWithImpl<$Res>
    extends _$AllergyCopyWithImpl<$Res, _$AllergyImpl>
    implements _$$AllergyImplCopyWith<$Res> {
  __$$AllergyImplCopyWithImpl(
      _$AllergyImpl _value, $Res Function(_$AllergyImpl) _then)
      : super(_value, _then);

  /// Create a copy of Allergy
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? allergen = null,
    Object? type = null,
    Object? severity = null,
    Object? symptoms = null,
    Object? firstOccurrence = freezed,
    Object? lastOccurrence = freezed,
    Object? treatment = freezed,
    Object? notes = freezed,
    Object? isActive = null,
  }) {
    return _then(_$AllergyImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      allergen: null == allergen
          ? _value.allergen
          : allergen // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as String,
      symptoms: null == symptoms
          ? _value._symptoms
          : symptoms // ignore: cast_nullable_to_non_nullable
              as List<String>,
      firstOccurrence: freezed == firstOccurrence
          ? _value.firstOccurrence
          : firstOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastOccurrence: freezed == lastOccurrence
          ? _value.lastOccurrence
          : lastOccurrence // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      treatment: freezed == treatment
          ? _value.treatment
          : treatment // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AllergyImpl implements _Allergy {
  const _$AllergyImpl(
      {@JsonKey(name: '_id') required this.id,
      required this.allergen,
      required this.type,
      required this.severity,
      required final List<String> symptoms,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      this.firstOccurrence,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      this.lastOccurrence,
      this.treatment,
      this.notes,
      this.isActive = true})
      : _symptoms = symptoms;

  factory _$AllergyImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllergyImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String allergen;
  @override
  final String type;
  @override
  final String severity;
  final List<String> _symptoms;
  @override
  List<String> get symptoms {
    if (_symptoms is EqualUnmodifiableListView) return _symptoms;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symptoms);
  }

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? firstOccurrence;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime? lastOccurrence;
  @override
  final String? treatment;
  @override
  final String? notes;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'Allergy(id: $id, allergen: $allergen, type: $type, severity: $severity, symptoms: $symptoms, firstOccurrence: $firstOccurrence, lastOccurrence: $lastOccurrence, treatment: $treatment, notes: $notes, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllergyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.allergen, allergen) ||
                other.allergen == allergen) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            const DeepCollectionEquality().equals(other._symptoms, _symptoms) &&
            (identical(other.firstOccurrence, firstOccurrence) ||
                other.firstOccurrence == firstOccurrence) &&
            (identical(other.lastOccurrence, lastOccurrence) ||
                other.lastOccurrence == lastOccurrence) &&
            (identical(other.treatment, treatment) ||
                other.treatment == treatment) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      allergen,
      type,
      severity,
      const DeepCollectionEquality().hash(_symptoms),
      firstOccurrence,
      lastOccurrence,
      treatment,
      notes,
      isActive);

  /// Create a copy of Allergy
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllergyImplCopyWith<_$AllergyImpl> get copyWith =>
      __$$AllergyImplCopyWithImpl<_$AllergyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllergyImplToJson(
      this,
    );
  }
}

abstract class _Allergy implements Allergy {
  const factory _Allergy(
      {@JsonKey(name: '_id') required final String id,
      required final String allergen,
      required final String type,
      required final String severity,
      required final List<String> symptoms,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      final DateTime? firstOccurrence,
      @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
      final DateTime? lastOccurrence,
      final String? treatment,
      final String? notes,
      final bool isActive}) = _$AllergyImpl;

  factory _Allergy.fromJson(Map<String, dynamic> json) = _$AllergyImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get allergen;
  @override
  String get type;
  @override
  String get severity;
  @override
  List<String> get symptoms;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get firstOccurrence;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime? get lastOccurrence;
  @override
  String? get treatment;
  @override
  String? get notes;
  @override
  bool get isActive;

  /// Create a copy of Allergy
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllergyImplCopyWith<_$AllergyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
