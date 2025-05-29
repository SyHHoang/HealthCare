// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prescription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Medicine _$MedicineFromJson(Map<String, dynamic> json) {
  return _Medicine.fromJson(json);
}

/// @nodoc
mixin _$Medicine {
  String get name => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Medicine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicineCopyWith<Medicine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicineCopyWith<$Res> {
  factory $MedicineCopyWith(Medicine value, $Res Function(Medicine) then) =
      _$MedicineCopyWithImpl<$Res, Medicine>;
  @useResult
  $Res call({
    String name,
    String dosage,
    String frequency,
    String duration,
    String? notes,
  });
}

/// @nodoc
class _$MedicineCopyWithImpl<$Res, $Val extends Medicine>
    implements $MedicineCopyWith<$Res> {
  _$MedicineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            dosage:
                null == dosage
                    ? _value.dosage
                    : dosage // ignore: cast_nullable_to_non_nullable
                        as String,
            frequency:
                null == frequency
                    ? _value.frequency
                    : frequency // ignore: cast_nullable_to_non_nullable
                        as String,
            duration:
                null == duration
                    ? _value.duration
                    : duration // ignore: cast_nullable_to_non_nullable
                        as String,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicineImplCopyWith<$Res>
    implements $MedicineCopyWith<$Res> {
  factory _$$MedicineImplCopyWith(
    _$MedicineImpl value,
    $Res Function(_$MedicineImpl) then,
  ) = __$$MedicineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String dosage,
    String frequency,
    String duration,
    String? notes,
  });
}

