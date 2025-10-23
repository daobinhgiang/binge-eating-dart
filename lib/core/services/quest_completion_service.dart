import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_item.dart';
import '../../providers/exp_provider.dart';
import 'todo_service.dart';
import 'streak_service.dart';
import 'lesson_progress_service.dart';
import 'task_regeneration_service.dart';
import 'exp_service.dart';

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
    WidgetRef? ref,
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
          // Get old streak before incrementing
          final oldStreak = await _streakService.getCurrentStreak(userId);
          currentStreak = await _streakService.incrementStreak(userId);
          streakUpdated = true;
          if (currentStreak > 0) {
            print('   ✅ Streak updated to: $currentStreak days');
            
            // Set suppression flag to prevent automatic streak animation in home screen
            // Auth provider will be refreshed AFTER quest dialog is dismissed
            if (ref != null) {
              print('   🔒 Suppressing automatic streak animation (will show after quest dialog)');
              ref.read(streakAnimationSuppressionProvider.notifier).suppressStreakAnimation(
                oldStreak: oldStreak,
                newStreak: currentStreak,
                isReset: currentStreak == 0,
              );
              print('   ℹ️  Auth provider will be refreshed after quest dialog dismissal');
            }
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
  /// Directly updates user document with new EXP and calculates new level
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
      final currentLevel = (userDoc.get('level') ?? 1) as int;
      final newExp = currentExp + expAmount;

      // Calculate new level based on new EXP (same logic as backend)
      final expService = ExpService();
      final newLevel = expService.calculateLevel(newExp);

      // Update user document with new EXP and level
      await _firestore.collection('users').doc(userId).update({
        'exp': newExp,
        'level': newLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('   Updated user exp: $currentExp → $newExp');
      print('   Updated user level: $currentLevel → $newLevel');

      return expAmount;
    } catch (e) {
      print('   ⚠️  Error awarding EXP: $e');
      return 0;
    }
  }

  /// Handle lesson completion with progress tracking
  /// This tracks total lessons and checks if any quests are completed
  Future<QuestCompletionResult> handleLessonCompletion({
    required String userId,
    required String lessonId,
    WidgetRef? ref,
  }) async {
    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('📚 LESSON COMPLETION HANDLER');
      print('═══════════════════════════════════════════════════════════');
      print('   Lesson ID: $lessonId');
      print('   User ID: $userId');
      print('   Timestamp: ${DateTime.now()}');

      // 🆕 CRITICAL: Clear cache BEFORE regeneration to ensure fresh data
      print('\n🔄 Pre-Step: Clearing cache before task regeneration...');
      _todoService.clearUserCache(userId);

      // 🆕 Step 0: Ensure quests are generated before checking
      print('\n🔄 Step 0: Checking and regenerating tasks if needed...');
      final regenerationService = TaskRegenerationService();
      final regeneratedTasks = await regenerationService.checkAndRegenerateTasks(userId);
      print('   ✅ Regeneration check complete. Generated: ${regeneratedTasks.length} new tasks');

      final lessonProgressService = LessonProgressService();
      
      print('\n📊 Step 1: Recording lesson completion...');
      // Record the lesson completion and get updated progress
      final progress = await lessonProgressService.recordLessonCompletion(userId);
      
      print('   ✅ Progress recorded!');
      print('   📅 Lessons completed TODAY: ${progress['lessonsCompletedToday']}');
      print('   📆 Lessons completed THIS WEEK: ${progress['lessonsCompletedThisWeek']}');

      print('\n🔍 Step 2: Checking for matching quests...');
      // Clear cache again to ensure we get fresh data that includes newly generated tasks
      _todoService.clearUserCache(userId);
      // Now check for matching quests related to lesson completion
      final allTodos = await _todoService.getUserTodos(userId);
      
      print('   Total todos fetched: ${allTodos.length}');
      
      // Debug: Print ALL todos to understand what we have
      print('   📋 ALL TODOS:');
      for (final todo in allTodos) {
        print('      - "${todo.title}" (activityId: "${todo.activityId}", tier: ${todo.tier}, completed: ${todo.isCompleted}, hasMetadata: ${todo.tierMetadata != null})');
      }
      
      // Find quests that are about completing N lessons
      final lessonQuests = allTodos.where((todo) {
        // Check if quest is about lessons (e.g., "Complete 2 lessons")
        final notCompleted = !todo.isCompleted;
        final activityMatches = todo.activityId == 'complete_lessons';
        final hasMetadata = todo.tierMetadata != null;
        
        final matches = notCompleted && activityMatches && hasMetadata;
        if (!matches && (activityMatches || todo.title.contains('Lesson'))) {
          print('      ❌ Quest "${todo.title}" does NOT match: notCompleted=$notCompleted, activityMatches=$activityMatches, hasMetadata=$hasMetadata');
        }
        
        return matches;
      }).toList();

      print('   Found ${lessonQuests.length} pending lesson-based quests');
      
      // Debug: Print details of found quests
      for (final quest in lessonQuests) {
        print('   📌 Quest found: "${quest.title}"');
        print('      - ID: ${quest.id}');
        print('      - ActivityID: ${quest.activityId}');
        print('      - Tier: ${quest.tier}');
        print('      - Metadata: ${quest.tierMetadata}');
      }

      QuestCompletionResult? completedQuestResult;

      // Check each lesson quest to see if it's now completed
      for (final quest in lessonQuests) {
        final requiredCount = quest.tierMetadata?['requiredCount'] as int?;
        final trackBy = quest.tierMetadata?['trackBy'] as String? ?? 'daily'; // 'daily' or 'weekly'
        
        if (requiredCount == null) continue;

        final currentCount = trackBy == 'weekly' 
            ? progress['lessonsCompletedThisWeek']! 
            : progress['lessonsCompletedToday']!;

        print('\n   📋 Checking Quest: "${quest.title}"');
        print('      - Required: $requiredCount lessons');
        print('      - Tracking: ${trackBy.toUpperCase()}');
        print('      - Current: $currentCount lessons');
        print('      - Progress: $currentCount/$requiredCount');

        // 🆕 ALWAYS update the quest's progress in metadata, even if not completed yet
        print('      📝 Updating quest progress in metadata...');
        final updatedMetadata = Map<String, dynamic>.from(quest.tierMetadata ?? {});
        updatedMetadata['currentCount'] = currentCount;
        updatedMetadata['requiredCount'] = requiredCount;
        updatedMetadata['trackBy'] = trackBy;
        
        // Update the quest document with current progress
        final updatedQuest = quest.copyWith(
          tierMetadata: updatedMetadata,
          updatedAt: DateTime.now(),
        );
        
        await _todoService.updateTodo(updatedQuest);
        print('      ✅ Quest progress updated: $currentCount/$requiredCount');

        // If requirement met, mark quest as complete
        if (currentCount >= requiredCount) {
          print('      ✅✅✅ QUEST REQUIREMENT MET! ✅✅✅');
          
          print('\n💰 Step 3: Awarding quest rewards...');
          final expAwarded = await _awardQuestEXP(userId, quest);
          print('   ✅ Awarded $expAwarded EXP');
          print('   ℹ️  Auth provider will be refreshed after quest dialog dismissal');
          
          print('\n📝 Step 4: Marking quest as completed...');
          // Mark quest as completed
          await _todoService.markTodoCompleted(userId, quest.id);
          print('   ✅ Quest marked complete in Firestore');
          
          completedQuestResult = QuestCompletionResult(
            questCompleted: true,
            completedQuest: updatedQuest,
            expAwarded: expAwarded,
            streakUpdated: false,
          );
          
          break; // Only complete one quest per lesson
        } else {
          final remaining = requiredCount - currentCount;
          print('      ⏳ Need $remaining more lesson(s)');
        }
      }

      print('\n═══════════════════════════════════════════════════════════');
      if (completedQuestResult != null) {
        print('🎉 RESULT: QUEST COMPLETED!');
        print('   Quest: "${completedQuestResult.completedQuest?.title}"');
        print('   EXP Awarded: ${completedQuestResult.expAwarded}');
      } else {
        print('ℹ️  RESULT: No quest completed this session');
        print('   Lesson progress is being tracked for future completion');
      }
      print('═══════════════════════════════════════════════════════════\n');

      if (completedQuestResult != null) {
        return completedQuestResult;
      }

      // No quest completed, but return success for lesson completion
      return QuestCompletionResult(
        questCompleted: false,
        expAwarded: 0,
      );

    } catch (e) {
      print('❌ ERROR in handleLessonCompletion: $e');
      print('═══════════════════════════════════════════════════════════\n');
      return QuestCompletionResult(questCompleted: false);
    }
  }
  
  /// Synchronize all lesson-based quest progress with actual lesson counts
  /// This ensures quests show correct progress even if they were just generated
  /// Call this on app startup or when viewing the quest list
  Future<void> syncLessonQuestProgress(String userId) async {
    try {
      print('\n🔄 SYNCING LESSON QUEST PROGRESS');
      
      // Get current lesson progress
      final lessonProgressService = LessonProgressService();
      final progress = await lessonProgressService.getLessonProgress(userId);
      
      print('   Current progress:');
      print('   - Lessons today: ${progress['lessonsCompletedToday']}');
      print('   - Lessons this week: ${progress['lessonsCompletedThisWeek']}');
      
      // Get all todos
      final allTodos = await _todoService.getUserTodos(userId);
      
      // Find lesson-based quests
      final lessonQuests = allTodos.where((todo) {
        return !todo.isCompleted && 
               todo.activityId == 'complete_lessons' && 
               todo.tierMetadata != null;
      }).toList();
      
      print('   Found ${lessonQuests.length} lesson quests to sync');
      
      // Update each quest with current progress
      for (final quest in lessonQuests) {
        final trackBy = quest.tierMetadata?['trackBy'] as String? ?? 'daily';
        final requiredCount = quest.tierMetadata?['requiredCount'] as int?;
        
        if (requiredCount == null) continue;
        
        final currentCount = trackBy == 'weekly' 
            ? progress['lessonsCompletedThisWeek']! 
            : progress['lessonsCompletedToday']!;
        
        // Update quest metadata with current progress
        final updatedMetadata = Map<String, dynamic>.from(quest.tierMetadata ?? {});
        updatedMetadata['currentCount'] = currentCount;
        
        final updatedQuest = quest.copyWith(
          tierMetadata: updatedMetadata,
          updatedAt: DateTime.now(),
        );
        
        await _todoService.updateTodo(updatedQuest);
        print('   ✅ Synced "${quest.title}": $currentCount/$requiredCount');
      }
      
      print('   Sync complete!\n');
    } catch (e) {
      print('   ⚠️  Error syncing quest progress: $e\n');
    }
  }

  /// Clear all cached quest completion data
  /// Called during account deletion to prevent stale data
  void clearCache() {
    // This service doesn't have a cache, but we add this method
    // for consistency and future-proofing
    print('[QuestCompletionService] Cache cleared');
  }
}
