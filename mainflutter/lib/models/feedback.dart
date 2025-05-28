import 'package:freezed_annotation/freezed_annotation.dart';

part 'feedback.freezed.dart';
part 'feedback.g.dart';

@freezed
class Feedback with _$Feedback {
  const factory Feedback({
    String? id,
    required double rating,
    required String service,
    required String title,
    required String content,
    String? pros,
    String? cons,
    String? suggestions,
    String? email,
    String? phone,
    List<String>? images,
    String? userId,
    DateTime? createdAt,
  }) = _Feedback;

  factory Feedback.fromJson(Map<String, dynamic> json) => _$FeedbackFromJson(json);
} 