/// @nodoc
class __$$MedicineImplCopyWithImpl<$Res>
    extends _$MedicineCopyWithImpl<$Res, _$MedicineImpl>
    implements _$$MedicineImplCopyWith<$Res> {
  __$$MedicineImplCopyWithImpl(
    _$MedicineImpl _value,
    $Res Function(_$MedicineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$MedicineImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        dosage:
            null == dosage
                ? _value.dosage
                : dosage // ignore: cast_nullable_to_non_nullable
                    as String,
        frequency:
            null == frequency
                ? _value.frequency
                : frequency // ignore: cast_nullable_to_non_nullable
                    as String,
        duration:
            null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                    as String,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicineImpl with DiagnosticableTreeMixin implements _Medicine {
  const _$MedicineImpl({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.notes,
  });

  factory _$MedicineImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicineImplFromJson(json);

  @override
  final String name;
  @override
  final String dosage;
  @override
  final String frequency;
  @override
  final String duration;
  @override
  final String? notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Medicine(name: $name, dosage: $dosage, frequency: $frequency, duration: $duration, notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Medicine'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('dosage', dosage))
      ..add(DiagnosticsProperty('frequency', frequency))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicineImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, dosage, frequency, duration, notes);

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      __$$MedicineImplCopyWithImpl<_$MedicineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicineImplToJson(this);
  }
}

abstract class _Medicine implements Medicine {
  const factory _Medicine({
    required final String name,
    required final String dosage,
    required final String frequency,
    required final String duration,
    final String? notes,
  }) = _$MedicineImpl;

  factory _Medicine.fromJson(Map<String, dynamic> json) =
      _$MedicineImpl.fromJson;

  @override
  String get name;
  @override
  String get dosage;
  @override
  String get frequency;
  @override
  String get duration;
  @override
  String? get notes;

  /// Create a copy of Medicine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicineImplCopyWith<_$MedicineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Prescription _$PrescriptionFromJson(Map<String, dynamic> json) {
  return _Prescription.fromJson(json);
}

/// @nodoc
mixin _$Prescription {
  String? get id => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get doctorId => throw _privateConstructorUsedError;
  String get diagnosis => throw _privateConstructorUsedError;
  List<Medicine> get medicines => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Prescription to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrescriptionCopyWith<Prescription> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrescriptionCopyWith<$Res> {
  factory $PrescriptionCopyWith(
    Prescription value,
    $Res Function(Prescription) then,
  ) = _$PrescriptionCopyWithImpl<$Res, Prescription>;
  @useResult
  $Res call({
    String? id,
    String? userId,
    String? doctorId,
    String diagnosis,
    List<Medicine> medicines,
    String? notes,
    DateTime date,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$PrescriptionCopyWithImpl<$Res, $Val extends Prescription>
    implements $PrescriptionCopyWith<$Res> {
  _$PrescriptionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? doctorId = freezed,
    Object? diagnosis = null,
    Object? medicines = null,
    Object? notes = freezed,
    Object? date = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                freezed == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String?,
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String?,
            doctorId:
                freezed == doctorId
                    ? _value.doctorId
                    : doctorId // ignore: cast_nullable_to_non_nullable
                        as String?,
            diagnosis:
                null == diagnosis
                    ? _value.diagnosis
                    : diagnosis // ignore: cast_nullable_to_non_nullable
                        as String,
            medicines:
                null == medicines
                    ? _value.medicines
                    : medicines // ignore: cast_nullable_to_non_nullable
                        as List<Medicine>,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            createdAt:
                freezed == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updatedAt:
                freezed == updatedAt
                    ? _value.updatedAt
                    : updatedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PrescriptionImplCopyWith<$Res>
    implements $PrescriptionCopyWith<$Res> {
  factory _$$PrescriptionImplCopyWith(
    _$PrescriptionImpl value,
    $Res Function(_$PrescriptionImpl) then,
  ) = __$$PrescriptionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String? userId,
    String? doctorId,
    String diagnosis,
    List<Medicine> medicines,
    String? notes,
    DateTime date,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$PrescriptionImplCopyWithImpl<$Res>
    extends _$PrescriptionCopyWithImpl<$Res, _$PrescriptionImpl>
    implements _$$PrescriptionImplCopyWith<$Res> {
  __$$PrescriptionImplCopyWithImpl(
    _$PrescriptionImpl _value,
    $Res Function(_$PrescriptionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? doctorId = freezed,
    Object? diagnosis = null,
    Object? medicines = null,
    Object? notes = freezed,
    Object? date = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$PrescriptionImpl(
        id:
            freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String?,
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String?,
        doctorId:
            freezed == doctorId
                ? _value.doctorId
                : doctorId // ignore: cast_nullable_to_non_nullable
                    as String?,
        diagnosis:
            null == diagnosis
                ? _value.diagnosis
                : diagnosis // ignore: cast_nullable_to_non_nullable
                    as String,
        medicines:
            null == medicines
                ? _value._medicines
                : medicines // ignore: cast_nullable_to_non_nullable
                    as List<Medicine>,
        notes:
            freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                    as String?,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        createdAt:
            freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updatedAt:
            freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PrescriptionImpl with DiagnosticableTreeMixin implements _Prescription {
  const _$PrescriptionImpl({
    this.id,
    this.userId,
    this.doctorId,
    required this.diagnosis,
    required final List<Medicine> medicines,
    this.notes,
    required this.date,
    this.createdAt,
    this.updatedAt,
  }) : _medicines = medicines;

  factory _$PrescriptionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PrescriptionImplFromJson(json);

  @override
  final String? id;
  @override
  final String? userId;
  @override
  final String? doctorId;
  @override
  final String diagnosis;
  final List<Medicine> _medicines;
  @override
  List<Medicine> get medicines {
    if (_medicines is EqualUnmodifiableListView) return _medicines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medicines);
  }

  @override
  final String? notes;
  @override
  final DateTime date;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Prescription(id: $id, userId: $userId, doctorId: $doctorId, diagnosis: $diagnosis, medicines: $medicines, notes: $notes, date: $date, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Prescription'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('doctorId', doctorId))
      ..add(DiagnosticsProperty('diagnosis', diagnosis))
      ..add(DiagnosticsProperty('medicines', medicines))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrescriptionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.doctorId, doctorId) ||
                other.doctorId == doctorId) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            const DeepCollectionEquality().equals(
              other._medicines,
              _medicines,
            ) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    doctorId,
    diagnosis,
    const DeepCollectionEquality().hash(_medicines),
    notes,
    date,
    createdAt,
    updatedAt,
  );

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrescriptionImplCopyWith<_$PrescriptionImpl> get copyWith =>
      __$$PrescriptionImplCopyWithImpl<_$PrescriptionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PrescriptionImplToJson(this);
  }
}

abstract class _Prescription implements Prescription {
  const factory _Prescription({
    final String? id,
    final String? userId,
    final String? doctorId,
    required final String diagnosis,
    required final List<Medicine> medicines,
    final String? notes,
    required final DateTime date,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$PrescriptionImpl;

  factory _Prescription.fromJson(Map<String, dynamic> json) =
      _$PrescriptionImpl.fromJson;

  @override
  String? get id;
  @override
  String? get userId;
  @override
  String? get doctorId;
  @override
  String get diagnosis;
  @override
  List<Medicine> get medicines;
  @override
  String? get notes;
  @override
  DateTime get date;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Prescription
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrescriptionImplCopyWith<_$PrescriptionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
