import '../models/task_template.dart';

/// Bundled task templates for the quest system
/// These templates define the structure of auto-generated quests
class TaskTemplatesData {
  /// Get all default seed templates (Daily tasks)
  static List<TaskTemplate> getDefaultSeeds() {
    final now = DateTime.now();
    
    return [
      // Journal Seeds
      TaskTemplate(
        id: 'seed_journal_food_diary',
        category: 'journaling',
        tier: TaskTier.seeds,
        title: 'Complete Today\'s Food Diary',
        description: 'Record your meals and reflections for today',
        activityId: 'food_diary',
        expReward: 50,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'type': 'food_diary',
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'seed_journal_body_image',
        category: 'journaling',
        tier: TaskTier.seeds,
        title: 'Reflect on Body Image',
        description: 'Take a moment to journal about your body image today',
        activityId: 'body_image_diary',
        expReward: 50,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'type': 'body_image_diary',
          'priority': 2,
        },
      ),
      TaskTemplate(
        id: 'seed_journal_weight',
        category: 'journaling',
        tier: TaskTier.seeds,
        title: 'Log Your Weight',
        description: 'Record your weight if you feel comfortable',
        activityId: 'weight_diary',
        expReward: 30,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'type': 'weight_diary',
          'priority': 3,
        },
      ),
      
