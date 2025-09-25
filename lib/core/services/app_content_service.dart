import 'package:cloud_firestore/cloud_firestore.dart';

class AppContentService {
  static final AppContentService _instance = AppContentService._internal();
  factory AppContentService() => _instance;
  AppContentService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for app content
  String? _cachedAppContent;
  DateTime? _cacheTimestamp;
  static const Duration _cacheTimeout = Duration(hours: 12);

  // Generate context about all app content for OpenAI API
  Future<String> getAppContentContext() async {
    try {
      // Check cache first
      if (_cachedAppContent != null && 
          _cacheTimestamp != null &&
          DateTime.now().difference(_cacheTimestamp!) < _cacheTimeout) {
        return _cachedAppContent!;
      }

      // Define chapters available in the app (these contain the lesson content)
      final chapters = [
        {
          'chapterNumber': 1,
          'title': 'Introduction to Binge Eating Recovery',
          'description': 'Learn the fundamentals of binge eating disorder and how recovery works',
          'tags': ['introduction', 'basics', 'understanding'],
          'firstLessonId': 'lesson_1_1',
        },
        {
          'chapterNumber': 2,
          'title': 'Understanding Binge Eating Disorder',
          'description': 'Deep dive into the causes, triggers, and psychology of binge eating',
          'tags': ['psychology', 'triggers', 'understanding'],
          'firstLessonId': 'lesson_2_1',
        },
        {
          'chapterNumber': 3,
          'title': 'Emotional Foundations',
          'description': 'Build emotional awareness and regulation skills',
          'tags': ['emotions', 'awareness', 'regulation'],
          'firstLessonId': 'lesson_3_1',
        },
        {
          'chapterNumber': 4,
          'title': 'Mindful Eating Basics',
          'description': 'Learn mindful eating principles and practices',
          'tags': ['mindfulness', 'eating', 'awareness'],
          'firstLessonId': 'lesson_4_1',
        },
        {
          'chapterNumber': 5,
          'title': 'Breaking Binge Patterns',
          'description': 'Strategies to interrupt and prevent binge episodes',
          'tags': ['patterns', 'prevention', 'strategies'],
          'firstLessonId': 'lesson_5_1',
        },
        {
          'chapterNumber': 6,
          'title': 'Body Image and Self-Compassion',
          'description': 'Develop a healthier relationship with your body and self',
          'tags': ['body_image', 'self_compassion', 'acceptance'],
          'firstLessonId': 'lesson_6_1',
        },
        {
          'chapterNumber': 7,
          'title': 'Nutrition Without Obsession',
          'description': 'Learn balanced nutrition principles without restriction',
          'tags': ['nutrition', 'balance', 'flexibility'],
          'firstLessonId': 'lesson_7_1',
        },
        {
          'chapterNumber': 8,
          'title': 'Stress and Emotional Regulation',
          'description': 'Master stress management and emotional coping skills',
          'tags': ['stress', 'emotions', 'coping'],
          'firstLessonId': 'lesson_8_1',
        },
        {
          'chapterNumber': 9,
          'title': 'Social and Environmental Factors',
          'description': 'Navigate social situations and environmental triggers',
          'tags': ['social', 'environment', 'triggers'],
          'firstLessonId': 'lesson_9_1',
        },
        {
          'chapterNumber': 10,
          'title': 'Building Sustainable Habits',
          'description': 'Create lasting positive changes in daily life',
          'tags': ['habits', 'sustainability', 'lifestyle'],
          'firstLessonId': 'lesson_10_1',
        },
        {
          'chapterNumber': 11,
          'title': 'Advanced Recovery Strategies',
          'description': 'Advanced techniques for complex recovery challenges',
          'tags': ['advanced', 'strategies', 'complex'],
          'firstLessonId': 'lesson_11_1',
        },
        {
          'chapterNumber': 12,
          'title': 'Relapse Prevention',
          'description': 'Prevent setbacks and maintain long-term recovery',
          'tags': ['relapse', 'prevention', 'maintenance'],
          'firstLessonId': 'lesson_12_1',
        },
      ];

      // Define tools/exercises available in the app (these are hardcoded in the frontend)
      final tools = [
        {
          'id': 'problem_solving',
          'title': 'Problem Solving',
          'description': 'Structured approach to solving challenges and difficulties',
          'type': 'tool',
          'tags': ['cognitive', 'planning', 'coping'],
        },
        {
          'id': 'meal_planning',
          'title': 'Meal Planning',
          'description': 'Plan and organize your meals effectively to support recovery',
          'type': 'tool',
          'tags': ['nutrition', 'planning', 'structure'],
        },
        {
          'id': 'urge_surfing',
          'title': 'Urge Surfing Activities',
          'description': 'Learn to ride out urges and cravings without acting on them',
          'type': 'tool',
          'tags': ['mindfulness', 'coping', 'urges'],
        },
        {
          'id': 'addressing_overconcern',
          'title': 'Addressing Overconcern',
          'description': 'Work through excessive concerns about weight and body shape',
          'type': 'tool',
          'tags': ['body_image', 'cognitive', 'self_esteem'],
        },
        {
          'id': 'addressing_setbacks',
          'title': 'Addressing Setbacks',
          'description': 'Navigate and learn from recovery setbacks effectively',
          'type': 'tool',
          'tags': ['resilience', 'recovery', 'coping'],
        },
      ];

      // Define exercises (same as tools in this context)
      final exercises = tools.map((tool) => {
        ...tool,
        'type': 'exercise',
        'durationMinutes': 20,
      }).toList();

      // Generate structured content context
      final contentContext = '''
CHAPTERS AVAILABLE (recommend first lesson from relevant chapters):
${chapters.map((chapter) => "- Chapter ${chapter['chapterNumber']}: ${chapter['title']} | Description: ${chapter['description']} | Tags: ${(chapter['tags'] as List<dynamic>).join(', ')} | First Lesson ID: ${chapter['firstLessonId']}").join('\n')}

TOOLS AVAILABLE:
${tools.map((tool) => "- ID: ${tool['id']}, Title: ${tool['title']}, Description: ${tool['description']}, Type: ${tool['type']}, Tags: ${(tool['tags'] as List<dynamic>).join(', ')}").join('\n')}

EXERCISES AVAILABLE:
${exercises.map((exercise) => "- ID: ${exercise['id']}, Title: ${exercise['title']}, Description: ${exercise['description']}, Type: ${exercise['type']}, Tags: ${(exercise['tags'] as List<dynamic>).join(', ')}, Duration: ${exercise['durationMinutes']} minutes").join('\n')}
''';

      // Update cache
      _cachedAppContent = contentContext;
      _cacheTimestamp = DateTime.now();
      
      return contentContext;
    } catch (e) {
      // If there's an error, return a basic context to avoid breaking the app
      return '''
ERROR FETCHING APP CONTENT: $e

BASIC CONTEXT:
CHAPTERS AVAILABLE (recommend first lesson from relevant chapters):
- Chapter 1: Introduction to Binge Eating Recovery | Description: Learn the fundamentals of binge eating disorder and how recovery works | Tags: introduction, basics, understanding | First Lesson ID: lesson_1_1
- Chapter 2: Understanding Binge Eating Disorder | Description: Deep dive into the causes, triggers, and psychology of binge eating | Tags: psychology, triggers, understanding | First Lesson ID: lesson_2_1
- Chapter 4: Mindful Eating Basics | Description: Learn mindful eating principles and practices | Tags: mindfulness, eating, awareness | First Lesson ID: lesson_4_1

TOOLS AVAILABLE:
- ID: problem_solving, Title: Problem Solving, Description: Structured approach to solving challenges and difficulties, Type: tool, Tags: cognitive, planning, coping
- ID: urge_surfing, Title: Urge Surfing Activities, Description: Learn to ride out urges and cravings without acting on them, Type: tool, Tags: mindfulness, coping, urges

EXERCISES AVAILABLE:
- ID: problem_solving, Title: Problem Solving, Description: Structured approach to solving challenges and difficulties, Type: exercise, Tags: cognitive, planning, coping, Duration: 20 minutes
- ID: urge_surfing, Title: Urge Surfing Activities, Description: Learn to ride out urges and cravings without acting on them, Type: exercise, Tags: mindfulness, coping, urges, Duration: 20 minutes
''';
    }
  }

  // Method to clear cache and force refresh of content
  void clearCache() {
    _cachedAppContent = null;
    _cacheTimestamp = null;
  }
}
