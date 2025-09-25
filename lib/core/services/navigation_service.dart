import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/todo_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../screens/lessons/lesson_1_1.dart';
import '../../screens/lessons/lesson_1_2.dart';
import '../../screens/lessons/lesson_1_3.dart';
import '../../screens/lessons/lesson_2_1.dart';
import '../../screens/lessons/lesson_2_2.dart';
import '../../screens/lessons/lesson_2_3.dart';
import '../../screens/lessons/lesson_2_4.dart';
import '../../screens/lessons/lesson_2_5.dart';
import '../../screens/lessons/lesson_3_1.dart';
import '../../screens/lessons/lesson_3_2.dart';
import '../../screens/lessons/lesson_3_3.dart';
import '../../screens/lessons/lesson_4_1.dart';
import '../../screens/lessons/lesson_4_2.dart';
import '../../screens/lessons/lesson_4_3.dart';
import '../../screens/lessons/lesson_4_4.dart';
import '../../screens/lessons/lesson_5_1.dart';
import '../../screens/lessons/lesson_5_2.dart';
import '../../screens/lessons/lesson_5_3.dart';
import '../../screens/lessons/lesson_6_1.dart';
import '../../screens/lessons/lesson_6_2.dart';
import '../../screens/lessons/lesson_6_3.dart';

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
    if (lessonScreen == null) {
      lessonScreen = _getLessonScreenByActivityId(todo.activityId);
    }
    
    if (lessonScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => lessonScreen!),
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
    if (lessonScreen == null) {
      lessonScreen = _getLessonScreenByActivityId(activityId);
    }
    
    if (lessonScreen != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => lessonScreen!),
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
    // Journal activities would navigate to the journal tab
    // For now, just navigate to the main journal screen
    context.go('/journal');
  }

  // Get lesson screen by chapter and lesson number
  Widget? _getLessonScreenByChapterAndNumber(int chapterNumber, int lessonNumber) {
    switch (chapterNumber) {
      case 1:
        switch (lessonNumber) {
          case 1: return const Lesson11Screen();
          case 2: return const Lesson12Screen();
          case 3: return const Lesson13Screen();
        }
        break;
      case 2:
        switch (lessonNumber) {
          case 1: return const Lesson21Screen();
          case 2: return const Lesson22Screen();
          case 3: return const Lesson23Screen();
          case 4: return const Lesson24Screen();
          case 5: return const Lesson25Screen();
        }
        break;
      case 3:
        switch (lessonNumber) {
          case 1: return const Lesson31Screen();
          case 2: return const Lesson32Screen();
          case 3: return const Lesson33Screen();
        }
        break;
      case 4:
        switch (lessonNumber) {
          case 1: return const Lesson41Screen();
          case 2: return const Lesson42Screen();
          case 3: return const Lesson43Screen();
          case 4: return const Lesson44Screen();
        }
        break;
      case 5:
        switch (lessonNumber) {
          case 1: return const Lesson51Screen();
          case 2: return const Lesson52Screen();
          case 3: return const Lesson53Screen();
        }
        break;
      case 6:
        switch (lessonNumber) {
          case 1: return const Lesson61Screen();
          case 2: return const Lesson62Screen();
          case 3: return const Lesson63Screen();
        }
        break;
    }
    return null;
  }

  // Get lesson screen by activity ID (fallback method)
  Widget? _getLessonScreenByActivityId(String activityId) {
    // This is a fallback method that tries to map activity IDs to lesson screens
    // The activity ID might be in the format "lesson_X_Y" or similar
    
    // Try to parse lesson from activity ID
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
