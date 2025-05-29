// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'treatment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Treatment _$TreatmentFromJson(Map<String, dynamic> json) {
  return _Treatment.fromJson(json);
}

/// @nodoc
mixin _$Treatment {
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  String get diagnosis => throw _privateConstructorUsedError;
  String get treatmentPlan => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  DateTime? get endDate => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  List<Medication> get medications => throw _privateConstructorUsedError;
  List<Procedure> get procedures => throw _privateConstructorUsedError;
  FollowUp? get followUp => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Treatment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TreatmentCopyWith<Treatment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreatmentCopyWith<$Res> {
  factory $TreatmentCopyWith(Treatment value, $Res Function(Treatment) then) =
      _$TreatmentCopyWithImpl<$Res, Treatment>;
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String diagnosis,
    String treatmentPlan,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime startDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? endDate,
    String status,
    List<Medication> medications,
    List<Procedure> procedures,
    FollowUp? followUp,
    String? notes,
  });

  $FollowUpCopyWith<$Res>? get followUp;
}

/// @nodoc
class _$TreatmentCopyWithImpl<$Res, $Val extends Treatment>
    implements $TreatmentCopyWith<$Res> {
  _$TreatmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diagnosis = null,
    Object? treatmentPlan = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = null,
    Object? medications = null,
    Object? procedures = null,
    Object? followUp = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            diagnosis:
                null == diagnosis
                    ? _value.diagnosis
                    : diagnosis // ignore: cast_nullable_to_non_nullable
                        as String,
            treatmentPlan:
                null == treatmentPlan
                    ? _value.treatmentPlan
                    : treatmentPlan // ignore: cast_nullable_to_non_nullable
                        as String,
            startDate:
                null == startDate
                    ? _value.startDate
                    : startDate // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            endDate:
                freezed == endDate
                    ? _value.endDate
                    : endDate // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            medications:
                null == medications
                    ? _value.medications
                    : medications // ignore: cast_nullable_to_non_nullable
                        as List<Medication>,
            procedures:
                null == procedures
                    ? _value.procedures
                    : procedures // ignore: cast_nullable_to_non_nullable
                        as List<Procedure>,
            followUp:
                freezed == followUp
                    ? _value.followUp
                    : followUp // ignore: cast_nullable_to_non_nullable
                        as FollowUp?,
            notes:
                freezed == notes
                    ? _value.notes
                    : notes // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FollowUpCopyWith<$Res>? get followUp {
    if (_value.followUp == null) {
      return null;
    }

    return $FollowUpCopyWith<$Res>(_value.followUp!, (value) {
      return _then(_value.copyWith(followUp: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TreatmentImplCopyWith<$Res>
    implements $TreatmentCopyWith<$Res> {
  factory _$$TreatmentImplCopyWith(
    _$TreatmentImpl value,
    $Res Function(_$TreatmentImpl) then,
  ) = __$$TreatmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: '_id') String id,
    String diagnosis,
    String treatmentPlan,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime startDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    DateTime? endDate,
    String status,
    List<Medication> medications,
    List<Procedure> procedures,
    FollowUp? followUp,
    String? notes,
  });

  @override
  $FollowUpCopyWith<$Res>? get followUp;
}

/// @nodoc
class __$$TreatmentImplCopyWithImpl<$Res>
    extends _$TreatmentCopyWithImpl<$Res, _$TreatmentImpl>
    implements _$$TreatmentImplCopyWith<$Res> {
  __$$TreatmentImplCopyWithImpl(
    _$TreatmentImpl _value,
    $Res Function(_$TreatmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? diagnosis = null,
    Object? treatmentPlan = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? status = null,
    Object? medications = null,
    Object? procedures = null,
    Object? followUp = freezed,
    Object? notes = freezed,
  }) {
    return _then(
      _$TreatmentImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        diagnosis:
            null == diagnosis
                ? _value.diagnosis
                : diagnosis // ignore: cast_nullable_to_non_nullable
                    as String,
        treatmentPlan:
            null == treatmentPlan
                ? _value.treatmentPlan
                : treatmentPlan // ignore: cast_nullable_to_non_nullable
                    as String,
        startDate:
            null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        endDate:
            freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        medications:
            null == medications
                ? _value._medications
                : medications // ignore: cast_nullable_to_non_nullable
                    as List<Medication>,
        procedures:
            null == procedures
                ? _value._procedures
                : procedures // ignore: cast_nullable_to_non_nullable
                    as List<Procedure>,
        followUp:
            freezed == followUp
                ? _value.followUp
                : followUp // ignore: cast_nullable_to_non_nullable
                    as FollowUp?,
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
class _$TreatmentImpl with DiagnosticableTreeMixin implements _Treatment {
  const _$TreatmentImpl({
    @JsonKey(name: '_id') required this.id,
    required this.diagnosis,
    required this.treatmentPlan,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required this.startDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    this.endDate,
    required this.status,
    final List<Medication> medications = const [],
    final List<Procedure> procedures = const [],
    this.followUp,
    this.notes,
  }) : _medications = medications,
       _procedures = procedures;

  factory _$TreatmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreatmentImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String id;
  @override
  final String diagnosis;
  @override
  final String treatmentPlan;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime startDate;
  @override
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  final DateTime? endDate;
  @override
  final String status;
  final List<Medication> _medications;
  @override
  @JsonKey()
  List<Medication> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  final List<Procedure> _procedures;
  @override
  @JsonKey()
  List<Procedure> get procedures {
    if (_procedures is EqualUnmodifiableListView) return _procedures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_procedures);
  }

  @override
  final FollowUp? followUp;
  @override
  final String? notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Treatment(id: $id, diagnosis: $diagnosis, treatmentPlan: $treatmentPlan, startDate: $startDate, endDate: $endDate, status: $status, medications: $medications, procedures: $procedures, followUp: $followUp, notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Treatment'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('diagnosis', diagnosis))
      ..add(DiagnosticsProperty('treatmentPlan', treatmentPlan))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('medications', medications))
      ..add(DiagnosticsProperty('procedures', procedures))
      ..add(DiagnosticsProperty('followUp', followUp))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreatmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.treatmentPlan, treatmentPlan) ||
                other.treatmentPlan == treatmentPlan) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            const DeepCollectionEquality().equals(
              other._procedures,
              _procedures,
            ) &&
            (identical(other.followUp, followUp) ||
                other.followUp == followUp) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    diagnosis,
    treatmentPlan,
    startDate,
    endDate,
    status,
    const DeepCollectionEquality().hash(_medications),
    const DeepCollectionEquality().hash(_procedures),
    followUp,
    notes,
  );

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TreatmentImplCopyWith<_$TreatmentImpl> get copyWith =>
      __$$TreatmentImplCopyWithImpl<_$TreatmentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreatmentImplToJson(this);
  }
}

