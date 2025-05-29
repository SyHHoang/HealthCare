// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DrugImpl _$$DrugImplFromJson(Map<String, dynamic> json) => _$DrugImpl(
  id: json['id'] as String?,
  name: json['name'] as String,
  category: json['category'] as String?,
  type: json['type'] as String?,
  activeIngredient: json['activeIngredient'] as String?,
  manufacturer: json['manufacturer'] as String?,
  uses: json['uses'] as String?,
  dosage: json['dosage'] as String?,
  contraindications: json['contraindications'] as String?,
  sideEffects: json['sideEffects'] as String?,
);

Map<String, dynamic> _$$DrugImplToJson(_$DrugImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'type': instance.type,
      'activeIngredient': instance.activeIngredient,
      'manufacturer': instance.manufacturer,
      'uses': instance.uses,
      'dosage': instance.dosage,
      'contraindications': instance.contraindications,
      'sideEffects': instance.sideEffects,
    };
