import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/onboarding_data.dart';
import 'onboarding_service.dart';
import 'week_data_service.dart';

/// Service to fetch comprehensive user context for AI interactions
class UserContextService {
  static final UserContextService _instance = UserContextService._internal();
  factory UserContextService() => _instance;
  UserContextService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OnboardingService _onboardingService = OnboardingService();
  final WeekDataService _weekDataService = WeekDataService();

  /// Get comprehensive user context for AI chat
  Future<Map<String, dynamic>> getUserContext(String userId) async {
    try {
      // Fetch user profile
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw 'User not found';
      }

      final userData = UserModel.fromFirestore(userDoc);
      
      // Fetch data in parallel for better performance
      final results = await Future.wait([
        _onboardingService.getOnboardingData(userId).catchError((_) => null),
        _weekDataService.getCurrentWeekData(userId).catchError((_) => <String, dynamic>{}),
        _getRecentAssessments(userId).catchError((_) => <String, dynamic>{}),
        _getLessonProgress(userId).catchError((_) => <String, dynamic>{}),
      ]);

      final onboardingData = results[0] as OnboardingData?;
      final currentWeekData = results[1] as Map<String, dynamic>;
      final assessmentData = results[2] as Map<String, dynamic>;
      final lessonProgress = results[3] as Map<String, dynamic>;

      return {
        'user': {
          'firstName': userData.firstName,
          'lastName': userData.lastName,
          'level': userData.level,
          'exp': userData.exp,
          'role': userData.role.displayName,
          'onboardingCompleted': userData.onboardingCompleted,
          'createdAt': userData.createdAt.toIso8601String(),
        },
        'onboarding': onboardingData != null ? {
          'completed': onboardingData.isComplete,
          'totalScore': onboardingData.totalScore,
          'answersCount': onboardingData.answers.length,
          'completedAt': onboardingData.completedAt.toIso8601String(),
        } : null,
        'currentWeek': currentWeekData,
        'assessments': assessmentData,
        'lessonProgress': lessonProgress,
      };
    } catch (e) {
      print('Error fetching user context: $e');
      rethrow;
    }
  }

  /// Get recent assessment completions
  Future<Map<String, dynamic>> _getRecentAssessments(String userId) async {
    try {
      final assessmentsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('assessments')
          .orderBy('completedAt', descending: true)
          .limit(10)
          .get();

      final assessments = <String, Map<String, dynamic>>{};
      
      for (final doc in assessmentsSnapshot.docs) {
        final data = doc.data();
        assessments[doc.id] = {
          'lessonId': data['lessonId'],
          'completedAt': data['completedAt'] != null 
              ? (data['completedAt'] as Timestamp).toDate().toIso8601String()
              : null,
          'isCompleted': data['isCompleted'] ?? false,
        };
      }

      return {
        'completed': assessments,
        'totalCompleted': assessments.length,
      };
    } catch (e) {
      print('Error fetching assessments: $e');
      return {};
    }
  }

  /// Get lesson completion progress
  Future<Map<String, dynamic>> _getLessonProgress(String userId) async {
    try {
      final progressSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();

      final completedLessons = <String>[];
      int totalExpEarned = 0;

      for (final doc in progressSnapshot.docs) {
        final data = doc.data();
        if (data['isCompleted'] == true) {
          completedLessons.add(doc.id);
        }
        if (data['expEarned'] != null) {
          totalExpEarned += (data['expEarned'] as int);
        }
      }

      return {
        'completedLessons': completedLessons,
        'totalLessonsCompleted': completedLessons.length,
        'totalExpEarned': totalExpEarned,
      };
    } catch (e) {
      print('Error fetching lesson progress: $e');
      return {
        'completedLessons': [],
        'totalLessonsCompleted': 0,
        'totalExpEarned': 0,
      };
    }
  }

  /// Format user context for AI prompt
  String formatUserContextForAI(Map<String, dynamic> context) {
    final buffer = StringBuffer();
    
    // User profile
    final user = context['user'] as Map<String, dynamic>?;
    if (user != null) {
      buffer.writeln('USER PROFILE:');
      buffer.writeln('- Name: ${user['firstName']} ${user['lastName']}');
      buffer.writeln('- Current Level: ${user['level']}');
      buffer.writeln('- Experience Points: ${user['exp']}');
      buffer.writeln('- Onboarding Completed: ${user['onboardingCompleted']}');
      
      final createdAt = DateTime.parse(user['createdAt'] as String);
      final daysSinceJoined = DateTime.now().difference(createdAt).inDays;
      buffer.writeln('- Days in program: $daysSinceJoined');
      buffer.writeln();
    }

    // Onboarding data
    final onboarding = context['onboarding'] as Map<String, dynamic>?;
    if (onboarding != null && onboarding['completed'] == true) {
      buffer.writeln('ONBOARDING ASSESSMENT:');
      buffer.writeln('- Initial assessment score: ${onboarding['totalScore']}/48');
      buffer.writeln('- Completed: ${onboarding['completedAt']}');
      buffer.writeln();
    }

    // Current week data
    final currentWeek = context['currentWeek'] as Map<String, dynamic>?;
    if (currentWeek != null && currentWeek.isNotEmpty) {
      buffer.writeln('CURRENT WEEK (Week ${currentWeek['weekNumber']}):');
      buffer.writeln('- Total meals logged: ${currentWeek['totalMeals']}');
      buffer.writeln('- Binge episodes: ${currentWeek['bingeCount']}');
      buffer.writeln('- Binge rate: ${(currentWeek['bingeRate'] as num).toStringAsFixed(1)}%');
      buffer.writeln('- Body image checks: ${currentWeek['bodyImageCheckCount']}');
      
      if (currentWeek['latestWeight'] != null) {
        buffer.writeln('- Latest weight: ${currentWeek['latestWeight']}');
      }
      
      final bingeLocations = currentWeek['bingeLocations'] as Map<String, dynamic>?;
      if (bingeLocations != null && bingeLocations.isNotEmpty) {
        buffer.writeln('- Common binge locations: ${bingeLocations.keys.take(3).join(', ')}');
      }
      
      final bingeTimes = currentWeek['bingeTimes'] as Map<String, dynamic>?;
      if (bingeTimes != null && bingeTimes.isNotEmpty) {
        buffer.writeln('- Common binge times: ${bingeTimes.keys.take(3).join(', ')}');
      }
      
      // Add detailed food diary entries
      final foodDiaries = currentWeek['foodDiaries'] as List<dynamic>?;
      if (foodDiaries != null && foodDiaries.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('FOOD DIARY ENTRIES:');
        for (int i = 0; i < foodDiaries.length && i < 10; i++) {
          final entry = foodDiaries[i] as Map<String, dynamic>;
          final time = DateTime.parse(entry['mealTime'] as String).toString().substring(11, 16);
          final food = entry['foodAndDrinks'] as String;
          final location = entry['location'] as String;
          final isBinge = entry['isBinge'] as bool;
          final bingeIndicator = isBinge ? ' (BINGE)' : '';
          final context = entry['contextAndComments'] as String? ?? '';
          
          buffer.writeln('- $time: $food$bingeIndicator | Location: $location');
          if (context.isNotEmpty) {
            buffer.writeln('  Context: $context');
          }
        }
        if (foodDiaries.length > 10) {
          buffer.writeln('- ... and ${foodDiaries.length - 10} more entries');
        }
      }
      
      // Add detailed weight diary entries
      final weightDiaries = currentWeek['weightDiaries'] as List<dynamic>?;
      if (weightDiaries != null && weightDiaries.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('WEIGHT TRACKING:');
        for (int i = 0; i < weightDiaries.length && i < 5; i++) {
          final entry = weightDiaries[i] as Map<String, dynamic>;
          final time = DateTime.parse(entry['createdAt'] as String).toString().substring(11, 16);
          final weight = entry['weight'] as num;
          final unit = entry['unit'] as String;
          buffer.writeln('- $time: $weight $unit');
        }
        if (weightDiaries.length > 5) {
          buffer.writeln('- ... and ${weightDiaries.length - 5} more entries');
        }
      }
      
      // Add detailed body image diary entries
      final bodyImageDiaries = currentWeek['bodyImageDiaries'] as List<dynamic>?;
      if (bodyImageDiaries != null && bodyImageDiaries.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('BODY IMAGE DIARY:');
        for (int i = 0; i < bodyImageDiaries.length && i < 5; i++) {
          final entry = bodyImageDiaries[i] as Map<String, dynamic>;
          final time = DateTime.parse(entry['checkTime'] as String).toString().substring(11, 16);
          final howChecked = entry['howChecked'] as String;
          final whereChecked = entry['whereChecked'] as String;
          final feelings = entry['contextAndFeelings'] as String? ?? '';
          
          buffer.writeln('- $time: $howChecked | $whereChecked');
          if (feelings.isNotEmpty) {
            buffer.writeln('  Feelings: $feelings');
          }
        }
        if (bodyImageDiaries.length > 5) {
          buffer.writeln('- ... and ${bodyImageDiaries.length - 5} more entries');
        }
      }
      
      buffer.writeln();
    }

    // Assessment progress
    final assessments = context['assessments'] as Map<String, dynamic>?;
    if (assessments != null && assessments.isNotEmpty) {
      final totalCompleted = assessments['totalCompleted'] ?? 0;
      if (totalCompleted > 0) {
        buffer.writeln('ASSESSMENTS COMPLETED:');
        buffer.writeln('- Total assessments: $totalCompleted');
        
        final completed = assessments['completed'] as Map<String, dynamic>?;
        if (completed != null) {
          final recentAssessments = completed.entries.take(3).map((e) => e.value['lessonId']).join(', ');
          buffer.writeln('- Recent: $recentAssessments');
        }
        buffer.writeln();
      }
    }

    // Lesson progress
    final lessonProgress = context['lessonProgress'] as Map<String, dynamic>?;
    if (lessonProgress != null && lessonProgress.isNotEmpty) {
      final totalCompleted = lessonProgress['totalLessonsCompleted'] ?? 0;
      if (totalCompleted > 0) {
        buffer.writeln('LESSON PROGRESS:');
        buffer.writeln('- Lessons completed: $totalCompleted');
        buffer.writeln('- Total EXP earned from lessons: ${lessonProgress['totalExpEarned']}');
        
        final completedLessons = lessonProgress['completedLessons'] as List<dynamic>?;
        if (completedLessons != null && completedLessons.isNotEmpty) {
          final recentLessons = completedLessons.take(5).join(', ');
          buffer.writeln('- Recently completed: $recentLessons');
        }
        buffer.writeln();
      }
    }

    return buffer.toString();
  }
}

