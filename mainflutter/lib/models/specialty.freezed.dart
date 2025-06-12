// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'specialty.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Specialty _$SpecialtyFromJson(Map<String, dynamic> json) {
  return _Specialty.fromJson(json);
}

/// @nodoc
mixin _$Specialty {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get icon => throw _privateConstructorUsedError;
  bool get isSuggested => throw _privateConstructorUsedError;
  double? get confidence => throw _privateConstructorUsedError;

  /// Serializes this Specialty to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Specialty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpecialtyCopyWith<Specialty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpecialtyCopyWith<$Res> {
  factory $SpecialtyCopyWith(Specialty value, $Res Function(Specialty) then) =
      _$SpecialtyCopyWithImpl<$Res, Specialty>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String name,
    String description,
    String? icon,
    bool isSuggested,
    double? confidence,
  });
}

/// @nodoc
class _$SpecialtyCopyWithImpl<$Res, $Val extends Specialty>
    implements $SpecialtyCopyWith<$Res> {
  _$SpecialtyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Specialty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? icon = freezed,
    Object? isSuggested = null,
    Object? confidence = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            icon:
                freezed == icon
                    ? _value.icon
                    : icon // ignore: cast_nullable_to_non_nullable
                        as String?,
            isSuggested:
                null == isSuggested
                    ? _value.isSuggested
                    : isSuggested // ignore: cast_nullable_to_non_nullable
                        as bool,
            confidence:
                freezed == confidence
                    ? _value.confidence
                    : confidence // ignore: cast_nullable_to_non_nullable
                        as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SpecialtyImplCopyWith<$Res>
    implements $SpecialtyCopyWith<$Res> {
  factory _$$SpecialtyImplCopyWith(
    _$SpecialtyImpl value,
    $Res Function(_$SpecialtyImpl) then,
  ) = __$$SpecialtyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String? id,
    String name,
    String description,
    String? icon,
    bool isSuggested,
    double? confidence,
  });
}

/// @nodoc
class __$$SpecialtyImplCopyWithImpl<$Res>
    extends _$SpecialtyCopyWithImpl<$Res, _$SpecialtyImpl>
    implements _$$SpecialtyImplCopyWith<$Res> {
  __$$SpecialtyImplCopyWithImpl(
    _$SpecialtyImpl _value,
    $Res Function(_$SpecialtyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Specialty
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? name = null,
    Object? description = null,
    Object? icon = freezed,
    Object? isSuggested = null,
    Object? confidence = freezed,
  }) {
    return _then(
      _$SpecialtyImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        icon:
            freezed == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                    as String?,
        isSuggested:
            null == isSuggested
                ? _value.isSuggested
                : isSuggested // ignore: cast_nullable_to_non_nullable
                    as bool,
        confidence:
            freezed == confidence
                ? _value.confidence
                : confidence // ignore: cast_nullable_to_non_nullable
                    as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SpecialtyImpl implements _Specialty {
  const _$SpecialtyImpl({
    @JsonKey(name: '_id') this.id,
    required this.name,
    required this.description,
    this.icon,
    this.isSuggested = false,
    this.confidence,
  });

  factory _$SpecialtyImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpecialtyImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String? icon;
  @override
  @JsonKey()
  final bool isSuggested;
  @override
  final double? confidence;

  @override
  String toString() {
    return 'Specialty(id: $id, name: $name, description: $description, icon: $icon, isSuggested: $isSuggested, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpecialtyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isSuggested, isSuggested) ||
                other.isSuggested == isSuggested) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    icon,
    isSuggested,
    confidence,
  );

  /// Create a copy of Specialty
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpecialtyImplCopyWith<_$SpecialtyImpl> get copyWith =>
      __$$SpecialtyImplCopyWithImpl<_$SpecialtyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpecialtyImplToJson(this);
  }
}

abstract class _Specialty implements Specialty {
  const factory _Specialty({
    @JsonKey(name: '_id') final String? id,
    required final String name,
    required final String description,
    final String? icon,
    final bool isSuggested,
    final double? confidence,
  }) = _$SpecialtyImpl;

  factory _Specialty.fromJson(Map<String, dynamic> json) =
      _$SpecialtyImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String? get icon;
  @override
  bool get isSuggested;
  @override
  double? get confidence;

  /// Create a copy of Specialty
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpecialtyImplCopyWith<_$SpecialtyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
