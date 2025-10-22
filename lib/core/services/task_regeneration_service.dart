import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/regeneration_log.dart';
import '../../data/task_templates.dart';
import 'todo_service.dart';
import 'streak_service.dart';
import 'quest_completion_service.dart';

class TaskRegenerationService {
  static final TaskRegenerationService _instance = TaskRegenerationService._internal();
  factory TaskRegenerationService() => _instance;
  TaskRegenerationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TodoService _todoService = TodoService();
  
  // In-memory cache of last regeneration log per user
  // This prevents race conditions where Firestore hasn't synced yet
  final Map<String, RegenerationLog> _lastRegenerationCache = {};
 
  /// Check and regenerate tasks if needed
  /// Returns: List of newly generated tasks
  Future<List<TodoItem>> checkAndRegenerateTasks(String userId) async {
    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('🔍 REGENERATION CHECK STARTED for userId: $userId');
      print('⏰ Current time: ${DateTime.now()}');
      print('═══════════════════════════════════════════════════════════');
      
      print('\n📖 Querying Firestore for last regeneration log...');
      final lastLog = await getLastRegeneration(userId);
      
      if (lastLog == null) {
        print('❌ No previous regeneration log found!');
      } else {
        print('✅ Found regeneration log:');
        print('   - regeneratedAt: ${lastLog.regeneratedAt}');
        print('   - seedsDate: ${lastLog.seedsDate}');
        print('   - growthWeek: ${lastLog.growthWeek}');
        print('   - growthYear: ${lastLog.growthYear}');
      }
      
      final newTasks = <TodoItem>[];

      // Check streak if it's a new day
      print('\n🔥 CHECKING STREAK...');
      final streakService = StreakService();
      final streakWasReset = await streakService.checkAndResetStreakIfNeeded(userId);
      if (streakWasReset) {
        print('🔄 Streak was reset today');
      } else {
        print('✅ Streak check complete');
      }

      // Check if Seeds need regeneration (daily)
      print('\n🌱 CHECKING SEEDS...');
      // FIRST: Check if seeds already exist for today (most reliable)
      final seedsExist = await _existingSeedsForTodayExist(userId);
      if (seedsExist) {
        print('✅ Seeds already exist for today - NO REGENERATION NEEDED');
      } else {
        // SECOND: Check log if no seeds exist
        final seedsNeedRegen = _seedsNeedRegeneration(lastLog);
        print('Seeds need regeneration? $seedsNeedRegen');
        
        if (seedsNeedRegen) {
          print('🔄 Generating seeds...');
          final seeds = await generateSeeds(userId);
          newTasks.addAll(seeds);
          print('✅ Generated ${seeds.length} seeds');
        } else {
          print('⏭️  Skipping seeds - already generated today');
        }
      }

      // Check if Growth Tasks need regeneration (weekly)
      print('\n📈 CHECKING GROWTH TASKS...');
      // FIRST: Check if growth tasks already exist for this week (most reliable)
      final growthTasksExist = await _existingGrowthTasksForThisWeekExist(userId);
      if (growthTasksExist) {
        print('✅ Growth tasks already exist for this week - NO REGENERATION NEEDED');
      } else {
        // SECOND: Check log if no growth tasks exist
        final growthNeedRegen = _growthTasksNeedRegeneration(lastLog);
        print('Growth tasks need regeneration? $growthNeedRegen');
        
        if (growthNeedRegen) {
          print('🔄 Generating growth tasks...');
          final growthTasks = await generateGrowthTasks(userId);
          newTasks.addAll(growthTasks);
          print('✅ Generated ${growthTasks.length} growth tasks');
        } else {
          print('⏭️  Skipping growth tasks - already generated this week');
        }
      }

      // Clean up expired tasks
      print('\n🧹 CLEANING UP EXPIRED TASKS...');
      await cleanupExpiredTasks(userId);

      // 🆕 Sync lesson quest progress after generating seeds
      if (newTasks.any((task) => task.isSeed && task.activityId == 'complete_lessons')) {
        print('\n🔄 SYNCING LESSON QUEST PROGRESS...');
        final questCompletionService = QuestCompletionService();
        await questCompletionService.syncLessonQuestProgress(userId);
      }

      print('\n📊 REGENERATION COMPLETE:');
      print('   - Total new tasks generated: ${newTasks.length}');
      print('═══════════════════════════════════════════════════════════\n');
      
      return newTasks;
    } catch (e) {
      print('❌ ERROR in checkAndRegenerateTasks: $e');
      print('═══════════════════════════════════════════════════════════\n');
      return [];
    }
  }

  /// Generate Seeds for today
  Future<List<TodoItem>> generateSeeds(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueTime = DateTime(today.year, today.month, today.day, 19, 0); // 7 PM
      
      print('      🌱 Starting seed generation...');
      print('      Today: ${today.toIso8601String()}');
      print('      Due time (7 PM): ${dueTime.toIso8601String()}');
      
      // First, delete all previous incomplete seeds
      print('      🧹 Deleting old incomplete seeds...');
      await _deleteIncompleteSeedsBeforeGeneration(userId);
      
      // Check if this is the user's first day
      final isFirstDay = await _isUserFirstDay(userId);
      
      // Get seed templates based on whether it's first day or not
      final seedTemplates = isFirstDay 
          ? TaskTemplatesData.getFirstDaySeeds()  // 2 seeds for first day
          : TaskTemplatesData.getRandomSeeds(count: 3);  // 3 seeds normally
      
      if (isFirstDay) {
        print('      🌟 First day detected - generating 2 starter seeds');
      }
      print('      📋 Selected ${seedTemplates.length} seed templates');
      
      // Generate batch ID
      final batchId = 'seeds_${today.toIso8601String().split('T')[0]}_${now.millisecondsSinceEpoch}';
      print('      🏷️  Batch ID: $batchId');
      
      // Create TodoItems from templates
      final tasks = <TodoItem>[];
      final taskIds = <String>[];
      
      for (final template in seedTemplates) {
        final task = template.toTodoItem(userId, dueTime, regenerationBatchId: batchId);
        
        print('      ✏️  Creating task: ${task.title}');
        
        // Create in Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('todos')
            .doc(task.id)
            .set(task.toFirestore());
        
        print('      ✅ Saved to Firestore: ${task.id}');
        
        tasks.add(task);
        taskIds.add(task.id);
      }
      
      // Log the regeneration
      print('      📝 Logging regeneration...');
      await _logRegeneration(
        userId: userId,
        seedsDate: today.toIso8601String().split('T')[0],
        generatedTaskIds: taskIds,
      );
      print('      ✅ Regeneration logged');
      
      print('✅ Generated ${tasks.length} seeds for $userId');
      return tasks;
    } catch (e) {
      print('❌ Error generating seeds: $e');
      return [];
    }
  }

  /// Delete all incomplete seeds before generating new ones
  Future<void> _deleteIncompleteSeedsBeforeGeneration(String userId) async {
    try {
      final allTodos = await _todoService.getUserTodos(userId);
      
      int deletedCount = 0;
      for (final todo in allTodos) {
        // Delete if it's a seed, incomplete, and from a previous batch
        if (todo.isSeed && !todo.isCompleted) {
          await _todoService.deleteTodoForUser(userId, todo.id);
          print('         🗑️  Deleted old seed: "${todo.title}" (ID: ${todo.id})');
          deletedCount++;
        }
      }
      
      if (deletedCount == 0) {
        print('         ℹ️  No old seeds to delete');
      } else {
        print('         ✅ Deleted $deletedCount old seeds');
      }
    } catch (e) {
      print('         ❌ Error deleting incomplete seeds: $e');
    }
  }

  /// Delete all incomplete growth tasks before generating new ones
  Future<void> _deleteIncompleteGrowthTasksBeforeGeneration(String userId) async {
    try {
      final allTodos = await _todoService.getUserTodos(userId);
      
      int deletedCount = 0;
      for (final todo in allTodos) {
        // Delete if it's a growth task, incomplete, and from a previous batch
        if (todo.isGrowthTask && !todo.isCompleted) {
          await _todoService.deleteTodoForUser(userId, todo.id);
          print('         🗑️  Deleted old growth task: "${todo.title}" (ID: ${todo.id})');
          deletedCount++;
        }
      }
      
      if (deletedCount == 0) {
        print('         ℹ️  No old growth tasks to delete');
      } else {
        print('         ✅ Deleted $deletedCount old growth tasks');
      }
    } catch (e) {
      print('         ❌ Error deleting incomplete growth tasks: $e');
    }
  }

  /// Generate Growth Tasks for this week
  Future<List<TodoItem>> generateGrowthTasks(String userId) async {
    try {
      final now = DateTime.now();
      final weekNumber = _getISOWeekNumber(now);
      final year = now.year;
      
      print('      📈 Starting growth task generation...');
      print('      Week number: $weekNumber, Year: $year');
      
      // First, delete all previous incomplete growth tasks
      print('      🧹 Deleting old incomplete growth tasks...');
      await _deleteIncompleteGrowthTasksBeforeGeneration(userId);
      
      // Calculate due dates spread across the week
      final monday = _getMonday(now);
      final dueDates = [
        DateTime(monday.year, monday.month, monday.day, 19, 0), // Monday
        DateTime(monday.year, monday.month, monday.day + 2, 19, 0), // Wednesday
        DateTime(monday.year, monday.month, monday.day + 4, 19, 0), // Friday
      ];
      
      print('      📅 Week starts Monday: ${monday.toIso8601String()}');
      print('      Due dates: ${dueDates.map((d) => d.toIso8601String()).toList()}');
      
      // Get growth task templates
      final growthTemplates = TaskTemplatesData.getRandomGrowthTasks(count: 2);
      print('      📋 Selected ${growthTemplates.length} growth task templates');
      
      // Generate batch ID
      final batchId = 'growth_w${weekNumber}_${year}_${now.millisecondsSinceEpoch}';
      print('      🏷️  Batch ID: $batchId');
      
      // Create TodoItems from templates
      final tasks = <TodoItem>[];
      final taskIds = <String>[];
      
      for (var i = 0; i < growthTemplates.length; i++) {
        final template = growthTemplates[i];
        final dueDate = dueDates[i % dueDates.length];
        final task = template.toTodoItem(userId, dueDate, regenerationBatchId: batchId);
        
        print('      ✏️  Creating task: ${task.title} (due: ${dueDate.toIso8601String()})');
        
        // Create in Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('todos')
            .doc(task.id)
            .set(task.toFirestore());
        
        print('      ✅ Saved to Firestore: ${task.id}');
        
        tasks.add(task);
        taskIds.add(task.id);
      }
      
      // Log the regeneration
      print('      📝 Logging regeneration...');
      await _logRegeneration(
        userId: userId,
        growthWeek: weekNumber,
        growthYear: year,
        generatedTaskIds: taskIds,
      );
      print('      ✅ Regeneration logged');
      
      print('✅ Generated ${tasks.length} growth tasks for $userId');
      return tasks;
    } catch (e) {
      print('❌ Error generating growth tasks: $e');
      return [];
    }
  }

  /// Clean up expired tasks
  Future<void> cleanupExpiredTasks(String userId) async {
    try {
      final now = DateTime.now();
      final allTodos = await _todoService.getUserTodos(userId);
      
      int deletedCount = 0;
      for (final todo in allTodos) {
        // Skip completed tasks
        if (todo.isCompleted) continue;
        
        // Check if task should be auto-deleted
        if (todo.autoDeleteDate != null && now.isAfter(todo.autoDeleteDate!)) {
          await _todoService.deleteTodoForUser(userId, todo.id);
          print('   🗑️  Auto-deleted expired task: "${todo.title}"');
          deletedCount++;
        }
      }
      
      if (deletedCount == 0) {
        print('   ℹ️  No expired tasks to delete');
      } else {
        print('   ✅ Deleted $deletedCount expired tasks');
      }
    } catch (e) {
      print('   ❌ Error cleaning up expired tasks: $e');
    }
  }

  /// Get last regeneration log
  /// Checks in-memory cache first, then Firestore
  Future<RegenerationLog?> getLastRegeneration(String userId) async {
    try {
      // Check in-memory cache first
      if (_lastRegenerationCache.containsKey(userId)) {
        print('   ✅ Found regeneration log in memory cache');
        final cachedLog = _lastRegenerationCache[userId]!;
        print('   Cache details: regeneratedAt=${cachedLog.regeneratedAt}, seedsDate=${cachedLog.seedsDate}, growthWeek=${cachedLog.growthWeek}');
        return cachedLog;
      }
      
      print('   No cache found, querying Firestore...');
      print('   Path: users/$userId/regenerationLog');
      
      QuerySnapshot<Map<String, dynamic>>? querySnapshot;
      
      try {
        // Try with orderBy first with a timeout to prevent hanging on recently deleted accounts
        querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('regenerationLog')
            .orderBy('regeneratedAt', descending: true)
            .limit(1)
            .get()
            .timeout(
              const Duration(seconds: 3),
              onTimeout: () {
                print('   ⏱️  OrderBy query timed out after 3 seconds');
                throw TimeoutException('Query timed out');
              },
            );
        
        print('   Query with orderBy completed - returned ${querySnapshot.docs.length} document(s)');
      } catch (orderByError) {
        print('   ⚠️  OrderBy query failed: $orderByError');
        
        // Only try fallback if it's not a timeout
        if (orderByError is! TimeoutException) {
          print('   Falling back to getting all documents and sorting manually...');
          
          try {
            // Fallback: get all documents and sort manually (with timeout)
            querySnapshot = await _firestore
                .collection('users')
                .doc(userId)
                .collection('regenerationLog')
                .get()
                .timeout(
                  const Duration(seconds: 3),
                  onTimeout: () {
                    print('   ⏱️  Fallback query timed out after 3 seconds');
                    throw TimeoutException('Fallback query timed out');
                  },
                );
            
            print('   Retrieved ${querySnapshot.docs.length} documents for manual sorting');
          } catch (fallbackError) {
            print('   ❌ Fallback query also failed: $fallbackError');
            print('   Returning null - will regenerate tasks as if this is a new account');
            return null;
          }
        } else {
          print('   Timeout occurred - returning null to trigger regeneration');
          return null;
        }
      }
      
      if (querySnapshot.docs.isEmpty) {
        print('   ❌ No documents found in regenerationLog collection');
        return null;
      }
      
      // If we have multiple docs (from fallback), find the most recent one
      DocumentSnapshot<Map<String, dynamic>> latestDoc;
      if (querySnapshot.docs.length == 1) {
        latestDoc = querySnapshot.docs.first;
      } else {
        // Sort manually by regeneratedAt
        final sortedDocs = querySnapshot.docs.toList()..sort((a, b) {
          final aData = a.data();
          final bData = b.data();
          final aTime = _getTimestampValue(aData['regeneratedAt']);
          final bTime = _getTimestampValue(bData['regeneratedAt']);
          return bTime.compareTo(aTime); // descending
        });
        latestDoc = sortedDocs.first;
        print('   Manually sorted ${sortedDocs.length} documents, selected most recent');
      }
      
      print('   Found document ID: ${latestDoc.id}');
      print('   Document data: ${latestDoc.data()}');
      
      final log = RegenerationLog.fromFirestore(latestDoc);
      print('   ✅ Successfully parsed regeneration log from Firestore');
      print('   Log details: regeneratedAt=${log.regeneratedAt}, seedsDate=${log.seedsDate}, growthWeek=${log.growthWeek}');
      
      // Cache it for future checks
      _lastRegenerationCache[userId] = log;
      print('   💾 Cached regeneration log in memory');
      
      return log;
    } catch (e, stackTrace) {
      print('   ❌ Error getting last regeneration: $e');
      print('   Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// Helper to get timestamp value for sorting
  int _getTimestampValue(dynamic value) {
    if (value == null) return 0;
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  /// Log a regeneration event
  Future<void> _logRegeneration({
    required String userId,
    String? seedsDate,
    int? growthWeek,
    int? growthYear,
    required List<String> generatedTaskIds,
  }) async {
    try {
      print('   Creating regeneration log entry...');
      final now = DateTime.now();
      
      // If we already have a cached log from today, merge with it
      final existingCache = _lastRegenerationCache[userId];
      final isSameDay = existingCache != null && 
          existingCache.regeneratedAt.year == now.year &&
          existingCache.regeneratedAt.month == now.month &&
          existingCache.regeneratedAt.day == now.day;
      
      final log = RegenerationLog(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        regeneratedAt: now,
        // Merge with existing if from today, otherwise use new values
        seedsDate: seedsDate ?? (isSameDay ? existingCache.seedsDate : null),
        growthWeek: growthWeek ?? (isSameDay ? existingCache.growthWeek : null),
        growthYear: growthYear ?? (isSameDay ? existingCache.growthYear : null),
        generatedTaskIds: generatedTaskIds,
      );
      
      print('   Log data to be saved:');
      print('      - regeneratedAt: ${log.regeneratedAt}');
      print('      - seedsDate: $seedsDate');
      print('      - growthWeek: $growthWeek');
      print('      - growthYear: $growthYear');
      print('      - taskIds: ${generatedTaskIds.length} tasks');
      
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('regenerationLog')
          .add(log.toFirestore());
      
      print('   ✅ Regeneration log saved to Firestore with ID: ${docRef.id}');
      print('   Path: users/$userId/regenerationLog/${docRef.id}');
      
      // IMPORTANT: Update the in-memory cache immediately
      // This prevents race conditions on the next check
      final cachedLog = log.copyWith(id: docRef.id);
      _lastRegenerationCache[userId] = cachedLog;
      print('   💾 Updated in-memory cache with new regeneration log');
      
      // Update user document with regeneration info for fast lookups
      await _updateUserRegenerationInfo(
        userId: userId,
        seedsDate: log.seedsDate,
        growthWeek: log.growthWeek,
        growthYear: log.growthYear,
      );
      
      // Verify the write by reading it back
      final verification = await docRef.get();
      if (verification.exists) {
        print('   ✅ Verified: Document exists in Firestore');
      } else {
        print('   ⚠️  Warning: Document not found immediately after write');
      }
    } catch (e, stackTrace) {
      print('   ❌ Error logging regeneration: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Update user document with latest regeneration timestamps
  /// This enables fast lookups via the user document instead of querying the regenerationLog collection
  Future<void> _updateUserRegenerationInfo({
    required String userId,
    String? seedsDate,
    int? growthWeek,
    int? growthYear,
  }) async {
    try {
      final updates = <String, dynamic>{};
      
      if (seedsDate != null) {
        updates['lastSeedsGeneratedDate'] = seedsDate;
        updates['lastSeedsGeneratedAt'] = DateTime.now().millisecondsSinceEpoch;
        print('   📝 Updating user doc with seeds info: $seedsDate');
      }
      
      if (growthWeek != null) {
        updates['lastGrowthWeek'] = growthWeek;
        updates['lastGrowthYear'] = growthYear;
        updates['lastGrowthTasksGeneratedAt'] = DateTime.now().millisecondsSinceEpoch;
        print('   📝 Updating user doc with growth week: $growthWeek/$growthYear');
      }
      
      if (updates.isEmpty) return;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);
      
      print('   ✅ User document updated successfully');
    } catch (e) {
      print('   ⚠️  Warning: Could not update user document: $e');
      // Don't throw - this is optional for backwards compatibility
    }
  }

  /// Check if Seeds need regeneration
  /// Compares ONLY the date (not time) - regenerates if the date has changed
  bool _seedsNeedRegeneration(RegenerationLog? lastLog) {
    print('   Checking if seeds need regeneration...');
    
    if (lastLog == null) {
      print('   ❌ No regeneration log exists - REGENERATE SEEDS');
      return true;
    }
    
    if (lastLog.seedsDate == null) {
      print('   ❌ No seedsDate in log - REGENERATE SEEDS');
      return true;
    }
    
    try {
      final lastDate = DateTime.parse(lastLog.seedsDate!);
      final today = DateTime.now();
      
      print('   📅 Comparing dates (ignoring time):');
      print('      Last seeds generated: ${lastLog.seedsDate}');
      print('      Today: ${today.toString().split(' ')[0]}');
      
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      final isSameDay = lastDateOnly.isAtSameMomentAs(todayOnly);
      print('      Same day? $isSameDay');
      
      final needsRegen = !isSameDay;
      print('   ${needsRegen ? '✅ Will regenerate' : '⏭️  No regeneration needed'}: Date ${needsRegen ? 'changed' : 'unchanged'}');
      
      return needsRegen;
    } catch (e) {
      print('   ❌ Error parsing date: $e - REGENERATE SEEDS');
      return true; // Regenerate if there's an error
    }
  }

  /// Check if Growth Tasks need regeneration
  /// Compares week number and year - regenerates if the week has changed
  bool _growthTasksNeedRegeneration(RegenerationLog? lastLog) {
    print('   Checking if growth tasks need regeneration...');
    
    if (lastLog == null) {
      print('   ❌ No regeneration log exists - REGENERATE GROWTH TASKS');
      return true;
    }
    
    if (lastLog.growthWeek == null) {
      print('   ❌ No growthWeek in log - REGENERATE GROWTH TASKS');
      return true;
    }
    
    try {
      final currentWeek = _getISOWeekNumber(DateTime.now());
      final currentYear = DateTime.now().year;
      
      print('   📅 Comparing weeks:');
      print('      Last growth week: ${lastLog.growthWeek} (year: ${lastLog.growthYear})');
      print('      Current week: $currentWeek (year: $currentYear)');
      
      final weekMatch = lastLog.growthWeek == currentWeek;
      final yearMatch = lastLog.growthYear == currentYear;
      
      print('      Week match? $weekMatch');
      print('      Year match? $yearMatch');
      
      final needsRegen = !weekMatch || !yearMatch;
      print('   ${needsRegen ? '✅ Will regenerate' : '⏭️  No regeneration needed'}: Week ${needsRegen ? 'changed' : 'unchanged'}');
      
      return needsRegen;
    } catch (e) {
      print('   ❌ Error comparing weeks: $e - REGENERATE GROWTH TASKS');
      return true; // Regenerate if there's an error
    }
  }

  /// Get ISO week number
  int _getISOWeekNumber(DateTime date) {
    // ISO week numbering logic
    final jan4 = DateTime(date.year, 1, 4);
    final startOfYear = jan4.subtract(Duration(days: jan4.weekday - 1));
    final diffDays = date.difference(startOfYear).inDays;
    return (diffDays / 7).floor() + 1;
  }

  /// Get Monday of current week
  DateTime _getMonday(DateTime date) {
    final daysToSubtract = date.weekday - 1; // Monday is 1
    return date.subtract(Duration(days: daysToSubtract));
  }

  /// Check if seeds already exist for today
  Future<bool> _existingSeedsForTodayExist(String userId) async {
    try {
      // Add timeout to prevent hanging on recently deleted accounts
      final allTodos = await _todoService.getUserTodos(userId).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('   ⏱️  getUserTodos timed out - assuming no seeds exist');
          return <TodoItem>[];
        },
      );
      
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];
      
      final todaySeeds = allTodos.where((todo) {
        return todo.isSeed && 
               !todo.isCompleted && 
               todo.regenerationBatchId != null &&
               todo.regenerationBatchId!.contains(todayString);
      }).toList();
      
      print('   Found ${todaySeeds.length} existing seeds for today');
      return todaySeeds.isNotEmpty;
    } catch (e) {
      print('   ⚠️  Error checking existing seeds: $e');
      return false;
    }
  }

  /// Check if growth tasks already exist for this week
  Future<bool> _existingGrowthTasksForThisWeekExist(String userId) async {
    try {
      // Add timeout to prevent hanging on recently deleted accounts
      final allTodos = await _todoService.getUserTodos(userId).timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          print('   ⏱️  getUserTodos timed out - assuming no growth tasks exist');
          return <TodoItem>[];
        },
      );
      
      final now = DateTime.now();
      final weekNumber = _getISOWeekNumber(now);
      
      final thisWeekGrowthTasks = allTodos.where((todo) {
        return todo.isGrowthTask && 
               !todo.isCompleted && 
               todo.regenerationBatchId != null &&
               todo.regenerationBatchId!.contains('growth_w$weekNumber');
      }).toList();
      
      print('   Found ${thisWeekGrowthTasks.length} existing growth tasks for week $weekNumber');
      return thisWeekGrowthTasks.isNotEmpty;
    } catch (e) {
      print('   ⚠️  Error checking existing growth tasks: $e');
      return false;
    }
  }

  /// Check if today is the user's first day
  /// Compares the user's createdAt date with today's date
  Future<bool> _isUserFirstDay(String userId) async {
    try {
      print('      🔍 Checking if user is on their first day...');
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        print('      ⚠️  User document not found');
        return false;
      }
      
      final createdAtValue = userDoc.get('createdAt');
      DateTime? createdAt;
      
      // Handle different timestamp formats
      if (createdAtValue is Timestamp) {
        createdAt = createdAtValue.toDate();
      } else if (createdAtValue is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
      } else if (createdAtValue is double) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue.toInt());
      }
      
      if (createdAt == null) {
        print('      ⚠️  Could not parse createdAt field');
        return false;
      }
      
      // Compare dates only (ignore time)
      final createdDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      final isFirstDay = createdDate.isAtSameMomentAs(todayDate);
      
      print('      📅 Created date: ${createdDate.toIso8601String().split('T')[0]}');
      print('      📅 Today: ${todayDate.toIso8601String().split('T')[0]}');
      print('      ${isFirstDay ? '🌟 This is user\'s FIRST DAY!' : '✅ Not first day'}');
      
      return isFirstDay;
    } catch (e) {
      print('      ❌ Error checking first day: $e');
      return false; // Default to false if error
    }
  }

  /// Initialize mastery quests for a user
  Future<List<TodoItem>> initializeMasteryQuests(String userId, {
    required int currentStage,
    required int currentExp,
    required int journalStreakDays,
    required int totalExercisesCompleted,
  }) async {
    try {
      // Get relevant mastery quests
      final masteryTemplates = TaskTemplatesData.getMasteryQuestsForUser(
        currentStage: currentStage,
        currentExp: currentExp,
        journalStreakDays: journalStreakDays,
        totalExercisesCompleted: totalExercisesCompleted,
      );
      
      // Check which ones already exist
      final existingTodos = await _todoService.getUserTodos(userId);
      final existingTemplateIds = existingTodos
          .where((todo) => todo.templateId != null)
          .map((todo) => todo.templateId!)
          .toSet();
      
      // Filter out existing quests
      final newTemplates = masteryTemplates
          .where((template) => !existingTemplateIds.contains(template.id))
          .toList();
      
      if (newTemplates.isEmpty) {
        return [];
      }
      
      // Create TodoItems from templates
      final tasks = <TodoItem>[];
      final now = DateTime.now();
      final farFuture = DateTime(now.year + 1, now.month, now.day); // 1 year in future
      
      for (final template in newTemplates) {
        final task = template.toTodoItem(userId, farFuture);
        
        // Create in Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('todos')
            .doc(task.id)
            .set(task.toFirestore());
        
        tasks.add(task);
      }
      
      print('Initialized ${tasks.length} mastery quests for $userId');
      return tasks;
    } catch (e) {
      print('Error initializing mastery quests: $e');
      return [];
    }
  }

  /// Force regenerate all tasks (for testing or manual trigger)
  Future<Map<String, List<TodoItem>>> forceRegenerateAll(String userId) async {
    try {
      // Clean up existing auto-generated tasks
      await _cleanupAutoGeneratedTasks(userId);
      
      // Generate new tasks
      final seeds = await generateSeeds(userId);
      final growthTasks = await generateGrowthTasks(userId);
      
      return {
        'seeds': seeds,
        'growthTasks': growthTasks,
      };
    } catch (e) {
      print('Error force regenerating tasks: $e');
      return {'seeds': [], 'growthTasks': []};
    }
  }

  /// Clean up auto-generated tasks
  Future<void> _cleanupAutoGeneratedTasks(String userId) async {
    try {
      final allTodos = await _todoService.getUserTodos(userId);
      
      for (final todo in allTodos) {
        // Delete if it's a seed or growth task (has regenerationBatchId)
        if (todo.regenerationBatchId != null && !todo.isCompleted) {
          await _todoService.deleteTodoForUser(userId, todo.id);
        }
      }
    } catch (e) {
      print('Error cleaning up auto-generated tasks: $e');
    }
  }

  /// Clear the in-memory cache of regeneration logs
  void clearCache() {
    _lastRegenerationCache.clear();
    print('In-memory regeneration cache cleared.');
  }
}

