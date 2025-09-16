import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lesson_service.dart';
import '../models/lesson.dart';

// Lesson service provider
final lessonServiceProvider = Provider<LessonService>((ref) => LessonService());

// Provider to track lesson completion changes
class LessonCompletionNotifier extends StateNotifier<int> {
  LessonCompletionNotifier(this._lessonService) : super(0);

  final LessonService _lessonService;

  // Notify when a lesson is completed
  void notifyLessonCompleted() {
    // Increment the state to trigger listeners
    state = state + 1;
  }

  // Get the next suggested lesson
  Future<Lesson?> getNextSuggestedLesson() async {
    return await _lessonService.getNextSuggestedLesson();
  }
}

// Provider for lesson completion state
final lessonCompletionProvider = StateNotifierProvider<LessonCompletionNotifier, int>((ref) {
  final lessonService = ref.watch(lessonServiceProvider);
  return LessonCompletionNotifier(lessonService);
});

// Provider for next suggested lesson
final nextSuggestedLessonProvider = FutureProvider<Lesson?>((ref) async {
  // Watch the completion state to trigger refresh when lessons are completed
  ref.watch(lessonCompletionProvider);
  
  final lessonService = ref.watch(lessonServiceProvider);
  return await lessonService.getNextSuggestedLesson();
});
