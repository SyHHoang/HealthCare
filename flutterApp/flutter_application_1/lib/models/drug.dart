import 'package:freezed_annotation/freezed_annotation.dart';

part 'drug.freezed.dart';
part 'drug.g.dart';

@freezed
class Drug with _$Drug {
  const factory Drug({
    String? id,
    required String name,
    String? category,
    String? type,
    String? activeIngredient,
    String? manufacturer,
    String? uses,
    String? dosage,
    String? contraindications,
    String? sideEffects,
  }) = _Drug;

  factory Drug.fromJson(Map<String, dynamic> json) => _$DrugFromJson(json);
} 