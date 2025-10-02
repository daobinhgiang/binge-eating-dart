import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/todo_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../providers/auto_todo_provider.dart';
import '../../screens/lessons/lesson_1_1.dart';
import '../../screens/lessons/lesson_1_2.dart';
import '../../screens/lessons/lesson_1_3.dart';
import '../../screens/lessons/lesson_3_1.dart';
import '../../screens/lessons/lesson_3_2.dart';
import '../../screens/lessons/lesson_3_3.dart';
import '../../screens/lessons/lesson_3_4.dart';
import '../../screens/lessons/lesson_3_5.dart';
import '../../screens/lessons/lesson_3_6.dart';
import '../../screens/lessons/lesson_3_7.dart';
import '../../screens/lessons/lesson_3_8.dart';
import '../../screens/lessons/lesson_3_9.dart';
import '../../screens/lessons/lesson_3_10.dart';
// Stage 2 lesson imports
import '../../screens/lessons/lesson_s2_4_3.dart';
import '../../screens/lessons/lesson_s2_2_7.dart';
import '../../screens/lessons/lesson_s2_3_5.dart';
import '../../screens/lessons/lesson_s2_7_2_1.dart';
import '../../screens/lessons/lesson_s3_0_2_1.dart';
import '../../screens/lessons/lesson_1_2_1.dart';