abstract class _Treatment implements Treatment {
  const factory _Treatment({
    @JsonKey(name: '_id') required final String id,
    required final String diagnosis,
    required final String treatmentPlan,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required final DateTime startDate,
    @JsonKey(
      fromJson: _nullableDateTimeFromJson,
      toJson: _nullableDateTimeToJson,
    )
    final DateTime? endDate,
    required final String status,
    final List<Medication> medications,
    final List<Procedure> procedures,
    final FollowUp? followUp,
    final String? notes,
  }) = _$TreatmentImpl;

  factory _Treatment.fromJson(Map<String, dynamic> json) =
      _$TreatmentImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String get id;
  @override
  String get diagnosis;
  @override
  String get treatmentPlan;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get startDate;
  @override
  @JsonKey(fromJson: _nullableDateTimeFromJson, toJson: _nullableDateTimeToJson)
  DateTime? get endDate;
  @override
  String get status;
  @override
  List<Medication> get medications;
  @override
  List<Procedure> get procedures;
  @override
  FollowUp? get followUp;
  @override
  String? get notes;

  /// Create a copy of Treatment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TreatmentImplCopyWith<_$TreatmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Medication _$MedicationFromJson(Map<String, dynamic> json) {
  return _Medication.fromJson(json);
}

/// @nodoc
mixin _$Medication {
  String get name => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;

  /// Serializes this Medication to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Medication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MedicationCopyWith<Medication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationCopyWith<$Res> {
  factory $MedicationCopyWith(
    Medication value,
    $Res Function(Medication) then,
  ) = _$MedicationCopyWithImpl<$Res, Medication>;
  @useResult
  $Res call({String name, String dosage, String frequency, String duration});
}