      // Exercise/Tool Seeds
      TaskTemplate(
        id: 'seed_tool_coping',
        category: 'exercises',
        tier: TaskTier.seeds,
        title: 'Practice a Coping Strategy',
        description: 'Use one of your recovery tools today',
        activityId: 'coping_strategies',
        expReward: 60,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'toolType': 'coping',
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'seed_tool_mindfulness',
        category: 'exercises',
        tier: TaskTier.seeds,
        title: 'Mindfulness Exercise',
        description: 'Take 5 minutes for mindful breathing or body scan',
        activityId: 'mindfulness_exercise',
        expReward: 50,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'toolType': 'mindfulness',
          'priority': 2,
        },
      ),
    ];
  }

  /// Get all default growth task templates (Weekly tasks)
  static List<TaskTemplate> getDefaultGrowthTasks() {
    final now = DateTime.now();
    
    return [
      // Lesson Growth Tasks
      TaskTemplate(
        id: 'growth_lesson_complete_section',
        category: 'lessons',
        tier: TaskTier.growthTasks,
        title: 'Complete This Week\'s Lesson',
        description: 'Work through your current lesson section',
        activityId: '', // Will be dynamically set based on user progress
        expReward: 200,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'dynamic': true,
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'growth_lesson_review',
        category: 'lessons',
        tier: TaskTier.growthTasks,
        title: 'Review Previous Lessons',
        description: 'Revisit key concepts from earlier chapters',
        activityId: '', // Dynamic
        expReward: 150,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'dynamic': true,
          'priority': 3,
        },
      ),
      
      // Quiz Growth Tasks
      TaskTemplate(
        id: 'growth_quiz_assessment',
        category: 'exercises',
        tier: TaskTier.growthTasks,
        title: 'Complete Assessment Quiz',
        description: 'Test your understanding with this week\'s quiz',
        activityId: '', // Dynamic based on current chapter
        expReward: 250,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'toolType': 'quiz',
          'dynamic': true,
          'priority': 2,
        },
      ),
      
      // Major Exercise Growth Tasks
      TaskTemplate(
        id: 'growth_exercise_problem_solving',
        category: 'exercises',
        tier: TaskTier.growthTasks,
        title: 'Problem-Solving Exercise',
        description: 'Practice structured problem-solving techniques',
        activityId: 'problem_solving',
        expReward: 200,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'toolType': 'problem_solving',
          'priority': 2,
        },
      ),
      TaskTemplate(
        id: 'growth_exercise_meal_planning',
        category: 'exercises',
        tier: TaskTier.growthTasks,
        title: 'Meal Planning Exercise',
        description: 'Create a structured meal plan for the week',
        activityId: 'meal_planning',
        expReward: 200,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'toolType': 'meal_planning',
          'priority': 3,
        },
      ),
      
      // Weekly Reflection
      TaskTemplate(
        id: 'growth_journal_weekly_reflection',
        category: 'journaling',
        tier: TaskTier.growthTasks,
        title: 'Weekly Reflection',
        description: 'Reflect on your progress this week',
        activityId: 'weekly_reflection',
        expReward: 150,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'type': 'reflection',
          'priority': 4,
        },
      ),
    ];
  }

  /// Get all default mastery quest templates (Persistent tasks)
  static List<TaskTemplate> getDefaultMasteryQuests() {
    final now = DateTime.now();
    
    return [
      // Stage Completion Quests
      TaskTemplate(
        id: 'mastery_stage1_complete',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Complete All Stage 1 Lessons',
        description: 'Finish every lesson in Stage 1',
        activityId: 'stage_1_completion',
        expReward: 1000,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'stage': 1,
          'trackable': true,
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'mastery_stage2_complete',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Complete All Stage 2 Lessons',
        description: 'Finish every lesson in Stage 2',
        activityId: 'stage_2_completion',
        expReward: 1500,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'stage': 2,
          'trackable': true,
          'priority': 2,
        },
      ),
      TaskTemplate(
        id: 'mastery_stage3_complete',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Complete All Stage 3 Lessons',
        description: 'Finish every lesson in Stage 3',
        activityId: 'stage_3_completion',
        expReward: 2000,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'stage': 3,
          'trackable': true,
          'priority': 3,
        },
      ),
      
      // Streak Quests
      TaskTemplate(
        id: 'mastery_journal_streak_7',
        category: 'journaling',
        tier: TaskTier.masteryQuests,
        title: 'Maintain 7-Day Journal Streak',
        description: 'Journal for 7 consecutive days',
        activityId: 'journal_streak_7',
        expReward: 500,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'streakType': 'journal',
          'streakTarget': 7,
          'trackable': true,
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'mastery_journal_streak_30',
        category: 'journaling',
        tier: TaskTier.masteryQuests,
        title: 'Maintain 30-Day Journal Streak',
        description: 'Journal for 30 consecutive days',
        activityId: 'journal_streak_30',
        expReward: 1500,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'streakType': 'journal',
          'streakTarget': 30,
          'trackable': true,
          'priority': 2,
        },
      ),
      
      // EXP Milestone Quests
      TaskTemplate(
        id: 'mastery_exp_1000',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Earn 1,000 EXP',
        description: 'Reach 1,000 total experience points',
        activityId: 'exp_milestone_1000',
        expReward: 500,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'milestoneType': 'exp',
          'milestoneTarget': 1000,
          'trackable': true,
          'priority': 1,
        },
      ),
      TaskTemplate(
        id: 'mastery_exp_5000',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Earn 5,000 EXP',
        description: 'Reach 5,000 total experience points',
        activityId: 'exp_milestone_5000',
        expReward: 1000,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'milestoneType': 'exp',
          'milestoneTarget': 5000,
          'trackable': true,
          'priority': 2,
        },
      ),
      TaskTemplate(
        id: 'mastery_exp_10000',
        category: 'lessons',
        tier: TaskTier.masteryQuests,
        title: 'Earn 10,000 EXP',
        description: 'Reach 10,000 total experience points',
        activityId: 'exp_milestone_10000',
        expReward: 2000,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'milestoneType': 'exp',
          'milestoneTarget': 10000,
          'trackable': true,
          'priority': 3,
        },
      ),
      
      // Exercise Completion Quests
      TaskTemplate(
        id: 'mastery_exercises_10',
        category: 'exercises',
        tier: TaskTier.masteryQuests,
        title: 'Complete 10 Exercises',
        description: 'Finish 10 different recovery exercises',
        activityId: 'exercises_milestone_10',
        expReward: 500,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'milestoneType': 'exercises',
          'milestoneTarget': 10,
          'trackable': true,
          'priority': 2,
        },
      ),
      TaskTemplate(
        id: 'mastery_exercises_25',
        category: 'exercises',
        tier: TaskTier.masteryQuests,
        title: 'Complete 25 Exercises',
        description: 'Finish 25 different recovery exercises',
        activityId: 'exercises_milestone_25',
        expReward: 1000,
        createdAt: now,
        updatedAt: now,
        metadata: {
          'milestoneType': 'exercises',
          'milestoneTarget': 25,
          'trackable': true,
          'priority': 3,
        },
      ),
    ];
  }

  /// Get seed templates based on user's current stage
  static List<TaskTemplate> getSeedsForStage(int stage) {
    // For now, return all seeds
    // In future, filter based on stage progression
    return getDefaultSeeds();
  }

  /// Get growth tasks based on user's current chapter
  static List<TaskTemplate> getGrowthTasksForChapter(int stage, int chapter) {
    // For now, return all growth tasks
    // In future, customize based on chapter content
    return getDefaultGrowthTasks();
  }

  /// Get mastery quests based on user's progress
  static List<TaskTemplate> getMasteryQuestsForUser({
    required int currentStage,
    required int currentExp,
    required int journalStreakDays,
    required int totalExercisesCompleted,
  }) {
    final allQuests = getDefaultMasteryQuests();
    final relevantQuests = <TaskTemplate>[];

    for (final quest in allQuests) {
      // Filter out completed stages
      if (quest.metadata?['stage'] != null) {
        final stageNum = quest.metadata!['stage'] as int;
        if (stageNum <= currentStage + 1) {
          // Show current and next stage quests
          relevantQuests.add(quest);
        }
        continue;
      }

      // Filter EXP milestones
      if (quest.metadata?['milestoneType'] == 'exp') {
        final target = quest.metadata!['milestoneTarget'] as int;
        if (currentExp < target && target <= currentExp * 3) {
          // Show achievable milestones
          relevantQuests.add(quest);
        }
        continue;
      }

      // Filter journal streaks
      if (quest.metadata?['streakType'] == 'journal') {
        final target = quest.metadata!['streakTarget'] as int;
        if (journalStreakDays < target && target <= journalStreakDays + 30) {
          relevantQuests.add(quest);
        }
        continue;
      }

      // Filter exercise milestones
      if (quest.metadata?['milestoneType'] == 'exercises') {
        final target = quest.metadata!['milestoneTarget'] as int;
        if (totalExercisesCompleted < target) {
          relevantQuests.add(quest);
        }
        continue;
      }

      // Include any unfiltered quests
      relevantQuests.add(quest);
    }

    return relevantQuests;
  }

  /// Get a random selection of seed templates
  static List<TaskTemplate> getRandomSeeds({int count = 3}) {
    final seeds = getDefaultSeeds();
    seeds.shuffle();
    return seeds.take(count).toList();
  }

  /// Get a random selection of growth task templates
  static List<TaskTemplate> getRandomGrowthTasks({int count = 2}) {
    final growthTasks = getDefaultGrowthTasks();
    growthTasks.shuffle();
    return growthTasks.take(count).toList();
  }
}