// Stage 3 lesson imports
// Assessment imports
import '../../screens/assessments/assessment_2_1_screen.dart';
// Journal survey imports
import '../../screens/journal/food_diary_survey_screen.dart';
import '../../screens/journal/body_image_diary_survey_screen.dart';
import '../../screens/assessments/assessment_2_2_screen.dart';
import '../../screens/assessments/assessment_2_3_screen.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigate to the appropriate screen based on todo item
  void navigateToTodoActivity(BuildContext context, TodoItem todo, [WidgetRef? ref]) {
    // Automatically mark the todo as completed when user accesses it
    _markTodoCompleted(todo, ref);
    
    switch (todo.type) {
      case TodoType.lesson:
        _navigateToLesson(context, todo);
        break;
      case TodoType.tool:
        _navigateToTool(context, todo);
        break;
      case TodoType.journal:
        _navigateToJournal(context, todo);
        break;
    }
  }

  // Helper method to mark todo as completed in the background
  void _markTodoCompleted(TodoItem todo, WidgetRef? ref) {
    if (ref == null) return;
    
    try {
      final user = ref.read(currentUserDataProvider);
      if (user != null && !todo.isCompleted) {
        // Mark todo as completed in the background
        ref.read(userTodosProvider(user.id).notifier)
            .markCompletedByActivity(todo.activityId, todo.type);
            
        // If this is a lesson, also mark it in the auto todo system
        if (todo.type == TodoType.lesson) {
          ref.read(autoTodoInitializationProvider(user.id).notifier)
              .markLessonCompleted(todo.activityId);
        }
      }
    } catch (e) {
      // Silently fail - this is a background operation
      // We don't want to disrupt the user experience if this fails
    }
  }

  // Public method to mark any activity as completed (for direct navigation to lessons/tools)
  static void markActivityCompleted(WidgetRef ref, String activityId, TodoType type) {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user != null) {
        // Mark any matching pending todo as completed in the background
        ref.read(userTodosProvider(user.id).notifier)
            .markCompletedByActivity(activityId, type);
            
        // If this is a lesson, also mark it in the auto todo system
        if (type == TodoType.lesson) {
          ref.read(autoTodoInitializationProvider(user.id).notifier)
              .markLessonCompleted(activityId);
        }
      }
    } catch (e) {
      // Silently fail - this is a background operation
      // We don't want to disrupt the user experience if this fails
    }
  }

  // Navigate to lesson based on activity ID
  void _navigateToLesson(BuildContext context, TodoItem todo) {
    Widget? lessonScreen;
    
    // Try to get lesson from activity data first (from manually created todos)
    final activityData = todo.activityData;
    if (activityData != null && 
        activityData.containsKey('chapterNumber') && 
        activityData.containsKey('lessonNumber')) {
      final chapterNumber = activityData['chapterNumber'] as int;
      final lessonNumber = activityData['lessonNumber'] as int;
      lessonScreen = _getLessonScreenByChapterAndNumber(chapterNumber, lessonNumber);
    }
    
    // If no activity data, try to parse from activity ID (from AI recommendations)
    lessonScreen ??= _getLessonScreenByActivityId(todo.activityId);
    
    if (lessonScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => lessonScreen!,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson "${todo.title}" not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  // Public method to navigate to lesson from chatbot or other sources
  void navigateToLesson(BuildContext context, {required Map<String, dynamic> activityData, required String activityId}) {
    Widget? lessonScreen;
    
    // Try to get lesson from activity data first
    if (activityData.containsKey('chapterNumber') && 
        activityData.containsKey('lessonNumber')) {
      final chapterNumber = activityData['chapterNumber'] as int;
      final lessonNumber = activityData['lessonNumber'] as int;
      lessonScreen = _getLessonScreenByChapterAndNumber(chapterNumber, lessonNumber);
    }
    
    // If no activity data, try to parse from activity ID
    lessonScreen ??= _getLessonScreenByActivityId(activityId);
    
    if (lessonScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => lessonScreen!,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Navigate to tool based on activity ID
  void _navigateToTool(BuildContext context, TodoItem todo) {
    String? route;
    
    // Map activity IDs to tool routes
    switch (todo.activityId) {
      case 'problem_solving':
        route = '/tools/problem-solving';
        break;
      case 'meal_planning':
        route = '/tools/meal-planning';
        break;
      case 'urge_surfing':
        route = '/tools/urge-surfing';
        break;
      case 'addressing_overconcern':
        route = '/tools/addressing-overconcern';
        break;
      case 'addressing_setbacks':
        route = '/tools/addressing-setbacks';
        break;
      case 'purge_control':
        route = '/tools/purge-control';
        break;
      case 'shape_checking':
        route = '/tools/shape-checking';
        break;
      case 'addressing_comparisons':
        route = '/tools/addressing-comparisons';
        break;
      case 'addressing_feeling_fat':
        route = '/tools/addressing-feeling-fat';
        break;
    }
    
    if (route != null) {
      context.push(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tool "${todo.title}" not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Navigate to journal based on activity ID
  void _navigateToJournal(BuildContext context, TodoItem todo) {
    // Extract journal type from activity data
    final journalType = todo.activityData?['journalType'] as String?;
    
    if (journalType == null) {
      // Fallback to main journal screen if no journal type
      context.go('/journal');
      return;
    }
    
    // Navigate to specific journal survey based on type
    switch (journalType) {
      case 'food_diary':
        _navigateToFoodDiarySurvey(context);
        break;
      case 'body_image_diary':
        _navigateToBodyImageDiarySurvey(context);
        break;
      default:
        // Fallback to main journal screen
        context.go('/journal');
    }
  }
  
  // Navigate to food diary survey
  void _navigateToFoodDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodDiarySurveyScreen(),
      ),
    );
  }
  
  // Weight diary survey navigation removed
  
  // Navigate to body image diary survey
  void _navigateToBodyImageDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BodyImageDiarySurveyScreen(),
      ),
    );
  }

  // Get lesson screen by chapter and lesson number (only Stage 1 lessons)
  Widget? _getLessonScreenByChapterAndNumber(int chapterNumber, int lessonNumber) {
    switch (chapterNumber) {
      case 1:
        switch (lessonNumber) {
          case 1: return const Lesson11Screen();
          case 2: return const Lesson12Screen();
          case 21: return const Lesson121Screen(); // 2.1 exercise
          case 3: return const Lesson13Screen();
        }
        break;
      case 2:
        switch (lessonNumber) {
          case 1: return const Assessment21Screen();
          case 2: return const Assessment22Screen();
          case 3: return const Assessment23Screen();
        }
        break;
      case 3:
        switch (lessonNumber) {
          case 1: return const Lesson31Screen();
          case 2: return const Lesson32Screen();
          case 3: return const Lesson33Screen();
          case 4: return const Lesson34Screen();
          case 5: return const Lesson35Screen();
          case 6: return const Lesson36Screen();
          case 7: return const Lesson37Screen();
          case 8: return const Lesson38Screen();
          case 9: return const Lesson39Screen();
          case 10: return const Lesson310Screen();
        }
        break;
      case 4:
        switch (lessonNumber) {
          case 3: return const LessonS243Screen();
        }
        break;
    }
    return null;
  }

  // Get lesson screen by activity ID (fallback method)
  Widget? _getLessonScreenByActivityId(String activityId) {
    // This is a fallback method that tries to map activity IDs to lesson screens
    // The activity ID might be in the format "lesson_X_Y" or "lesson_sX_Y_Z"
    
    // Handle Stage 2 lesson IDs (e.g., "lesson_s2_2_7")
    if (activityId.startsWith('lesson_s2_')) {
      switch (activityId) {
        case 'lesson_s2_2_7':
          return const LessonS227Screen();
        case 'lesson_s2_3_5':
          return const LessonS235Screen();
        case 'lesson_s2_4_3':
          return const LessonS243Screen();
        case 'lesson_s2_7_3':
          return const LessonS2721Screen();
        // Add more Stage 2 lessons as needed
      }
    }
    
    // Handle Stage 3 lesson IDs (e.g., "lesson_s3_0_2_1")
    if (activityId.startsWith('lesson_s3_')) {
      switch (activityId) {
        case 'lesson_s3_0_2_1':
          return const LessonS3021Screen();
        // Add more Stage 3 lessons as needed
      }
    }
    
    // Try to parse Stage 1 lesson from activity ID
    final parts = activityId.split('_');
    if (parts.length >= 3 && parts[0] == 'lesson') {
      try {
        final chapterNumber = int.parse(parts[1]);
        final lessonNumber = int.parse(parts[2]);
        return _getLessonScreenByChapterAndNumber(chapterNumber, lessonNumber);
      } catch (e) {
        // Could not parse lesson numbers from activity ID
      }
    }
    
    return null;
  }
}