/// @nodoc
class _$MedicationCopyWithImpl<$Res, $Val extends Medication>
    implements $MedicationCopyWith<$Res> {
  _$MedicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Medication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MedicationImplCopyWith<$Res>
    implements $MedicationCopyWith<$Res> {
  factory _$$MedicationImplCopyWith(
    _$MedicationImpl value,
    $Res Function(_$MedicationImpl) then,
  ) = __$$MedicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String dosage, String frequency, String duration});
}

/// @nodoc
class __$$MedicationImplCopyWithImpl<$Res>
    extends _$MedicationCopyWithImpl<$Res, _$MedicationImpl>
    implements _$$MedicationImplCopyWith<$Res> {
  __$$MedicationImplCopyWithImpl(
    _$MedicationImpl _value,
    $Res Function(_$MedicationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Medication
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? duration = null,
  }) {
    return _then(
      _$MedicationImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationImpl with DiagnosticableTreeMixin implements _Medication {
  const _$MedicationImpl({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  factory _$MedicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationImplFromJson(json);

  @override
  final String name;
  @override
  final String dosage;
  @override
  final String frequency;
  @override
  final String duration;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Medication(name: $name, dosage: $dosage, frequency: $frequency, duration: $duration)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Medication'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('dosage', dosage))
      ..add(DiagnosticsProperty('frequency', frequency))
      ..add(DiagnosticsProperty('duration', duration));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, dosage, frequency, duration);

  /// Create a copy of Medication
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      __$$MedicationImplCopyWithImpl<_$MedicationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationImplToJson(this);
  }
}

abstract class _Medication implements Medication {
  const factory _Medication({
    required final String name,
    required final String dosage,
    required final String frequency,
    required final String duration,
  }) = _$MedicationImpl;

  factory _Medication.fromJson(Map<String, dynamic> json) =
      _$MedicationImpl.fromJson;

  @override
  String get name;
  @override
  String get dosage;
  @override
  String get frequency;
  @override
  String get duration;

  /// Create a copy of Medication
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Procedure _$ProcedureFromJson(Map<String, dynamic> json) {
  return _Procedure.fromJson(json);
}

/// @nodoc
mixin _$Procedure {
  String get name => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get date => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this Procedure to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProcedureCopyWith<Procedure> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProcedureCopyWith<$Res> {
  factory $ProcedureCopyWith(Procedure value, $Res Function(Procedure) then) =
      _$ProcedureCopyWithImpl<$Res, Procedure>;
  @useResult
  $Res call({
    String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime date,
    String? notes,
  });
}

/// @nodoc
class _$ProcedureCopyWithImpl<$Res, $Val extends Procedure>
    implements $ProcedureCopyWith<$Res> {
  _$ProcedureCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? date = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
abstract class _$$ProcedureImplCopyWith<$Res>
    implements $ProcedureCopyWith<$Res> {
  factory _$$ProcedureImplCopyWith(
    _$ProcedureImpl value,
    $Res Function(_$ProcedureImpl) then,
  ) = __$$ProcedureImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime date,
    String? notes,
  });
}

/// @nodoc
class __$$ProcedureImplCopyWithImpl<$Res>
    extends _$ProcedureCopyWithImpl<$Res, _$ProcedureImpl>
    implements _$$ProcedureImplCopyWith<$Res> {
  __$$ProcedureImplCopyWithImpl(
    _$ProcedureImpl _value,
    $Res Function(_$ProcedureImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? date = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$ProcedureImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
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
class _$ProcedureImpl with DiagnosticableTreeMixin implements _Procedure {
  const _$ProcedureImpl({
    required this.name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required this.date,
    this.notes,
  });

  factory _$ProcedureImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProcedureImplFromJson(json);

  @override
  final String name;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  @override
  final String? notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Procedure(name: $name, date: $date, notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Procedure'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcedureImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, date, notes);

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcedureImplCopyWith<_$ProcedureImpl> get copyWith =>
      __$$ProcedureImplCopyWithImpl<_$ProcedureImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProcedureImplToJson(this);
  }
}

abstract class _Procedure implements Procedure {
  const factory _Procedure({
    required final String name,
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required final DateTime date,
    final String? notes,
  }) = _$ProcedureImpl;

  factory _Procedure.fromJson(Map<String, dynamic> json) =
      _$ProcedureImpl.fromJson;

  @override
  String get name;
  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get date;
  @override
  String? get notes;

  /// Create a copy of Procedure
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcedureImplCopyWith<_$ProcedureImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FollowUp _$FollowUpFromJson(Map<String, dynamic> json) {
  return _FollowUp.fromJson(json);
}

/// @nodoc
mixin _$FollowUp {
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get date => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this FollowUp to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowUp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowUpCopyWith<FollowUp> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowUpCopyWith<$Res> {
  factory $FollowUpCopyWith(FollowUp value, $Res Function(FollowUp) then) =
      _$FollowUpCopyWithImpl<$Res, FollowUp>;
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime date,
    String? notes,
  });
}

/// @nodoc
class _$FollowUpCopyWithImpl<$Res, $Val extends FollowUp>
    implements $FollowUpCopyWith<$Res> {
  _$FollowUpCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowUp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? notes = freezed}) {
    return _then(
      _value.copyWith(
            date:
                null == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
abstract class _$$FollowUpImplCopyWith<$Res>
    implements $FollowUpCopyWith<$Res> {
  factory _$$FollowUpImplCopyWith(
    _$FollowUpImpl value,
    $Res Function(_$FollowUpImpl) then,
  ) = __$$FollowUpImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    DateTime date,
    String? notes,
  });
}

/// @nodoc
class __$$FollowUpImplCopyWithImpl<$Res>
    extends _$FollowUpCopyWithImpl<$Res, _$FollowUpImpl>
    implements _$$FollowUpImplCopyWith<$Res> {
  __$$FollowUpImplCopyWithImpl(
    _$FollowUpImpl _value,
    $Res Function(_$FollowUpImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowUp
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? notes = freezed}) {
    return _then(
      _$FollowUpImpl(
        date:
            null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as DateTime,
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
class _$FollowUpImpl with DiagnosticableTreeMixin implements _FollowUp {
  const _$FollowUpImpl({
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required this.date,
    this.notes,
  });

  factory _$FollowUpImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowUpImplFromJson(json);

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;
  @override
  final String? notes;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'FollowUp(date: $date, notes: $notes)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'FollowUp'))
      ..add(DiagnosticsProperty('date', date))
      ..add(DiagnosticsProperty('notes', notes));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowUpImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, notes);

  /// Create a copy of FollowUp
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowUpImplCopyWith<_$FollowUpImpl> get copyWith =>
      __$$FollowUpImplCopyWithImpl<_$FollowUpImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowUpImplToJson(this);
  }
}

abstract class _FollowUp implements FollowUp {
  const factory _FollowUp({
    @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
    required final DateTime date,
    final String? notes,
  }) = _$FollowUpImpl;

  factory _FollowUp.fromJson(Map<String, dynamic> json) =
      _$FollowUpImpl.fromJson;

  @override
  @JsonKey(fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  DateTime get date;
  @override
  String? get notes;

  /// Create a copy of FollowUp
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowUpImplCopyWith<_$FollowUpImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
