import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/todo_item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigate to the appropriate screen based on todo item
  void navigateToTodoActivity(BuildContext context, TodoItem todo, [WidgetRef? ref]) {
    // Automatically mark the todo as completed when user accesses it
    _markTodoCompleted(todo, ref);
    
    switch (todo.type) {
      case TodoType.tool:
        _navigateToTool(context, todo);
        break;
      case TodoType.journal:
        _navigateToJournal(context, todo);
        break;
    }
  }

  // Mark todo as completed
  void _markTodoCompleted(TodoItem todo, WidgetRef? ref) {
    if (ref != null && !todo.isCompleted) {
      final user = ref.read(currentUserDataProvider);
      if (user != null) {
        ref.read(userTodosProvider(user.id).notifier).markCompleted(todo.id);
      }
    }
  }

  // Show message that lessons are not available
  void _showLessonNotAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lessons are not available at this time'),
        backgroundColor: Colors.orange,
      ),
    );
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
          content: Text('Tool "${todo.title}" not available yet'),
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
      // Default to main journal screen
      context.go('/journal');
    }
  }

  // Get tool route based on activity ID
  String? _getToolRoute(String activityId) {
    switch (activityId) {
      case 'urge_surfing':
        return '/tools/urge-surfing';
      case 'problem_solving':
        return '/tools/problem-solving';
      case 'addressing_setbacks':
        return '/tools/addressing-setbacks';
      case 'addressing_overconcern':
        return '/tools/addressing-overconcern';
      case 'meal_planning':
        return '/tools/meal-planning';
      default:
        return '/tools'; // Default to tools screen
    }
  }

  // Get journal route based on activity ID
  String? _getJournalRoute(String activityId) {
    switch (activityId) {
      case 'food_diary':
        return '/journal/food-diary';
      case 'body_image_diary':
        return '/journal/body-image';
      case 'weight_diary':
        return '/journal/weight';
      default:
        return '/journal'; // Default to main journal screen
    }
  }

  // Public method to mark any activity as completed (for direct navigation to tools)
  static void markActivityCompleted(WidgetRef ref, String activityId, TodoType type) {
    try {
      // Find the todo with this activity ID and mark it as completed
      // Get current user to access their todos
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      
      final todos = ref.read(userTodosProvider(user.id)).value ?? [];
      final todo = todos.firstWhere(
        (t) => t.activityId == activityId && t.type == type && !t.isCompleted,
        orElse: () => throw StateError('Todo not found'),
      );
      
      ref.read(userTodosProvider(user.id).notifier).markCompleted(todo.id);
    } catch (e) {
      // Todo not found or already completed - this is fine
      print('Activity completion: $e');
    }
  }
}