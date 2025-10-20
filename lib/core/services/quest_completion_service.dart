import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import 'todo_service.dart';
import 'streak_service.dart';

/// Data class representing the result of a quest completion
class QuestCompletionResult {
  final bool questCompleted;
  final TodoItem? completedQuest;
  final int expAwarded;
  final bool streakUpdated;
  final int? currentStreak;

  QuestCompletionResult({
    required this.questCompleted,
    this.completedQuest,
    this.expAwarded = 0,
    this.streakUpdated = false,
    this.currentStreak,
  });
}

/// Service to handle quest completion events
/// When a user completes an activity (lesson, tool, journal),
/// this service detects if there's a matching quest and marks it as completed
class QuestCompletionService {
  static final QuestCompletionService _instance = QuestCompletionService._internal();
  factory QuestCompletionService() => _instance;
  QuestCompletionService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TodoService _todoService = TodoService();
  final StreakService _streakService = StreakService();

  /// Handle activity completion (lesson, tool, or journal)
  /// This is called when user finishes an activity
  /// Returns completion result with quest info and EXP awarded
  Future<QuestCompletionResult> handleActivityCompletion({
    required String userId,
    required String activityId,
    required TodoType type,
  }) async {
    try {
      print('\n🎯 QUEST COMPLETION HANDLER TRIGGERED');
      print('   userId: $userId');
      print('   activityId: $activityId');
      print('   type: $type');

      // Step 1: Find matching pending quest
      print('\n📋 Step 1: Finding matching pending quest...');
      final matchingTodo = await _findMatchingPendingQuest(userId, activityId, type);

      if (matchingTodo == null) {
        print('   ℹ️  No pending quest found for this activity');
        return QuestCompletionResult(questCompleted: false);
      }

      print('   ✅ Found quest: "${matchingTodo.title}" (ID: ${matchingTodo.id})');

      // Step 2: Award EXP
      print('\n💰 Step 2: Awarding EXP...');
      final expAwarded = await _awardQuestEXP(userId, matchingTodo);
      print('   ✅ Awarded $expAwarded EXP');

      // Step 3: Update streak if applicable
      print('\n🔥 Step 3: Checking streak...');
      bool streakUpdated = false;
      int? currentStreak;
      
      if (matchingTodo.isSeed) {
        // Daily seeds contribute to journal streak
        print('   📝 Quest is a seed - checking if all daily tasks completed');
        final allTasksCompleted = await _streakService.getAllDailyTasksCompleted(userId);
        if (allTasksCompleted) {
          currentStreak = await _streakService.incrementStreak(userId);
          streakUpdated = true;
          if (currentStreak > 0) {
            print('   ✅ Streak updated to: $currentStreak days');
          }
        } else {
          print('   ℹ️  Not all daily tasks completed yet, streak not updated');
        }
      }

      print('\n✅ QUEST COMPLETION SUCCESSFUL');
      print('   Quest: "${matchingTodo.title}"');
      print('   EXP Awarded: $expAwarded');
      if (streakUpdated) print('   Streak: $currentStreak days');

      return QuestCompletionResult(
        questCompleted: true,
        completedQuest: matchingTodo,
        expAwarded: expAwarded,
        streakUpdated: streakUpdated,
        currentStreak: currentStreak,
      );
    } catch (e) {
      print('❌ Error in handleActivityCompletion: $e');
      return QuestCompletionResult(questCompleted: false);
    }
  }

  /// Find a matching pending quest for the given activity
  Future<TodoItem?> _findMatchingPendingQuest(
    String userId,
    String activityId,
    TodoType type,
  ) async {
    try {
      return await _todoService.markTodoCompletedByActivity(userId, activityId, type);
    } catch (e) {
      // No matching quest found - this is normal, some activities might not have quests
      return null;
    }
  }

  /// Award EXP for completing a quest
  /// Directly updates user document with new EXP
  Future<int> _awardQuestEXP(String userId, TodoItem quest) async {
    try {
      final expAmount = quest.expReward;

      // Get current user EXP and level
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        print('   ⚠️  User document not found');
        return 0;
      }

      final currentExp = (userDoc.get('exp') ?? 0) as int;
      final newExp = currentExp + expAmount;

      // Update user document with new EXP
      await _firestore.collection('users').doc(userId).update({
        'exp': newExp,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('   Updated user exp: $currentExp → $newExp');

      return expAmount;
    } catch (e) {
      print('   ⚠️  Error awarding EXP: $e');
      return 0;
    }
  }
}
