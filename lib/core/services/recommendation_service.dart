import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/onboarding_answer.dart';
// AI services removed from recommendations
import './todo_service.dart';

class RecommendationService {
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  // AI services removed
  final TodoService _todoService = TodoService();

  // Generate personalized recommendations based on onboarding answers
  Future<List<TodoItem>> generateRecommendationsFromOnboarding(
    String userId,
    List<OnboardingAnswer> answers,
  ) async {
    try {
      // Prepare survey answers for the OpenAI API
      final answersFormatted = answers.map((answer) => {
        'question': answer.question,
        'answer': answer.selectedText,
        'questionNumber': answer.questionNumber,
      }).toList();
      
      // AI-based recommendations removed; return empty list
      final todoItems = <TodoItem>[];
      final now = DateTime.now();
      
      // Intentionally no-op
      
      return todoItems;
    } catch (e) {
      throw 'Failed to generate recommendations: $e';
    }
  }

  // Generate personalized recommendations based on analytics insights and patterns
  Future<List<TodoItem>> generateRecommendationsFromAnalytics(
    String userId,
    Map<String, dynamic> analysis,
  ) async {
    try {
      // AI-based analytics recommendations removed; return empty list
      return <TodoItem>[];
    } catch (e) {
      throw 'Failed to generate analytics-based recommendations: $e';
    }
  }
  
  // Helper to validate recommendation format
  bool _isValidRecommendation(dynamic recommendation) {
    return recommendation is Map &&
        recommendation.containsKey('type') &&
        recommendation.containsKey('id') &&
        recommendation.containsKey('title') &&
        recommendation.containsKey('description');
  }
  
  // Helper to parse todo type from string
  TodoType _parseTodoType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'tool':
      case 'exercise': // Treat exercises as tools since they're interactive activities
        return TodoType.tool;
      case 'journal':
        return TodoType.journal;
      case 'lesson':
      default:
        return TodoType.lesson;
    }
  }
  
  // Helper to parse due date from string
  DateTime? _parseDueDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}
