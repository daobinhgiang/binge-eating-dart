import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/todo_item.dart';
import '../../models/regeneration_log.dart';
import '../../data/task_templates.dart';
import 'todo_service.dart';

class TaskRegenerationService {
  static final TaskRegenerationService _instance = TaskRegenerationService._internal();
  factory TaskRegenerationService() => _instance;
  TaskRegenerationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TodoService _todoService = TodoService();
  
  // Session-level cache: Maps userId -> last regeneration check timestamp
  // This prevents duplicate regeneration checks within the same session
  final Map<String, DateTime> _lastRegenerationCheck = {};
  final Duration _regenerationCheckCooldown = const Duration(minutes: 5);
 
  /// Check and regenerate tasks if needed
  /// Returns: List of newly generated tasks
  Future<List<TodoItem>> checkAndRegenerateTasks(String userId) async {
    try {
      print('\n═══════════════════════════════════════════════════════════');
      print('🔍 REGENERATION CHECK STARTED for userId: $userId');
      print('═══════════════════════════════════════════════════════════');
      
      // Prevent duplicate checks within 5 minutes (session cache)
      final lastCheck = _lastRegenerationCheck[userId];
      final now = DateTime.now();
      print('⏰ Current time: $now');
      print('💾 Last check time: $lastCheck');
      
      if (lastCheck != null && DateTime.now().difference(lastCheck).inMinutes < _regenerationCheckCooldown.inMinutes) {
        final minutesAgo = DateTime.now().difference(lastCheck).inMinutes;
        print('⏭️  SKIPPING - Already checked $minutesAgo minutes ago (< 5 min cooldown)');
        print('═══════════════════════════════════════════════════════════\n');
        return [];
      }
      
      // Update last check time
      _lastRegenerationCheck[userId] = DateTime.now();
      print('✅ Session cache updated - proceeding with regeneration check');
      
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

      // Check if Seeds need regeneration (daily)
      print('\n🌱 CHECKING SEEDS...');
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

      // Check if Growth Tasks need regeneration (weekly)
      print('\n📈 CHECKING GROWTH TASKS...');
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

      // Clean up expired tasks
      print('\n🧹 CLEANING UP EXPIRED TASKS...');
      await cleanupExpiredTasks(userId);

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
      
      // Get seed templates
      final seedTemplates = TaskTemplatesData.getRandomSeeds(count: 3);
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
  Future<RegenerationLog?> getLastRegeneration(String userId) async {
    try {
      print('   Querying regenerationLog collection...');
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('regenerationLog')
          .orderBy('regeneratedAt', descending: true)
          .limit(1)
          .get();
      
      print('   Query returned ${querySnapshot.docs.length} document(s)');
      
      if (querySnapshot.docs.isEmpty) {
        print('   ❌ No documents found in regenerationLog');
        return null;
      }
      
      final log = RegenerationLog.fromFirestore(querySnapshot.docs.first);
      print('   ✅ Found regeneration log');
      return log;
    } catch (e) {
      print('   ❌ Error getting last regeneration: $e');
      return null;
    }
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
      final log = RegenerationLog(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        regeneratedAt: DateTime.now(),
        seedsDate: seedsDate,
        growthWeek: growthWeek,
        growthYear: growthYear,
        generatedTaskIds: generatedTaskIds,
      );
      
      print('   Log data:');
      print('      - seedsDate: $seedsDate');
      print('      - growthWeek: $growthWeek');
      print('      - growthYear: $growthYear');
      print('      - taskIds: ${generatedTaskIds.length} tasks');
      
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('regenerationLog')
          .add(log.toFirestore());
      
      print('   ✅ Regeneration log saved to Firestore');
    } catch (e) {
      print('   ❌ Error logging regeneration: $e');
    }
  }

  /// Check if Seeds need regeneration
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
      
      print('   📅 Comparing dates:');
      print('      Last seeds generated: ${lastLog.seedsDate} ($lastDate)');
      print('      Today: ${today.toString().split(' ')[0]}');
      
      final lastDateOnly = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final todayOnly = DateTime(today.year, today.month, today.day);
      
      print('      Last date only: $lastDateOnly');
      print('      Today only: $todayOnly');
      
      final isSameDay = lastDateOnly.isAtSameMomentAs(todayOnly);
      print('      Same day? $isSameDay');
      
      final needsRegen = !isSameDay;
      print('   ${needsRegen ? '❌' : '✅'} Needs regeneration: $needsRegen');
      
      return needsRegen;
    } catch (e) {
      print('   ❌ Error parsing date: $e - REGENERATE SEEDS');
      return true; // Regenerate if there's an error
    }
  }

  /// Check if Growth Tasks need regeneration
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
      print('   ${needsRegen ? '❌' : '✅'} Needs regeneration: $needsRegen');
      
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
}

