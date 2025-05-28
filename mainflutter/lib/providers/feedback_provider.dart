import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';

part 'feedback_provider.g.dart';

@riverpod
class FeedbackNotifier extends _$FeedbackNotifier {
  @override
  FutureOr<List<Feedback>> build() async {
    return _loadFeedbacks();
  }

  Future<List<Feedback>> _loadFeedbacks() async {
    try {
      return await FeedbackService.getFeedbacks();
    } catch (e) {
      throw Exception('Failed to load feedbacks: $e');
    }
  }

  Future<void> submitFeedback(Feedback feedback) async {
    try {
      state = const AsyncValue.loading();
      await FeedbackService.submitFeedback(feedback);
      state = AsyncValue.data(await _loadFeedbacks());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
} 