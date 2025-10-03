import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import 'todo_service.dart';

class AutoTodoService {
  static final AutoTodoService _instance = AutoTodoService._internal();
  factory AutoTodoService() => _instance;
  AutoTodoService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TodoService _todoService = TodoService();

  // Cache for stages data to avoid repeated instantiation
  static List<Stage>? _stagesCache;
  
  List<Stage> get _stages {
    return _stagesCache ??= [
      Stage1Data.getStage1(),
      Stage2Data.getStage2(),
      Stage3Data.getStage3(),
    ];
  }

  /// Initialize todos for a user - called every time the user opens the app
  Future<void> initializeUserTodos(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // First, ensure no todos are overdue by rescaling them to today
      await _rescaleOverdueTodos(userId, today);
      
      // Get user's completed lessons
      final completedLessons = await _getCompletedLessons(userId);
      
      // Get current todos to avoid duplicates
      final existingTodos = await _todoService.getUserTodos(userId);
      final existingActivityIds = existingTodos
          .where((todo) => !todo.isCompleted)
          .map((todo) => todo.activityId)
          .toSet();

      // Calculate the current stage/chapter the user should be on
      final userProgress = await _calculateUserProgress(completedLessons);
      
      // Clear any outdated todos and reassign based on current progress
      await _reassignTodos(userId, userProgress, existingActivityIds, completedLessons);
      
      print('✅ Auto todos initialized for user $userId');
    } catch (e) {
      print('❌ Error initializing auto todos: $e');
      // Don't throw - this should be a background operation that doesn't interrupt user experience
    }
  }

  /// Get completed lessons for a user
  Future<Set<String>> _getCompletedLessons(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('completed_lessons')
          .get();

      return snapshot.docs.map((doc) => doc.data()['lessonId'] as String).toSet();
    } catch (e) {
      print('Error getting completed lessons: $e');
      return {};
    }
  }

  /// Calculate what stage/chapter the user should currently be working on
  Future<UserProgress> _calculateUserProgress(Set<String> completedLessons) async {
    // Find the highest completed lesson to determine current position
    int currentStage = 1;
    int currentChapter = 1;
    int highestCompletedLessonInChapter = 0;

    for (final stage in _stages) {
      for (final chapter in stage.chapters) {
        int completedInThisChapter = 0;
        int highestLessonInChapter = 0;

        for (final lesson in chapter.lessons) {
          if (completedLessons.contains(lesson.id)) {
            completedInThisChapter++;
            highestLessonInChapter = lesson.lessonNumber;
          }
        }

        // If this chapter has completed lessons, update current position
        if (completedInThisChapter > 0) {
          currentStage = stage.stageNumber;
          currentChapter = chapter.chapterNumber;
          highestCompletedLessonInChapter = highestLessonInChapter;
        }
      }
    }

    return UserProgress(
      currentStage: currentStage,
      currentChapter: currentChapter,
      highestCompletedLessonInChapter: highestCompletedLessonInChapter,
    );
  }

  /// Reassign todos based on current user progress and scaling logic
  Future<void> _reassignTodos(
    String userId, 
    UserProgress progress, 
    Set<String> existingActivityIds,
    Set<String> completedLessons,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Delete completed todos that are older than 7 days to keep the list clean
    await _cleanupOldCompletedTodos(userId);
    
    // Update any overdue todos to be due today
    await _rescaleOverdueTodos(userId, today);

    // Get the current chapter user should be working on
    final currentChapter = _getCurrentChapter(progress);
    if (currentChapter == null) return;

    // Get current chapter information for planning
    
    // Always set due date to today or future - never in the past
    DateTime chapterDueDate = today;

    // Assign todos for current chapter (due today)
    await _assignChapterTodos(userId, currentChapter, chapterDueDate, existingActivityIds, completedLessons);

    // Assign 3 daily journal tasks for today
    await _assignDailyJournalTodos(userId, today, existingActivityIds);

    // Always pre-assign future chapters with their respective journal tasks
    // This ensures users can see upcoming lessons and plan ahead
    await _assignFutureChapters(userId, progress, chapterDueDate, existingActivityIds, completedLessons);
  }

  /// Get the current chapter the user should be working on
  Chapter? _getCurrentChapter(UserProgress progress) {
    try {
      final stage = _stages.firstWhere((s) => s.stageNumber == progress.currentStage);
      return stage.chapters.firstWhere((c) => c.chapterNumber == progress.currentChapter);
    } catch (e) {
      // If not found, default to first chapter of first stage
      return _stages.first.chapters.first;
    }
  }

  /// Assign todos for a specific chapter
  Future<void> _assignChapterTodos(
    String userId,
    Chapter chapter,
    DateTime dueDate,
    Set<String> existingActivityIds,
    Set<String> completedLessons,
  ) async {
    for (final lesson in chapter.lessons) {
      // Skip if lesson is already completed
      if (completedLessons.contains(lesson.id)) continue;
      
      // Skip if todo already exists
      if (existingActivityIds.contains(lesson.id)) continue;

      // Create todo for lesson
      await _createLessonTodo(userId, lesson, dueDate);
    }
  }

  /// Assign daily journal todos (3 per day)
  Future<void> _assignDailyJournalTodos(
    String userId,
    DateTime date,
    Set<String> existingActivityIds,
  ) async {
    final journalTypes = [
      'food_diary',
      'body_image_diary',
      'weight_diary'
    ];

    for (int i = 0; i < journalTypes.length; i++) {
      // Create a unique activity ID that includes the date
      // This ensures different journal tasks for different days
      final dateString = '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
      final activityId = '${journalTypes[i]}_$dateString';
      
      // Skip if already exists
      if (existingActivityIds.contains(activityId)) continue;

      await _createJournalTodo(userId, journalTypes[i], activityId, date);
    }
  }

  /// Assign future chapters (for pre-planning)
  Future<void> _assignFutureChapters(
    String userId,
    UserProgress progress,
    DateTime startDate,
    Set<String> existingActivityIds,
    Set<String> completedLessons,
  ) async {
    // Get all future chapters in the correct order (by stage, then chapter)
    final futureChapters = _getFutureChapters(progress, 14); // Plan for next 2 weeks
    
    // For each future chapter, assign todos for that day
    for (int i = 0; i < futureChapters.length; i++) {
      final chapter = futureChapters[i];
      final chapterDueDate = startDate.add(Duration(days: i + 1));
      
      // Assign chapter lessons for this day
      await _assignChapterTodos(userId, chapter, chapterDueDate, existingActivityIds, completedLessons);
      
      // Also assign journal tasks for this future day
      await _assignDailyJournalTodos(userId, chapterDueDate, existingActivityIds);
    }
  }

  /// Get list of future chapters to assign in the correct order (by stage, then chapter)
  List<Chapter> _getFutureChapters(UserProgress progress, int count) {
    final chapters = <Chapter>[];
    final orderedStages = List.of(_stages)..sort((a, b) => a.stageNumber.compareTo(b.stageNumber));
    
    // First, collect all future chapters across all stages
    for (final stage in orderedStages) {
      // Sort chapters within the stage
      final orderedChapters = List.of(stage.chapters)..sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));
      
      for (final chapter in orderedChapters) {
        // Add chapters that come after current progress
        if (stage.stageNumber > progress.currentStage || 
            (stage.stageNumber == progress.currentStage && chapter.chapterNumber > progress.currentChapter)) {
          chapters.add(chapter);
        }
      }
    }
    
    // Return only the requested number of chapters
    return chapters.take(count).toList();
  }

  /// Create a todo for a lesson
  Future<void> _createLessonTodo(String userId, Lesson lesson, DateTime dueDate) async {
    try {
      await _todoService.createTodo(
        userId: userId,
        title: lesson.title,
        description: lesson.description,
        type: TodoType.lesson,
        activityId: lesson.id,
        activityData: {
          'chapterNumber': lesson.chapterNumber,
          'lessonNumber': lesson.lessonNumber,
          'type': 'lesson',
          'stageNumber': _getStageNumberForLesson(lesson),
        },
        dueDate: dueDate,
      );
    } catch (e) {
      print('Error creating lesson todo: $e');
    }
  }
  
  /// Helper method to find the stage number for a lesson
  int _getStageNumberForLesson(Lesson lesson) {
    for (final stage in _stages) {
      for (final chapter in stage.chapters) {
        if (chapter.chapterNumber == lesson.chapterNumber) {
          for (final l in chapter.lessons) {
            if (l.id == lesson.id) {
              return stage.stageNumber;
            }
          }
        }
      }
    }
    return 1; // Default to stage 1 if not found
  }

  /// Create a todo for journal activity
  Future<void> _createJournalTodo(String userId, String journalType, String activityId, DateTime dueDate) async {
    try {
      final titles = {
        'food_diary': 'Food Diary Entry',
        'body_image_diary': 'Body Image Check-in',
        'weight_diary': 'Weight Entry',
      };

      final descriptions = {
        'food_diary': 'Record your meals, thoughts, and feelings in your food diary',
        'body_image_diary': 'Log any body checking behaviors or "feeling fat" moments',
        'weight_diary': 'Log your current weight to track your progress',
      };

      await _todoService.createTodo(
        userId: userId,
        title: titles[journalType] ?? 'Journal Entry',
        description: descriptions[journalType] ?? 'Complete your daily journaling',
        type: TodoType.journal,
        activityId: activityId,
        activityData: {
          'journalType': journalType,
          'type': 'journal',
        },
        dueDate: dueDate,
      );
    } catch (e) {
      print('Error creating journal todo: $e');
    }
  }

  /// Clean up completed todos older than 7 days
  Future<void> _cleanupOldCompletedTodos(String userId) async {
    try {
      final todos = await _todoService.getUserTodos(userId);
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      
      for (final todo in todos) {
        if (todo.isCompleted && 
            todo.completedAt != null && 
            todo.completedAt!.isBefore(weekAgo)) {
          await _todoService.deleteTodoForUser(userId, todo.id);
        }
      }
    } catch (e) {
      print('Error cleaning up old todos: $e');
    }
  }
  
  /// Rescale any overdue todos to be due today
  Future<void> _rescaleOverdueTodos(String userId, DateTime today) async {
    try {
      final todos = await _todoService.getUserTodos(userId);
      final pendingTodos = todos.where((todo) => !todo.isCompleted).toList();
      
      // Find overdue todos
      final overdueTodos = pendingTodos.where((todo) {
        final dueDate = DateTime(todo.dueDate.year, todo.dueDate.month, todo.dueDate.day);
        return dueDate.isBefore(today);
      }).toList();
      
      // Update all overdue todos to be due today
      for (final todo in overdueTodos) {
        final updatedTodo = todo.copyWith(
          dueDate: today,
          updatedAt: DateTime.now(),
        );
        
        await _todoService.updateTodo(updatedTodo);
      }
      
      if (overdueTodos.isNotEmpty) {
        print('Rescaled ${overdueTodos.length} overdue todos to be due today');
      }
    } catch (e) {
      print('Error rescaling overdue todos: $e');
    }
  }

  /// Force refresh todos (can be called manually)
  Future<void> refreshUserTodos(String userId) async {
    await initializeUserTodos(userId);
  }

  /// Mark lesson as completed and update todos accordingly
  Future<void> markLessonCompleted(String userId, String lessonId) async {
    try {
      // Mark lesson as completed in user_progress
      await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('completed_lessons')
          .doc(lessonId)
          .set({
        'lessonId': lessonId,
        'completedAt': FieldValue.serverTimestamp(),
        'userId': userId,
      });

      // Mark corresponding todo as completed
      await _todoService.markTodoCompletedByActivity(userId, lessonId, TodoType.lesson);

      // Refresh todos to update progression
      await initializeUserTodos(userId);
    } catch (e) {
      print('Error marking lesson completed: $e');
    }
  }
}

/// Helper class to track user progress
class UserProgress {
  final int currentStage;
  final int currentChapter;
  final int highestCompletedLessonInChapter;

  UserProgress({
    required this.currentStage,
    required this.currentChapter,
    required this.highestCompletedLessonInChapter,
  });
}
