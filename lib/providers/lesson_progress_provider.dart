import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/lesson_service.dart';
import '../data/stage_1_data.dart';
import '../data/stage_2_data.dart';
import '../data/stage_3_data.dart';
import '../models/lesson.dart';
import '../models/stage.dart';

// Lesson service provider
final lessonServiceProvider = Provider<LessonService>((ref) => LessonService());

// Provider for completed lessons
final completedLessonsProvider = FutureProvider.family<Set<String>, String>((ref, userId) async {
  final lessonService = ref.read(lessonServiceProvider);
  return await lessonService.getCompletedLessons();
});

// Provider for lesson progress (completed/total)
final lessonProgressProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final completedLessons = await ref.watch(completedLessonsProvider(userId).future);
  
  // Get all lessons from all stages
  final allStages = [
    Stage1Data.getStage1(),
    Stage2Data.getStage2(),
    Stage3Data.getStage3(),
  ];
  
  int totalLessons = 0;
  int completedCount = 0;
  
  for (final stage in allStages) {
    for (final chapter in stage.chapters) {
      for (final lesson in chapter.lessons) {
        totalLessons++;
        if (completedLessons.contains(lesson.id)) {
          completedCount++;
        }
      }
    }
  }
  
  return {
    'completed': completedCount,
    'total': totalLessons,
  };
});

// Provider for next uncompleted lesson
final nextUncompletedLessonProvider = FutureProvider.family<Lesson?, String>((ref, userId) async {
  final completedLessons = await ref.watch(completedLessonsProvider(userId).future);
  
  // Get all lessons from all stages in order
  final allStages = [
    Stage1Data.getStage1(),
    Stage2Data.getStage2(),
    Stage3Data.getStage3(),
  ];
  
  for (final stage in allStages) {
    for (final chapter in stage.chapters) {
      for (final lesson in chapter.lessons) {
        if (!completedLessons.contains(lesson.id)) {
          return lesson;
        }
      }
    }
  }
  
  return null; // All lessons completed
});

// Provider for next 4 uncompleted lessons (for carousel)
final nextUncompletedLessonsProvider = FutureProvider.family<List<Lesson>, String>((ref, userId) async {
  print('DEBUG Provider: Fetching lessons for user $userId');
  final completedLessons = await ref.watch(completedLessonsProvider(userId).future);
  print('DEBUG Provider: Completed lessons: ${completedLessons.length}');
  
  // Get all lessons from all stages in order
  final allStages = [
    Stage1Data.getStage1(),
    Stage2Data.getStage2(),
    Stage3Data.getStage3(),
  ];
  
  final uncompletedLessons = <Lesson>[];
  
  for (final stage in allStages) {
    for (final chapter in stage.chapters) {
      for (final lesson in chapter.lessons) {
        if (!completedLessons.contains(lesson.id)) {
          uncompletedLessons.add(lesson);
          if (uncompletedLessons.length >= 4) {
            print('DEBUG Provider: Returning ${uncompletedLessons.length} lessons');
            print('DEBUG Provider: First lesson: ${uncompletedLessons[0].title}');
            return uncompletedLessons;
          }
        }
      }
    }
  }
  
  print('DEBUG Provider: Returning ${uncompletedLessons.length} lessons (less than 4)');
  return uncompletedLessons; // Return whatever we found (less than 4 if near completion)
});

// Provider for lesson completion status
final lessonCompletionProvider = FutureProvider.family<bool, ({String userId, String lessonId})>((ref, params) async {
  final completedLessons = await ref.watch(completedLessonsProvider(params.userId).future);
  return completedLessons.contains(params.lessonId);
});

// Provider for stage progress
final stageProgressProvider = FutureProvider.family<Map<String, dynamic>, ({String userId, int stageNumber})>((ref, params) async {
  final completedLessons = await ref.watch(completedLessonsProvider(params.userId).future);
  
  // Get the specific stage
  Stage stage;
  switch (params.stageNumber) {
    case 1:
      stage = Stage1Data.getStage1();
      break;
    case 2:
      stage = Stage2Data.getStage2();
      break;
    case 3:
      stage = Stage3Data.getStage3();
      break;
    default:
      return {'completed': 0, 'total': 0, 'percentage': 0.0};
  }
  
  int totalLessons = 0;
  int completedCount = 0;
  
  for (final chapter in stage.chapters) {
    for (final lesson in chapter.lessons) {
      totalLessons++;
      if (completedLessons.contains(lesson.id)) {
        completedCount++;
      }
    }
  }
  
  final percentage = totalLessons > 0 ? (completedCount / totalLessons) * 100 : 0.0;
  
  return {
    'completed': completedCount,
    'total': totalLessons,
    'percentage': percentage,
  };
});
