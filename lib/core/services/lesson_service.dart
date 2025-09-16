import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/lesson.dart';
import '../../models/lesson_slide.dart';
import '../../models/user_progress.dart';

class LessonService {
  static const String _collectionName = 'lessons';
  static const String _userProgressCollectionName = 'user_progress';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Chapter titles mapping
  static const Map<int, String> _chapterTitles = {
    1: "Introduction to Binge Eating Recovery",
    2: "Understanding Binge Eating Disorder", 
    3: "Emotional Foundations",
    4: "Mindful Eating Basics",
    5: "Breaking Binge Patterns",
    6: "Body Image and Self-Compassion",
    7: "Nutrition Without Obsession",
    8: "Stress and Emotional Regulation",
    9: "Social and Environmental Factors",
    10: "Building Sustainable Habits",
    11: "Advanced Recovery Strategies",
    12: "Relapse Prevention",
    13: "Relationship with Food",
    14: "Body Acceptance Journey",
    15: "Mindfulness and Meditation",
    16: "Social Support Systems",
    17: "Life Balance and Wellness",
    18: "Maintaining Long-term Recovery",
    101: "Emergency Resources", // Appendix I
    102: "Meal Planning Resources", // Appendix II
    103: "Body Image Resources", // Appendix III
    104: "Supporting Others", // Appendix IV
  };

  // Get chapter title by number
  static String getChapterTitle(int chapterNumber) {
    return _chapterTitles[chapterNumber] ?? 'Chapter $chapterNumber';
  }

  // Get all lessons
  Future<List<Lesson>> getAllLessons() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Sort lessons by chapter and lesson number in memory
      lessons.sort((a, b) {
        if (a.chapterNumber != b.chapterNumber) {
          return a.chapterNumber.compareTo(b.chapterNumber);
        }
        return a.lessonNumber.compareTo(b.lessonNumber);
      });

      return lessons;
    } catch (e) {
      throw Exception('Failed to fetch lessons: $e');
    }
  }

  // Get a specific lesson by ID
  Future<Lesson?> getLessonById(String lessonId) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_collectionName)
          .doc(lessonId)
          .get();

      if (doc.exists) {
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch lesson: $e');
    }
  }

  // Get lesson by chapter and lesson number
  Future<Lesson?> getLessonByChapterAndNumber(int chapterNumber, int lessonNumber) async {
    try {
      // Use a simple query without ordering to avoid index requirements
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('chapterNumber', isEqualTo: chapterNumber)
          .where('lessonNumber', isEqualTo: lessonNumber)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch lesson: $e');
    }
  }

  // Create a new lesson
  Future<String> createLesson(Lesson lesson) async {
    try {
      final DocumentReference docRef = await _firestore
          .collection(_collectionName)
          .add(lesson.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create lesson: $e');
    }
  }

  // Create a lesson with specific ID
  Future<void> createLessonWithId(String id, Lesson lesson) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .set(lesson.toMap());
    } catch (e) {
      throw Exception('Failed to create lesson with ID: $e');
    }
  }

  // Update an existing lesson
  Future<void> updateLesson(String lessonId, Lesson lesson) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(lessonId)
          .update(lesson.toMap());
    } catch (e) {
      throw Exception('Failed to update lesson: $e');
    }
  }

  // Mark lesson as completed
  Future<void> markLessonCompleted(String lessonId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get lesson details
      final lesson = await getLessonById(lessonId);
      if (lesson == null) {
        throw Exception('Lesson not found');
      }

      final now = DateTime.now();
      
      // Update user progress
      await _firestore
          .collection(_userProgressCollectionName)
          .doc('${user.uid}_$lessonId')
          .set({
        'userId': user.uid,
        'lessonId': lessonId,
        'chapterNumber': lesson.chapterNumber,
        'lessonNumber': lesson.lessonNumber,
        'isCompleted': true,
        'completedAt': now.millisecondsSinceEpoch,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to mark lesson as completed: $e');
    }
  }

  // Check if a lesson is unlocked for the current user
  Future<bool> isLessonUnlocked(String lessonId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return false; // No user authenticated, no lessons unlocked
      }

      final lesson = await getLessonById(lessonId);
      if (lesson == null) {
        return false;
      }

      // Chapters 1-18 have progressive unlocking
      if (lesson.chapterNumber >= 1 && lesson.chapterNumber <= 18) {
        return await _isProgressiveLessonUnlocked(user.uid, lesson);
      }

      // Appendices (101-104) also have progressive unlocking
      if (lesson.chapterNumber >= 101 && lesson.chapterNumber <= 104) {
        return await _isProgressiveLessonUnlocked(user.uid, lesson);
      }

      // No other chapters should exist, but default to unlocked
      return true;
    } catch (e) {
      print('Error checking lesson unlock status: $e');
      return false;
    }
  }

  // Check if a progressive lesson (chapters 1-18 and appendices 101-104) is unlocked
  Future<bool> _isProgressiveLessonUnlocked(String userId, Lesson lesson) async {
    try {
      // First lesson of each chapter is always unlocked
      if (lesson.lessonNumber == 1) {
        return true;
      }

      // For other lessons in the chapter, check if the previous lesson is completed
      final previousLessonNumber = lesson.lessonNumber - 1;
      String previousLessonId;
      
      // Handle different lesson ID formats
      if (lesson.chapterNumber >= 101 && lesson.chapterNumber <= 104) {
        // Appendix lessons use format: appendix_X_Y
        final appendixNumber = lesson.chapterNumber - 100;
        previousLessonId = 'appendix_${appendixNumber}_$previousLessonNumber';
      } else {
        // Regular lessons use format: lesson_X_Y
        previousLessonId = 'lesson_${lesson.chapterNumber}_$previousLessonNumber';
      }
      
      final progressDoc = await _firestore
          .collection(_userProgressCollectionName)
          .doc('${userId}_$previousLessonId')
          .get();

      if (progressDoc.exists) {
        final progress = UserProgress.fromMap(progressDoc.data()!, progressDoc.id);
        return progress.isCompleted;
      }

      return false;
    } catch (e) {
      print('Error checking progressive lesson unlock: $e');
      return false;
    }
  }

  // Get user progress for a specific lesson
  Future<UserProgress?> getUserProgress(String lessonId) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore
          .collection(_userProgressCollectionName)
          .doc('${user.uid}_$lessonId')
          .get();

      if (doc.exists) {
        return UserProgress.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user progress: $e');
      return null;
    }
  }

  // Get the last completed lesson for the current user
  Future<UserProgress?> getLastCompletedLesson() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      // Get all completed lessons for this user
      final progressQuery = await _firestore
          .collection(_userProgressCollectionName)
          .where('userId', isEqualTo: user.uid)
          .where('isCompleted', isEqualTo: true)
          .get();
          
      if (progressQuery.docs.isEmpty) {
        return null;
      }
      
      // Sort by completedAt in memory to avoid needing a composite index
      final sortedDocs = progressQuery.docs.toList();
      sortedDocs.sort((a, b) {
        final aCompletedAt = a.data()['completedAt'] as int? ?? 0;
        final bCompletedAt = b.data()['completedAt'] as int? ?? 0;
        return bCompletedAt.compareTo(aCompletedAt); // Descending order
      });
      
      final mostRecentDoc = sortedDocs.first;
      return UserProgress.fromMap(mostRecentDoc.data(), mostRecentDoc.id);
    } catch (e) {
      print('Error getting last completed lesson: $e');
      return null;
    }
  }

  // Get the next suggested lesson based on the last completed lesson
  Future<Lesson?> getNextSuggestedLesson() async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final lastCompleted = await getLastCompletedLesson();
      
      // If no lessons completed, suggest the first lesson of Chapter 1
      if (lastCompleted == null) {
        return await getLessonById('lesson_1_1');
      }

      // Determine the next lesson based on the last completed lesson
      String? nextLessonId = _getNextLessonId(lastCompleted);
      
      if (nextLessonId != null) {
        final nextLesson = await getLessonById(nextLessonId);
        
        if (nextLesson != null) {
          // Verify the next lesson is unlocked
          final isUnlocked = await isLessonUnlocked(nextLessonId);
          
          if (isUnlocked) {
            return nextLesson;
          }
        }
      }

      // If no logical next lesson, find the first unlocked lesson
      return await _findFirstUnlockedLesson();
    } catch (e) {
      print('Error getting next suggested lesson: $e');
      return null;
    }
  }

  // Helper method to determine the next lesson ID based on completed lesson
  String? _getNextLessonId(UserProgress lastCompleted) {
    final chapterNumber = lastCompleted.chapterNumber;
    final lessonNumber = lastCompleted.lessonNumber;
    
    // For appendices (101-104)
    if (chapterNumber >= 101 && chapterNumber <= 104) {
      final appendixNumber = chapterNumber - 100;
      final appendixLessonsCount = _getAppendixLessonsCount(appendixNumber);
      
      if (lessonNumber < appendixLessonsCount) {
        // Next lesson in same appendix
        return 'appendix_${appendixNumber}_${lessonNumber + 1}';
      } else {
        // Move to next appendix if available
        if (appendixNumber < 4) {
          return 'appendix_${appendixNumber + 1}_1';
        }
      }
      return null;
    }
    
    // For regular chapters (1-18)
    final chapterLessonsCount = _getChapterLessonsCount(chapterNumber);
    
    if (lessonNumber < chapterLessonsCount) {
      // Next lesson in same chapter
      return 'lesson_${chapterNumber}_${lessonNumber + 1}';
    } else {
      // Move to next chapter if available
      if (chapterNumber < 18) {
        return 'lesson_${chapterNumber + 1}_1';
      } else {
        // After chapter 18, suggest first appendix
        return 'appendix_1_1';
      }
    }
  }

  // Helper method to get the number of lessons in a chapter
  int _getChapterLessonsCount(int chapterNumber) {
    switch (chapterNumber) {
      case 1: return 6;
      case 2: return 6;
      case 3: return 4;
      case 4: return 5;
      case 5: return 4;
      case 6: return 6;
      case 7: return 5;
      case 8: return 4;
      case 9: return 4;
      case 10: return 5;
      case 11: return 4;
      case 12: return 4;
      case 13: return 4;
      case 14: return 4;
      case 15: return 4;
      case 16: return 4;
      case 17: return 4;
      case 18: return 4;
      default: return 1;
    }
  }

  // Helper method to get the number of lessons in an appendix
  int _getAppendixLessonsCount(int appendixNumber) {
    switch (appendixNumber) {
      case 1: return 3; // Appendix I
      case 2: return 4; // Appendix II
      case 3: return 2; // Appendix III
      case 4: return 2; // Appendix IV
      default: return 1;
    }
  }

  // Helper method to find the first unlocked lesson if logical progression fails
  Future<Lesson?> _findFirstUnlockedLesson() async {
    try {
      // Check chapters 1-18 first
      for (int chapter = 1; chapter <= 18; chapter++) {
        final lessonsCount = _getChapterLessonsCount(chapter);
        for (int lesson = 1; lesson <= lessonsCount; lesson++) {
          final lessonId = 'lesson_${chapter}_$lesson';
          if (await isLessonUnlocked(lessonId)) {
            return await getLessonById(lessonId);
          }
        }
      }
      
      // Check appendices if no main chapter lessons available
      for (int appendix = 1; appendix <= 4; appendix++) {
        final lessonsCount = _getAppendixLessonsCount(appendix);
        for (int lesson = 1; lesson <= lessonsCount; lesson++) {
          final lessonId = 'appendix_${appendix}_$lesson';
          if (await isLessonUnlocked(lessonId)) {
            return await getLessonById(lessonId);
          }
        }
      }
      
      return null;
    } catch (e) {
      print('Error finding first unlocked lesson: $e');
      return null;
    }
  }

  // Get all user progress for a specific chapter
  Future<List<UserProgress>> getUserProgressForChapter(int chapterNumber) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final snapshot = await _firestore
          .collection(_userProgressCollectionName)
          .where('userId', isEqualTo: user.uid)
          .where('chapterNumber', isEqualTo: chapterNumber)
          .get();

      return snapshot.docs
          .map((doc) => UserProgress.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting user progress for chapter: $e');
      return [];
    }
  }

  // Get all lessons for a specific chapter
  Future<List<Lesson>> getLessonsByChapter(int chapterNumber) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .where('chapterNumber', isEqualTo: chapterNumber)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Sort lessons by lesson number
      lessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));

      return lessons;
    } catch (e) {
      throw Exception('Failed to fetch lessons for chapter: $e');
    }
  }

  // Get all lessons organized by chapters
  Future<Map<int, List<Lesson>>> getAllLessonsGroupedByChapter() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final lessons = snapshot.docs
          .map((doc) => Lesson.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      // Group lessons by chapter number
      final Map<int, List<Lesson>> lessonsByChapter = {};
      for (final lesson in lessons) {
        if (!lessonsByChapter.containsKey(lesson.chapterNumber)) {
          lessonsByChapter[lesson.chapterNumber] = [];
        }
        lessonsByChapter[lesson.chapterNumber]!.add(lesson);
      }

      // Sort lessons within each chapter by lesson number
      for (final chapterLessons in lessonsByChapter.values) {
        chapterLessons.sort((a, b) => a.lessonNumber.compareTo(b.lessonNumber));
      }

      return lessonsByChapter;
    } catch (e) {
      throw Exception('Failed to fetch lessons grouped by chapter: $e');
    }
  }

  // Get lessons for a chapter with unlock status
  Future<List<Map<String, dynamic>>> getLessonsWithUnlockStatus(int chapterNumber) async {
    try {
      final lessons = await getLessonsByChapter(chapterNumber);
      final lessonsWithStatus = <Map<String, dynamic>>[];

      for (final lesson in lessons) {
        final isUnlocked = await isLessonUnlocked(lesson.id);
        final progress = await getUserProgress(lesson.id);
        
        lessonsWithStatus.add({
          'lesson': lesson,
          'isUnlocked': isUnlocked,
          'isCompleted': progress?.isCompleted ?? false,
          'completedAt': progress?.completedAt,
        });
      }

      return lessonsWithStatus;
    } catch (e) {
      print('Error getting lessons with unlock status: $e');
      return [];
    }
  }

  // Delete a lesson
  Future<void> deleteLesson(String lessonId) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(lessonId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete lesson: $e');
    }
  }

  // Initialize default lesson data
  Future<void> initializeDefaultLessons() async {
    try {
      // Get all default lessons that should exist
      final defaultLessons = _getDefaultLessons();
      
      // Check each lesson individually and create if missing
      for (final lesson in defaultLessons) {
        try {
          final existingLesson = await getLessonById(lesson.id);
          if (existingLesson == null) {
            // Lesson doesn't exist, create it
            await createLessonWithId(lesson.id, lesson);
            print('Created lesson: ${lesson.id}');
        }
      } catch (e) {
          print('Warning: Could not check/create lesson ${lesson.id}: $e');
          // Continue with other lessons even if one fails
        }
      }
    } catch (e) {
      throw Exception('Failed to initialize default lessons: $e');
    }
  }

  // Force re-initialization of all lessons (useful for updates)
  Future<void> forceReinitializeLessons() async {
    try {
      // Get all default lessons that should exist
      final defaultLessons = _getDefaultLessons();
      
      // Create or update each lesson
      for (final lesson in defaultLessons) {
        try {
          await createLessonWithId(lesson.id, lesson);
          print('Created/Updated lesson: ${lesson.id}');
        } catch (e) {
          print('Warning: Could not create/update lesson ${lesson.id}: $e');
          // Continue with other lessons even if one fails
        }
      }
    } catch (e) {
      throw Exception('Failed to force reinitialize lessons: $e');
    }
  }

  List<Lesson> _getDefaultLessons() {
    final now = DateTime.now();
    
    return [
      // Lesson 1.1 - 4 slides
      Lesson(
        id: 'lesson_1_1',
        title: 'Who Is Nurtra For?',
        description: 'Understanding who can benefit from Nurtra\'s approach to binge eating recovery.',
        chapterNumber: 1,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_1_1_1',
            title: 'Welcome to Nurtra',
            content: 'Nurtra is designed for individuals who are struggling with binge eating and are ready to take control of their relationship with food.',
            slideNumber: 1,
            bulletPoints: [
              'People experiencing regular episodes of binge eating',
              'Individuals who feel out of control around food',
              'Those who have tried other approaches without success'
            ],
          ),
          LessonSlide(
            id: 'slide_1_1_2',
            title: 'Who Can Benefit',
            content: 'This program is specifically tailored for anyone ready to develop a healthier relationship with food.',
            slideNumber: 2,
            bulletPoints: [
              'Anyone ready to develop a healthier relationship with food',
              'People seeking evidence-based recovery strategies',
              'Those looking for structured, step-by-step guidance'
            ],
          ),
          LessonSlide(
            id: 'slide_1_1_3',
            title: 'Recognizing the Signs',
            content: 'If you find yourself eating large amounts of food in a short period, feeling guilty or ashamed afterward, or using food as a way to cope with emotions, Nurtra can help.',
            slideNumber: 3,
            bulletPoints: [
              'Eating large amounts of food in short periods',
              'Feeling guilty or ashamed after eating',
              'Using food to cope with emotions'
            ],
          ),
          LessonSlide(
            id: 'slide_1_1_4',
            title: 'Your Recovery Journey',
            content: 'Nurtra can help you break these patterns and build lasting change. You\'re taking the first step by being here.',
            slideNumber: 4,
            bulletPoints: [
              'Break unhealthy eating patterns',
              'Build lasting positive changes',
              'Develop sustainable recovery strategies'
            ],
            additionalInfo: 'Remember: Recovery is possible, and you\'re not alone in this journey.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 1.2 - 2 slides
      Lesson(
        id: 'lesson_1_2',
        title: 'Why Trust Nurtra?',
        description: 'Understanding the evidence-based foundation and expert design behind Nurtra\'s approach.',
        chapterNumber: 1,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_1_2_1',
            title: 'Evidence-Based Foundation',
            content: 'Nurtra is built on a foundation of scientific research and evidence-based practices.',
            slideNumber: 1,
            bulletPoints: [
              'Evidence-based methods from proven research',
              'Expert-designed content by licensed therapists',
              'Proven results from thousands of users'
            ],
          ),
          LessonSlide(
            id: 'slide_1_2_2',
            title: 'Your Safety and Support',
            content: 'We understand that trust is earned, not given. That\'s why we\'re committed to transparency and providing you with the tools you need.',
            slideNumber: 2,
            bulletPoints: [
              'Privacy & safety with industry-standard security',
              'Ongoing support throughout your journey',
              'Transparency in our methods and approach'
            ],
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 1.3 - 4 slides
      Lesson(
        id: 'lesson_1_3',
        title: 'How to Use Nurtra for Best Results',
        description: 'Guidelines for getting the most out of your Nurtra experience.',
        chapterNumber: 1,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_1_3_1',
            title: 'Set Aside Dedicated Time',
            content: 'Schedule 15-30 minutes daily for your Nurtra practice. Consistency is key to building new habits and seeing progress.',
            slideNumber: 1,
            bulletPoints: [
              '15-30 minutes daily practice',
              'Consistency builds new habits',
              'Regular practice shows progress'
            ],
          ),
          LessonSlide(
            id: 'slide_1_3_2',
            title: 'Complete Lessons in Order',
            content: 'Work through the chapters sequentially. Each lesson builds upon the previous ones, creating a comprehensive recovery foundation.',
            slideNumber: 2,
            bulletPoints: [
              'Work through chapters sequentially',
              'Each lesson builds on previous ones',
              'Creates comprehensive recovery foundation'
            ],
          ),
          LessonSlide(
            id: 'slide_1_3_3',
            title: 'Practice Mindfulness',
            content: 'Engage fully with each lesson. Take notes, reflect on the content, and apply the techniques in your daily life.',
            slideNumber: 3,
            bulletPoints: [
              'Engage fully with each lesson',
              'Take notes and reflect on content',
              'Apply techniques in daily life'
            ],
          ),
          LessonSlide(
            id: 'slide_1_3_4',
            title: 'Track Your Progress',
            content: 'Use the journaling features to monitor your thoughts, feelings, and behaviors. Be patient with yourself and seek support when needed.',
            slideNumber: 4,
            bulletPoints: [
              'Use journaling features to monitor progress',
              'Be patient with yourself during recovery',
              'Seek support when needed'
            ],
            additionalInfo: 'Remember: The most important step is starting. Even small, consistent actions can lead to significant positive changes.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.1 - 6 slides
      Lesson(
        id: 'lesson_2_1',
        title: 'What Does "Binge" Really Mean?',
        description: 'Understanding the true meaning of binge eating and its clinical definition.',
        chapterNumber: 2,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_2_1_1',
            title: 'Understanding the Term',
            content: 'The term "binge" is often misunderstood. Let\'s clarify what it actually means in the context of eating disorders.',
            slideNumber: 1,
            bulletPoints: [
              'Often misunderstood term',
              'Important to clarify meaning',
              'Context of eating disorders'
            ],
          ),
          LessonSlide(
            id: 'slide_2_1_2',
            title: 'Clinical Definition',
            content: 'A binge episode involves eating an unusually large amount of food in a discrete period of time (typically within 2 hours) with a sense of loss of control over eating.',
            slideNumber: 2,
            bulletPoints: [
              'Unusually large amount of food',
              'Discrete period of time (typically 2 hours)',
              'Sense of loss of control over eating'
            ],
          ),
          LessonSlide(
            id: 'slide_2_1_3',
            title: 'Key Components',
            content: 'Two essential elements: 1) Large quantity of food, and 2) Feeling out of control during the episode.',
            slideNumber: 3,
            bulletPoints: [
              'Large quantity of food',
              'Feeling out of control',
              'Both elements must be present'
            ],
          ),
          LessonSlide(
            id: 'slide_2_1_4',
            title: 'Common Misconceptions',
            content: 'A "binge" isn\'t just overeating or having a big meal. It\'s characterized by the loss of control and the amount consumed.',
            slideNumber: 4,
            bulletPoints: [
              'Not just overeating',
              'Not just having a big meal',
              'Characterized by loss of control and amount'
            ],
          ),
          LessonSlide(
            id: 'slide_2_1_5',
            title: 'Why Understanding Matters',
            content: 'Understanding the true meaning of "binge" is crucial for recognizing patterns and seeking appropriate help.',
            slideNumber: 5,
            bulletPoints: [
              'Crucial for recognizing patterns',
              'Helps in seeking appropriate help',
              'Important for self-awareness'
            ],
          ),
          LessonSlide(
            id: 'slide_2_1_6',
            title: 'It\'s Not About Willpower',
            content: 'It\'s not about willpower or self-control - it\'s a complex psychological and behavioral pattern that requires understanding and support.',
            slideNumber: 6,
            bulletPoints: [
              'Not about willpower',
              'Not about self-control',
              'Complex psychological and behavioral pattern'
            ],
            additionalInfo: 'Remember: Understanding binge eating is the first step toward recovery. You\'re not alone in this journey.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.2 - 6 slides
      Lesson(
        id: 'lesson_2_2',
        title: 'Why Do We Binge?',
        description: 'Understanding the underlying causes and triggers of binge eating episodes.',
        chapterNumber: 2,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_2_2_1',
            title: 'Complex Causes',
            content: 'Binge eating has multiple interconnected causes - it\'s rarely about just one factor.',
            slideNumber: 1,
            bulletPoints: [
              'Multiple interconnected causes',
              'Rarely about just one factor',
              'Biological, psychological, and social elements'
            ],
          ),
          LessonSlide(
            id: 'slide_2_2_2',
            title: 'Emotional Triggers',
            content: 'Many people binge in response to difficult emotions like stress, anxiety, depression, loneliness, or boredom.',
            slideNumber: 2,
            bulletPoints: [
              'Response to difficult emotions',
              'Stress, anxiety, depression',
              'Loneliness or boredom'
            ],
          ),
          LessonSlide(
            id: 'slide_2_2_3',
            title: 'Restrictive Eating Patterns',
            content: 'Overly restrictive dieting or skipping meals can lead to intense hunger and trigger binge episodes.',
            slideNumber: 3,
            bulletPoints: [
              'Overly restrictive dieting',
              'Skipping meals leads to intense hunger',
              'Can trigger binge episodes'
            ],
          ),
          LessonSlide(
            id: 'slide_2_2_4',
            title: 'Biological Factors',
            content: 'Genetics, brain chemistry, and hormonal changes can all influence eating behaviors and binge tendencies.',
            slideNumber: 4,
            bulletPoints: [
              'Genetic predisposition',
              'Brain chemistry imbalances',
              'Hormonal changes affect eating'
            ],
          ),
          LessonSlide(
            id: 'slide_2_2_5',
            title: 'Environmental Influences',
            content: 'Social situations, food availability, family dynamics, and cultural factors can contribute to binge eating.',
            slideNumber: 5,
            bulletPoints: [
              'Social situations and pressure',
              'Food availability and environment',
              'Family dynamics and cultural factors'
            ],
          ),
          LessonSlide(
            id: 'slide_2_2_6',
            title: 'Breaking the Cycle',
            content: 'Understanding your personal triggers is the first step toward breaking the binge cycle and developing healthier coping strategies.',
            slideNumber: 6,
            bulletPoints: [
              'Identify your personal triggers',
              'First step to breaking the cycle',
              'Develop healthier coping strategies'
            ],
            additionalInfo: 'Remember: Understanding your triggers empowers you to make different choices.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.3 - 3 slides
      Lesson(
        id: 'lesson_2_3',
        title: 'The Binge-Restrict Cycle',
        description: 'Understanding how restriction and binging create a harmful cycle.',
        chapterNumber: 2,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_2_3_1',
            title: 'The Vicious Cycle',
            content: 'The binge-restrict cycle is a common pattern where periods of restriction lead to binge episodes, followed by more restriction.',
            slideNumber: 1,
            bulletPoints: [
              'Common destructive pattern',
              'Restriction leads to binge episodes',
              'Followed by more restriction'
            ],
          ),
          LessonSlide(
            id: 'slide_2_3_2',
            title: 'How It Works',
            content: 'Restriction creates physical and psychological deprivation, which increases the likelihood of losing control around food.',
            slideNumber: 2,
            bulletPoints: [
              'Creates physical deprivation',
              'Creates psychological deprivation',
              'Increases likelihood of losing control'
            ],
          ),
          LessonSlide(
            id: 'slide_2_3_3',
            title: 'Breaking Free',
            content: 'Breaking this cycle requires addressing both the physical restriction and the emotional relationship with food.',
            slideNumber: 3,
            bulletPoints: [
              'Address physical restriction',
              'Address emotional relationship with food',
              'Requires comprehensive approach'
            ],
            additionalInfo: 'Remember: Breaking the cycle takes time and patience with yourself.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.4 - 8 slides
      Lesson(
        id: 'lesson_2_4',
        title: 'Emotional vs. Physical Hunger',
        description: 'Learning to distinguish between emotional and physical hunger cues.',
        chapterNumber: 2,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_2_4_1',
            title: 'Two Types of Hunger',
            content: 'Understanding the difference between physical hunger and emotional hunger is crucial for recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Physical hunger vs emotional hunger',
              'Different causes and characteristics',
              'Crucial for recovery understanding'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_2',
            title: 'Physical Hunger Signs',
            content: 'Physical hunger develops gradually, occurs below the neck, and can be satisfied with various foods.',
            slideNumber: 2,
            bulletPoints: [
              'Develops gradually over time',
              'Felt below the neck (stomach, body)',
              'Can be satisfied with various foods'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_3',
            title: 'Emotional Hunger Signs',
            content: 'Emotional hunger comes on suddenly, feels urgent, and often craves specific comfort foods.',
            slideNumber: 3,
            bulletPoints: [
              'Comes on suddenly and urgently',
              'Felt above the neck (mind, emotions)',
              'Craves specific comfort foods'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_4',
            title: 'Physical Hunger Timing',
            content: 'Physical hunger can wait and grows stronger over time. It\'s connected to your last meal and energy needs.',
            slideNumber: 4,
            bulletPoints: [
              'Can wait and grows gradually',
              'Connected to last meal timing',
              'Related to actual energy needs'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_5',
            title: 'Emotional Hunger Timing',
            content: 'Emotional hunger demands immediate satisfaction and isn\'t related to when you last ate.',
            slideNumber: 5,
            bulletPoints: [
              'Demands immediate satisfaction',
              'Not related to meal timing',
              'Triggered by emotions or situations'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_6',
            title: 'After Eating: Physical',
            content: 'Physical hunger stops when you\'re full, and you feel satisfied and content after eating.',
            slideNumber: 6,
            bulletPoints: [
              'Stops when physically full',
              'Feel satisfied and content',
              'Body signals satiety clearly'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_7',
            title: 'After Eating: Emotional',
            content: 'Emotional hunger often doesn\'t stop at fullness and may lead to feelings of guilt or shame afterward.',
            slideNumber: 7,
            bulletPoints: [
              'Doesn\'t stop at physical fullness',
              'May lead to overeating',
              'Often followed by guilt or shame'
            ],
          ),
          LessonSlide(
            id: 'slide_2_4_8',
            title: 'Practice Awareness',
            content: 'Learning to pause and check in with yourself before eating can help you distinguish between these two types of hunger.',
            slideNumber: 8,
            bulletPoints: [
              'Pause before eating',
              'Check in with yourself',
              'Practice distinguishing the difference'
            ],
            additionalInfo: 'Remember: This skill takes practice. Be patient as you learn to recognize your hunger cues.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.5 - 3 slides
      Lesson(
        id: 'lesson_2_5',
        title: 'Common Binge Triggers',
        description: 'Identifying and understanding your personal binge triggers.',
        chapterNumber: 2,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_2_5_1',
            title: 'Identifying Your Triggers',
            content: 'Triggers are situations, emotions, or thoughts that increase the likelihood of a binge episode.',
            slideNumber: 1,
            bulletPoints: [
              'Situations that increase binge risk',
              'Emotional states that trigger binges',
              'Thoughts that lead to episodes'
            ],
          ),
          LessonSlide(
            id: 'slide_2_5_2',
            title: 'Common Trigger Categories',
            content: 'Common triggers include stress, loneliness, boredom, anxiety, seeing certain foods, or being in specific locations.',
            slideNumber: 2,
            bulletPoints: [
              'Emotional: stress, loneliness, anxiety',
              'Environmental: certain foods, locations',
              'Mental: boredom, negative thoughts'
            ],
          ),
          LessonSlide(
            id: 'slide_2_5_3',
            title: 'Your Personal Pattern',
            content: 'Everyone has unique triggers. Keeping a journal can help you identify your specific patterns and prepare strategies.',
            slideNumber: 3,
            bulletPoints: [
              'Everyone has unique triggers',
              'Keeping a journal helps identify patterns',
              'Prepare strategies in advance'
            ],
            additionalInfo: 'Remember: Awareness of your triggers is the first step toward managing them effectively.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 2.6 - 5 slides
      Lesson(
        id: 'lesson_2_6',
        title: 'Building Awareness',
        description: 'Developing mindful awareness of your eating patterns and triggers.',
        chapterNumber: 2,
        lessonNumber: 6,
        slides: [
          LessonSlide(
            id: 'slide_2_6_1',
            title: 'The Power of Awareness',
            content: 'Awareness is the foundation of change. You can\'t change what you\'re not aware of.',
            slideNumber: 1,
            bulletPoints: [
              'Foundation of all change',
              'Can\'t change without awareness',
              'First step in recovery process'
            ],
          ),
          LessonSlide(
            id: 'slide_2_6_2',
            title: 'Mindful Observation',
            content: 'Practice observing your thoughts, feelings, and behaviors around food without judgment.',
            slideNumber: 2,
            bulletPoints: [
              'Observe thoughts without judgment',
              'Notice feelings around food',
              'Watch behaviors with curiosity'
            ],
          ),
          LessonSlide(
            id: 'slide_2_6_3',
            title: 'The HALT Check',
            content: 'Before eating, ask yourself: Am I Hungry, Angry, Lonely, or Tired? This simple check can reveal emotional eating patterns.',
            slideNumber: 3,
            bulletPoints: [
              'H - Hungry: Physical hunger?',
              'A - Angry: Feeling frustrated?',
              'L - Lonely: Seeking connection?',
              'T - Tired: Need rest instead?'
            ],
          ),
          LessonSlide(
            id: 'slide_2_6_4',
            title: 'Body Scan Practice',
            content: 'Regularly check in with your body. Notice physical sensations, hunger levels, and emotional states.',
            slideNumber: 4,
            bulletPoints: [
              'Regular body check-ins',
              'Notice physical sensations',
              'Assess hunger and emotional states'
            ],
          ),
          LessonSlide(
            id: 'slide_2_6_5',
            title: 'Building the Habit',
            content: 'Awareness becomes stronger with practice. Make it a daily habit to check in with yourself multiple times.',
            slideNumber: 5,
            bulletPoints: [
              'Awareness strengthens with practice',
              'Make it a daily habit',
              'Check in multiple times per day'
            ],
            additionalInfo: 'Remember: Building awareness takes time. Be patient and gentle with yourself as you develop this skill.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 3.1 - 4 slides
      Lesson(
        id: 'lesson_3_1',
        title: 'Introduction to Mindful Eating',
        description: 'Learning the basics of mindful eating and how it can help with recovery.',
        chapterNumber: 3,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_3_1_1',
            title: 'What is Mindful Eating?',
            content: 'Mindful eating is the practice of paying full attention to the experience of eating and drinking, both inside and outside the body.',
            slideNumber: 1,
            bulletPoints: [
              'Paying full attention to eating experience',
              'Noticing physical and emotional sensations',
              'Eating without distractions or judgment'
            ],
          ),
          LessonSlide(
            id: 'slide_3_1_2',
            title: 'Benefits of Mindful Eating',
            content: 'Mindful eating can help break the binge-restrict cycle by increasing awareness of hunger, fullness, and emotional eating triggers.',
            slideNumber: 2,
            bulletPoints: [
              'Increases awareness of hunger and fullness',
              'Helps identify emotional eating triggers',
              'Reduces automatic or mindless eating'
            ],
          ),
          LessonSlide(
            id: 'slide_3_1_3',
            title: 'Mindful vs. Mindless Eating',
            content: 'Mindless eating often happens when we\'re distracted, emotional, or following strict rules. Mindful eating brings conscious awareness to our food choices.',
            slideNumber: 3,
            bulletPoints: [
              'Mindless: Eating while distracted or emotional',
              'Mindless: Following strict diet rules without awareness',
              'Mindful: Conscious awareness of food choices and sensations'
            ],
          ),
          LessonSlide(
            id: 'slide_3_1_4',
            title: 'Starting Your Practice',
            content: 'Begin with small steps - try eating one meal or snack per day mindfully, without distractions like TV or phone.',
            slideNumber: 4,
            bulletPoints: [
              'Start with one mindful meal or snack daily',
              'Eliminate distractions like TV or phone',
              'Focus on taste, texture, and eating pace'
            ],
            additionalInfo: 'Remember: Mindful eating is a practice, not perfection. Be patient and kind with yourself as you learn.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 3.2 - 5 slides
      Lesson(
        id: 'lesson_3_2',
        title: 'Hunger and Fullness Cues',
        description: 'Learning to recognize and trust your body\'s natural hunger and fullness signals.',
        chapterNumber: 3,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_3_2_1',
            title: 'Understanding Hunger Scale',
            content: 'The hunger scale ranges from 1 (starving) to 10 (uncomfortably full). Learning to identify where you are helps guide eating decisions.',
            slideNumber: 1,
            bulletPoints: [
              '1-2: Starving, dizzy, irritable',
              '3-4: Hungry, ready to eat',
              '5-6: Neutral, satisfied',
              '7-8: Full, comfortable',
              '9-10: Overly full, uncomfortable'
            ],
          ),
          LessonSlide(
            id: 'slide_3_2_2',
            title: 'Recognizing True Hunger',
            content: 'Physical hunger develops gradually and can be satisfied with various foods. It\'s felt in the body, not the mind.',
            slideNumber: 2,
            bulletPoints: [
              'Develops gradually over time',
              'Felt as physical sensations in the body',
              'Can be satisfied with various foods',
              'Not urgent or demanding'
            ],
          ),
          LessonSlide(
            id: 'slide_3_2_3',
            title: 'Identifying Fullness',
            content: 'Fullness is the feeling of having eaten enough. It\'s important to eat slowly to give your body time to register satisfaction.',
            slideNumber: 3,
            bulletPoints: [
              'Feeling of having eaten enough',
              'Takes 15-20 minutes for brain to register fullness',
              'Eating slowly helps recognize satiety',
              'Comfortable, not stuffed feeling'
            ],
          ),
          LessonSlide(
            id: 'slide_3_2_4',
            title: 'When Cues Are Unclear',
            content: 'After periods of restriction or binging, hunger and fullness cues may be disrupted. This is normal and they can be restored with consistent, adequate eating.',
            slideNumber: 4,
            bulletPoints: [
              'Cues may be disrupted after restriction/binging',
              'This is normal and temporary',
              'Consistent eating helps restore natural cues',
              'Be patient with the process'
            ],
          ),
          LessonSlide(
            id: 'slide_3_2_5',
            title: 'Practicing Cue Awareness',
            content: 'Check in with your hunger and fullness levels before, during, and after eating. Notice how different foods and eating speeds affect your satisfaction.',
            slideNumber: 5,
            bulletPoints: [
              'Check hunger before eating',
              'Notice fullness during and after meals',
              'Observe how different foods affect satisfaction',
              'Practice regularly to rebuild trust'
            ],
            additionalInfo: 'Remember: Rebuilding trust with your hunger and fullness cues takes time. Be patient and consistent.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 3.3 - 6 slides
      Lesson(
        id: 'lesson_3_3',
        title: 'Breaking the All-or-Nothing Mindset',
        description: 'Moving away from black-and-white thinking about food and eating.',
        chapterNumber: 3,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_3_3_1',
            title: 'What is All-or-Nothing Thinking?',
            content: 'All-or-nothing thinking categorizes foods, eating behaviors, and even ourselves as either "good" or "bad" with no middle ground.',
            slideNumber: 1,
            bulletPoints: [
              'Categorizes foods as "good" or "bad"',
              'Views eating behaviors as perfect or failure',
              'No recognition of middle ground or gray areas',
              'Often leads to shame and guilt'
            ],
          ),
          LessonSlide(
            id: 'slide_3_3_2',
            title: 'How It Fuels Binge Eating',
            content: 'This mindset creates a cycle: restriction leads to "breaking rules," which triggers feelings of failure and often results in binge eating.',
            slideNumber: 2,
            bulletPoints: [
              'Restriction creates pressure to be "perfect"',
              'Any deviation feels like complete failure',
              'Failure triggers "might as well" mentality',
              'Leads to binge eating and more restriction'
            ],
          ),
          LessonSlide(
            id: 'slide_3_3_3',
            title: 'Examples of Black-and-White Thinking',
            content: 'Common thoughts include "I ruined my diet," "I have no willpower," or "I\'ll start fresh tomorrow." These thoughts maintain the binge-restrict cycle.',
            slideNumber: 3,
            bulletPoints: [
              '"I ruined my diet" after eating one cookie',
              '"I have no willpower" after normal eating',
              '"I\'ll start fresh tomorrow" mentality',
              'Labeling foods as completely forbidden'
            ],
          ),
          LessonSlide(
            id: 'slide_3_3_4',
            title: 'Developing Gray Area Thinking',
            content: 'Gray area thinking recognizes that eating exists on a spectrum. All foods can fit into a balanced approach to eating.',
            slideNumber: 4,
            bulletPoints: [
              'Eating exists on a spectrum',
              'All foods can fit into balanced eating',
              'One meal or snack doesn\'t define your health',
              'Progress, not perfection, is the goal'
            ],
          ),
          LessonSlide(
            id: 'slide_3_3_5',
            title: 'Challenging Perfectionist Thoughts',
            content: 'When you notice all-or-nothing thoughts, pause and ask: "Is this thought helpful? What would I tell a friend in this situation?"',
            slideNumber: 5,
            bulletPoints: [
              'Notice when perfectionist thoughts arise',
              'Ask: "Is this thought helpful?"',
              'Consider: "What would I tell a friend?"',
              'Replace with more balanced perspective'
            ],
          ),
          LessonSlide(
            id: 'slide_3_3_6',
            title: 'Practicing Flexibility',
            content: 'Recovery involves learning to be flexible with food choices and eating patterns while still taking care of your health and well-being.',
            slideNumber: 6,
            bulletPoints: [
              'Practice flexibility with food choices',
              'Allow for imperfect eating experiences',
              'Focus on overall patterns, not individual meals',
              'Balance structure with spontaneity'
            ],
            additionalInfo: 'Remember: Flexibility and balance are skills that develop over time. Be patient as you practice gray area thinking.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 3.4 - 4 slides
      Lesson(
        id: 'lesson_3_4',
        title: 'Creating Structure Without Restriction',
        description: 'Learning to create helpful eating structure while avoiding restrictive patterns.',
        chapterNumber: 3,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_3_4_1',
            title: 'Structure vs. Restriction',
            content: 'Structure provides a framework for consistent eating, while restriction involves rigid rules and forbidden foods. Structure is flexible; restriction is rigid.',
            slideNumber: 1,
            bulletPoints: [
              'Structure: Flexible framework for eating',
              'Restriction: Rigid rules and forbidden foods',
              'Structure supports stability',
              'Restriction often leads to rebellion'
            ],
          ),
          LessonSlide(
            id: 'slide_3_4_2',
            title: 'Benefits of Gentle Structure',
            content: 'Appropriate structure helps prevent extreme hunger, provides energy throughout the day, and creates predictability that can reduce anxiety around food.',
            slideNumber: 2,
            bulletPoints: [
              'Prevents extreme hunger and fullness',
              'Provides consistent energy throughout day',
              'Reduces anxiety and food preoccupation',
              'Creates foundation for intuitive eating'
            ],
          ),
          LessonSlide(
            id: 'slide_3_4_3',
            title: 'Creating Your Structure',
            content: 'Focus on regular meal timing, including all food groups, and planning ahead while remaining flexible for unexpected situations.',
            slideNumber: 3,
            bulletPoints: [
              'Aim for regular meal and snack timing',
              'Include variety and all food groups',
              'Plan ahead when possible',
              'Remain flexible for life\'s unexpected moments'
            ],
          ),
          LessonSlide(
            id: 'slide_3_4_4',
            title: 'Flexibility Within Structure',
            content: 'Your eating structure should adapt to your life, not control it. Allow for social occasions, schedule changes, and personal preferences.',
            slideNumber: 4,
            bulletPoints: [
              'Structure adapts to your life, not controls it',
              'Allow for social eating occasions',
              'Adjust for schedule changes',
              'Honor personal preferences and cravings'
            ],
            additionalInfo: 'Remember: The goal is to create a sustainable approach that supports your recovery and overall well-being.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 4: COPING STRATEGIES - 5 lessons

      // Lesson 4.1 - 4 slides
      Lesson(
        id: 'lesson_4_1',
        title: 'Identifying Your Coping Patterns',
        description: 'Understanding how you currently cope with difficult emotions and situations.',
        chapterNumber: 4,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_4_1_1',
            title: 'What Are Coping Strategies?',
            content: 'Coping strategies are the methods we use to manage stress, difficult emotions, and challenging situations in our lives.',
            slideNumber: 1,
            bulletPoints: [
              'Methods for managing stress and emotions',
              'Can be helpful or unhelpful',
              'Often developed unconsciously over time',
              'Everyone has different coping patterns'
            ],
          ),
          LessonSlide(
            id: 'slide_4_1_2',
            title: 'Helpful vs. Unhelpful Coping',
            content: 'Helpful coping strategies address problems directly or manage emotions in healthy ways. Unhelpful strategies may provide temporary relief but often create more problems.',
            slideNumber: 2,
            bulletPoints: [
              'Helpful: Problem-solving, seeking support, exercise',
              'Unhelpful: Avoidance, substance use, binge eating',
              'Temporary relief vs. long-term solutions',
              'Consider the consequences of each strategy'
            ],
          ),
          LessonSlide(
            id: 'slide_4_1_3',
            title: 'Your Current Patterns',
            content: 'Take time to reflect on how you typically respond to stress, anxiety, sadness, anger, or boredom. Notice patterns without judgment.',
            slideNumber: 3,
            bulletPoints: [
              'How do you respond to stress?',
              'What do you do when feeling anxious or sad?',
              'How do you handle anger or frustration?',
              'What happens when you\'re bored or lonely?'
            ],
          ),
          LessonSlide(
            id: 'slide_4_1_4',
            title: 'Building Awareness',
            content: 'Awareness is the first step toward change. Start noticing your coping patterns in real-time without trying to change them immediately.',
            slideNumber: 4,
            bulletPoints: [
              'Notice patterns without judgment',
              'Observe triggers and responses',
              'Track patterns in a journal',
              'Awareness comes before change'
            ],
            additionalInfo: 'Remember: There\'s no shame in recognizing unhelpful patterns. This awareness is the foundation for developing healthier coping strategies.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 4.2 - 5 slides
      Lesson(
        id: 'lesson_4_2',
        title: 'Healthy Alternatives to Binge Eating',
        description: 'Developing alternative coping strategies to replace binge eating behaviors.',
        chapterNumber: 4,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_4_2_1',
            title: 'Why We Need Alternatives',
            content: 'Binge eating often serves as a coping mechanism. To break this pattern, we need to develop other ways to meet the same emotional needs.',
            slideNumber: 1,
            bulletPoints: [
              'Binge eating serves emotional functions',
              'Removing without replacing leads to void',
              'Alternatives must meet similar needs',
              'Practice makes new habits stick'
            ],
          ),
          LessonSlide(
            id: 'slide_4_2_2',
            title: 'Physical Alternatives',
            content: 'Physical activities can help release tension, boost mood, and provide a healthy outlet for emotions.',
            slideNumber: 2,
            bulletPoints: [
              'Take a walk or jog',
              'Do yoga or stretching',
              'Dance to favorite music',
              'Try progressive muscle relaxation',
              'Take a warm bath or shower'
            ],
          ),
          LessonSlide(
            id: 'slide_4_2_3',
            title: 'Creative and Mental Alternatives',
            content: 'Engaging your mind in creative or absorbing activities can redirect focus and provide emotional release.',
            slideNumber: 3,
            bulletPoints: [
              'Write in a journal or blog',
              'Draw, paint, or do crafts',
              'Read a book or listen to podcasts',
              'Do puzzles or brain games',
              'Learn something new online'
            ],
          ),
          LessonSlide(
            id: 'slide_4_2_4',
            title: 'Social and Emotional Alternatives',
            content: 'Connecting with others or processing emotions directly can address the underlying needs that binge eating was meeting.',
            slideNumber: 4,
            bulletPoints: [
              'Call or text a friend',
              'Practice meditation or mindfulness',
              'Write down your feelings',
              'Use breathing exercises',
              'Engage in spiritual practices'
            ],
          ),
          LessonSlide(
            id: 'slide_4_2_5',
            title: 'Creating Your Toolkit',
            content: 'Develop a personalized list of 10-15 alternative coping strategies. Keep this list easily accessible for when you need it most.',
            slideNumber: 5,
            bulletPoints: [
              'Choose strategies that appeal to you',
              'Include quick (5-minute) and longer options',
              'Test different approaches',
              'Keep your list accessible',
              'Update it as you discover what works'
            ],
            additionalInfo: 'Remember: It takes time to establish new habits. Be patient with yourself as you practice these alternatives.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 4.3 - 6 slides
      Lesson(
        id: 'lesson_4_3',
        title: 'The STOP Technique',
        description: 'Learning a simple but powerful technique to interrupt the urge to binge.',
        chapterNumber: 4,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_4_3_1',
            title: 'What is the STOP Technique?',
            content: 'STOP is an acronym for a four-step process: Stop, Take a breath, Observe, and Proceed mindfully. It creates space between urge and action.',
            slideNumber: 1,
            bulletPoints: [
              'S - Stop what you\'re doing',
              'T - Take a deep breath',
              'O - Observe your thoughts and feelings',
              'P - Proceed with conscious choice'
            ],
          ),
          LessonSlide(
            id: 'slide_4_3_2',
            title: 'S - Stop',
            content: 'When you notice the urge to binge, literally stop whatever you\'re doing. This interrupts the automatic pattern and creates a moment of pause.',
            slideNumber: 2,
            bulletPoints: [
              'Physically stop your current activity',
              'Step away from food if possible',
              'Notice: "I\'m having an urge to binge"',
              'Remember: This is just an urge, not a command'
            ],
          ),
          LessonSlide(
            id: 'slide_4_3_3',
            title: 'T - Take a Breath',
            content: 'Take several slow, deep breaths. This activates your nervous system\'s calming response and helps you think more clearly.',
            slideNumber: 3,
            bulletPoints: [
              'Take 3-5 slow, deep breaths',
              'Focus on exhaling longer than inhaling',
              'Feel your body relaxing with each breath',
              'This activates your calming response'
            ],
          ),
          LessonSlide(
            id: 'slide_4_3_4',
            title: 'O - Observe',
            content: 'Notice what you\'re thinking and feeling without judgment. What triggered this urge? What emotions are present?',
            slideNumber: 4,
            bulletPoints: [
              'What am I thinking right now?',
              'What emotions am I feeling?',
              'What triggered this urge?',
              'What do I really need in this moment?'
            ],
          ),
          LessonSlide(
            id: 'slide_4_3_5',
            title: 'P - Proceed Mindfully',
            content: 'Based on your observations, make a conscious choice about how to proceed. You might choose to eat mindfully, use an alternative coping strategy, or address the underlying need.',
            slideNumber: 5,
            bulletPoints: [
              'Choose your response consciously',
              'Consider: What would be most helpful right now?',
              'Options: Alternative coping, mindful eating, addressing needs',
              'Remember: Any conscious choice is progress'
            ],
          ),
          LessonSlide(
            id: 'slide_4_3_6',
            title: 'Practice Makes Progress',
            content: 'The STOP technique gets easier with practice. Even if you don\'t always prevent a binge, using this technique builds awareness and self-control over time.',
            slideNumber: 6,
            bulletPoints: [
              'Practice the technique regularly',
              'Don\'t expect perfection immediately',
              'Each time you use STOP, you\'re building skills',
              'Progress, not perfection, is the goal'
            ],
            additionalInfo: 'Remember: Even if you proceed to eat after using STOP, you\'ve still practiced an important skill. Building awareness is always progress.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 4.4 - 4 slides
      Lesson(
        id: 'lesson_4_4',
        title: 'Managing Difficult Emotions',
        description: 'Learning healthy ways to process and cope with challenging emotions.',
        chapterNumber: 4,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_4_4_1',
            title: 'Emotions Are Information',
            content: 'Emotions, even difficult ones, provide valuable information about our needs, values, and situations. Learning to listen to them is key to recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Emotions carry important information',
              'They signal our needs and values',
              'Avoiding emotions often makes them stronger',
              'All emotions are temporary and valid'
            ],
          ),
          LessonSlide(
            id: 'slide_4_4_2',
            title: 'The RAIN Technique',
            content: 'RAIN helps you process difficult emotions: Recognize, Allow, Investigate, and Non-attachment. This creates space for emotions without being overwhelmed.',
            slideNumber: 2,
            bulletPoints: [
              'R - Recognize: "What am I feeling?"',
              'A - Allow: "It\'s okay to feel this way"',
              'I - Investigate: "Where do I feel this in my body?"',
              'N - Non-attachment: "This feeling will pass"'
            ],
          ),
          LessonSlide(
            id: 'slide_4_4_3',
            title: 'Emotion Regulation Strategies',
            content: 'Different strategies work for different emotions and situations. Build a toolkit of approaches for various emotional challenges.',
            slideNumber: 3,
            bulletPoints: [
              'For anxiety: Deep breathing, grounding techniques',
              'For sadness: Gentle movement, creative expression',
              'For anger: Physical activity, writing, talking',
              'For loneliness: Reach out to others, self-compassion'
            ],
          ),
          LessonSlide(
            id: 'slide_4_4_4',
            title: 'Building Emotional Tolerance',
            content: 'Recovery involves learning to tolerate difficult emotions without immediately trying to escape them through food or other means.',
            slideNumber: 4,
            bulletPoints: [
              'Practice sitting with emotions for short periods',
              'Remember: Emotions are temporary waves',
              'Use self-compassion during difficult moments',
              'Celebrate small victories in emotional tolerance'
            ],
            additionalInfo: 'Remember: Learning to manage emotions takes time and practice. Be patient and gentle with yourself as you develop these skills.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 4.5 - 5 slides
      Lesson(
        id: 'lesson_4_5',
        title: 'Building Your Support System',
        description: 'Creating and maintaining supportive relationships for your recovery journey.',
        chapterNumber: 4,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_4_5_1',
            title: 'Why Support Matters',
            content: 'Recovery is easier with support. Having people who understand and encourage your journey can make a significant difference in your success.',
            slideNumber: 1,
            bulletPoints: [
              'Recovery is challenging to do alone',
              'Support provides encouragement and accountability',
              'Others can offer perspective and advice',
              'Sharing struggles reduces shame and isolation'
            ],
          ),
          LessonSlide(
            id: 'slide_4_5_2',
            title: 'Types of Support',
            content: 'Support can come from various sources and take different forms. Consider both professional and personal support options.',
            slideNumber: 2,
            bulletPoints: [
              'Professional: Therapists, counselors, nutritionists',
              'Personal: Family, friends, partners',
              'Peer: Support groups, online communities',
              'Spiritual: Religious communities, mentors'
            ],
          ),
          LessonSlide(
            id: 'slide_4_5_3',
            title: 'Choosing Your Support Team',
            content: 'Look for people who are non-judgmental, trustworthy, and willing to learn about eating disorder recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Choose non-judgmental, trustworthy people',
              'Look for those willing to learn and understand',
              'Avoid diet-focused or triggering individuals',
              'Quality is more important than quantity'
            ],
          ),
          LessonSlide(
            id: 'slide_4_5_4',
            title: 'Communicating Your Needs',
            content: 'Be clear about what kind of support you need. This might include listening, encouragement, accountability, or help with specific situations.',
            slideNumber: 4,
            bulletPoints: [
              'Be specific about what you need',
              'Explain your recovery goals and challenges',
              'Set boundaries around food and diet talk',
              'Ask for what would be most helpful'
            ],
          ),
          LessonSlide(
            id: 'slide_4_5_5',
            title: 'Maintaining Relationships',
            content: 'Support is a two-way street. Show appreciation for your supporters and be willing to offer support to others when appropriate.',
            slideNumber: 5,
            bulletPoints: [
              'Express gratitude regularly',
              'Be there for your supporters too',
              'Communicate openly about your needs',
              'Remember that relationships evolve',
              'Professional support may be needed alongside personal support'
            ],
            additionalInfo: 'Remember: Building a support system takes time. Start with one or two trusted people and gradually expand your network.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 5: REBUILDING YOUR RELATIONSHIP WITH FOOD - 6 lessons

      // Lesson 5.1 - 4 slides
      Lesson(
        id: 'lesson_5_1',
        title: 'Food Rules vs. Food Freedom',
        description: 'Understanding how food rules contribute to binge eating and moving toward food freedom.',
        chapterNumber: 5,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_5_1_1',
            title: 'What Are Food Rules?',
            content: 'Food rules are rigid guidelines about what, when, how much, or how to eat. While some structure is helpful, rigid rules often backfire and contribute to binge eating.',
            slideNumber: 1,
            bulletPoints: [
              'Rigid guidelines about eating',
              'Often learned from diet culture',
              'Can feel safe but are often restrictive',
              'May contribute to binge-restrict cycle'
            ],
          ),
          LessonSlide(
            id: 'slide_5_1_2',
            title: 'Common Problematic Food Rules',
            content: 'Many food rules seem healthy but can be too rigid and create an unhealthy relationship with food.',
            slideNumber: 2,
            bulletPoints: [
              '"Never eat after 7 PM"',
              '"Carbs are bad"',
              '"I must finish everything on my plate"',
              '"Dessert is only for special occasions"',
              '"I can only eat X calories per day"'
            ],
          ),
          LessonSlide(
            id: 'slide_5_1_3',
            title: 'How Rules Lead to Binging',
            content: 'Rigid food rules create psychological and physical restriction, which often leads to feelings of deprivation and eventual loss of control around food.',
            slideNumber: 3,
            bulletPoints: [
              'Rules create psychological restriction',
              'Restriction leads to feelings of deprivation',
              'Deprivation increases food preoccupation',
              'Eventually leads to "breaking" rules and binging'
            ],
          ),
          LessonSlide(
            id: 'slide_5_1_4',
            title: 'Moving Toward Food Freedom',
            content: 'Food freedom means trusting your body and making food choices based on hunger, satisfaction, and how foods make you feel, rather than rigid rules.',
            slideNumber: 4,
            bulletPoints: [
              'Trust your body\'s signals',
              'Make choices based on how you feel',
              'All foods can fit in a balanced approach',
              'Flexibility over rigidity',
              'Permission to eat what satisfies you'
            ],
            additionalInfo: 'Remember: Moving from food rules to food freedom is a gradual process. Be patient with yourself as you learn to trust your body again.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 5.2 - 5 slides
      Lesson(
        id: 'lesson_5_2',
        title: 'Making Peace with All Foods',
        description: 'Learning to include all types of foods in your eating without guilt or restriction.',
        chapterNumber: 5,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_5_2_1',
            title: 'The Forbidden Fruit Effect',
            content: 'When we label foods as "forbidden" or "bad," we often want them more. This psychological reactance can lead to obsessive thoughts and eventual binge eating.',
            slideNumber: 1,
            bulletPoints: [
              'Forbidden foods become more appealing',
              'Creates obsessive thoughts about restricted foods',
              'Leads to feeling out of control when eating them',
              'Psychological reactance increases desire'
            ],
          ),
          LessonSlide(
            id: 'slide_5_2_2',
            title: 'Neutralizing Food Morality',
            content: 'Foods are not inherently good or bad - they\'re just foods with different nutritional profiles. Removing moral judgment helps reduce food anxiety.',
            slideNumber: 2,
            bulletPoints: [
              'Foods don\'t have moral value',
              'All foods provide some form of nourishment',
              'Some foods nourish the body, others the soul',
              'Balance comes naturally without moral judgment'
            ],
          ),
          LessonSlide(
            id: 'slide_5_2_3',
            title: 'The Habituation Process',
            content: 'When previously forbidden foods become truly allowed, their appeal often decreases naturally. This is called habituation.',
            slideNumber: 3,
            bulletPoints: [
              'Habituation: decreased response to repeated exposure',
              'Forbidden foods lose their special appeal',
              'Natural preferences emerge without restriction',
              'Body naturally seeks variety and balance'
            ],
          ),
          LessonSlide(
            id: 'slide_5_2_4',
            title: 'Practical Steps to Food Peace',
            content: 'Start by giving yourself unconditional permission to eat foods you\'ve been restricting, while practicing mindful eating to notice how they affect you.',
            slideNumber: 4,
            bulletPoints: [
              'Give yourself unconditional permission to eat',
              'Start with less triggering foods first',
              'Practice mindful eating to notice effects',
              'Remove judgment from food choices'
            ],
          ),
          LessonSlide(
            id: 'slide_5_2_5',
            title: 'Gentle Nutrition',
            content: 'Once you\'ve made peace with food, you can incorporate gentle nutrition - making food choices that honor both your taste preferences and your health.',
            slideNumber: 5,
            bulletPoints: [
              'Honor both taste and health',
              'Choose foods that make you feel good',
              'No food is off-limits',
              'Progress, not perfection',
              'Trust emerges over time'
            ],
            additionalInfo: 'Remember: Making peace with food takes time. Some foods may feel scary at first, and that\'s completely normal.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 5.3 - 6 slides
      Lesson(
        id: 'lesson_5_3',
        title: 'Intuitive Eating Principles',
        description: 'Understanding the core principles of intuitive eating and how they support recovery.',
        chapterNumber: 5,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_5_3_1',
            title: 'What is Intuitive Eating?',
            content: 'Intuitive eating is an approach that honors your internal cues for hunger, fullness, and satisfaction while rejecting diet mentality.',
            slideNumber: 1,
            bulletPoints: [
              'Honor internal hunger and fullness cues',
              'Reject diet mentality and food rules',
              'Find satisfaction in eating experiences',
              'Respect your body and its needs'
            ],
          ),
          LessonSlide(
            id: 'slide_5_3_2',
            title: 'Rejecting Diet Mentality',
            content: 'The first principle involves letting go of the hope that the next diet will work and recognizing how diet mentality has harmed your relationship with food.',
            slideNumber: 2,
            bulletPoints: [
              'Recognize diets don\'t work long-term',
              'Let go of the "thin ideal"',
              'Stop moral judgment of food choices',
              'Release guilt and shame around eating'
            ],
          ),
          LessonSlide(
            id: 'slide_5_3_3',
            title: 'Honoring Hunger and Fullness',
            content: 'Learning to recognize and respond to your body\'s biological signals for when to start and stop eating.',
            slideNumber: 3,
            bulletPoints: [
              'Eat when physically hungry',
              'Stop when comfortably satisfied',
              'Respect your body\'s energy needs',
              'Trust your body\'s wisdom'
            ],
          ),
          LessonSlide(
            id: 'slide_5_3_4',
            title: 'Making Peace with Food',
            content: 'Giving yourself unconditional permission to eat helps prevent the feeling of deprivation that can lead to binge eating.',
            slideNumber: 4,
            bulletPoints: [
              'Unconditional permission to eat',
              'No foods are forbidden',
              'Challenge food police thoughts',
              'Reduce deprivation and preoccupation'
            ],
          ),
          LessonSlide(
            id: 'slide_5_3_5',
            title: 'Discovering Satisfaction',
            content: 'When you eat what you really want in a comfortable environment, it\'s easier to feel satisfied and naturally stop eating.',
            slideNumber: 5,
            bulletPoints: [
              'Eat foods you truly want',
              'Create pleasant eating environments',
              'Pay attention to taste and texture',
              'Satisfaction helps with natural stopping'
            ],
          ),
          LessonSlide(
            id: 'slide_5_3_6',
            title: 'Respecting Your Body',
            content: 'Body respect involves accepting your genetic blueprint and treating your body with dignity, regardless of its size.',
            slideNumber: 6,
            bulletPoints: [
              'Accept your genetic blueprint',
              'Treat your body with dignity',
              'Focus on health behaviors, not weight',
              'Appreciate what your body can do'
            ],
            additionalInfo: 'Remember: Intuitive eating is a journey, not a destination. Be patient with yourself as you rediscover your body\'s natural wisdom.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 5.4 - 5 slides
      Lesson(
        id: 'lesson_5_4',
        title: 'Dealing with Food Cravings',
        description: 'Understanding cravings and learning healthy ways to respond to them.',
        chapterNumber: 5,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_5_4_1',
            title: 'Understanding Cravings',
            content: 'Cravings are normal and provide valuable information about your body\'s needs, emotional state, or level of restriction.',
            slideNumber: 1,
            bulletPoints: [
              'Cravings are normal and informative',
              'May indicate physical or emotional needs',
              'Often increase with restriction',
              'Not a sign of weakness or lack of willpower'
            ],
          ),
          LessonSlide(
            id: 'slide_5_4_2',
            title: 'Types of Cravings',
            content: 'Cravings can be physical (body needs nutrients), emotional (seeking comfort), or habitual (triggered by routines or environments).',
            slideNumber: 2,
            bulletPoints: [
              'Physical: Body needs specific nutrients',
              'Emotional: Seeking comfort or coping',
              'Habitual: Triggered by routines or places',
              'Restriction-induced: Result of deprivation'
            ],
          ),
          LessonSlide(
            id: 'slide_5_4_3',
            title: 'The Craving Investigation',
            content: 'Before acting on a craving, pause to investigate what might be driving it. This awareness helps you respond more thoughtfully.',
            slideNumber: 3,
            bulletPoints: [
              'Pause before acting on the craving',
              'Ask: "What am I really craving?"',
              'Consider: Physical hunger, emotions, habits',
              'Notice: "When did this craving start?"'
            ],
          ),
          LessonSlide(
            id: 'slide_5_4_4',
            title: 'Responding to Cravings',
            content: 'Sometimes the best response is to honor the craving mindfully. Other times, addressing the underlying need may be more helpful.',
            slideNumber: 4,
            bulletPoints: [
              'Honor physical cravings mindfully',
              'Address emotional needs directly when possible',
              'Challenge restriction-induced cravings by eating regularly',
              'Practice self-compassion regardless of choice'
            ],
          ),
          LessonSlide(
            id: 'slide_5_4_5',
            title: 'Craving Myths',
            content: 'Many beliefs about cravings are unhelpful myths. Understanding the truth can help you respond more kindly to yourself.',
            slideNumber: 5,
            bulletPoints: [
              'Myth: Cravings mean you lack willpower',
              'Truth: Cravings are biological and psychological signals',
              'Myth: You should always resist cravings',
              'Truth: Sometimes honoring cravings prevents binges',
              'Myth: Healthy people don\'t have cravings',
              'Truth: Everyone experiences cravings'
            ],
            additionalInfo: 'Remember: Learning to work with your cravings, rather than against them, often leads to more peace and less preoccupation with food.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 5.5 - 5 slides
      Lesson(
        id: 'lesson_5_5',
        title: 'Eating for Energy and Mood',
        description: 'Understanding how food choices affect your energy levels and emotional well-being.',
        chapterNumber: 5,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_5_5_1',
            title: 'Food as Fuel',
            content: 'Food provides the energy your body needs to function. Understanding how different foods affect your energy can help guide your choices.',
            slideNumber: 1,
            bulletPoints: [
              'Food provides energy for all body functions',
              'Different foods affect energy differently',
              'Balanced meals provide steady energy',
              'Regular eating prevents energy crashes'
            ],
          ),
          LessonSlide(
            id: 'slide_5_5_2',
            title: 'Blood Sugar and Energy',
            content: 'Eating regularly and including protein, healthy fats, and complex carbohydrates helps maintain stable blood sugar and consistent energy.',
            slideNumber: 2,
            bulletPoints: [
              'Regular meals stabilize blood sugar',
              'Protein helps maintain steady energy',
              'Complex carbs provide sustained fuel',
              'Healthy fats support satiety and mood'
            ],
          ),
          LessonSlide(
            id: 'slide_5_5_3',
            title: 'Food and Mood Connection',
            content: 'What you eat can significantly impact your mood, anxiety levels, and overall mental well-being throughout the day.',
            slideNumber: 3,
            bulletPoints: [
              'Food directly affects brain chemistry',
              'Skipping meals can increase anxiety',
              'Certain nutrients support mood stability',
              'Hydration also affects mood and energy'
            ],
          ),
          LessonSlide(
            id: 'slide_5_5_4',
            title: 'Energy-Supporting Food Patterns',
            content: 'Consistent meal timing, balanced nutrition, and adequate hydration support steady energy and stable mood throughout the day.',
            slideNumber: 4,
            bulletPoints: [
              'Eat at regular intervals (3-4 hours)',
              'Include protein at each meal and snack',
              'Don\'t skip breakfast',
              'Stay adequately hydrated',
              'Listen to your body\'s needs'
            ],
          ),
          LessonSlide(
            id: 'slide_5_5_5',
            title: 'Gentle Nutrition in Practice',
            content: 'You can honor your health while also honoring your cravings and satisfaction. It\'s about finding balance, not perfection.',
            slideNumber: 5,
            bulletPoints: [
              'Health and satisfaction can coexist',
              'Focus on how foods make you feel',
              'Progress, not perfection',
              'All foods can fit in a balanced approach',
              'Trust develops over time'
            ],
            additionalInfo: 'Remember: Paying attention to how foods affect your energy and mood is information, not judgment. Use this awareness with self-compassion.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 5.6 - 6 slides
      Lesson(
        id: 'lesson_5_6',
        title: 'Overcoming Food Guilt and Shame',
        description: 'Learning to eat without guilt and shame, regardless of your food choices.',
        chapterNumber: 5,
        lessonNumber: 6,
        slides: [
          LessonSlide(
            id: 'slide_5_6_1',
            title: 'Understanding Food Guilt',
            content: 'Food guilt is the negative emotion we feel about eating certain foods or amounts. This guilt often perpetuates the binge-restrict cycle.',
            slideNumber: 1,
            bulletPoints: [
              'Negative emotions about food choices',
              'Often learned from diet culture',
              'Perpetuates binge-restrict cycle',
              'Not based on actual harm caused'
            ],
          ),
          LessonSlide(
            id: 'slide_5_6_2',
            title: 'The Shame Spiral',
            content: 'Food shame goes deeper than guilt - it\'s about feeling like a bad person for eating certain ways. This shame can lead to isolation and more problematic eating.',
            slideNumber: 2,
            bulletPoints: [
              'Shame: "I am bad" vs. Guilt: "I did something bad"',
              'Creates isolation and secrecy around food',
              'Leads to more problematic eating behaviors',
              'Prevents seeking help and support'
            ],
          ),
          LessonSlide(
            id: 'slide_5_6_3',
            title: 'Where Guilt and Shame Come From',
            content: 'Food guilt and shame are often learned from diet culture, family messages, and societal expectations about eating and body size.',
            slideNumber: 3,
            bulletPoints: [
              'Diet culture messages about "good" and "bad" foods',
              'Family attitudes toward food and eating',
              'Social media and advertising',
              'Healthcare providers\' weight bias',
              'Personal perfectionist tendencies'
            ],
          ),
          LessonSlide(
            id: 'slide_5_6_4',
            title: 'Challenging Guilt and Shame',
            content: 'Learning to identify and challenge thoughts that create food guilt and shame is essential for recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Notice thoughts that create guilt',
              'Ask: "Is this thought helpful or harmful?"',
              'Challenge black-and-white thinking',
              'Practice self-compassion instead of self-criticism'
            ],
          ),
          LessonSlide(
            id: 'slide_5_6_5',
            title: 'Self-Compassion Practices',
            content: 'Treating yourself with the same kindness you\'d show a good friend helps break the cycle of guilt and shame around food.',
            slideNumber: 5,
            bulletPoints: [
              'Speak to yourself like a good friend',
              'Acknowledge that suffering is part of human experience',
              'Practice mindful awareness of self-critical thoughts',
              'Remember: You deserve kindness regardless of food choices'
            ],
          ),
          LessonSlide(
            id: 'slide_5_6_6',
            title: 'Food Neutrality',
            content: 'The goal is to reach a place where food choices don\'t carry emotional weight - where eating is simply nourishing your body without moral implications.',
            slideNumber: 6,
            bulletPoints: [
              'Food choices don\'t define your worth',
              'Eating is morally neutral',
              'All bodies deserve nourishment',
              'Recovery means eating without emotional turmoil',
              'Peace with food is possible'
            ],
            additionalInfo: 'Remember: Overcoming food guilt and shame takes time and practice. Be patient with yourself as you learn to eat with peace and neutrality.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 6: BODY IMAGE AND SELF-ACCEPTANCE - 6 lessons

      // Lesson 6.1 - 4 slides
      Lesson(
        id: 'lesson_6_1',
        title: 'Understanding Body Image',
        description: 'Exploring what body image is and how it affects your relationship with food and yourself.',
        chapterNumber: 6,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_6_1_1',
            title: 'What is Body Image?',
            content: 'Body image is how you think, feel, and behave in relation to your body. It includes your perceptions, emotions, and actions regarding your physical self.',
            slideNumber: 1,
            bulletPoints: [
              'How you think about your body',
              'How you feel about your body',
              'How you behave toward your body',
              'Your perception of how others see you'
            ],
          ),
          LessonSlide(
            id: 'slide_6_1_2',
            title: 'Components of Body Image',
            content: 'Body image has multiple components: perceptual (how you see yourself), cognitive (thoughts about your body), affective (feelings), and behavioral (actions).',
            slideNumber: 2,
            bulletPoints: [
              'Perceptual: How you see your body',
              'Cognitive: Thoughts and beliefs about your body',
              'Affective: Feelings and emotions about your body',
              'Behavioral: Actions related to your body'
            ],
          ),
          LessonSlide(
            id: 'slide_6_1_3',
            title: 'Body Image and Eating Disorders',
            content: 'Poor body image often contributes to eating disorders and can make recovery more challenging. Improving body image is an important part of healing.',
            slideNumber: 3,
            bulletPoints: [
              'Poor body image fuels eating disorders',
              'Body dissatisfaction drives restrictive behaviors',
              'Negative body image increases anxiety around food',
              'Healing body image supports recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_6_1_4',
            title: 'Body Image Can Change',
            content: 'Body image is learned and can be modified. With practice and patience, you can develop a more positive and accepting relationship with your body.',
            slideNumber: 4,
            bulletPoints: [
              'Body image is learned, not fixed',
              'Can be improved with practice',
              'Small changes make big differences',
              'Recovery includes body acceptance'
            ],
            additionalInfo: 'Remember: Improving body image is a journey, not a destination. Be patient with yourself as you work toward greater body acceptance.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 6.2 - 5 slides
      Lesson(
        id: 'lesson_6_2',
        title: 'Challenging Negative Body Thoughts',
        description: 'Learning to identify and challenge negative thoughts about your body.',
        chapterNumber: 6,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_6_2_1',
            title: 'Common Negative Body Thoughts',
            content: 'Negative body thoughts are often automatic, repetitive, and exaggerated. Learning to recognize them is the first step to changing them.',
            slideNumber: 1,
            bulletPoints: [
              '"I\'m so fat/ugly/disgusting"',
              '"Everyone is judging my body"',
              '"I can\'t wear that because of how I look"',
              '"I hate my [body part]"',
              '"I need to lose weight to be acceptable"'
            ],
          ),
          LessonSlide(
            id: 'slide_6_2_2',
            title: 'The Impact of Body Checking',
            content: 'Body checking behaviors like frequent weighing, mirror checking, or clothes fitting rituals often increase negative body thoughts and distress.',
            slideNumber: 2,
            bulletPoints: [
              'Frequent weighing or measuring',
              'Excessive mirror checking',
              'Comparing body parts to others',
              'Clothes fitting rituals',
              'These behaviors increase distress'
            ],
          ),
          LessonSlide(
            id: 'slide_6_2_3',
            title: 'Thought Challenging Techniques',
            content: 'When you notice negative body thoughts, try asking yourself: Is this thought helpful? Is it based on facts? What would I tell a friend?',
            slideNumber: 3,
            bulletPoints: [
              'Is this thought helpful or harmful?',
              'Is this based on facts or feelings?',
              'What would I tell a friend in this situation?',
              'How does this thought affect my behavior?'
            ],
          ),
          LessonSlide(
            id: 'slide_6_2_4',
            title: 'Reframing Negative Thoughts',
            content: 'Practice replacing negative body thoughts with more neutral or compassionate ones. This takes practice but becomes easier over time.',
            slideNumber: 4,
            bulletPoints: [
              'Instead of "I hate my body" → "My body is working hard for me"',
              'Instead of "I\'m so fat" → "I\'m having a difficult body day"',
              'Instead of "I\'m disgusting" → "I deserve kindness"',
              'Focus on what your body does, not how it looks'
            ],
          ),
          LessonSlide(
            id: 'slide_6_2_5',
            title: 'Body Neutrality',
            content: 'Body neutrality focuses on what your body can do rather than how it looks. This can be easier to achieve than body positivity.',
            slideNumber: 5,
            bulletPoints: [
              'Focus on function over form',
              'Appreciate what your body does for you',
              'Neutral thoughts: "My body is my body"',
              'Less pressure than forced positivity',
              'A stepping stone to acceptance'
            ],
            additionalInfo: 'Remember: Changing negative thought patterns takes time and practice. Be patient with yourself as you develop new ways of thinking.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 6.3 - 4 slides
      Lesson(
        id: 'lesson_6_3',
        title: 'Media Literacy and Body Image',
        description: 'Understanding how media influences body image and developing critical media literacy skills.',
        chapterNumber: 6,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_6_3_1',
            title: 'Media\'s Impact on Body Image',
            content: 'Media constantly exposes us to unrealistic beauty standards and altered images, which can negatively impact how we view our own bodies.',
            slideNumber: 1,
            bulletPoints: [
              'Unrealistic beauty standards in media',
              'Heavily edited and filtered images',
              'Narrow representation of body types',
              'Constant exposure affects self-perception'
            ],
          ),
          LessonSlide(
            id: 'slide_6_3_2',
            title: 'The Reality Behind Images',
            content: 'Most images in media are heavily edited, filtered, or manipulated. Even the models and influencers don\'t look like their edited photos in real life.',
            slideNumber: 2,
            bulletPoints: [
              'Professional lighting and angles',
              'Digital editing and filters',
              'Models don\'t always look like their photos',
              'Even "candid" shots are often curated'
            ],
          ),
          LessonSlide(
            id: 'slide_6_3_3',
            title: 'Curating Your Media Diet',
            content: 'Actively choose media that makes you feel good about yourself. Unfollow accounts that trigger negative body thoughts.',
            slideNumber: 3,
            bulletPoints: [
              'Unfollow triggering accounts',
              'Follow body-positive and diverse creators',
              'Limit exposure to diet culture content',
              'Seek out authentic, unfiltered content',
              'Your feed should inspire, not trigger'
            ],
          ),
          LessonSlide(
            id: 'slide_6_3_4',
            title: 'Critical Media Consumption',
            content: 'Develop the habit of questioning what you see in media. Ask yourself: What is this trying to sell me? How does this make me feel?',
            slideNumber: 4,
            bulletPoints: [
              'Question: "What is this trying to sell me?"',
              'Notice: "How does this make me feel?"',
              'Remember: These images aren\'t reality',
              'Choose media that supports your recovery'
            ],
            additionalInfo: 'Remember: You have control over your media consumption. Choose content that supports your well-being and recovery journey.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 6.4 - 5 slides
      Lesson(
        id: 'lesson_6_4',
        title: 'Body Appreciation and Gratitude',
        description: 'Learning to appreciate your body for what it does rather than how it looks.',
        chapterNumber: 6,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_6_4_1',
            title: 'Shifting Focus to Function',
            content: 'Instead of focusing on how your body looks, try appreciating all the amazing things your body does for you every day.',
            slideNumber: 1,
            bulletPoints: [
              'Your heart beats automatically',
              'Your lungs breathe without conscious effort',
              'Your body heals cuts and bruises',
              'Your muscles allow you to move and hug',
              'Your senses let you experience the world'
            ],
          ),
          LessonSlide(
            id: 'slide_6_4_2',
            title: 'Daily Body Gratitude',
            content: 'Practice thanking your body for specific things it does. This helps shift your relationship from criticism to appreciation.',
            slideNumber: 2,
            bulletPoints: [
              'Thank your legs for carrying you',
              'Appreciate your arms for allowing hugs',
              'Acknowledge your hands for creating things',
              'Be grateful for your eyes for seeing beauty',
              'Honor your body\'s resilience and strength'
            ],
          ),
          LessonSlide(
            id: 'slide_6_4_3',
            title: 'Body Appreciation Practices',
            content: 'Regular practices can help you develop a more appreciative relationship with your body over time.',
            slideNumber: 3,
            bulletPoints: [
              'Write daily body gratitude lists',
              'Practice gentle movement you enjoy',
              'Engage in nurturing self-care',
              'Speak kindly to your body',
              'Focus on comfort over appearance'
            ],
          ),
          LessonSlide(
            id: 'slide_6_4_4',
            title: 'Your Body\'s Wisdom',
            content: 'Your body has incredible wisdom - it knows how to heal, when to rest, when to eat, and how to maintain balance. Learning to trust this wisdom is part of recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Your body knows how to heal itself',
              'It signals when you need rest or fuel',
              'It maintains complex internal balance',
              'It adapts to countless daily challenges',
              'Trust in your body\'s innate wisdom'
            ],
          ),
          LessonSlide(
            id: 'slide_6_4_5',
            title: 'Body Respect in Action',
            content: 'Treating your body with respect means nourishing it adequately, moving it gently, resting when needed, and speaking to it kindly.',
            slideNumber: 5,
            bulletPoints: [
              'Nourish your body adequately',
              'Move in ways that feel good',
              'Rest when your body needs it',
              'Speak to your body with kindness',
              'Honor your body\'s needs and limits'
            ],
            additionalInfo: 'Remember: Body appreciation is a practice, not a destination. Small daily acts of body kindness add up to significant change over time.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 6.5 - 5 slides
      Lesson(
        id: 'lesson_6_5',
        title: 'Dealing with Weight Stigma',
        description: 'Understanding weight stigma and developing resilience against weight-based discrimination.',
        chapterNumber: 6,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_6_5_1',
            title: 'What is Weight Stigma?',
            content: 'Weight stigma refers to negative attitudes, beliefs, and discrimination toward individuals based on their weight or size.',
            slideNumber: 1,
            bulletPoints: [
              'Negative attitudes based on weight',
              'Discrimination in healthcare, employment, etc.',
              'Assumption that weight equals health or worth',
              'Harmful to people of all sizes'
            ],
          ),
          LessonSlide(
            id: 'slide_6_5_2',
            title: 'Forms of Weight Stigma',
            content: 'Weight stigma can be explicit (direct comments) or implicit (assumptions and biases). It occurs in healthcare, workplace, social settings, and media.',
            slideNumber: 2,
            bulletPoints: [
              'Explicit: Direct comments about weight',
              'Implicit: Assumptions and biases',
              'Healthcare bias and discrimination',
              'Workplace and social discrimination',
              'Media representation and messaging'
            ],
          ),
          LessonSlide(
            id: 'slide_6_5_3',
            title: 'Impact of Weight Stigma',
            content: 'Experiencing weight stigma can lead to increased stress, depression, anxiety, and ironically, weight gain. It also reduces healthcare seeking.',
            slideNumber: 3,
            bulletPoints: [
              'Increased stress and mental health issues',
              'Reduced healthcare seeking',
              'Shame and social isolation',
              'Paradoxically associated with weight gain',
              'Decreased quality of life'
            ],
          ),
          LessonSlide(
            id: 'slide_6_5_4',
            title: 'Building Resilience',
            content: 'Developing resilience against weight stigma involves challenging internalized weight bias and building a support network.',
            slideNumber: 4,
            bulletPoints: [
              'Challenge your own weight biases',
              'Build a supportive community',
              'Advocate for yourself in healthcare',
              'Practice self-compassion',
              'Remember: Weight doesn\'t determine worth'
            ],
          ),
          LessonSlide(
            id: 'slide_6_5_5',
            title: 'Response Strategies',
            content: 'When faced with weight stigma, you can choose how to respond - from direct confrontation to internal boundary setting.',
            slideNumber: 5,
            bulletPoints: [
              'Set boundaries with family and friends',
              'Prepare responses to common comments',
              'Choose healthcare providers wisely',
              'Focus on your recovery, not others\' opinions',
              'Remember: You don\'t owe anyone an explanation'
            ],
            additionalInfo: 'Remember: Weight stigma says nothing about you and everything about our society\'s harmful biases. Your worth is not determined by your weight.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 6.6 - 6 slides
      Lesson(
        id: 'lesson_6_6',
        title: 'Developing Self-Compassion',
        description: 'Learning to treat yourself with kindness and understanding, especially during difficult times.',
        chapterNumber: 6,
        lessonNumber: 6,
        slides: [
          LessonSlide(
            id: 'slide_6_6_1',
            title: 'What is Self-Compassion?',
            content: 'Self-compassion involves treating yourself with the same kindness you would show a good friend, especially during times of struggle or failure.',
            slideNumber: 1,
            bulletPoints: [
              'Kindness toward yourself during difficulty',
              'Recognition that suffering is part of human experience',
              'Mindful awareness of your struggles',
              'Alternative to harsh self-criticism'
            ],
          ),
          LessonSlide(
            id: 'slide_6_6_2',
            title: 'Three Components of Self-Compassion',
            content: 'Self-compassion has three main components: self-kindness (vs. self-judgment), common humanity (vs. isolation), and mindfulness (vs. over-identification).',
            slideNumber: 2,
            bulletPoints: [
              'Self-kindness vs. self-judgment',
              'Common humanity vs. isolation',
              'Mindfulness vs. over-identification',
              'All three work together for healing'
            ],
          ),
          LessonSlide(
            id: 'slide_6_6_3',
            title: 'Self-Compassion in Recovery',
            content: 'Self-compassion is especially important in eating disorder recovery, as it helps reduce shame and supports sustained behavior change.',
            slideNumber: 3,
            bulletPoints: [
              'Reduces shame and self-criticism',
              'Supports sustained behavior change',
              'Helps you bounce back from setbacks',
              'Creates emotional safety for healing',
              'More effective than self-criticism'
            ],
          ),
          LessonSlide(
            id: 'slide_6_6_4',
            title: 'Self-Compassion Practices',
            content: 'Regular self-compassion practices can help you develop this skill over time. Start with small moments of kindness toward yourself.',
            slideNumber: 4,
            bulletPoints: [
              'Place hand on heart during difficult moments',
              'Speak to yourself like a good friend',
              'Write yourself compassionate letters',
              'Practice loving-kindness meditation',
              'Use self-compassion breaks during struggles'
            ],
          ),
          LessonSlide(
            id: 'slide_6_6_5',
            title: 'Common Self-Compassion Obstacles',
            content: 'Many people resist self-compassion, thinking it will make them lazy or self-indulgent. Research shows the opposite is true.',
            slideNumber: 5,
            bulletPoints: [
              'Fear: "Self-compassion will make me lazy"',
              'Truth: It increases motivation and resilience',
              'Fear: "I don\'t deserve compassion"',
              'Truth: All humans deserve kindness',
              'Self-compassion strengthens rather than weakens'
            ],
          ),
          LessonSlide(
            id: 'slide_6_6_6',
            title: 'Self-Compassion and Body Image',
            content: 'Practicing self-compassion toward your body can significantly improve body image and reduce body-related distress.',
            slideNumber: 6,
            bulletPoints: [
              'Speak kindly to your body',
              'Forgive your body for not being "perfect"',
              'Appreciate your body\'s efforts',
              'Treat your body with gentleness',
              'Remember: Your body deserves compassion'
            ],
            additionalInfo: 'Remember: Self-compassion is a skill that improves with practice. Be patient with yourself as you learn to be your own best friend.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 7: RELAPSE PREVENTION - 4 lessons

      // Lesson 7.1 - 5 slides
      Lesson(
        id: 'lesson_7_1',
        title: 'Understanding Setbacks vs. Relapse',
        description: 'Learning the difference between temporary setbacks and full relapse, and how to respond to each.',
        chapterNumber: 7,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_7_1_1',
            title: 'Recovery Is Not Linear',
            content: 'Recovery from binge eating is not a straight line. Expect ups and downs as you heal and develop new patterns.',
            slideNumber: 1,
            bulletPoints: [
              'Recovery has natural ups and downs',
              'Progress is not always forward',
              'Setbacks are part of the process',
              'Each challenge is a learning opportunity'
            ],
          ),
          LessonSlide(
            id: 'slide_7_1_2',
            title: 'What Is a Setback?',
            content: 'A setback is a temporary return to old behaviors during recovery. It\'s normal, expected, and doesn\'t erase your progress.',
            slideNumber: 2,
            bulletPoints: [
              'Temporary return to old behaviors',
              'Normal and expected part of recovery',
              'Doesn\'t erase previous progress',
              'An opportunity to learn and adjust'
            ],
          ),
          LessonSlide(
            id: 'slide_7_1_3',
            title: 'What Is a Relapse?',
            content: 'A relapse is a more sustained return to problematic eating patterns, often accompanied by giving up on recovery efforts.',
            slideNumber: 3,
            bulletPoints: [
              'Sustained return to problematic patterns',
              'Often involves giving up on recovery',
              'May include returning to restrictive behaviors',
              'Can be prevented with early intervention'
            ],
          ),
          LessonSlide(
            id: 'slide_7_1_4',
            title: 'The Key Difference',
            content: 'The main difference is in your response: setbacks involve getting back on track quickly, while relapse involves abandoning recovery efforts.',
            slideNumber: 4,
            bulletPoints: [
              'Setback: Quick return to recovery efforts',
              'Relapse: Abandoning recovery altogether',
              'Your response determines the outcome',
              'Self-compassion prevents setbacks from becoming relapses'
            ],
          ),
          LessonSlide(
            id: 'slide_7_1_5',
            title: 'Responding to Setbacks',
            content: 'When setbacks occur, practice self-compassion, learn from the experience, and gently return to your recovery practices.',
            slideNumber: 5,
            bulletPoints: [
              'Practice self-compassion, not self-criticism',
              'Learn from what triggered the setback',
              'Gently return to recovery practices',
              'Reach out for support if needed',
              'Remember: One binge doesn\'t define your recovery'
            ],
            additionalInfo: 'Remember: Setbacks are temporary detours, not permanent destinations. How you respond to them determines your recovery success.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 7.2 - 6 slides
      Lesson(
        id: 'lesson_7_2',
        title: 'Creating Your Relapse Prevention Plan',
        description: 'Developing a personalized plan to prevent and respond to potential relapses.',
        chapterNumber: 7,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_7_2_1',
            title: 'Why You Need a Plan',
            content: 'A relapse prevention plan helps you recognize warning signs early and provides specific strategies to maintain your recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Recognizes warning signs early',
              'Provides specific strategies to use',
              'Reduces panic during difficult moments',
              'Increases confidence in recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_7_2_2',
            title: 'Identifying Your Warning Signs',
            content: 'Warning signs are thoughts, feelings, or behaviors that typically precede a binge episode. Everyone\'s are different.',
            slideNumber: 2,
            bulletPoints: [
              'Thoughts: "I\'ve already messed up today"',
              'Feelings: Increased stress, loneliness, or anxiety',
              'Behaviors: Skipping meals, isolating, body checking',
              'Situations: Specific times, places, or events'
            ],
          ),
          LessonSlide(
            id: 'slide_7_2_3',
            title: 'Your Coping Strategy Toolkit',
            content: 'List specific strategies you\'ll use when warning signs appear. Include immediate actions and longer-term supports.',
            slideNumber: 3,
            bulletPoints: [
              'Immediate actions: STOP technique, breathing',
              'Physical strategies: Walk, stretch, bath',
              'Mental strategies: Journaling, calling friend',
              'Environmental: Change location, remove triggers'
            ],
          ),
          LessonSlide(
            id: 'slide_7_2_4',
            title: 'Your Support Network',
            content: 'Identify specific people you can reach out to for support, and plan what you\'ll say when you contact them.',
            slideNumber: 4,
            bulletPoints: [
              'List 3-5 people you can call',
              'Include their contact information',
              'Plan what you\'ll say: "I\'m struggling and need support"',
              'Include professional supports if available'
            ],
          ),
          LessonSlide(
            id: 'slide_7_2_5',
            title: 'Environmental Modifications',
            content: 'Consider changes to your environment that support recovery and reduce the likelihood of binge episodes.',
            slideNumber: 5,
            bulletPoints: [
              'Keep regular meal schedule reminders',
              'Remove or modify triggering foods if needed',
              'Create calming spaces in your home',
              'Plan for high-risk situations in advance'
            ],
          ),
          LessonSlide(
            id: 'slide_7_2_6',
            title: 'Regular Plan Review',
            content: 'Your relapse prevention plan should be a living document that you review and update regularly as you grow in recovery.',
            slideNumber: 6,
            bulletPoints: [
              'Review your plan monthly',
              'Update strategies as you learn what works',
              'Add new triggers as you identify them',
              'Celebrate your progress and growth'
            ],
            additionalInfo: 'Remember: Your relapse prevention plan is your safety net. The time to create it is when you\'re feeling stable, not during a crisis.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 7.3 - 4 slides
      Lesson(
        id: 'lesson_7_3',
        title: 'High-Risk Situations',
        description: 'Identifying and preparing for situations that increase the risk of binge episodes.',
        chapterNumber: 7,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_7_3_1',
            title: 'What Are High-Risk Situations?',
            content: 'High-risk situations are circumstances that increase your vulnerability to binge eating. They\'re different for everyone.',
            slideNumber: 1,
            bulletPoints: [
              'Situations that increase binge risk',
              'Different for everyone',
              'Can be predictable or unexpected',
              'Include emotional, social, and environmental factors'
            ],
          ),
          LessonSlide(
            id: 'slide_7_3_2',
            title: 'Common High-Risk Situations',
            content: 'While everyone\'s triggers are unique, some situations commonly increase binge risk across many people.',
            slideNumber: 2,
            bulletPoints: [
              'Social events with lots of food',
              'Times of high stress or major life changes',
              'Being alone for extended periods',
              'Holidays and celebrations',
              'After conflict or difficult emotions',
              'When overly hungry or tired'
            ],
          ),
          LessonSlide(
            id: 'slide_7_3_3',
            title: 'Planning for High-Risk Situations',
            content: 'The key is preparation. When you know a high-risk situation is coming, you can plan specific strategies in advance.',
            slideNumber: 3,
            bulletPoints: [
              'Identify your personal high-risk situations',
              'Plan specific coping strategies in advance',
              'Have a support person you can contact',
              'Practice self-care before and after',
              'Set realistic expectations for yourself'
            ],
          ),
          LessonSlide(
            id: 'slide_7_3_4',
            title: 'When Plans Don\'t Work',
            content: 'Sometimes despite your best planning, you may still struggle. This doesn\'t mean you\'ve failed - it means you\'re human.',
            slideNumber: 4,
            bulletPoints: [
              'Plans don\'t always work perfectly',
              'This doesn\'t mean you\'ve failed',
              'Learn from what happened',
              'Adjust your plan for next time',
              'Practice self-compassion'
            ],
            additionalInfo: 'Remember: The goal isn\'t to never struggle in high-risk situations, but to handle them more skillfully over time.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 7.4 - 5 slides
      Lesson(
        id: 'lesson_7_4',
        title: 'Building Long-Term Recovery',
        description: 'Strategies for maintaining recovery and continuing to grow beyond binge eating.',
        chapterNumber: 7,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_7_4_1',
            title: 'Recovery Is an Ongoing Process',
            content: 'Recovery isn\'t a destination you reach, but an ongoing process of growth, learning, and healing that continues throughout life.',
            slideNumber: 1,
            bulletPoints: [
              'Recovery is a lifelong process',
              'Continuous growth and learning',
              'Always opportunities for deeper healing',
              'Each stage brings new insights'
            ],
          ),
          LessonSlide(
            id: 'slide_7_4_2',
            title: 'Maintaining Recovery Practices',
            content: 'Even when you feel stable, maintaining certain recovery practices helps prevent gradual drift back toward old patterns.',
            slideNumber: 2,
            bulletPoints: [
              'Continue mindful eating practices',
              'Maintain regular meal patterns',
              'Keep using coping skills regularly',
              'Stay connected with support systems',
              'Practice ongoing self-compassion'
            ],
          ),
          LessonSlide(
            id: 'slide_7_4_3',
            title: 'Continued Growth Areas',
            content: 'Recovery opens up space to work on other areas of your life that may have been affected by your eating struggles.',
            slideNumber: 3,
            bulletPoints: [
              'Relationship improvements',
              'Career and life goals',
              'Physical health and fitness',
              'Creative pursuits and hobbies',
              'Spiritual or personal growth'
            ],
          ),
          LessonSlide(
            id: 'slide_7_4_4',
            title: 'Helping Others',
            content: 'Many people in recovery find meaning in helping others who are struggling with similar challenges.',
            slideNumber: 4,
            bulletPoints: [
              'Share your story when appropriate',
              'Mentor others in early recovery',
              'Volunteer with eating disorder organizations',
              'Advocate for better treatment and understanding'
            ],
          ),
          LessonSlide(
            id: 'slide_7_4_5',
            title: 'Celebrating Your Journey',
            content: 'Take time to acknowledge how far you\'ve come and celebrate the courage it takes to change your relationship with food.',
            slideNumber: 5,
            bulletPoints: [
              'Acknowledge your progress regularly',
              'Celebrate small and large victories',
              'Recognize your courage and strength',
              'Be proud of choosing recovery',
              'You deserve a peaceful relationship with food'
            ],
            additionalInfo: 'Remember: You have already shown incredible strength by committing to recovery. That strength will carry you forward.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 8: STRESS MANAGEMENT - 4 lessons

      // Lesson 8.1 - 5 slides
      Lesson(
        id: 'lesson_8_1',
        title: 'Understanding Stress and Eating',
        description: 'Exploring the connection between stress and eating behaviors, and why stress management is crucial for recovery.',
        chapterNumber: 8,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_8_1_1',
            title: 'The Stress-Eating Connection',
            content: 'Stress and eating are closely connected. Understanding this relationship is key to breaking the cycle of stress-induced binge eating.',
            slideNumber: 1,
            bulletPoints: [
              'Stress affects eating behaviors',
              'Can lead to under-eating or overeating',
              'Binge eating often serves as stress relief',
              'Breaking this cycle requires new coping skills'
            ],
          ),
          LessonSlide(
            id: 'slide_8_1_2',
            title: 'How Stress Affects Your Body',
            content: 'When you\'re stressed, your body releases hormones like cortisol that can increase appetite and cravings for high-calorie foods.',
            slideNumber: 2,
            bulletPoints: [
              'Stress hormones like cortisol increase appetite',
              'Cravings for high-calorie foods increase',
              'Blood sugar regulation is affected',
              'Digestion and nutrient absorption are impaired'
            ],
          ),
          LessonSlide(
            id: 'slide_8_1_3',
            title: 'Emotional Eating vs. Stress Eating',
            content: 'While related, emotional eating and stress eating have some differences in triggers and patterns.',
            slideNumber: 3,
            bulletPoints: [
              'Emotional eating: Response to feelings',
              'Stress eating: Response to pressure and demands',
              'Both involve eating for non-hunger reasons',
              'Both require similar coping strategies'
            ],
          ),
          LessonSlide(
            id: 'slide_8_1_4',
            title: 'Common Stress Triggers',
            content: 'Identifying your personal stress triggers helps you anticipate and prepare for challenging situations.',
            slideNumber: 4,
            bulletPoints: [
              'Work deadlines and pressure',
              'Relationship conflicts',
              'Financial concerns',
              'Health issues',
              'Major life changes',
              'Daily hassles and overwhelm'
            ],
          ),
          LessonSlide(
            id: 'slide_8_1_5',
            title: 'Breaking the Stress-Eating Cycle',
            content: 'Breaking this cycle involves both stress management techniques and alternative coping strategies for when stress does occur.',
            slideNumber: 5,
            bulletPoints: [
              'Learn stress management techniques',
              'Develop alternative coping strategies',
              'Practice stress prevention when possible',
              'Build resilience over time',
              'Seek support during stressful periods'
            ],
            additionalInfo: 'Remember: You can\'t eliminate all stress from your life, but you can change how you respond to it.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 8.2 - 6 slides
      Lesson(
        id: 'lesson_8_2',
        title: 'Breathing and Relaxation Techniques',
        description: 'Learning practical breathing and relaxation techniques to manage stress and reduce the urge to binge.',
        chapterNumber: 8,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_8_2_1',
            title: 'The Power of Breath',
            content: 'Breathing is one of the most accessible and effective tools for managing stress and anxiety. It\'s always available to you.',
            slideNumber: 1,
            bulletPoints: [
              'Always available when you need it',
              'Activates your body\'s relaxation response',
              'Helps you feel more in control',
              'Can be done anywhere, anytime'
            ],
          ),
          LessonSlide(
            id: 'slide_8_2_2',
            title: 'Basic Deep Breathing',
            content: 'Deep breathing involves breathing slowly and deeply into your belly rather than shallow breathing into your chest.',
            slideNumber: 2,
            bulletPoints: [
              'Breathe in slowly through your nose for 4 counts',
              'Hold for 4 counts',
              'Exhale slowly through your mouth for 6 counts',
              'Repeat 5-10 times',
              'Focus on your belly rising and falling'
            ],
          ),
          LessonSlide(
            id: 'slide_8_2_3',
            title: 'Progressive Muscle Relaxation',
            content: 'This technique involves systematically tensing and then relaxing different muscle groups to release physical tension.',
            slideNumber: 3,
            bulletPoints: [
              'Start with your toes and work upward',
              'Tense each muscle group for 5 seconds',
              'Then relax and notice the difference',
              'Move through: feet, legs, abdomen, arms, shoulders, face',
              'End by relaxing your whole body'
            ],
          ),
          LessonSlide(
            id: 'slide_8_2_4',
            title: 'Quick Relaxation Techniques',
            content: 'These techniques can be used in moments when you feel stressed and need quick relief.',
            slideNumber: 4,
            bulletPoints: [
              '5-4-3-2-1 grounding: Name 5 things you see, 4 you hear, 3 you feel, 2 you smell, 1 you taste',
              'Shoulder rolls and neck stretches',
              'Clench and release your fists',
              'Take 3 deep breaths with long exhales',
              'Splash cold water on your face'
            ],
          ),
          LessonSlide(
            id: 'slide_8_2_5',
            title: 'Building a Daily Practice',
            content: 'Regular practice of relaxation techniques builds your stress resilience and makes the techniques more effective when you need them.',
            slideNumber: 5,
            bulletPoints: [
              'Practice for 5-10 minutes daily',
              'Choose a consistent time each day',
              'Start with basic techniques',
              'Use apps or guided recordings if helpful',
              'Be patient - skills develop over time'
            ],
          ),
          LessonSlide(
            id: 'slide_8_2_6',
            title: 'Using Techniques Before Eating',
            content: 'Try using a quick relaxation technique before meals to help you eat more mindfully and reduce stress-driven eating.',
            slideNumber: 6,
            bulletPoints: [
              'Take 3 deep breaths before eating',
              'Do a quick body scan for tension',
              'Set an intention for mindful eating',
              'Create a moment of calm before meals',
              'This helps transition from stress to nourishment'
            ],
            additionalInfo: 'Remember: These techniques work best with regular practice. Even 5 minutes a day can make a significant difference.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 8.3 - 5 slides
      Lesson(
        id: 'lesson_8_3',
        title: 'Time Management and Boundaries',
        description: 'Learning to manage time effectively and set healthy boundaries to reduce stress and prevent overwhelm.',
        chapterNumber: 8,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_8_3_1',
            title: 'Poor Time Management and Eating',
            content: 'Poor time management often leads to irregular eating patterns, which can increase the risk of binge episodes.',
            slideNumber: 1,
            bulletPoints: [
              'Skipping meals due to being "too busy"',
              'Eating quickly without attention',
              'Using food to cope with time pressure',
              'Feeling out of control with time leads to feeling out of control with food'
            ],
          ),
          LessonSlide(
            id: 'slide_8_3_2',
            title: 'Prioritizing Your Needs',
            content: 'Learning to prioritize your basic needs, including regular eating, is essential for both time management and recovery.',
            slideNumber: 2,
            bulletPoints: [
              'Schedule meals like important appointments',
              'Make time for self-care activities',
              'Recognize that rest is productive',
              'Your needs matter as much as others\''
            ],
          ),
          LessonSlide(
            id: 'slide_8_3_3',
            title: 'Setting Healthy Boundaries',
            content: 'Boundaries protect your time, energy, and recovery by helping you say no to demands that don\'t serve your well-being.',
            slideNumber: 3,
            bulletPoints: [
              'Learn to say no to unreasonable demands',
              'Protect time for meals and self-care',
              'Communicate your needs clearly',
              'Don\'t over-commit yourself',
              'It\'s okay to disappoint others sometimes'
            ],
          ),
          LessonSlide(
            id: 'slide_8_3_4',
            title: 'Time Management Strategies',
            content: 'Effective time management reduces stress and creates space for the activities that support your recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Use calendars and planning tools',
              'Break large tasks into smaller steps',
              'Build in buffer time between activities',
              'Prepare meals and snacks in advance',
              'Learn to delegate when possible'
            ],
          ),
          LessonSlide(
            id: 'slide_8_3_5',
            title: 'Creating Margin in Your Life',
            content: 'Margin is the space between your current capacity and your limits. Having margin prevents overwhelm and supports recovery.',
            slideNumber: 5,
            bulletPoints: [
              'Don\'t schedule every minute of your day',
              'Build in time for unexpected events',
              'Allow time to transition between activities',
              'Schedule regular rest and downtime',
              'Margin creates space for mindful eating'
            ],
            additionalInfo: 'Remember: Managing your time well is an act of self-care that supports your recovery from binge eating.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 8.4 - 4 slides
      Lesson(
        id: 'lesson_8_4',
        title: 'Building Stress Resilience',
        description: 'Developing long-term resilience to stress through lifestyle changes and mindset shifts.',
        chapterNumber: 8,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_8_4_1',
            title: 'What Is Stress Resilience?',
            content: 'Stress resilience is your ability to adapt and bounce back from stressful situations without being overwhelmed.',
            slideNumber: 1,
            bulletPoints: [
              'Ability to adapt to stress',
              'Bounce back from difficult situations',
              'Maintain stability during challenges',
              'Can be developed and strengthened over time'
            ],
          ),
          LessonSlide(
            id: 'slide_8_4_2',
            title: 'Lifestyle Factors for Resilience',
            content: 'Certain lifestyle choices significantly impact your ability to handle stress effectively.',
            slideNumber: 2,
            bulletPoints: [
              'Regular sleep schedule (7-9 hours)',
              'Regular physical activity',
              'Consistent meal patterns',
              'Limiting alcohol and caffeine',
              'Spending time in nature',
              'Maintaining social connections'
            ],
          ),
          LessonSlide(
            id: 'slide_8_4_3',
            title: 'Mindset and Perspective',
            content: 'How you think about and interpret stressful situations greatly affects how they impact you.',
            slideNumber: 3,
            bulletPoints: [
              'View challenges as opportunities to grow',
              'Focus on what you can control',
              'Practice gratitude regularly',
              'Maintain perspective on temporary situations',
              'Develop a growth mindset'
            ],
          ),
          LessonSlide(
            id: 'slide_8_4_4',
            title: 'Building Your Resilience Plan',
            content: 'Create a personalized plan for building and maintaining stress resilience that supports your eating disorder recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Identify your current stress management strengths',
              'Choose 2-3 resilience-building activities to focus on',
              'Create daily and weekly practices',
              'Monitor your stress levels regularly',
              'Adjust your plan as needed'
            ],
            additionalInfo: 'Remember: Building resilience takes time and practice. Start small and be consistent rather than trying to change everything at once.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 9: SOCIAL EATING AND RELATIONSHIPS - 6 lessons

      // Lesson 9.1 - 4 slides
      Lesson(
        id: 'lesson_9_1',
        title: 'Navigating Social Eating',
        description: 'Learning to eat comfortably in social situations while maintaining your recovery.',
        chapterNumber: 9,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_9_1_1',
            title: 'Why Social Eating Is Challenging',
            content: 'Social eating can be difficult in recovery because it involves food, people, and often unpredictable situations.',
            slideNumber: 1,
            bulletPoints: [
              'Combines food with social pressure',
              'Less control over food choices',
              'May trigger comparison with others',
              'Can bring up shame or self-consciousness'
            ],
          ),
          LessonSlide(
            id: 'slide_9_1_2',
            title: 'Preparing for Social Eating',
            content: 'Preparation can help you feel more confident and comfortable in social eating situations.',
            slideNumber: 2,
            bulletPoints: [
              'Eat a small snack beforehand if needed',
              'Review the menu in advance when possible',
              'Plan what you\'ll say if offered unwanted food',
              'Bring a trusted support person when appropriate',
              'Set realistic expectations for yourself'
            ],
          ),
          LessonSlide(
            id: 'slide_9_1_3',
            title: 'During Social Eating',
            content: 'Focus on connection with others while honoring your hunger and fullness cues as much as possible.',
            slideNumber: 3,
            bulletPoints: [
              'Focus on the social connection, not just the food',
              'Eat at your own pace when possible',
              'Listen to your hunger and fullness cues',
              'It\'s okay to leave food on your plate',
              'Engage in conversation to stay present'
            ],
          ),
          LessonSlide(
            id: 'slide_9_1_4',
            title: 'After Social Eating',
            content: 'Process the experience with self-compassion and learn from what went well and what was challenging.',
            slideNumber: 4,
            bulletPoints: [
              'Avoid compensatory behaviors',
              'Return to normal eating patterns',
              'Reflect on what went well',
              'Learn from challenging moments',
              'Practice self-compassion'
            ],
            additionalInfo: 'Remember: Social eating gets easier with practice. Each experience teaches you something about navigating these situations.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 9.2 - 5 slides
      Lesson(
        id: 'lesson_9_2',
        title: 'Dealing with Food Comments',
        description: 'Learning to respond to comments about food, eating, or your body from others.',
        chapterNumber: 9,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_9_2_1',
            title: 'Common Problematic Comments',
            content: 'Many people make comments about food and eating without realizing how harmful they can be to someone in recovery.',
            slideNumber: 1,
            bulletPoints: [
              '"Are you sure you should eat that?"',
              '"I\'m being so bad eating this!"',
              '"You\'re so good for ordering a salad"',
              '"I need to work off this meal"',
              '"You look like you\'ve lost/gained weight"'
            ],
          ),
          LessonSlide(
            id: 'slide_9_2_2',
            title: 'Why These Comments Are Harmful',
            content: 'These comments reinforce diet culture and food moralizing, which can trigger shame and disordered eating thoughts.',
            slideNumber: 2,
            bulletPoints: [
              'Reinforce food moralizing (good/bad foods)',
              'Can trigger shame and self-criticism',
              'May lead to comparison and competition',
              'Perpetuate diet culture mentality',
              'Can derail recovery progress'
            ],
          ),
          LessonSlide(
            id: 'slide_9_2_3',
            title: 'Response Strategies',
            content: 'You can choose from different strategies depending on your relationship with the person and your energy level.',
            slideNumber: 3,
            bulletPoints: [
              'Redirect: "I prefer not to talk about food/weight"',
              'Educate: "I don\'t think of foods as good or bad"',
              'Ignore: Simply don\'t respond to the comment',
              'Leave: Remove yourself from the situation',
              'Set boundary: "Please don\'t comment on my eating"'
            ],
          ),
          LessonSlide(
            id: 'slide_9_2_4',
            title: 'Internal Response Strategies',
            content: 'How you respond internally to these comments is just as important as your external response.',
            slideNumber: 4,
            bulletPoints: [
              'Remind yourself: "This is their issue, not mine"',
              'Use self-compassion: "I\'m doing what\'s right for me"',
              'Refocus on your recovery values',
              'Take deep breaths to stay grounded',
              'Remember your "why" for recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_9_2_5',
            title: 'Creating Safer Spaces',
            content: 'Over time, you can work to create environments where these harmful comments are less likely to occur.',
            slideNumber: 5,
            bulletPoints: [
              'Educate close friends and family',
              'Model body-positive language yourself',
              'Speak up when you have the energy',
              'Seek out like-minded communities',
              'Remember: You can\'t control others, only your response'
            ],
            additionalInfo: 'Remember: You don\'t have to educate everyone or engage with every comment. Protecting your energy is also valid.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 9.3 - 6 slides
      Lesson(
        id: 'lesson_9_3',
        title: 'Family Dynamics and Food',
        description: 'Understanding and improving family relationships around food and eating.',
        chapterNumber: 9,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_9_3_1',
            title: 'Family Food Culture',
            content: 'Every family has its own culture around food, eating, and body image that can significantly impact recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Family rules and beliefs about food',
              'Mealtime dynamics and conversations',
              'Body image messages and attitudes',
              'Cultural and generational influences'
            ],
          ),
          LessonSlide(
            id: 'slide_9_3_2',
            title: 'Common Family Challenges',
            content: 'Many families unknowingly engage in behaviors that can be challenging for someone in eating disorder recovery.',
            slideNumber: 2,
            bulletPoints: [
              'Food policing: monitoring or commenting on eating',
              'Diet talk and weight discussions',
              'Using food for emotional regulation',
              'Pressuring to eat certain amounts or types',
              'Lack of understanding about eating disorders'
            ],
          ),
          LessonSlide(
            id: 'slide_9_3_3',
            title: 'Educating Your Family',
            content: 'When possible and appropriate, educating family members about eating disorders and recovery can be very helpful.',
            slideNumber: 3,
            bulletPoints: [
              'Share information about eating disorders',
              'Explain what is and isn\'t helpful',
              'Ask for specific support you need',
              'Set clear boundaries around food talk',
              'Suggest family therapy if needed'
            ],
          ),
          LessonSlide(
            id: 'slide_9_3_4',
            title: 'Setting Family Boundaries',
            content: 'You may need to set boundaries with family members to protect your recovery, even if they don\'t understand.',
            slideNumber: 4,
            bulletPoints: [
              '"I don\'t want to discuss my eating or weight"',
              '"Please don\'t comment on my food choices"',
              '"I need support, not advice about food"',
              'Leave the room if boundaries are violated',
              'Limit contact if necessary for your health'
            ],
          ),
          LessonSlide(
            id: 'slide_9_3_5',
            title: 'Creating New Family Traditions',
            content: 'When possible, you can work to create new family traditions that don\'t center entirely around food.',
            slideNumber: 5,
            bulletPoints: [
              'Suggest non-food activities for gatherings',
              'Focus on connection rather than consumption',
              'Create new holiday traditions',
              'Encourage body-positive conversations',
              'Model healthy attitudes about food and body'
            ],
          ),
          LessonSlide(
            id: 'slide_9_3_6',
            title: 'When Family Isn\'t Supportive',
            content: 'Sometimes family members aren\'t able or willing to support your recovery, and you may need to seek support elsewhere.',
            slideNumber: 6,
            bulletPoints: [
              'Build your chosen family of supportive friends',
              'Seek professional support',
              'Join support groups or online communities',
              'Remember: You can\'t change others, only yourself',
              'Your recovery is still possible and important'
            ],
            additionalInfo: 'Remember: You deserve support in your recovery. If family can\'t provide it, that doesn\'t mean you should give up - it means you need to look elsewhere.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 9.4 - 4 slides
      Lesson(
        id: 'lesson_9_4',
        title: 'Dating and Relationships',
        description: 'Navigating romantic relationships and dating while in recovery from binge eating.',
        chapterNumber: 9,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_9_4_1',
            title: 'Dating with an Eating Disorder History',
            content: 'Dating can bring up unique challenges when you have a history of eating disorders, but healthy relationships are absolutely possible.',
            slideNumber: 1,
            bulletPoints: [
              'Anxiety about eating in front of others',
              'Concerns about body image and attraction',
              'Questions about when/how to disclose your history',
              'Fear of judgment or rejection'
            ],
          ),
          LessonSlide(
            id: 'slide_9_4_2',
            title: 'When to Disclose Your History',
            content: 'Deciding when and how to share your eating disorder history is a personal choice that depends on various factors.',
            slideNumber: 2,
            bulletPoints: [
              'You\'re not obligated to disclose immediately',
              'Consider the level of trust and commitment',
              'Share when you feel ready and safe',
              'Focus on your recovery and growth',
              'Their reaction tells you about their character'
            ],
          ),
          LessonSlide(
            id: 'slide_9_4_3',
            title: 'Healthy Relationship Qualities',
            content: 'Look for partners who demonstrate qualities that support your overall well-being and recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Respect for your boundaries',
              'Support for your self-care practices',
              'Acceptance of your body as it is',
              'Understanding and patience with your journey',
              'Their own healthy relationship with food and body'
            ],
          ),
          LessonSlide(
            id: 'slide_9_4_4',
            title: 'Red Flags to Watch For',
            content: 'Be aware of relationship dynamics that could potentially harm your recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Comments about your eating, weight, or body',
              'Pressure to eat certain ways',
              'Using your eating disorder against you in arguments',
              'Lack of support for your recovery efforts',
              'Their own disordered eating behaviors'
            ],
            additionalInfo: 'Remember: You deserve a partner who loves and accepts you as you are, and who supports your journey toward healing.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 9.5 - 5 slides
      Lesson(
        id: 'lesson_9_5',
        title: 'Building a Support Network',
        description: 'Creating and maintaining supportive relationships that enhance your recovery journey.',
        chapterNumber: 9,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_9_5_1',
            title: 'Types of Support You Need',
            content: 'Different types of support serve different needs in your recovery. You don\'t need to get everything from one person.',
            slideNumber: 1,
            bulletPoints: [
              'Emotional support: listening, empathy, encouragement',
              'Practical support: help with daily tasks',
              'Informational support: advice and guidance',
              'Social support: companionship and belonging',
              'Professional support: therapy, medical care'
            ],
          ),
          LessonSlide(
            id: 'slide_9_5_2',
            title: 'Where to Find Support',
            content: 'Support can come from many different sources. Cast a wide net and be open to unexpected connections.',
            slideNumber: 2,
            bulletPoints: [
              'Family and existing friends',
              'Support groups (in-person or online)',
              'Therapy or counseling',
              'Religious or spiritual communities',
              'Hobby groups and classes',
              'Volunteer organizations'
            ],
          ),
          LessonSlide(
            id: 'slide_9_5_3',
            title: 'Being a Good Friend to Yourself',
            content: 'Part of building a support network is learning to be supportive to yourself.',
            slideNumber: 3,
            bulletPoints: [
              'Practice self-compassion',
              'Celebrate your progress',
              'Forgive yourself for setbacks',
              'Advocate for your needs',
              'Treat yourself with kindness'
            ],
          ),
          LessonSlide(
            id: 'slide_9_5_4',
            title: 'Maintaining Supportive Relationships',
            content: 'Good relationships require mutual care and attention. Be willing to give support as well as receive it.',
            slideNumber: 4,
            bulletPoints: [
              'Express gratitude regularly',
              'Check in on your support people',
              'Offer help when you\'re able',
              'Be honest about your needs',
              'Respect others\' boundaries too'
            ],
          ),
          LessonSlide(
            id: 'slide_9_5_5',
            title: 'Quality Over Quantity',
            content: 'It\'s better to have a few close, supportive relationships than many superficial ones.',
            slideNumber: 5,
            bulletPoints: [
              'Deep connections are more valuable than many acquaintances',
              'Invest time in relationships that feel nourishing',
              'It\'s okay to let go of unsupportive relationships',
              'Quality support can come from unexpected places',
              'Even one strong supportive relationship makes a difference'
            ],
            additionalInfo: 'Remember: Building a support network takes time. Start with one person and gradually expand your circle of support.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 9.6 - 4 slides
      Lesson(
        id: 'lesson_9_6',
        title: 'Communicating Your Needs',
        description: 'Learning to express your needs clearly and ask for help when you need it.',
        chapterNumber: 9,
        lessonNumber: 6,
        slides: [
          LessonSlide(
            id: 'slide_9_6_1',
            title: 'Why Communication Is Important',
            content: 'Clear communication about your needs helps others support you effectively and reduces misunderstandings.',
            slideNumber: 1,
            bulletPoints: [
              'People can\'t read your mind',
              'Clear requests get better responses',
              'Prevents resentment and frustration',
              'Helps others learn how to support you',
              'Models healthy relationship skills'
            ],
          ),
          LessonSlide(
            id: 'slide_9_6_2',
            title: 'Identifying Your Needs',
            content: 'Before you can communicate your needs, you need to identify what they are. This takes practice and self-awareness.',
            slideNumber: 2,
            bulletPoints: [
              'What type of support would be helpful?',
              'What specific actions would you like?',
              'What should people avoid saying or doing?',
              'When do you most need support?',
              'What would make you feel most understood?'
            ],
          ),
          LessonSlide(
            id: 'slide_9_6_3',
            title: 'How to Ask for Help',
            content: 'Asking for help can feel vulnerable, but it\'s a strength, not a weakness. Here are some strategies for effective requests.',
            slideNumber: 3,
            bulletPoints: [
              'Be specific about what you need',
              'Explain why it would be helpful',
              'Give people permission to say no',
              'Express appreciation for their willingness to listen',
              'Follow up with gratitude'
            ],
          ),
          LessonSlide(
            id: 'slide_9_6_4',
            title: 'When People Can\'t Help',
            content: 'Sometimes people can\'t provide the support you need, and that\'s okay. It doesn\'t mean you\'re asking for too much.',
            slideNumber: 4,
            bulletPoints: [
              'People have their own limitations',
              'It\'s not a reflection of your worth',
              'Thank them for their honesty',
              'Look for support elsewhere',
              'Don\'t give up on asking for help'
            ],
            additionalInfo: 'Remember: Asking for help is a skill that gets easier with practice. You deserve support, and it\'s okay to need other people.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 10: LIFE SKILLS AND RECOVERY MAINTENANCE - 5 lessons

      // Lesson 10.1 - 5 slides
      Lesson(
        id: 'lesson_10_1',
        title: 'Meal Planning and Preparation',
        description: 'Practical skills for planning and preparing meals that support your recovery and well-being.',
        chapterNumber: 10,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_10_1_1',
            title: 'Why Meal Planning Helps Recovery',
            content: 'Meal planning reduces decision fatigue, ensures regular eating, and helps prevent both restriction and binge episodes.',
            slideNumber: 1,
            bulletPoints: [
              'Reduces daily food decisions',
              'Ensures regular eating patterns',
              'Prevents both restriction and binging',
              'Saves time and reduces stress',
              'Helps with grocery shopping and budgeting'
            ],
          ),
          LessonSlide(
            id: 'slide_10_1_2',
            title: 'Flexible Meal Planning',
            content: 'The goal is structure, not rigidity. Your meal plan should adapt to your life, not control it.',
            slideNumber: 2,
            bulletPoints: [
              'Plan general meal categories, not exact foods',
              'Include variety and foods you enjoy',
              'Allow for spontaneous changes',
              'Plan for different scenarios (busy days, social events)',
              'Focus on adequacy and balance, not perfection'
            ],
          ),
          LessonSlide(
            id: 'slide_10_1_3',
            title: 'Basic Meal Planning Steps',
            content: 'Start simple and build complexity as meal planning becomes more natural.',
            slideNumber: 3,
            bulletPoints: [
              'Choose one day per week for planning',
              'Consider your schedule for the week',
              'Plan meals and snacks for regular timing',
              'Include a variety of food groups',
              'Make a grocery list based on your plan'
            ],
          ),
          LessonSlide(
            id: 'slide_10_1_4',
            title: 'Meal Preparation Strategies',
            content: 'Preparing food in advance can make it easier to stick to regular eating patterns.',
            slideNumber: 4,
            bulletPoints: [
              'Batch cook grains, proteins, and vegetables',
              'Wash and chop fruits and vegetables',
              'Prepare grab-and-go snacks',
              'Cook extra portions for leftovers',
              'Keep some convenient backup options available'
            ],
          ),
          LessonSlide(
            id: 'slide_10_1_5',
            title: 'Adapting to Your Needs',
            content: 'Your meal planning approach should change as your recovery progresses and your life circumstances change.',
            slideNumber: 5,
            bulletPoints: [
              'Start with more structure if needed',
              'Gradually add flexibility as you feel ready',
              'Adjust for changes in schedule or appetite',
              'Listen to your body\'s changing needs',
              'Remember: the goal is nourishment, not perfection'
            ],
            additionalInfo: 'Remember: Meal planning is a tool to support your recovery, not another way to control your eating. Keep it flexible and kind.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 10.2 - 6 slides
      Lesson(
        id: 'lesson_10_2',
        title: 'Exercise and Movement in Recovery',
        description: 'Developing a healthy relationship with exercise and movement that supports rather than harms your recovery.',
        chapterNumber: 10,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_10_2_1',
            title: 'Exercise vs. Movement',
            content: 'There\'s a difference between compulsive exercise and joyful movement. Understanding this difference is crucial for recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Exercise: Often focused on burning calories or changing body',
              'Movement: Focused on feeling good and body appreciation',
              'Exercise: Can become compulsive and rigid',
              'Movement: Flexible and responsive to body\'s needs'
            ],
          ),
          LessonSlide(
            id: 'slide_10_2_2',
            title: 'Warning Signs of Problematic Exercise',
            content: 'Be aware of signs that your relationship with exercise might be becoming unhealthy.',
            slideNumber: 2,
            bulletPoints: [
              'Exercising when injured or sick',
              'Extreme anxiety when unable to exercise',
              'Exercising primarily to "earn" food or "burn off" meals',
              'Isolating from others to exercise',
              'Exercise taking priority over other important activities'
            ],
          ),
          LessonSlide(
            id: 'slide_10_2_3',
            title: 'Benefits of Healthy Movement',
            content: 'When approached healthily, movement can actually support your eating disorder recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Improves mood and reduces anxiety',
              'Helps you connect with your body',
              'Increases strength and energy',
              'Provides stress relief',
              'Can be a form of self-care'
            ],
          ),
          LessonSlide(
            id: 'slide_10_2_4',
            title: 'Finding Joyful Movement',
            content: 'The key is finding types of movement that you genuinely enjoy and that make you feel good.',
            slideNumber: 4,
            bulletPoints: [
              'Try different activities to find what you enjoy',
              'Focus on how movement makes you feel',
              'Include both structured and unstructured movement',
              'Consider social movement activities',
              'Listen to your body\'s needs for rest'
            ],
          ),
          LessonSlide(
            id: 'slide_10_2_5',
            title: 'Movement Guidelines for Recovery',
            content: 'These guidelines can help you maintain a healthy relationship with movement during recovery.',
            slideNumber: 5,
            bulletPoints: [
              'Move for joy, not punishment',
              'Rest when your body needs it',
              'Don\'t use movement to compensate for eating',
              'Choose movement based on how you feel',
              'If it feels compulsive, take a break'
            ],
          ),
          LessonSlide(
            id: 'slide_10_2_6',
            title: 'When to Seek Guidance',
            content: 'Sometimes it\'s helpful to work with professionals who understand eating disorders when returning to movement.',
            slideNumber: 6,
            bulletPoints: [
              'Consider working with a recovery-informed trainer',
              'Physical therapists can help if you have injuries',
              'Discuss movement with your treatment team',
              'Join movement classes focused on body positivity',
              'Remember: rest is also a form of self-care'
            ],
            additionalInfo: 'Remember: Your worth is not determined by how much you exercise. Movement should add joy to your life, not stress.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 10.3 - 4 slides
      Lesson(
        id: 'lesson_10_3',
        title: 'Sleep and Recovery',
        description: 'Understanding the importance of sleep for eating disorder recovery and strategies for better sleep.',
        chapterNumber: 10,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_10_3_1',
            title: 'Sleep and Eating Disorders',
            content: 'Sleep and eating are closely connected. Poor sleep can increase the risk of binge episodes and make recovery more difficult.',
            slideNumber: 1,
            bulletPoints: [
              'Poor sleep increases appetite hormones',
              'Tired brains have less impulse control',
              'Sleep deprivation increases stress',
              'Disrupted sleep affects mood regulation'
            ],
          ),
          LessonSlide(
            id: 'slide_10_3_2',
            title: 'How Eating Disorders Affect Sleep',
            content: 'Eating disorders can disrupt sleep patterns, creating a cycle where poor sleep makes recovery more challenging.',
            slideNumber: 2,
            bulletPoints: [
              'Hunger can interfere with falling asleep',
              'Overeating can cause discomfort and disrupt sleep',
              'Anxiety about food can keep you awake',
              'Shame and guilt can contribute to insomnia'
            ],
          ),
          LessonSlide(
            id: 'slide_10_3_3',
            title: 'Sleep Hygiene for Recovery',
            content: 'Good sleep hygiene practices can significantly improve both your sleep quality and your recovery progress.',
            slideNumber: 3,
            bulletPoints: [
              'Keep a consistent sleep schedule',
              'Create a relaxing bedtime routine',
              'Limit screens before bedtime',
              'Keep your bedroom cool, dark, and quiet',
              'Avoid large meals close to bedtime',
              'Consider a light snack if hungry before bed'
            ],
          ),
          LessonSlide(
            id: 'slide_10_3_4',
            title: 'When to Seek Help',
            content: 'If sleep problems persist despite good sleep hygiene, it may be helpful to seek professional help.',
            slideNumber: 4,
            bulletPoints: [
              'Persistent insomnia or sleep disturbances',
              'Sleeping too much or too little',
              'Sleep interfering with daily functioning',
              'Sleep issues related to eating disorder thoughts',
              'Consider sleep medicine or therapy'
            ],
            additionalInfo: 'Remember: Good sleep is not a luxury - it\'s a necessity for recovery. Prioritize sleep as part of your self-care.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 10.4 - 5 slides
      Lesson(
        id: 'lesson_10_4',
        title: 'Work and School Balance',
        description: 'Managing work or school responsibilities while maintaining your recovery priorities.',
        chapterNumber: 10,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_10_4_1',
            title: 'Recovery as Your Priority',
            content: 'While work and school are important, your recovery needs to be a top priority for long-term success in all areas.',
            slideNumber: 1,
            bulletPoints: [
              'Recovery supports success in other areas',
              'Your health enables you to perform better',
              'Short-term accommodations for long-term gains',
              'You can\'t pour from an empty cup'
            ],
          ),
          LessonSlide(
            id: 'slide_10_4_2',
            title: 'Practical Workplace Strategies',
            content: 'There are practical ways to support your recovery while meeting your work or school obligations.',
            slideNumber: 2,
            bulletPoints: [
              'Pack meals and snacks for the day',
              'Set reminders to eat at regular times',
              'Take actual lunch breaks away from your desk',
              'Create boundaries around food-related social events',
              'Keep recovery resources accessible'
            ],
          ),
          LessonSlide(
            id: 'slide_10_4_3',
            title: 'Managing Stress and Perfectionism',
            content: 'Work and school can trigger perfectionism and stress, which can increase the risk of eating disorder behaviors.',
            slideNumber: 3,
            bulletPoints: [
              'Set realistic expectations for yourself',
              'Practice saying no to overcommitment',
              'Use stress management techniques during the day',
              'Remember that good enough is often enough',
              'Seek help when feeling overwhelmed'
            ],
          ),
          LessonSlide(
            id: 'slide_10_4_4',
            title: 'Disclosure and Accommodations',
            content: 'You may choose to disclose your eating disorder to access accommodations, but this is a personal decision.',
            slideNumber: 4,
            bulletPoints: [
              'You\'re not required to disclose',
              'Consider the benefits and risks',
              'Know your rights regarding accommodations',
              'Document requests in writing if needed',
              'Seek support from disability services if available'
            ],
          ),
          LessonSlide(
            id: 'slide_10_4_5',
            title: 'Long-term Success',
            content: 'Building sustainable work or school habits that support your recovery will benefit you in the long run.',
            slideNumber: 5,
            bulletPoints: [
              'Recovery skills transfer to other areas',
              'Self-care improves performance',
              'Healthy boundaries benefit everyone',
              'You can be successful and in recovery',
              'Your value isn\'t determined by productivity'
            ],
            additionalInfo: 'Remember: You don\'t have to choose between recovery and success. Recovery actually enables you to be more successful.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 10.5 - 6 slides
      Lesson(
        id: 'lesson_10_5',
        title: 'Creating Your Recovery Maintenance Plan',
        description: 'Developing a comprehensive plan for maintaining your recovery long-term.',
        chapterNumber: 10,
        lessonNumber: 5,
        slides: [
          LessonSlide(
            id: 'slide_10_5_1',
            title: 'Why You Need a Maintenance Plan',
            content: 'A recovery maintenance plan helps you stay on track and prevents gradual drift back toward old patterns.',
            slideNumber: 1,
            bulletPoints: [
              'Prevents gradual drift back to old patterns',
              'Provides structure for ongoing recovery',
              'Helps you recognize warning signs early',
              'Keeps recovery practices active',
              'Supports continued growth and healing'
            ],
          ),
          LessonSlide(
            id: 'slide_10_5_2',
            title: 'Daily Recovery Practices',
            content: 'Identify daily practices that support your recovery and commit to maintaining them consistently.',
            slideNumber: 2,
            bulletPoints: [
              'Regular meal and snack timing',
              'Daily self-check-ins with hunger and fullness',
              'Stress management practices',
              'Body appreciation or gratitude practice',
              'Connection with support system'
            ],
          ),
          LessonSlide(
            id: 'slide_10_5_3',
            title: 'Weekly and Monthly Check-ins',
            content: 'Regular self-assessment helps you stay aware of your recovery status and make adjustments as needed.',
            slideNumber: 3,
            bulletPoints: [
              'Weekly: Review eating patterns and mood',
              'Monthly: Assess overall recovery progress',
              'Note any warning signs or concerning patterns',
              'Celebrate successes and progress',
              'Adjust practices as needed'
            ],
          ),
          LessonSlide(
            id: 'slide_10_5_4',
            title: 'Ongoing Support and Resources',
            content: 'Maintain connections with resources and supports that have been helpful in your recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Continue therapy or support groups as needed',
              'Maintain connections with recovery-minded friends',
              'Keep educational resources accessible',
              'Know when and how to access professional help',
              'Stay connected with recovery communities'
            ],
          ),
          LessonSlide(
            id: 'slide_10_5_5',
            title: 'Adapting Your Plan Over Time',
            content: 'Your recovery maintenance plan should evolve as you grow and as your life circumstances change.',
            slideNumber: 5,
            bulletPoints: [
              'Review and update your plan regularly',
              'Adapt to life changes and new challenges',
              'Add new goals as you achieve others',
              'Stay flexible while maintaining core practices',
              'Remember that growth is ongoing'
            ],
          ),
          LessonSlide(
            id: 'slide_10_5_6',
            title: 'Your Recovery Legacy',
            content: 'Consider how you want to use your recovery experience to create meaning and help others.',
            slideNumber: 6,
            bulletPoints: [
              'How can you use your experience to help others?',
              'What wisdom have you gained through recovery?',
              'How do you want to advocate for change?',
              'What legacy do you want to leave?',
              'Remember: Your recovery matters beyond just you'
            ],
            additionalInfo: 'Remember: Recovery is not a destination but a way of life. You have already shown incredible courage - continue to honor that courage.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 11: TRAUMA AND EATING - 3 lessons

      // Lesson 11.1 - 5 slides
      Lesson(
        id: 'lesson_11_1',
        title: 'Understanding Trauma and Eating Disorders',
        description: 'Exploring the connection between trauma and eating disorders, and how trauma can affect eating behaviors.',
        chapterNumber: 11,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_11_1_1',
            title: 'What is Trauma?',
            content: 'Trauma is a response to an event that is deeply distressing or disturbing. It can be a single incident or repeated experiences over time.',
            slideNumber: 1,
            bulletPoints: [
              'Single traumatic events or repeated experiences',
              'Overwhelms your ability to cope',
              'Can be physical, emotional, or psychological',
              'Affects how you see yourself and the world'
            ],
          ),
          LessonSlide(
            id: 'slide_11_1_2',
            title: 'Types of Trauma',
            content: 'Trauma can take many forms, from obvious events like accidents or violence to more subtle forms like emotional neglect or chronic stress.',
            slideNumber: 2,
            bulletPoints: [
              'Acute trauma: Single shocking events',
              'Complex trauma: Repeated or prolonged exposure',
              'Developmental trauma: Childhood experiences',
              'Vicarious trauma: Witnessing others\' suffering',
              'Historical trauma: Generational or cultural trauma'
            ],
          ),
          LessonSlide(
            id: 'slide_11_1_3',
            title: 'The Trauma-Eating Connection',
            content: 'Many people with eating disorders have experienced trauma. Eating behaviors can become ways of coping with traumatic memories or feelings.',
            slideNumber: 3,
            bulletPoints: [
              'High correlation between trauma and eating disorders',
              'Food can provide comfort and control',
              'Eating behaviors may numb painful emotions',
              'Body image issues may stem from trauma',
              'Restriction or binging can feel protective'
            ],
          ),
          LessonSlide(
            id: 'slide_11_1_4',
            title: 'How Trauma Affects the Body',
            content: 'Trauma impacts the nervous system, stress response, and how we relate to our bodies, which can all influence eating behaviors.',
            slideNumber: 4,
            bulletPoints: [
              'Dysregulated nervous system',
              'Chronic stress response activation',
              'Disconnection from body signals',
              'Difficulty with emotional regulation',
              'Hypervigilance or dissociation'
            ],
          ),
          LessonSlide(
            id: 'slide_11_1_5',
            title: 'Trauma-Informed Recovery',
            content: 'Understanding trauma\'s role in your eating disorder can be important for recovery, though not everyone needs trauma-focused treatment.',
            slideNumber: 5,
            bulletPoints: [
              'Recognize trauma\'s potential role',
              'Consider trauma-informed therapy',
              'Focus on safety and stabilization first',
              'Build coping skills before processing trauma',
              'Recovery is possible regardless of trauma history'
            ],
            additionalInfo: 'Remember: Having trauma in your history doesn\'t mean you\'re broken. You survived difficult experiences, and that shows your strength.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 11.2 - 4 slides
      Lesson(
        id: 'lesson_11_2',
        title: 'Building Safety and Grounding',
        description: 'Learning techniques to feel safe in your body and manage trauma-related symptoms.',
        chapterNumber: 11,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_11_2_1',
            title: 'Creating Internal Safety',
            content: 'Building a sense of safety within yourself is foundational for both trauma recovery and eating disorder recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Safety is feeling secure and protected',
              'Can be physical, emotional, or psychological',
              'Foundation for all other recovery work',
              'Something you can cultivate within yourself'
            ],
          ),
          LessonSlide(
            id: 'slide_11_2_2',
            title: 'Grounding Techniques',
            content: 'Grounding helps you stay present when you feel overwhelmed or disconnected from your body.',
            slideNumber: 2,
            bulletPoints: [
              '5-4-3-2-1 technique: 5 things you see, 4 you hear, 3 you feel, 2 you smell, 1 you taste',
              'Feel your feet on the ground',
              'Hold an ice cube or splash cold water on face',
              'Name objects in the room',
              'Focus on your breathing'
            ],
          ),
          LessonSlide(
            id: 'slide_11_2_3',
            title: 'Body Awareness Practices',
            content: 'Gentle body awareness can help you reconnect with your body in a safe way.',
            slideNumber: 3,
            bulletPoints: [
              'Body scan meditation (start small)',
              'Gentle movement or stretching',
              'Notice areas of tension or relaxation',
              'Practice with self-compassion',
              'Stop if it becomes overwhelming'
            ],
          ),
          LessonSlide(
            id: 'slide_11_2_4',
            title: 'Creating External Safety',
            content: 'Building safety in your environment and relationships supports your overall recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Create safe spaces in your home',
              'Establish supportive relationships',
              'Set boundaries with triggering people',
              'Have emergency support contacts',
              'Know your triggers and plan accordingly'
            ],
            additionalInfo: 'Remember: Building safety takes time. Start small and be patient with yourself as you develop these skills.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 11.3 - 4 slides
      Lesson(
        id: 'lesson_11_3',
        title: 'Working with Trauma Responses',
        description: 'Understanding and managing common trauma responses that may affect your eating and recovery.',
        chapterNumber: 11,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_11_3_1',
            title: 'Common Trauma Responses',
            content: 'Trauma responses are automatic reactions that helped you survive difficult experiences. They\'re normal, but may interfere with recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Fight: Aggression, anger, irritability',
              'Flight: Anxiety, restlessness, avoidance',
              'Freeze: Numbness, paralysis, shutdown',
              'Fawn: People-pleasing, self-sacrifice'
            ],
          ),
          LessonSlide(
            id: 'slide_11_3_2',
            title: 'Trauma Responses and Eating',
            content: 'These responses can directly impact your eating behaviors and relationship with food.',
            slideNumber: 2,
            bulletPoints: [
              'Fight: May manifest as anger around food rules',
              'Flight: Avoiding meals or social eating',
              'Freeze: Feeling paralyzed about food choices',
              'Fawn: Eating to please others, ignoring own needs'
            ],
          ),
          LessonSlide(
            id: 'slide_11_3_3',
            title: 'Managing Trauma Responses',
            content: 'When you notice a trauma response, you can use specific strategies to help regulate your nervous system.',
            slideNumber: 3,
            bulletPoints: [
              'Recognize the response without judgment',
              'Use grounding techniques',
              'Practice deep breathing',
              'Move your body gently if possible',
              'Reach out for support if needed'
            ],
          ),
          LessonSlide(
            id: 'slide_11_3_4',
            title: 'Professional Support',
            content: 'Working with trauma-informed professionals can be very helpful for processing trauma while maintaining eating disorder recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Consider trauma-informed therapy',
              'EMDR, somatic therapy, or other approaches',
              'Ensure therapist understands eating disorders',
              'Coordinate with your treatment team',
              'Go at your own pace'
            ],
            additionalInfo: 'Remember: You don\'t have to work through trauma alone. Professional support can make the process safer and more effective.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 12: CO-OCCURRING CONDITIONS - 4 lessons

      // Lesson 12.1 - 4 slides
      Lesson(
        id: 'lesson_12_1',
        title: 'Depression and Eating Disorders',
        description: 'Understanding the relationship between depression and eating disorders, and strategies for managing both.',
        chapterNumber: 12,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_12_1_1',
            title: 'The Depression-Eating Disorder Connection',
            content: 'Depression and eating disorders often occur together, each influencing and potentially worsening the other.',
            slideNumber: 1,
            bulletPoints: [
              'High co-occurrence rates',
              'Can worsen each other',
              'Share similar brain chemistry changes',
              'Both involve issues with mood regulation'
            ],
          ),
          LessonSlide(
            id: 'slide_12_1_2',
            title: 'How Depression Affects Eating',
            content: 'Depression can impact appetite, energy for meal preparation, and motivation for self-care, all affecting eating patterns.',
            slideNumber: 2,
            bulletPoints: [
              'Changes in appetite (increase or decrease)',
              'Low energy for meal planning and preparation',
              'Reduced motivation for self-care',
              'Using food for emotional comfort',
              'Difficulty enjoying food (anhedonia)'
            ],
          ),
          LessonSlide(
            id: 'slide_12_1_3',
            title: 'Managing Both Conditions',
            content: 'Recovery often involves addressing both conditions simultaneously with professional support.',
            slideNumber: 3,
            bulletPoints: [
              'Work with professionals who understand both',
              'Medication may be helpful for some',
              'Focus on basic self-care first',
              'Build routine and structure',
              'Be patient with the process'
            ],
          ),
          LessonSlide(
            id: 'slide_12_1_4',
            title: 'Self-Care During Depression',
            content: 'When depression makes recovery feel harder, focus on small, manageable steps and be extra gentle with yourself.',
            slideNumber: 4,
            bulletPoints: [
              'Lower your expectations temporarily',
              'Focus on basic needs: food, sleep, hygiene',
              'Use support systems actively',
              'Practice self-compassion',
              'Remember: This is temporary'
            ],
            additionalInfo: 'Remember: Having depression doesn\'t mean you can\'t recover from your eating disorder. Both conditions are treatable.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 12.2 - 5 slides
      Lesson(
        id: 'lesson_12_2',
        title: 'Anxiety and Eating Disorders',
        description: 'Exploring how anxiety relates to eating disorders and learning anxiety management techniques.',
        chapterNumber: 12,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_12_2_1',
            title: 'Anxiety and Food',
            content: 'Anxiety and eating disorders frequently co-occur, with anxiety often driving eating disorder behaviors.',
            slideNumber: 1,
            bulletPoints: [
              'Anxiety often precedes eating disorder onset',
              'Food rules can feel like anxiety management',
              'Eating may temporarily reduce anxiety',
              'Restriction can increase anxiety over time'
            ],
          ),
          LessonSlide(
            id: 'slide_12_2_2',
            title: 'Types of Food-Related Anxiety',
            content: 'Anxiety around food can take many forms and affect different aspects of eating.',
            slideNumber: 2,
            bulletPoints: [
              'Fear of specific foods or food groups',
              'Anxiety about eating in public',
              'Worry about body changes from eating',
              'Perfectionism around meal timing',
              'Social anxiety around food situations'
            ],
          ),
          LessonSlide(
            id: 'slide_12_2_3',
            title: 'Anxiety Management Techniques',
            content: 'Learning to manage anxiety directly can reduce the need to use eating disorder behaviors for anxiety relief.',
            slideNumber: 3,
            bulletPoints: [
              'Deep breathing exercises',
              'Progressive muscle relaxation',
              'Mindfulness and grounding techniques',
              'Challenging anxious thoughts',
              'Gradual exposure to feared situations'
            ],
          ),
          LessonSlide(
            id: 'slide_12_2_4',
            title: 'Exposure and Response Prevention',
            content: 'Gradually facing feared foods or situations while resisting eating disorder behaviors can reduce anxiety over time.',
            slideNumber: 4,
            bulletPoints: [
              'Start with less anxiety-provoking situations',
              'Practice tolerating discomfort',
              'Use coping skills instead of eating disorder behaviors',
              'Gradually increase challenge level',
              'Celebrate small victories'
            ],
          ),
          LessonSlide(
            id: 'slide_12_2_5',
            title: 'Professional Help for Anxiety',
            content: 'Anxiety disorders are very treatable, often with therapy, medication, or both.',
            slideNumber: 5,
            bulletPoints: [
              'Cognitive Behavioral Therapy (CBT) is effective',
              'Medication can be helpful for some',
              'Combination treatment often most effective',
              'Work with professionals experienced in both conditions',
              'Be patient with the process'
            ],
            additionalInfo: 'Remember: Learning to manage anxiety takes time and practice. Each small step forward is meaningful progress.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 12.3 - 4 slides
      Lesson(
        id: 'lesson_12_3',
        title: 'OCD and Eating Disorders',
        description: 'Understanding obsessive-compulsive tendencies in eating disorders and how to address them.',
        chapterNumber: 12,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_12_3_1',
            title: 'OCD and Eating Disorder Overlap',
            content: 'Eating disorders and OCD share many features, including obsessive thoughts about food and compulsive behaviors.',
            slideNumber: 1,
            bulletPoints: [
              'Similar brain patterns and genetics',
              'Obsessive thoughts about food, weight, body',
              'Compulsive behaviors around eating',
              'Perfectionism and need for control',
              'Difficulty with uncertainty'
            ],
          ),
          LessonSlide(
            id: 'slide_12_3_2',
            title: 'Food-Related Obsessions and Compulsions',
            content: 'OCD-like symptoms in eating disorders often center around food, eating, and body-related themes.',
            slideNumber: 2,
            bulletPoints: [
              'Obsessions: Intrusive thoughts about food, calories, weight',
              'Compulsions: Rigid food rituals, checking behaviors',
              'Examples: Counting calories precisely, eating at exact times',
              'Symmetry or "just right" feelings around food',
              'Contamination fears around certain foods'
            ],
          ),
          LessonSlide(
            id: 'slide_12_3_3',
            title: 'Breaking OCD Cycles',
            content: 'Recovery involves learning to tolerate obsessive thoughts without performing compulsive behaviors.',
            slideNumber: 3,
            bulletPoints: [
              'Notice obsessive thoughts without judgment',
              'Resist performing compulsive behaviors',
              'Practice uncertainty tolerance',
              'Use mindfulness to observe thoughts',
              'Gradually reduce rigid food rules'
            ],
          ),
          LessonSlide(
            id: 'slide_12_3_4',
            title: 'Professional Treatment',
            content: 'OCD symptoms in eating disorders often require specialized treatment approaches.',
            slideNumber: 4,
            bulletPoints: [
              'Exposure and Response Prevention (ERP)',
              'Cognitive Behavioral Therapy',
              'Acceptance and Commitment Therapy',
              'Medication may be helpful',
              'Integrated treatment for both conditions'
            ],
            additionalInfo: 'Remember: OCD symptoms can make eating disorder recovery feel more challenging, but both conditions are very treatable.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 12.4 - 4 slides
      Lesson(
        id: 'lesson_12_4',
        title: 'ADHD and Eating Disorders',
        description: 'Understanding how ADHD can affect eating patterns and recovery from eating disorders.',
        chapterNumber: 12,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_12_4_1',
            title: 'ADHD and Eating Patterns',
            content: 'ADHD can significantly impact eating patterns through effects on attention, impulse control, and executive functioning.',
            slideNumber: 1,
            bulletPoints: [
              'Forgetting to eat meals',
              'Difficulty with meal planning and preparation',
              'Impulsive eating or restriction',
              'Trouble recognizing hunger and fullness cues',
              'Using food for stimulation or focus'
            ],
          ),
          LessonSlide(
            id: 'slide_12_4_2',
            title: 'ADHD Symptoms That Affect Recovery',
            content: 'Core ADHD symptoms can make eating disorder recovery more challenging in specific ways.',
            slideNumber: 2,
            bulletPoints: [
              'Inattention: Missing hunger cues, forgetting meals',
              'Hyperactivity: Using excessive exercise, restlessness',
              'Impulsivity: Binge eating, abandoning recovery plans',
              'Executive dysfunction: Difficulty with meal planning',
              'Emotional dysregulation: Using food to manage emotions'
            ],
          ),
          LessonSlide(
            id: 'slide_12_4_3',
            title: 'Strategies for ADHD and Eating Recovery',
            content: 'Specific strategies can help manage ADHD symptoms while supporting eating disorder recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Use alarms and reminders for meals',
              'Create structured meal and snack schedules',
              'Prepare meals and snacks in advance',
              'Use visual cues and lists',
              'Break tasks into smaller steps'
            ],
          ),
          LessonSlide(
            id: 'slide_12_4_4',
            title: 'Treatment Considerations',
            content: 'Managing both ADHD and eating disorders often requires integrated treatment approaches.',
            slideNumber: 4,
            bulletPoints: [
              'ADHD medication may affect appetite',
              'Coordinate with prescribing doctor',
              'Consider timing of medication with meals',
              'Therapy can address both conditions',
              'Structure and routine are especially important'
            ],
            additionalInfo: 'Remember: Having ADHD doesn\'t make eating disorder recovery impossible, but it may require different strategies and extra support.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 13: NUTRITION EDUCATION - 4 lessons

      // Lesson 13.1 - 5 slides
      Lesson(
        id: 'lesson_13_1',
        title: 'Nutrition Basics for Recovery',
        description: 'Learning fundamental nutrition concepts that support eating disorder recovery.',
        chapterNumber: 13,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_13_1_1',
            title: 'Nutrition vs. Diet Culture',
            content: 'True nutrition education supports health and well-being, while diet culture focuses on weight loss and restriction.',
            slideNumber: 1,
            bulletPoints: [
              'Nutrition: Nourishing your body for health',
              'Diet culture: Rules and restrictions for weight loss',
              'Nutrition is individualized and flexible',
              'Diet culture promotes one-size-fits-all approaches'
            ],
          ),
          LessonSlide(
            id: 'slide_13_1_2',
            title: 'Macronutrients Your Body Needs',
            content: 'Your body needs carbohydrates, proteins, and fats in adequate amounts to function properly.',
            slideNumber: 2,
            bulletPoints: [
              'Carbohydrates: Primary energy source for brain and body',
              'Proteins: Building and repairing tissues',
              'Fats: Hormone production, vitamin absorption, brain function',
              'All three are essential - your body needs them all'
            ],
          ),
          LessonSlide(
            id: 'slide_13_1_3',
            title: 'Micronutrients and Recovery',
            content: 'Vitamins and minerals support every body function and are especially important during eating disorder recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Support immune function and healing',
              'Important for brain function and mood',
              'Help with energy production',
              'Best obtained from variety of foods',
              'Supplements may be needed during recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_13_1_4',
            title: 'Energy Needs in Recovery',
            content: 'During recovery, your body often needs more energy than you might expect to heal and restore normal functioning.',
            slideNumber: 4,
            bulletPoints: [
              'Body needs extra energy for healing',
              'Metabolism may be slower initially',
              'Brain function requires significant energy',
              'Don\'t restrict during recovery',
              'Trust the process of refeeding'
            ],
          ),
          LessonSlide(
            id: 'slide_13_1_5',
            title: 'Gentle Nutrition Approach',
            content: 'Gentle nutrition focuses on adding nourishing foods rather than restricting, and considers both health and satisfaction.',
            slideNumber: 5,
            bulletPoints: [
              'Add nourishing foods rather than restrict',
              'Consider both health and satisfaction',
              'No foods are completely off-limits',
              'Focus on overall pattern, not individual meals',
              'Flexibility is key to sustainability'
            ],
            additionalInfo: 'Remember: Good nutrition supports your recovery, but it shouldn\'t become another form of restriction or control.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 13.2 - 4 slides
      Lesson(
        id: 'lesson_13_2',
        title: 'Understanding Your Body\'s Needs',
        description: 'Learning to recognize and respond to your body\'s nutritional and energy needs.',
        chapterNumber: 13,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_13_2_1',
            title: 'Individual Nutrition Needs',
            content: 'Everyone\'s nutritional needs are different based on age, activity level, genetics, health status, and personal preferences.',
            slideNumber: 1,
            bulletPoints: [
              'Needs vary by age, sex, activity level',
              'Genetics influence metabolism and preferences',
              'Health conditions may affect requirements',
              'Personal preferences and culture matter',
              'Needs change throughout life'
            ],
          ),
          LessonSlide(
            id: 'slide_13_2_2',
            title: 'Recognizing Adequate Nutrition',
            content: 'Signs of adequate nutrition include stable energy, good concentration, regular bodily functions, and overall well-being.',
            slideNumber: 2,
            bulletPoints: [
              'Stable energy throughout the day',
              'Good concentration and mental clarity',
              'Regular digestion and elimination',
              'Stable mood and emotional regulation',
              'Healthy hair, skin, and nails'
            ],
          ),
          LessonSlide(
            id: 'slide_13_2_3',
            title: 'Signs of Undernourishment',
            content: 'Undernourishment can manifest in many ways and significantly impact both physical and mental health.',
            slideNumber: 3,
            bulletPoints: [
              'Fatigue and low energy',
              'Difficulty concentrating',
              'Mood swings and irritability',
              'Frequent illness',
              'Hair loss, brittle nails, dry skin',
              'Digestive issues'
            ],
          ),
          LessonSlide(
            id: 'slide_13_2_4',
            title: 'Listening to Your Body',
            content: 'Your body gives you signals about its needs. Learning to listen and respond appropriately is part of recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Notice energy levels throughout the day',
              'Pay attention to how foods make you feel',
              'Observe cravings - they often indicate needs',
              'Trust your body\'s wisdom',
              'Be patient as signals normalize in recovery'
            ],
            additionalInfo: 'Remember: Your body is constantly working to maintain balance. Learning to work with it, rather than against it, supports your health.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 13.3 - 6 slides
      Lesson(
        id: 'lesson_13_3',
        title: 'Debunking Diet Culture Myths',
        description: 'Examining and challenging common nutrition myths promoted by diet culture.',
        chapterNumber: 13,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_13_3_1',
            title: 'Common Diet Culture Myths',
            content: 'Diet culture promotes many myths about nutrition that can be harmful to your relationship with food and your health.',
            slideNumber: 1,
            bulletPoints: [
              '"Carbs are bad for you"',
              '"Eating after 6 PM causes weight gain"',
              '"You need to detox your body"',
              '"Natural sugar is better than regular sugar"',
              '"You must eat breakfast to lose weight"'
            ],
          ),
          LessonSlide(
            id: 'slide_13_3_2',
            title: 'The Truth About Carbohydrates',
            content: 'Carbohydrates are essential nutrients that provide energy for your brain and body. Restricting them can harm both physical and mental health.',
            slideNumber: 2,
            bulletPoints: [
              'Brain requires glucose (from carbs) to function',
              'Primary energy source for muscles',
              'Support serotonin production (mood regulation)',
              'Include them at each meal for stable energy',
              'Whole grains, fruits, vegetables are all healthy carbs'
            ],
          ),
          LessonSlide(
            id: 'slide_13_3_3',
            title: 'The Reality of "Detox"',
            content: 'Your body naturally detoxifies itself through your liver, kidneys, and other organs. You don\'t need special diets or products.',
            slideNumber: 3,
            bulletPoints: [
              'Your liver and kidneys naturally detoxify',
              'No evidence that "detox" diets work',
              'Often just sophisticated marketing',
              'May actually harm your health',
              'Support natural detox with adequate nutrition'
            ],
          ),
          LessonSlide(
            id: 'slide_13_3_4',
            title: 'Meal Timing Myths',
            content: 'When you eat is less important than what and how much you eat overall. Your body can adapt to different eating patterns.',
            slideNumber: 4,
            bulletPoints: [
              'No magic time when food "turns to fat"',
              'Body processes food 24/7',
              'Focus on overall intake, not timing',
              'Eat when hungry, stop when satisfied',
              'Consistency helps with hunger cues'
            ],
          ),
          LessonSlide(
            id: 'slide_13_3_5',
            title: 'The Problem with "Good" and "Bad" Foods',
            content: 'Moralizing food creates guilt, shame, and an unhealthy relationship with eating. All foods can fit in a healthy diet.',
            slideNumber: 5,
            bulletPoints: [
              'Foods don\'t have moral value',
              'Labeling creates guilt and shame',
              'All foods can fit in a balanced approach',
              'Focus on overall pattern, not individual foods',
              'Enjoyment and satisfaction matter too'
            ],
          ),
          LessonSlide(
            id: 'slide_13_3_6',
            title: 'Finding Reliable Nutrition Information',
            content: 'Learn to identify credible nutrition sources and be skeptical of information that seems too good to be true.',
            slideNumber: 6,
            bulletPoints: [
              'Look for credentials: RD, PhD in nutrition',
              'Be wary of extreme claims or quick fixes',
              'Check if information is trying to sell something',
              'Consider the source and their motivations',
              'When in doubt, consult a registered dietitian'
            ],
            additionalInfo: 'Remember: If nutrition advice sounds too good to be true or promotes extreme restrictions, it probably is. Trust evidence-based information.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 13.4 - 5 slides
      Lesson(
        id: 'lesson_13_4',
        title: 'Working with a Registered Dietitian',
        description: 'Understanding how nutrition counseling can support your eating disorder recovery.',
        chapterNumber: 13,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_13_4_1',
            title: 'What is a Registered Dietitian?',
            content: 'Registered Dietitians (RDs) are nutrition experts with extensive education and training in nutrition science and counseling.',
            slideNumber: 1,
            bulletPoints: [
              'Bachelor\'s degree in nutrition or related field',
              'Supervised practice internship',
              'Pass national registration examination',
              'Complete continuing education requirements',
              'Some specialize in eating disorders'
            ],
          ),
          LessonSlide(
            id: 'slide_13_4_2',
            title: 'How RDs Help with Eating Disorder Recovery',
            content: 'Eating disorder specialists provide nutrition education, meal planning support, and help normalize eating patterns.',
            slideNumber: 2,
            bulletPoints: [
              'Nutrition education and meal planning',
              'Challenge food fears and rules',
              'Support weight restoration if needed',
              'Normalize eating patterns',
              'Coordinate with treatment team'
            ],
          ),
          LessonSlide(
            id: 'slide_13_4_3',
            title: 'What to Expect in Nutrition Counseling',
            content: 'Nutrition counseling for eating disorders is different from weight-loss focused nutrition advice.',
            slideNumber: 3,
            bulletPoints: [
              'Focus on healing relationship with food',
              'No weight-loss goals or calorie counting',
              'Gradual introduction of fear foods',
              'Education about nutrition needs',
              'Support through challenging meal experiences'
            ],
          ),
          LessonSlide(
            id: 'slide_13_4_4',
            title: 'Finding the Right Dietitian',
            content: 'Look for a dietitian who specializes in eating disorders and uses a non-diet, Health at Every Size approach.',
            slideNumber: 4,
            bulletPoints: [
              'Specializes in eating disorders',
              'Uses non-diet approach',
              'Supports Health at Every Size principles',
              'Good communication and rapport',
              'Works collaboratively with treatment team'
            ],
          ),
          LessonSlide(
            id: 'slide_13_4_5',
            title: 'Making the Most of Nutrition Counseling',
            content: 'Active participation and honesty with your dietitian will help you get the most benefit from nutrition counseling.',
            slideNumber: 5,
            bulletPoints: [
              'Be honest about eating patterns and fears',
              'Ask questions about nutrition concepts',
              'Practice recommendations between sessions',
              'Communicate challenges and concerns',
              'Trust the process even when it feels difficult'
            ],
            additionalInfo: 'Remember: A good eating disorder dietitian will support your recovery without promoting restriction or weight loss.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 14: EXERCISE AND MOVEMENT - 4 lessons

      // Lesson 14.1 - 5 slides
      Lesson(
        id: 'lesson_14_1',
        title: 'Healing Your Relationship with Exercise',
        description: 'Moving from compulsive exercise to joyful movement that supports your recovery.',
        chapterNumber: 14,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_14_1_1',
            title: 'Exercise vs. Joyful Movement',
            content: 'There\'s an important distinction between compulsive exercise and movement that truly serves your well-being.',
            slideNumber: 1,
            bulletPoints: [
              'Compulsive exercise: Driven by guilt, fear, or rules',
              'Joyful movement: Motivated by pleasure and self-care',
              'Exercise: Often focused on burning calories',
              'Movement: Focused on how it makes you feel'
            ],
          ),
          LessonSlide(
            id: 'slide_14_1_2',
            title: 'Signs of Compulsive Exercise',
            content: 'Compulsive exercise can be as harmful to recovery as other eating disorder behaviors.',
            slideNumber: 2,
            bulletPoints: [
              'Exercising when injured or sick',
              'Extreme distress when unable to exercise',
              'Exercise rules that feel rigid and inflexible',
              'Exercising primarily to "earn" food or "burn off" calories',
              'Exercise interfering with relationships or responsibilities'
            ],
          ),
          LessonSlide(
            id: 'slide_14_1_3',
            title: 'Benefits of Healthy Movement',
            content: 'When approached in a healthy way, movement can actually support eating disorder recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Improves mood and reduces anxiety',
              'Helps you connect with your body',
              'Increases strength and endurance',
              'Provides social connection opportunities',
              'Can be a form of self-expression'
            ],
          ),
          LessonSlide(
            id: 'slide_14_1_4',
            title: 'Redefining Fitness',
            content: 'True fitness includes not just physical strength, but also flexibility, balance, and mental well-being.',
            slideNumber: 4,
            bulletPoints: [
              'Strength: Ability to move through daily life',
              'Endurance: Sustained energy for activities you enjoy',
              'Flexibility: Physical and mental adaptability',
              'Balance: Both physical stability and life balance',
              'Mental fitness: Stress resilience and emotional health'
            ],
          ),
          LessonSlide(
            id: 'slide_14_1_5',
            title: 'Creating New Movement Habits',
            content: 'Focus on movement that feels good, energizes you, and enhances your life rather than restricting it.',
            slideNumber: 5,
            bulletPoints: [
              'Choose activities you genuinely enjoy',
              'Move in ways that feel good to your body',
              'Listen to your body\'s needs for rest',
              'Focus on strength, not appearance',
              'Make movement social and fun when possible'
            ],
            additionalInfo: 'Remember: Your body is designed to move, but that movement should enhance your life, not control it.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 14.2 - 4 slides
      Lesson(
        id: 'lesson_14_2',
        title: 'Movement for Mental Health',
        description: 'Understanding how movement can support mental health and emotional regulation in recovery.',
        chapterNumber: 14,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_14_2_1',
            title: 'Exercise and Mental Health',
            content: 'Physical activity has powerful effects on mental health, often comparable to medication for mild to moderate depression and anxiety.',
            slideNumber: 1,
            bulletPoints: [
              'Releases endorphins (natural mood boosters)',
              'Reduces stress hormones like cortisol',
              'Improves sleep quality',
              'Increases self-esteem and confidence',
              'Provides structure and routine'
            ],
          ),
          LessonSlide(
            id: 'slide_14_2_2',
            title: 'Movement for Anxiety Management',
            content: 'Physical activity can be particularly helpful for managing anxiety symptoms.',
            slideNumber: 2,
            bulletPoints: [
              'Helps burn off excess adrenaline',
              'Provides a healthy outlet for nervous energy',
              'Improves focus and concentration',
              'Builds confidence in your body\'s abilities',
              'Can serve as moving meditation'
            ],
          ),
          LessonSlide(
            id: 'slide_14_2_3',
            title: 'Body Connection Through Movement',
            content: 'Gentle movement can help you reconnect with your body in a positive way.',
            slideNumber: 3,
            bulletPoints: [
              'Helps you tune into body sensations',
              'Builds body appreciation and respect',
              'Improves body awareness and coordination',
              'Can reduce dissociation from your body',
              'Helps distinguish between different types of discomfort'
            ],
          ),
          LessonSlide(
            id: 'slide_14_2_4',
            title: 'Mindful Movement Practices',
            content: 'Incorporating mindfulness into movement can enhance both the physical and mental health benefits.',
            slideNumber: 4,
            bulletPoints: [
              'Yoga: Combines movement, breathing, and mindfulness',
              'Walking meditation: Focus on the rhythm of your steps',
              'Dance: Express emotions through movement',
              'Tai chi: Slow, flowing movements with breath awareness',
              'Swimming: Rhythmic, meditative movement'
            ],
            additionalInfo: 'Remember: The goal is to use movement as a tool for well-being, not as punishment for eating or a way to change your body.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 14.3 - 5 slides
      Lesson(
        id: 'lesson_14_3',
        title: 'Finding Activities You Enjoy',
        description: 'Exploring different types of movement to find what brings you joy and fits your lifestyle.',
        chapterNumber: 14,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_14_3_1',
            title: 'Rediscovering Movement Preferences',
            content: 'You may need to rediscover what types of movement you actually enjoy, separate from what diet culture told you to do.',
            slideNumber: 1,
            bulletPoints: [
              'Think back to childhood activities you enjoyed',
              'Consider what feels good to your body now',
              'Ignore what you think you "should" do',
              'Be open to trying new things',
              'It\'s okay if preferences change over time'
            ],
          ),
          LessonSlide(
            id: 'slide_14_3_2',
            title: 'Low-Impact Activities',
            content: 'Gentle activities can be great starting points for rebuilding a healthy relationship with movement.',
            slideNumber: 2,
            bulletPoints: [
              'Walking or hiking in nature',
              'Gentle yoga or stretching',
              'Swimming or water aerobics',
              'Cycling for pleasure',
              'Dancing to music you love',
              'Gardening or household activities'
            ],
          ),
          LessonSlide(
            id: 'slide_14_3_3',
            title: 'Social Movement Opportunities',
            content: 'Moving with others can make activity more enjoyable and provide social connection.',
            slideNumber: 3,
            bulletPoints: [
              'Group fitness classes focused on fun',
              'Walking with friends or family',
              'Team sports or recreational leagues',
              'Dance classes or social dancing',
              'Outdoor activities with groups',
              'Movement-based volunteer work'
            ],
          ),
          LessonSlide(
            id: 'slide_14_3_4',
            title: 'Creative and Expressive Movement',
            content: 'Movement can be a form of creative expression and emotional release.',
            slideNumber: 4,
            bulletPoints: [
              'Free-form dancing to favorite music',
              'Movement therapy or expressive arts',
              'Martial arts or self-defense',
              'Performance arts like theater or dance',
              'Playing with pets or children'
            ],
          ),
          LessonSlide(
            id: 'slide_14_3_5',
            title: 'Making Movement Sustainable',
            content: 'The best movement routine is one you can maintain long-term without it feeling like a burden.',
            slideNumber: 5,
            bulletPoints: [
              'Start slowly and build gradually',
              'Choose activities that fit your schedule',
              'Have backup options for different situations',
              'Focus on consistency over intensity',
              'Remember that rest days are important'
            ],
            additionalInfo: 'Remember: The best exercise is the one you\'ll actually do regularly. Choose based on enjoyment, not calorie burn.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 14.4 - 4 slides
      Lesson(
        id: 'lesson_14_4',
        title: 'Movement Guidelines for Recovery',
        description: 'Establishing healthy guidelines for movement that support rather than hinder your recovery.',
        chapterNumber: 14,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_14_4_1',
            title: 'Recovery-Focused Movement Principles',
            content: 'These principles can guide you toward a healthier relationship with movement.',
            slideNumber: 1,
            bulletPoints: [
              'Move for joy, not punishment',
              'Listen to your body\'s needs for rest',
              'Focus on how movement makes you feel',
              'Don\'t use movement to "earn" food',
              'It\'s okay to take breaks or modify activities'
            ],
          ),
          LessonSlide(
            id: 'slide_14_4_2',
            title: 'Warning Signs to Watch For',
            content: 'Be aware of signs that your relationship with movement might be becoming problematic again.',
            slideNumber: 2,
            bulletPoints: [
              'Exercising when sick, injured, or exhausted',
              'Anxiety or guilt when unable to exercise',
              'Exercise interfering with social plans',
              'Rigid rules about when, how, or how much to exercise',
              'Using exercise to compensate for eating'
            ],
          ),
          LessonSlide(
            id: 'slide_14_4_3',
            title: 'Creating Flexible Guidelines',
            content: 'Develop guidelines that provide structure while maintaining flexibility for life\'s unpredictability.',
            slideNumber: 3,
            bulletPoints: [
              'Aim for movement most days, not every day',
              'Have options for different energy levels',
              'Include both planned and spontaneous movement',
              'Allow for schedule changes and life events',
              'Focus on overall patterns, not daily perfection'
            ],
          ),
          LessonSlide(
            id: 'slide_14_4_4',
            title: 'Getting Professional Support',
            content: 'Consider working with professionals who understand eating disorders when returning to exercise.',
            slideNumber: 4,
            bulletPoints: [
              'Physical therapists for injury prevention',
              'Exercise physiologists familiar with eating disorders',
              'Personal trainers with Health at Every Size training',
              'Movement therapists for body connection work',
              'Always coordinate with your treatment team'
            ],
            additionalInfo: 'Remember: The goal is to develop a lifelong, positive relationship with movement that enhances your life and supports your recovery.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 15: SPECIAL POPULATIONS - 2 lessons

      // Lesson 15.1 - 6 slides
      Lesson(
        id: 'lesson_15_1',
        title: 'Athletes and Eating Disorders',
        description: 'Understanding the unique challenges athletes face with eating disorders and finding balanced approaches to sport and nutrition.',
        chapterNumber: 15,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_15_1_1',
            title: 'Athletic Culture and Eating Disorders',
            content: 'Certain aspects of athletic culture can increase the risk of developing eating disorders, especially in appearance or weight-focused sports.',
            slideNumber: 1,
            bulletPoints: [
              'Emphasis on body weight and composition',
              'Performance pressure and perfectionism',
              'Team weigh-ins and body fat measurements',
              'Aesthetic sports (gymnastics, dance, figure skating)',
              'Endurance sports with weight categories'
            ],
          ),
          LessonSlide(
            id: 'slide_15_1_2',
            title: 'Relative Energy Deficiency in Sport (REDs)',
            content: 'REDs occurs when athletes don\'t consume enough energy to support both their training demands and basic bodily functions.',
            slideNumber: 2,
            bulletPoints: [
              'Underfueling relative to training demands',
              'Can affect bone health, immunity, metabolism',
              'May impair performance despite initial improvements',
              'Can occur in athletes of any size',
              'Often mistaken for optimal training adaptation'
            ],
          ),
          LessonSlide(
            id: 'slide_15_1_3',
            title: 'Performance vs. Appearance',
            content: 'True athletic performance comes from proper fueling and recovery, not from achieving a certain body weight or appearance.',
            slideNumber: 3,
            bulletPoints: [
              'Optimal performance requires adequate nutrition',
              'Body weight doesn\'t always correlate with performance',
              'Each athlete has an individual optimal weight range',
              'Focus on strength, endurance, and skill development',
              'Health and longevity matter more than short-term gains'
            ],
          ),
          LessonSlide(
            id: 'slide_15_1_4',
            title: 'Fueling for Performance and Recovery',
            content: 'Athletes need adequate energy and nutrients to support training, performance, and recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Carbohydrates for energy and glycogen storage',
              'Protein for muscle repair and building',
              'Fats for hormone production and energy',
              'Adequate calories to support training demands',
              'Proper hydration before, during, and after exercise'
            ],
          ),
          LessonSlide(
            id: 'slide_15_1_5',
            title: 'Working with Sports Professionals',
            content: 'Athletes with eating disorders benefit from working with professionals who understand both athletics and eating disorder recovery.',
            slideNumber: 5,
            bulletPoints: [
              'Sports dietitians familiar with eating disorders',
              'Mental health professionals who understand athletic culture',
              'Coaches educated about eating disorder signs',
              'Team approach to support the athlete',
              'Consider time away from sport if needed for recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_15_1_6',
            title: 'Returning to Sport in Recovery',
            content: 'Returning to athletic participation during or after eating disorder recovery requires careful planning and support.',
            slideNumber: 6,
            bulletPoints: [
              'Ensure medical and nutritional stability first',
              'Modify training intensity and duration initially',
              'Focus on enjoyment and skill development',
              'Monitor for return of eating disorder behaviors',
              'Have ongoing support from treatment team'
            ],
            additionalInfo: 'Remember: True athletic excellence comes from taking care of your body, not punishing it. You can be both a successful athlete and fully recovered.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 15.2 - 5 slides
      Lesson(
        id: 'lesson_15_2',
        title: 'Eating Disorders in Midlife and Beyond',
        description: 'Understanding how eating disorders can manifest in midlife and later years, and recovery considerations for older adults.',
        chapterNumber: 15,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_15_2_1',
            title: 'Eating Disorders Are Not Just for Young People',
            content: 'Eating disorders can develop at any age or may persist or recur later in life. They are not limited to adolescents and young adults.',
            slideNumber: 1,
            bulletPoints: [
              'Can develop for first time in midlife or later',
              'May persist from younger years',
              'Can recur during life transitions',
              'Often go unrecognized in older adults',
              'May be triggered by life changes or loss'
            ],
          ),
          LessonSlide(
            id: 'slide_15_2_2',
            title: 'Unique Triggers in Midlife',
            content: 'Certain life events and changes common in midlife can trigger or worsen eating disorder behaviors.',
            slideNumber: 2,
            bulletPoints: [
              'Menopause and hormonal changes',
              'Divorce or relationship changes',
              'Children leaving home ("empty nest")',
              'Caring for aging parents',
              'Career changes or retirement',
              'Death of loved ones'
            ],
          ),
          LessonSlide(
            id: 'slide_15_2_3',
            title: 'Health Considerations in Older Adults',
            content: 'Eating disorders can have more serious health consequences in older adults due to age-related changes.',
            slideNumber: 3,
            bulletPoints: [
              'Increased risk of bone fractures',
              'Slower healing and recovery',
              'Interactions with medications',
              'Impact on existing health conditions',
              'Greater risk of complications'
            ],
          ),
          LessonSlide(
            id: 'slide_15_2_4',
            title: 'Treatment Considerations',
            content: 'Treatment for older adults may need to be modified to address unique needs and life circumstances.',
            slideNumber: 4,
            bulletPoints: [
              'Address age-related body changes with acceptance',
              'Consider medications and health conditions',
              'Include family and support systems',
              'Address grief and life transitions',
              'Adapt treatment approaches for different learning styles'
            ],
          ),
          LessonSlide(
            id: 'slide_15_2_5',
            title: 'Recovery Is Possible at Any Age',
            content: 'Recovery from eating disorders is possible regardless of age, though the approach may need to be adapted.',
            slideNumber: 5,
            bulletPoints: [
              'It\'s never too late to seek help',
              'Recovery can happen at any life stage',
              'Focus on health and quality of life',
              'Build on life experience and wisdom',
              'Consider what truly matters at this life stage'
            ],
            additionalInfo: 'Remember: You deserve recovery and a peaceful relationship with food at every stage of life. Your age doesn\'t disqualify you from healing.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 16: IDENTITY AND SELF-WORTH - 3 lessons

      // Lesson 16.1 - 5 slides
      Lesson(
        id: 'lesson_16_1',
        title: 'Separating Identity from Eating Disorder',
        description: 'Learning to distinguish between who you are and your eating disorder behaviors.',
        chapterNumber: 16,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_16_1_1',
            title: 'You Are Not Your Eating Disorder',
            content: 'An eating disorder is something you have, not something you are. Learning to separate your identity from your eating disorder is crucial for recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Eating disorder is a condition, not an identity',
              'You existed before the eating disorder',
              'You have qualities and strengths beyond your eating',
              'Recovery involves rediscovering who you are'
            ],
          ),
          LessonSlide(
            id: 'slide_16_1_2',
            title: 'When Eating Disorders Become Identity',
            content: 'Sometimes eating disorders can become so intertwined with identity that it feels scary to imagine life without them.',
            slideNumber: 2,
            bulletPoints: [
              'May feel like the eating disorder defines you',
              'Fear of losing identity in recovery',
              'Eating disorder may feel like only source of control',
              'Can become a way to get attention or care',
              'May feel like your only accomplishment'
            ],
          ),
          LessonSlide(
            id: 'slide_16_1_3',
            title: 'Rediscovering Your True Self',
            content: 'Recovery involves reconnecting with who you were before the eating disorder and discovering who you want to become.',
            slideNumber: 3,
            bulletPoints: [
              'Remember interests and hobbies you used to enjoy',
              'Explore new activities and experiences',
              'Pay attention to what brings you joy',
              'Notice your values and what matters to you',
              'Allow yourself to try new things without pressure'
            ],
          ),
          LessonSlide(
            id: 'slide_16_1_4',
            title: 'Building Identity Beyond Eating',
            content: 'A healthy identity includes many different aspects of who you are - relationships, interests, values, and goals.',
            slideNumber: 4,
            bulletPoints: [
              'Your relationships and how you connect with others',
              'Your interests, hobbies, and passions',
              'Your values and what you stand for',
              'Your goals and dreams for the future',
              'Your unique talents and strengths'
            ],
          ),
          LessonSlide(
            id: 'slide_16_1_5',
            title: 'The Fear of Recovery',
            content: 'It\'s normal to feel afraid of losing your eating disorder identity, but recovery opens up space for a fuller, richer sense of self.',
            slideNumber: 5,
            bulletPoints: [
              'Fear of losing control or structure',
              'Worry about who you\'ll be without the eating disorder',
              'Concern about taking up space or having needs',
              'Recovery allows for authentic self-expression',
              'You can discover parts of yourself you forgot existed'
            ],
            additionalInfo: 'Remember: Recovery doesn\'t take away who you are - it reveals who you\'ve always been underneath the eating disorder.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 16.2 - 4 slides
      Lesson(
        id: 'lesson_16_2',
        title: 'Building Self-Worth Beyond Appearance',
        description: 'Developing a sense of worth that isn\'t dependent on how you look or what you weigh.',
        chapterNumber: 16,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_16_2_1',
            title: 'The Appearance-Worth Connection',
            content: 'Many people with eating disorders tie their self-worth to their appearance, weight, or body size. This connection is harmful and unfounded.',
            slideNumber: 1,
            bulletPoints: [
              'Worth isn\'t determined by appearance',
              'This connection is learned, not natural',
              'It\'s reinforced by diet culture and media',
              'It prevents you from seeing your true value',
              'It can never provide lasting satisfaction'
            ],
          ),
          LessonSlide(
            id: 'slide_16_2_2',
            title: 'What Truly Determines Worth',
            content: 'Your worth as a human being is inherent and doesn\'t need to be earned through achievements, appearance, or behavior.',
            slideNumber: 2,
            bulletPoints: [
              'Worth is inherent - you\'re born with it',
              'It doesn\'t fluctuate based on external factors',
              'It can\'t be earned or lost',
              'Everyone has equal inherent worth',
              'It exists simply because you exist'
            ],
          ),
          LessonSlide(
            id: 'slide_16_2_3',
            title: 'Finding Value in Your Qualities',
            content: 'While your worth doesn\'t need to be earned, you can find meaning and value in your positive qualities and contributions.',
            slideNumber: 3,
            bulletPoints: [
              'Your kindness and compassion for others',
              'Your creativity and unique perspective',
              'Your resilience in facing challenges',
              'Your ability to connect with and support others',
              'Your growth and learning over time'
            ],
          ),
          LessonSlide(
            id: 'slide_16_2_4',
            title: 'Practicing Unconditional Self-Worth',
            content: 'Learning to value yourself regardless of external circumstances takes practice but leads to more stable self-esteem.',
            slideNumber: 4,
            bulletPoints: [
              'Practice self-compassion daily',
              'Notice when you tie worth to appearance',
              'Remind yourself of your inherent value',
              'Celebrate non-appearance related accomplishments',
              'Surround yourself with people who value you for who you are'
            ],
            additionalInfo: 'Remember: Your worth doesn\'t depend on your weight, your appearance, your achievements, or anything else. You matter simply because you exist.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 16.3 - 4 slides
      Lesson(
        id: 'lesson_16_3',
        title: 'Values-Based Living',
        description: 'Identifying your core values and learning to make choices based on what truly matters to you.',
        chapterNumber: 16,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_16_3_1',
            title: 'What Are Values?',
            content: 'Values are the principles and qualities that are most important to you. They guide your decisions and give your life meaning and direction.',
            slideNumber: 1,
            bulletPoints: [
              'Deeply held beliefs about what matters',
              'Guide your decisions and actions',
              'Give life meaning and purpose',
              'Are personal and unique to you',
              'Remain relatively stable over time'
            ],
          ),
          LessonSlide(
            id: 'slide_16_3_2',
            title: 'Common Values',
            content: 'While values are personal, here are some examples that many people find important.',
            slideNumber: 2,
            bulletPoints: [
              'Connection: Building meaningful relationships',
              'Growth: Learning and developing as a person',
              'Creativity: Expressing yourself and creating beauty',
              'Service: Helping others and contributing to community',
              'Authenticity: Being true to yourself',
              'Adventure: Exploring and experiencing new things'
            ],
          ),
          LessonSlide(
            id: 'slide_16_3_3',
            title: 'Values vs. Goals',
            content: 'Values are ongoing directions for living, while goals are specific achievements. Values can never be fully achieved - they guide how you live.',
            slideNumber: 3,
            bulletPoints: [
              'Values: Ongoing directions (like "being compassionate")',
              'Goals: Specific achievements (like "lose 10 pounds")',
              'Values guide how you pursue goals',
              'Goals can be achieved, values are lived',
              'Recovery involves aligning goals with values'
            ],
          ),
          LessonSlide(
            id: 'slide_16_3_4',
            title: 'Living According to Your Values',
            content: 'When your actions align with your values, life feels more meaningful and satisfying, regardless of external circumstances.',
            slideNumber: 4,
            bulletPoints: [
              'Make decisions based on what matters most to you',
              'Notice when eating disorder behaviors conflict with values',
              'Use values to guide recovery choices',
              'Small daily actions can reflect your values',
              'Values-based living increases life satisfaction'
            ],
            additionalInfo: 'Remember: Living according to your values creates a sense of purpose and meaning that no eating disorder behavior can provide.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 17: RECOVERY STORIES AND INSPIRATION - 4 lessons

      // Lesson 17.1 - 4 slides
      Lesson(
        id: 'lesson_17_1',
        title: 'Hope in Recovery',
        description: 'Understanding that recovery is possible and learning from others who have found freedom from eating disorders.',
        chapterNumber: 17,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_17_1_1',
            title: 'Recovery Is Possible',
            content: 'Thousands of people have recovered from eating disorders and gone on to live full, meaningful lives. Recovery is not only possible - it\'s probable with proper support.',
            slideNumber: 1,
            bulletPoints: [
              'Many people achieve full recovery',
              'Recovery looks different for everyone',
              'It\'s a process, not a destination',
              'Support and treatment improve outcomes significantly',
              'Hope is an essential ingredient in recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_17_1_2',
            title: 'What Recovery Looks Like',
            content: 'Recovery doesn\'t mean perfection. It means finding freedom from food obsession and building a life worth living.',
            slideNumber: 2,
            bulletPoints: [
              'Freedom from constant food thoughts',
              'Ability to eat flexibly and intuitively',
              'Engaging in life activities without food anxiety',
              'Healthy relationships with others',
              'Purpose and meaning beyond food and body'
            ],
          ),
          LessonSlide(
            id: 'slide_17_1_3',
            title: 'The Journey Takes Time',
            content: 'Recovery is rarely linear or quick. It\'s a journey with ups and downs, but each step forward is meaningful progress.',
            slideNumber: 3,
            bulletPoints: [
              'Recovery takes time - be patient with yourself',
              'Expect setbacks as part of the process',
              'Each person\'s timeline is different',
              'Small steps add up to big changes',
              'Progress isn\'t always visible day to day'
            ],
          ),
          LessonSlide(
            id: 'slide_17_1_4',
            title: 'You Can Do This',
            content: 'Every person who has recovered once felt hopeless or doubted their ability to get better. You have the same capacity for healing.',
            slideNumber: 4,
            bulletPoints: [
              'You have the same capacity for healing as anyone else',
              'Your eating disorder doesn\'t define your potential',
              'Many people who felt hopeless are now fully recovered',
              'You deserve recovery and a life of freedom',
              'Taking the step to learn about recovery shows your strength'
            ],
            additionalInfo: 'Remember: The fact that you\'re here, learning about recovery, shows that part of you believes healing is possible. Trust that part of yourself.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 17.2 - 5 slides
      Lesson(
        id: 'lesson_17_2',
        title: 'Overcoming Common Recovery Challenges',
        description: 'Learning from common challenges in recovery and strategies that have helped others overcome them.',
        chapterNumber: 17,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_17_2_1',
            title: 'Fear of Weight Gain',
            content: 'Fear of weight gain is one of the most common challenges in recovery, but many people find this fear decreases as recovery progresses.',
            slideNumber: 1,
            bulletPoints: [
              'Normal and expected fear in recovery',
              'Often worse in anticipation than reality',
              'Weight stabilizes as eating normalizes',
              'Focus on health rather than weight',
              'Body acceptance grows with time and practice'
            ],
          ),
          LessonSlide(
            id: 'slide_17_2_2',
            title: 'Social Situations and Food',
            content: 'Many people find social eating challenging in recovery, but with practice and support, it becomes much easier.',
            slideNumber: 2,
            bulletPoints: [
              'Start with smaller, safer social situations',
              'Practice self-advocacy and setting boundaries',
              'Remember that most people aren\'t focused on your eating',
              'Focus on connection rather than food',
              'It gets easier with repeated exposure'
            ],
          ),
          LessonSlide(
            id: 'slide_17_2_3',
            title: 'Perfectionism in Recovery',
            content: 'Many people struggle with wanting to do recovery "perfectly." Learning to embrace imperfection is part of the healing process.',
            slideNumber: 3,
            bulletPoints: [
              'Recovery isn\'t a test to pass perfectly',
              'Mistakes and setbacks are learning opportunities',
              'Progress over perfection',
              'Self-compassion is more helpful than self-criticism',
              'Perfect recovery doesn\'t exist'
            ],
          ),
          LessonSlide(
            id: 'slide_17_2_4',
            title: 'Finding Meaning Beyond Food',
            content: 'One of the most rewarding aspects of recovery is discovering interests, relationships, and purposes that eating disorders had overshadowed.',
            slideNumber: 4,
            bulletPoints: [
              'Rediscovering old interests and passions',
              'Building deeper, more authentic relationships',
              'Finding purpose in work, volunteering, or creativity',
              'Developing new skills and hobbies',
              'Contributing to others\' recovery journeys'
            ],
          ),
          LessonSlide(
            id: 'slide_17_2_5',
            title: 'The Unexpected Gifts of Recovery',
            content: 'Many people find that recovery brings unexpected positive changes beyond just freedom from the eating disorder.',
            slideNumber: 5,
            bulletPoints: [
              'Increased empathy and compassion for others',
              'Greater resilience in facing life challenges',
              'Deeper appreciation for simple pleasures',
              'Stronger sense of authentic self',
              'Ability to help others who are struggling'
            ],
            additionalInfo: 'Remember: Recovery often brings gifts you can\'t imagine while you\'re still struggling. Trust that healing is worth the effort.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 17.3 - 4 slides
      Lesson(
        id: 'lesson_17_3',
        title: 'Life After Recovery',
        description: 'Understanding what life can look like after recovery and how to maintain the freedom you\'ve gained.',
        chapterNumber: 17,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_17_3_1',
            title: 'Freedom from Food Obsession',
            content: 'One of the greatest gifts of recovery is mental freedom - no longer spending hours each day thinking about food, weight, or body image.',
            slideNumber: 1,
            bulletPoints: [
              'Mental space freed up for other interests',
              'Spontaneous eating decisions without anxiety',
              'Ability to focus on relationships and activities',
              'Peace with your body and appearance',
              'Energy available for pursuing goals and dreams'
            ],
          ),
          LessonSlide(
            id: 'slide_17_3_2',
            title: 'Authentic Relationships',
            content: 'Recovery allows for deeper, more authentic relationships as you\'re no longer hiding behind eating disorder behaviors.',
            slideNumber: 2,
            bulletPoints: [
              'More present and available in relationships',
              'Ability to be vulnerable and authentic',
              'No longer hiding eating behaviors',
              'Can focus on others rather than food anxiety',
              'Models healthy relationship with food for others'
            ],
          ),
          LessonSlide(
            id: 'slide_17_3_3',
            title: 'Pursuing Dreams and Goals',
            content: 'Recovery opens up energy and mental space to pursue goals and dreams that may have been put on hold during the eating disorder.',
            slideNumber: 3,
            bulletPoints: [
              'Career advancement and educational goals',
              'Creative pursuits and artistic expression',
              'Travel and adventure',
              'Starting a family or deepening family relationships',
              'Contributing to causes you care about'
            ],
          ),
          LessonSlide(
            id: 'slide_17_3_4',
            title: 'Maintaining Recovery',
            content: 'Life after recovery still requires ongoing attention to self-care and maintaining healthy habits, but it becomes much more natural.',
            slideNumber: 4,
            bulletPoints: [
              'Continue healthy coping strategies',
              'Maintain supportive relationships',
              'Stay connected to your values',
              'Seek help during stressful times',
              'Remember that recovery is an ongoing practice'
            ],
            additionalInfo: 'Remember: Recovery isn\'t a finish line you cross once - it\'s a way of living that becomes more natural and automatic over time.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 17.4 - 5 slides
      Lesson(
        id: 'lesson_17_4',
        title: 'Becoming a Recovery Advocate',
        description: 'Exploring how your recovery journey can inspire and help others who are struggling.',
        chapterNumber: 17,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_17_4_1',
            title: 'Your Story Matters',
            content: 'Your recovery story has the power to inspire hope in others who are struggling. Sharing your experience can be healing for both you and others.',
            slideNumber: 1,
            bulletPoints: [
              'Your experience can provide hope to others',
              'Sharing can be part of your own healing',
              'Each person\'s story is unique and valuable',
              'You don\'t need to be "perfectly recovered" to help',
              'Small acts of support can make a big difference'
            ],
          ),
          LessonSlide(
            id: 'slide_17_4_2',
            title: 'Ways to Support Others',
            content: 'There are many ways to support others in recovery, from formal advocacy to simply being a compassionate friend.',
            slideNumber: 2,
            bulletPoints: [
              'Volunteer with eating disorder organizations',
              'Share your story through speaking or writing',
              'Mentor someone earlier in recovery',
              'Advocate for better treatment and insurance coverage',
              'Simply be a supportive friend or family member'
            ],
          ),
          LessonSlide(
            id: 'slide_17_4_3',
            title: 'Protecting Your Own Recovery',
            content: 'While helping others is rewarding, it\'s important to protect your own recovery and set appropriate boundaries.',
            slideNumber: 3,
            bulletPoints: [
              'Ensure your own recovery is stable first',
              'Set boundaries around how much support you provide',
              'Don\'t try to be someone\'s therapist',
              'Take breaks from advocacy work when needed',
              'Remember you can\'t save everyone'
            ],
          ),
          LessonSlide(
            id: 'slide_17_4_4',
            title: 'Fighting Stigma',
            content: 'By living openly in recovery and challenging misconceptions, you help reduce stigma around eating disorders.',
            slideNumber: 4,
            bulletPoints: [
              'Challenge myths and stereotypes about eating disorders',
              'Show that recovery is possible',
              'Educate others about eating disorders',
              'Advocate for better representation in media',
              'Support policies that improve access to treatment'
            ],
          ),
          LessonSlide(
            id: 'slide_17_4_5',
            title: 'The Ripple Effect',
            content: 'Your recovery creates a ripple effect that extends far beyond yourself, touching the lives of family, friends, and even strangers.',
            slideNumber: 5,
            bulletPoints: [
              'Your recovery impacts family and friends',
              'You model healthy behaviors for others',
              'Your children or future children benefit',
              'You contribute to a culture of body acceptance',
              'Your story may save someone\'s life'
            ],
            additionalInfo: 'Remember: Your recovery is not just for you - it\'s a gift to everyone whose life you touch. You have the power to break cycles and create positive change.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // CHAPTER 18: RESOURCES AND NEXT STEPS - 4 lessons

      // Lesson 18.1 - 5 slides
      Lesson(
        id: 'lesson_18_1',
        title: 'Professional Treatment Options',
        description: 'Understanding different levels of care and types of treatment available for eating disorders.',
        chapterNumber: 18,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_18_1_1',
            title: 'Levels of Care',
            content: 'Eating disorder treatment is available at different intensity levels, from outpatient therapy to inpatient hospitalization.',
            slideNumber: 1,
            bulletPoints: [
              'Outpatient: Weekly therapy sessions',
              'Intensive Outpatient (IOP): Multiple sessions per week',
              'Partial Hospitalization (PHP): Daily treatment program',
              'Residential: 24/7 care in specialized facility',
              'Inpatient: Medical hospitalization for severe cases'
            ],
          ),
          LessonSlide(
            id: 'slide_18_1_2',
            title: 'Types of Therapy',
            content: 'Different therapeutic approaches can be effective for eating disorder recovery.',
            slideNumber: 2,
            bulletPoints: [
              'Cognitive Behavioral Therapy (CBT)',
              'Dialectical Behavior Therapy (DBT)',
              'Family-Based Treatment (FBT)',
              'Acceptance and Commitment Therapy (ACT)',
              'Psychodynamic therapy',
              'Group therapy and support groups'
            ],
          ),
          LessonSlide(
            id: 'slide_18_1_3',
            title: 'Treatment Team Members',
            content: 'Comprehensive eating disorder treatment often involves a team of professionals with different specialties.',
            slideNumber: 3,
            bulletPoints: [
              'Therapist: Mental health counseling',
              'Psychiatrist: Medication management',
              'Registered Dietitian: Nutrition counseling',
              'Medical Doctor: Physical health monitoring',
              'Case Manager: Coordination of care'
            ],
          ),
          LessonSlide(
            id: 'slide_18_1_4',
            title: 'Finding Treatment',
            content: 'There are resources to help you find qualified eating disorder treatment providers in your area.',
            slideNumber: 4,
            bulletPoints: [
              'National Eating Disorders Association (NEDA) directory',
              'International Association of Eating Disorders Professionals',
              'Academy for Eating Disorders provider directory',
              'Ask your primary care doctor for referrals',
              'Contact your insurance company for covered providers'
            ],
          ),
          LessonSlide(
            id: 'slide_18_1_5',
            title: 'Insurance and Financial Considerations',
            content: 'Understanding insurance coverage and exploring financial options can help make treatment more accessible.',
            slideNumber: 5,
            bulletPoints: [
              'Check your insurance benefits for mental health coverage',
              'Understand in-network vs. out-of-network costs',
              'Ask about sliding scale fees',
              'Look into scholarships or grants for treatment',
              'Consider telehealth options for accessibility'
            ],
            additionalInfo: 'Remember: Seeking professional help is a sign of strength, not weakness. You deserve support in your recovery journey.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 18.2 - 4 slides
      Lesson(
        id: 'lesson_18_2',
        title: 'Support Groups and Community',
        description: 'Finding and building supportive communities for your recovery journey.',
        chapterNumber: 18,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_18_2_1',
            title: 'The Power of Peer Support',
            content: 'Connecting with others who understand your experience can provide unique support and encouragement in recovery.',
            slideNumber: 1,
            bulletPoints: [
              'Others who truly understand your struggles',
              'Shared experiences and practical tips',
              'Accountability and encouragement',
              'Reduced isolation and shame',
              'Models of recovery and hope'
            ],
          ),
          LessonSlide(
            id: 'slide_18_2_2',
            title: 'Types of Support Groups',
            content: 'Support groups come in many formats and can be found both in-person and online.',
            slideNumber: 2,
            bulletPoints: [
              'Professional-led therapy groups',
              'Peer support groups',
              'Online communities and forums',
              'Recovery-focused social media groups',
              'Eating disorder-specific 12-step programs'
            ],
          ),
          LessonSlide(
            id: 'slide_18_2_3',
            title: 'Finding Safe Communities',
            content: 'It\'s important to find communities that support recovery rather than enabling eating disorder behaviors.',
            slideNumber: 3,
            bulletPoints: [
              'Look for recovery-focused groups',
              'Avoid pro-eating disorder communities',
              'Ensure moderation and professional oversight when possible',
              'Trust your instincts about whether a group feels supportive',
              'It\'s okay to leave groups that don\'t feel helpful'
            ],
          ),
          LessonSlide(
            id: 'slide_18_2_4',
            title: 'Building Your Recovery Community',
            content: 'Recovery is easier with support from multiple sources - both formal and informal.',
            slideNumber: 4,
            bulletPoints: [
              'Professional treatment team',
              'Support group members',
              'Recovery-minded friends and family',
              'Online recovery communities',
              'Mentors or sponsors in recovery'
            ],
            additionalInfo: 'Remember: You don\'t have to recover alone. Building a supportive community is an important part of the healing process.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 18.3 - 5 slides
      Lesson(
        id: 'lesson_18_3',
        title: 'Helpful Books and Resources',
        description: 'Discovering books, websites, and other resources that can support your recovery journey.',
        chapterNumber: 18,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_18_3_1',
            title: 'Books on Eating Disorder Recovery',
            content: 'There are many excellent books that can provide insight, strategies, and hope for recovery.',
            slideNumber: 1,
            bulletPoints: [
              '"Intuitive Eating" by Evelyn Tribole and Elyse Resch',
              '"Health at Every Size" by Lindo Bacon',
              '"Life Without Ed" by Jenni Schaefer',
              '"The Body Is Not an Apology" by Sonya Renee Taylor',
              '"Brain over Binge" by Kathryn Hansen'
            ],
          ),
          LessonSlide(
            id: 'slide_18_3_2',
            title: 'Body Image and Self-Acceptance Resources',
            content: 'These resources focus specifically on improving body image and developing self-acceptance.',
            slideNumber: 2,
            bulletPoints: [
              '"Body Positive Power" by Megan Crabbe',
              '"The Body Image Workbook" by Thomas Cash',
              '"More Than a Body" by Lexie and Lindsay Kite',
              '"The Self-Compassion Workbook" by Kristin Neff',
              'Body-positive social media accounts and podcasts'
            ],
          ),
          LessonSlide(
            id: 'slide_18_3_3',
            title: 'Online Resources and Websites',
            content: 'Reputable websites can provide education, resources, and connection to support services.',
            slideNumber: 3,
            bulletPoints: [
              'National Eating Disorders Association (NEDA)',
              'International Association of Eating Disorders Professionals',
              'Academy for Eating Disorders',
              'Project HEAL',
              'The Body Positive'
            ],
          ),
          LessonSlide(
            id: 'slide_18_3_4',
            title: 'Apps and Digital Tools',
            content: 'Technology can provide convenient support tools for recovery, though they shouldn\'t replace professional treatment.',
            slideNumber: 4,
            bulletPoints: [
              'Meditation and mindfulness apps',
              'Journaling and mood tracking apps',
              'Recovery-focused podcasts',
              'Body image and self-compassion apps',
              'Crisis hotline and text support services'
            ],
          ),
          LessonSlide(
            id: 'slide_18_3_5',
            title: 'Creating Your Resource Library',
            content: 'Building a collection of helpful resources can provide ongoing support and inspiration throughout your recovery.',
            slideNumber: 5,
            bulletPoints: [
              'Keep a list of books and resources that help you',
              'Save inspiring articles and blog posts',
              'Create playlists of recovery-focused podcasts',
              'Bookmark helpful websites and online tools',
              'Share resources with others in recovery'
            ],
            additionalInfo: 'Remember: Resources are tools to support your recovery, but they work best when combined with professional treatment and support.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Lesson 18.4 - 6 slides
      Lesson(
        id: 'lesson_18_4',
        title: 'Creating Your Personal Recovery Plan',
        description: 'Bringing together everything you\'ve learned to create a personalized plan for ongoing recovery.',
        chapterNumber: 18,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_18_4_1',
            title: 'Reflecting on Your Journey',
            content: 'Take time to reflect on how far you\'ve come and what you\'ve learned about yourself and recovery.',
            slideNumber: 1,
            bulletPoints: [
              'What have you learned about your triggers?',
              'Which coping strategies work best for you?',
              'What recovery tools have been most helpful?',
              'How has your relationship with food and body changed?',
              'What are you most proud of in your recovery?'
            ],
          ),
          LessonSlide(
            id: 'slide_18_4_2',
            title: 'Your Recovery Toolbox',
            content: 'Identify the specific tools and strategies that have been most helpful in your recovery.',
            slideNumber: 2,
            bulletPoints: [
              'Coping strategies for difficult emotions',
              'Grounding techniques for anxiety or overwhelm',
              'Mindful eating practices',
              'Body acceptance and self-compassion practices',
              'Support people you can reach out to'
            ],
          ),
          LessonSlide(
            id: 'slide_18_4_3',
            title: 'Ongoing Support Needs',
            content: 'Consider what types of ongoing support will help you maintain your recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Professional therapy or counseling',
              'Support groups or recovery communities',
              'Regular check-ins with treatment team',
              'Recovery-focused friendships',
              'Educational resources and continued learning'
            ],
          ),
          LessonSlide(
            id: 'slide_18_4_4',
            title: 'Goals and Dreams for the Future',
            content: 'Recovery opens up space to pursue goals and dreams that may have been overshadowed by your eating disorder.',
            slideNumber: 4,
            bulletPoints: [
              'Personal relationships you want to deepen',
              'Career or educational goals to pursue',
              'Creative or artistic expressions to explore',
              'Adventures or experiences you want to have',
              'Ways you want to contribute to others or your community'
            ],
          ),
          LessonSlide(
            id: 'slide_18_4_5',
            title: 'Your Recovery Maintenance Plan',
            content: 'Create a plan for maintaining your recovery and continuing to grow.',
            slideNumber: 5,
            bulletPoints: [
              'Daily practices that support your recovery',
              'Weekly or monthly check-ins with yourself',
              'Regular engagement with support systems',
              'Ongoing professional support as needed',
              'Plans for handling setbacks or challenges'
            ],
          ),
          LessonSlide(
            id: 'slide_18_4_6',
            title: 'Your Recovery Legacy',
            content: 'Consider how you want to use your recovery experience to create positive change in the world.',
            slideNumber: 6,
            bulletPoints: [
              'How can you support others who are struggling?',
              'What message do you want to share about recovery?',
              'How can you challenge stigma about eating disorders?',
              'What positive changes can you create in your community?',
              'How will you honor the courage it took to choose recovery?'
            ],
            additionalInfo: 'Remember: Your recovery is a gift - to yourself, to your loved ones, and to the world. You have shown incredible courage and strength. Continue to honor that courage as you move forward in your life.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // APPENDIX 1: EMERGENCY RESOURCES AND CRISIS MANAGEMENT - 3 lessons

      // Appendix 1.1 - 4 slides
      Lesson(
        id: 'appendix_1_1',
        title: 'Crisis Support and Hotlines',
        description: 'Essential crisis support resources and when to use them.',
        chapterNumber: 101,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_app1_1_1',
            title: 'When to Seek Emergency Help',
            content: 'Certain situations require immediate professional intervention. Recognizing these signs can be life-saving.',
            slideNumber: 1,
            bulletPoints: [
              'Thoughts of suicide or self-harm',
              'Severe dehydration or fainting',
              'Chest pain or heart palpitations',
              'Severe depression or inability to function',
              'Thoughts of hurting others'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_1_2',
            title: 'National Crisis Hotlines',
            content: 'These resources are available 24/7 and provide immediate support during crisis situations.',
            slideNumber: 2,
            bulletPoints: [
              '988 Suicide & Crisis Lifeline: 988',
              'National Eating Disorders Association Helpline: 1-800-931-2237',
              'Crisis Text Line: Text HOME to 741741',
              'SAMHSA National Helpline: 1-800-662-4357',
              'National Sexual Assault Hotline: 1-800-656-4673'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_1_3',
            title: 'Emergency Room vs. Crisis Centers',
            content: 'Understanding when to go to the emergency room versus other crisis resources.',
            slideNumber: 3,
            bulletPoints: [
              'Emergency Room: Medical emergencies, severe dehydration, heart issues',
              'Psychiatric Emergency Services: Suicidal thoughts, severe mental health crisis',
              'Crisis Respite Centers: Safe space for stabilization',
              'Mobile Crisis Teams: In-home crisis intervention',
              'Crisis Hotlines: Immediate emotional support and guidance'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_1_4',
            title: 'Creating Your Personal Crisis Plan',
            content: 'Having a plan in place before a crisis makes it easier to access help when you need it most.',
            slideNumber: 4,
            bulletPoints: [
              'List emergency contacts and their phone numbers',
              'Identify your nearest emergency room',
              'Know the signs that indicate you need help',
              'Share your plan with trusted friends or family',
              'Keep important phone numbers easily accessible'
            ],
            additionalInfo: 'Remember: Seeking help during a crisis is a sign of strength and self-care, not weakness. You deserve support.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 1.2 - 5 slides
      Lesson(
        id: 'appendix_1_2',
        title: 'Medical Complications and Warning Signs',
        description: 'Understanding serious medical complications of eating disorders and when to seek immediate medical care.',
        chapterNumber: 101,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_app1_2_1',
            title: 'Cardiovascular Warning Signs',
            content: 'Eating disorders can seriously affect your heart. These symptoms require immediate medical attention.',
            slideNumber: 1,
            bulletPoints: [
              'Chest pain or pressure',
              'Heart palpitations or irregular heartbeat',
              'Dizziness or fainting',
              'Extreme fatigue or weakness',
              'Shortness of breath'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_2_2',
            title: 'Dehydration and Electrolyte Imbalances',
            content: 'Severe dehydration and electrolyte imbalances can be life-threatening and require immediate medical care.',
            slideNumber: 2,
            bulletPoints: [
              'Severe dizziness or lightheadedness',
              'Confusion or difficulty concentrating',
              'Muscle cramps or weakness',
              'Nausea and vomiting',
              'Decreased urination or dark urine'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_2_3',
            title: 'Gastrointestinal Complications',
            content: 'Eating disorders can cause serious digestive system problems that may require medical intervention.',
            slideNumber: 3,
            bulletPoints: [
              'Severe abdominal pain',
              'Blood in vomit or stool',
              'Inability to keep fluids down',
              'Severe constipation (no bowel movement for several days)',
              'Signs of gastroparesis (stomach paralysis)'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_2_4',
            title: 'Bone and Metabolic Issues',
            content: 'Long-term effects on bones and metabolism can have serious health consequences.',
            slideNumber: 4,
            bulletPoints: [
              'Frequent bone fractures',
              'Severe dental problems',
              'Hair loss or brittle nails',
              'Feeling constantly cold',
              'Delayed wound healing'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_2_5',
            title: 'When to Seek Immediate Medical Care',
            content: 'Don\'t wait if you experience any of these symptoms. Early intervention can prevent serious complications.',
            slideNumber: 5,
            bulletPoints: [
              'Any chest pain or heart symptoms',
              'Severe dizziness or fainting',
              'Signs of severe dehydration',
              'Blood in vomit or stool',
              'Thoughts of self-harm'
            ],
            additionalInfo: 'Remember: Medical professionals are there to help, not judge. Being honest about your eating behaviors helps them provide the best care.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 1.3 - 4 slides
      Lesson(
        id: 'appendix_1_3',
        title: 'Safety Planning for High-Risk Situations',
        description: 'Creating specific safety plans for situations that commonly trigger eating disorder behaviors.',
        chapterNumber: 101,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_app1_3_1',
            title: 'Identifying Your High-Risk Situations',
            content: 'Understanding your personal triggers helps you prepare effective safety strategies.',
            slideNumber: 1,
            bulletPoints: [
              'Social events involving food',
              'Stressful periods (exams, work deadlines)',
              'Relationship conflicts or changes',
              'Comments about body or food',
              'Specific times of day or locations'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_3_2',
            title: 'Creating a Safety Plan',
            content: 'A detailed safety plan gives you concrete steps to follow when you\'re struggling.',
            slideNumber: 2,
            bulletPoints: [
              'Identify your warning signs',
              'List coping strategies that work for you',
              'Include contact information for support people',
              'Plan for removing access to harmful behaviors',
              'Know when and how to seek professional help'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_3_3',
            title: 'Support Team Contact List',
            content: 'Having a ready list of support contacts makes it easier to reach out when you need help.',
            slideNumber: 3,
            bulletPoints: [
              'Therapist or counselor contact information',
              'Trusted friends or family members',
              'Crisis hotlines and text services',
              'Medical providers (doctor, psychiatrist)',
              'Backup contacts if primary people aren\'t available'
            ],
          ),
          LessonSlide(
            id: 'slide_app1_3_4',
            title: 'Environmental Safety Strategies',
            content: 'Modifying your environment can reduce opportunities for eating disorder behaviors.',
            slideNumber: 4,
            bulletPoints: [
              'Remove or secure items used for harmful behaviors',
              'Plan alternative activities for triggering times',
              'Arrange for supervision during high-risk periods',
              'Create safe spaces in your home',
              'Have emergency supplies readily available'
            ],
            additionalInfo: 'Remember: Safety planning is an act of self-care. Having a plan doesn\'t mean you\'re planning to fail - it means you\'re planning to stay safe.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // APPENDIX 2: MEAL PLANNING AND NUTRITION GUIDES - 4 lessons

      // Appendix 2.1 - 5 slides
      Lesson(
        id: 'appendix_2_1',
        title: 'Sample Meal Plans for Recovery',
        description: 'Practical meal planning examples to support eating disorder recovery.',
        chapterNumber: 102,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_app2_1_1',
            title: 'Recovery Nutrition Principles',
            content: 'Meal planning in recovery focuses on adequacy, variety, and flexibility rather than restriction.',
            slideNumber: 1,
            bulletPoints: [
              'Include all food groups at most meals',
              'Eat regularly throughout the day',
              'Choose variety within and across food groups',
              'Honor hunger and fullness cues',
              'Include foods you enjoy'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_1_2',
            title: 'Basic Meal Structure',
            content: 'A balanced meal typically includes carbohydrates, protein, fat, and often fruits or vegetables.',
            slideNumber: 2,
            bulletPoints: [
              'Carbohydrates: Bread, rice, pasta, potatoes, fruits',
              'Protein: Meat, fish, eggs, beans, nuts, dairy',
              'Fats: Oils, nuts, seeds, avocado, butter',
              'Fruits/Vegetables: Fresh, frozen, or canned varieties',
              'Flavor enhancers: Herbs, spices, sauces'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_1_3',
            title: 'Sample Day 1',
            content: 'Here\'s an example of what a day of recovery eating might look like.',
            slideNumber: 3,
            bulletPoints: [
              'Breakfast: Oatmeal with banana and nuts, plus juice',
              'Snack: Yogurt with granola',
              'Lunch: Sandwich with protein, side salad, and chips',
              'Snack: Apple with peanut butter',
              'Dinner: Pasta with meat sauce, garlic bread, and vegetables'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_1_4',
            title: 'Sample Day 2',
            content: 'Variety is important - here\'s a different day of balanced eating.',
            slideNumber: 4,
            bulletPoints: [
              'Breakfast: Eggs and toast with avocado, plus fruit',
              'Snack: Trail mix',
              'Lunch: Burrito bowl with rice, beans, protein, and toppings',
              'Snack: Crackers with cheese',
              'Dinner: Stir-fry with rice and a dinner roll'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_1_5',
            title: 'Flexible Meal Planning Tips',
            content: 'Meal planning should support your recovery, not create more food rules.',
            slideNumber: 5,
            bulletPoints: [
              'Plan for about 70% of meals, leave 30% flexible',
              'Include foods you\'re working on in recovery',
              'Have backup options for when plans change',
              'Consider social meals and eating out',
              'Adjust portions based on hunger and fullness'
            ],
            additionalInfo: 'Remember: These are examples, not prescriptions. Work with a registered dietitian to create a meal plan that\'s right for your individual needs.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 2.2 - 4 slides
      Lesson(
        id: 'appendix_2_2',
        title: 'Grocery Shopping and Food Preparation',
        description: 'Practical strategies for grocery shopping and meal preparation during eating disorder recovery.',
        chapterNumber: 102,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_app2_2_1',
            title: 'Recovery-Focused Grocery Shopping',
            content: 'Grocery shopping in recovery means focusing on adequacy and variety rather than restriction.',
            slideNumber: 1,
            bulletPoints: [
              'Shop with a list that includes all food groups',
              'Include both fear foods and safe foods',
              'Don\'t shop when overly hungry',
              'Consider shopping with support if needed',
              'Focus on foods that nourish and satisfy you'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_2_2',
            title: 'Stocking Your Kitchen',
            content: 'Having a variety of foods available makes it easier to eat regularly and adequately.',
            slideNumber: 2,
            bulletPoints: [
              'Pantry staples: Rice, pasta, canned beans, nut butter',
              'Refrigerator basics: Milk, eggs, yogurt, fresh fruits/vegetables',
              'Freezer items: Frozen vegetables, frozen meals, bread',
              'Snack foods: Crackers, nuts, granola bars',
              'Comfort foods: Foods you enjoy and find satisfying'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_2_3',
            title: 'Meal Preparation Strategies',
            content: 'Simple meal preparation can make eating regularly easier and less stressful.',
            slideNumber: 3,
            bulletPoints: [
              'Prepare ingredients in advance (wash vegetables, cook grains)',
              'Keep simple meals and snacks on hand',
              'Use convenience foods when helpful',
              'Batch cook favorite recipes',
              'Have emergency backup meals available'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_2_4',
            title: 'Overcoming Food Shopping Anxiety',
            content: 'Food shopping can be triggering in recovery. These strategies can help.',
            slideNumber: 4,
            bulletPoints: [
              'Start with online grocery ordering if needed',
              'Shop during less crowded times',
              'Bring a support person if helpful',
              'Use grounding techniques if you feel overwhelmed',
              'Remember that all foods can fit in a healthy diet'
            ],
            additionalInfo: 'Remember: Learning to shop for and prepare food is a skill that develops over time. Be patient with yourself as you rebuild this relationship.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 2.3 - 6 slides
      Lesson(
        id: 'appendix_2_3',
        title: 'Eating Out and Social Food Situations',
        description: 'Strategies for navigating restaurants, social events, and other food-centered situations.',
        chapterNumber: 102,
        lessonNumber: 3,
        slides: [
          LessonSlide(
            id: 'slide_app2_3_1',
            title: 'Preparing for Restaurant Meals',
            content: 'A little preparation can make eating out more comfortable and less anxiety-provoking.',
            slideNumber: 1,
            bulletPoints: [
              'Look at the menu online beforehand if helpful',
              'Choose restaurants with variety and flexibility',
              'Practice ordering skills with support',
              'Focus on social connection, not just food',
              'Have a support plan if you feel overwhelmed'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_3_2',
            title: 'Ordering Strategies',
            content: 'Ordering in recovery means choosing foods that nourish you and support your recovery goals.',
            slideNumber: 2,
            bulletPoints: [
              'Order what sounds good or appealing',
              'Include foods from multiple food groups',
              'Don\'t be afraid to ask questions about preparation',
              'Avoid making special requests that restrict',
              'Remember that restaurant portions vary - that\'s normal'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_3_3',
            title: 'Social Eating Events',
            content: 'Parties, potlucks, and other social events can be challenging but are important parts of life.',
            slideNumber: 3,
            bulletPoints: [
              'Eat regular meals before and after the event',
              'Focus on social connection over food',
              'Try a variety of foods if available',
              'Don\'t skip the event because of food anxiety',
              'Have exit strategies if you feel overwhelmed'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_3_4',
            title: 'Handling Food Comments',
            content: 'Unfortunately, people sometimes make unhelpful comments about food. Here\'s how to handle them.',
            slideNumber: 4,
            bulletPoints: [
              'Have prepared responses: "I\'m satisfied with my choice"',
              'Change the subject to non-food topics',
              'Set boundaries: "I\'d prefer not to discuss food"',
              'Remember that their comments reflect their issues, not yours',
              'Seek support from trusted friends or family'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_3_5',
            title: 'Travel and Eating',
            content: 'Traveling can disrupt eating routines, but with planning, you can maintain recovery-supportive eating.',
            slideNumber: 5,
            bulletPoints: [
              'Pack snacks for travel days',
              'Research food options at your destination',
              'Maintain regular meal timing when possible',
              'Be flexible with food choices while traveling',
              'Don\'t use travel as an excuse to restrict'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_3_6',
            title: 'Building Confidence with Social Eating',
            content: 'Social eating gets easier with practice and the right mindset.',
            slideNumber: 6,
            bulletPoints: [
              'Start with smaller, safer social eating situations',
              'Practice with supportive friends or family',
              'Focus on the social aspects of meals',
              'Celebrate small victories',
              'Remember that food is meant to be enjoyed socially'
            ],
            additionalInfo: 'Remember: Social eating is an important part of recovery and life. These skills will become more natural with practice.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 2.4 - 5 slides
      Lesson(
        id: 'appendix_2_4',
        title: 'Special Dietary Considerations',
        description: 'Addressing medical dietary needs, food allergies, and other special considerations in eating disorder recovery.',
        chapterNumber: 102,
        lessonNumber: 4,
        slides: [
          LessonSlide(
            id: 'slide_app2_4_1',
            title: 'Medical Dietary Restrictions vs. Eating Disorder Rules',
            content: 'It\'s important to distinguish between medically necessary dietary changes and eating disorder-driven restrictions.',
            slideNumber: 1,
            bulletPoints: [
              'Medical restrictions are prescribed by healthcare providers',
              'They have specific health reasons and are time-limited when possible',
              'Eating disorder rules are often self-imposed and anxiety-driven',
              'Work with your team to determine what\'s truly necessary',
              'Don\'t use medical conditions to justify unnecessary restriction'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_4_2',
            title: 'Food Allergies and Intolerances',
            content: 'Legitimate food allergies and intolerances can be managed while maintaining eating disorder recovery.',
            slideNumber: 2,
            bulletPoints: [
              'Work with an allergist for proper testing',
              'Focus on what you CAN eat, not what you can\'t',
              'Learn about safe substitutions',
              'Don\'t assume you have allergies without proper testing',
              'Ensure adequate nutrition despite restrictions'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_4_3',
            title: 'Vegetarian and Vegan Considerations',
            content: 'Plant-based eating can be part of recovery when done for the right reasons and with proper planning.',
            slideNumber: 3,
            bulletPoints: [
              'Examine your motivations honestly',
              'Ensure adequate protein, calories, and nutrients',
              'Work with a dietitian familiar with both eating disorders and plant-based nutrition',
              'Include a variety of plant foods',
              'Consider whether this adds restriction to your recovery'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_4_4',
            title: 'Religious and Cultural Food Practices',
            content: 'Religious and cultural food practices can be honored while maintaining recovery.',
            slideNumber: 4,
            bulletPoints: [
              'Discuss with your treatment team how to honor traditions',
              'Focus on the spiritual/cultural meaning, not just food rules',
              'Find ways to participate that don\'t compromise recovery',
              'Consider modifications during vulnerable periods',
              'Remember that health is often valued in religious traditions'
            ],
          ),
          LessonSlide(
            id: 'slide_app2_4_5',
            title: 'Working with Healthcare Providers',
            content: 'Coordination between your eating disorder treatment team and other healthcare providers is essential.',
            slideNumber: 5,
            bulletPoints: [
              'Inform all providers about your eating disorder history',
              'Ask how recommendations might interact with recovery',
              'Request alternatives if suggestions seem restrictive',
              'Get recommendations in writing to share with your team',
              'Don\'t make dramatic dietary changes without team input'
            ],
            additionalInfo: 'Remember: True medical dietary needs can usually be accommodated without compromising eating disorder recovery. Work with your team to find solutions.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // APPENDIX 3: BODY IMAGE RESOURCES AND EXERCISES - 2 lessons

      // Appendix 3.1 - 6 slides
      Lesson(
        id: 'appendix_3_1',
        title: 'Body Neutrality and Acceptance Exercises',
        description: 'Practical exercises for developing a more neutral and accepting relationship with your body.',
        chapterNumber: 103,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_app3_1_1',
            title: 'Body Scan for Appreciation',
            content: 'This exercise helps you notice your body with curiosity and appreciation rather than judgment.',
            slideNumber: 1,
            bulletPoints: [
              'Lie down comfortably and close your eyes',
              'Start at the top of your head and slowly scan down',
              'Notice what each body part does for you',
              'Thank each part for its function',
              'If judgmental thoughts arise, gently redirect to function'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_1_2',
            title: 'Mirror Work for Neutrality',
            content: 'Learning to look at yourself with neutrality rather than harsh criticism.',
            slideNumber: 2,
            bulletPoints: [
              'Start with brief, clothed mirror exposure',
              'Focus on describing what you see factually',
              'Avoid judgmental language (good/bad, fat/thin)',
              'Practice neutral statements: "I see a person with brown hair"',
              'Gradually increase exposure time as comfort improves'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_1_3',
            title: 'Function Focus Exercise',
            content: 'Shifting focus from appearance to what your body can do.',
            slideNumber: 3,
            bulletPoints: [
              'List 10 things your body allows you to do',
              'Include basic functions: breathing, heart beating, healing',
              'Add activities you enjoy: hugging, walking, creating',
              'When appearance thoughts arise, redirect to function',
              'Add to your list regularly'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_1_4',
            title: 'Clothing Comfort Exercise',
            content: 'Choosing clothes based on comfort and self-expression rather than appearance goals.',
            slideNumber: 4,
            bulletPoints: [
              'Choose clothes that feel comfortable on your body',
              'Select colors and styles you enjoy',
              'Avoid clothes that are too tight or loose as punishment',
              'Consider what the clothing helps you do (work, play, rest)',
              'Notice how different fabrics and fits affect your mood'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_1_5',
            title: 'Body Kindness Practice',
            content: 'Treating your body with the same kindness you\'d show a good friend.',
            slideNumber: 5,
            bulletPoints: [
              'Notice when you\'re being harsh or critical',
              'Ask: "Would I talk to a friend this way?"',
              'Practice gentle, caring language about your body',
              'Focus on care rather than control',
              'Treat your body as an ally, not an enemy'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_1_6',
            title: 'Values-Based Body Relationship',
            content: 'Aligning how you treat your body with your deeper values.',
            slideNumber: 6,
            bulletPoints: [
              'Identify your core values (kindness, health, authenticity)',
              'Consider how these values apply to your body relationship',
              'Make choices based on values rather than appearance',
              'Ask: "Does this behavior align with my values?"',
              'Remember that self-care is a form of self-respect'
            ],
            additionalInfo: 'Remember: Body neutrality and acceptance are ongoing practices. Be patient with yourself as you develop these new ways of relating to your body.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 3.2 - 5 slides
      Lesson(
        id: 'appendix_3_2',
        title: 'Media Literacy and Social Media Guidelines',
        description: 'Developing critical media literacy skills and creating a social media environment that supports recovery.',
        chapterNumber: 103,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_app3_2_1',
            title: 'Understanding Media Manipulation',
            content: 'Most media images are heavily edited and don\'t represent reality.',
            slideNumber: 1,
            bulletPoints: [
              'Photos are routinely retouched and filtered',
              'Lighting, angles, and poses are carefully chosen',
              'Models and actors represent a tiny fraction of body diversity',
              'Advertising is designed to make you feel inadequate',
              'Even "candid" social media photos are often curated'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_2_2',
            title: 'Critical Questions for Media Consumption',
            content: 'Ask yourself these questions when consuming media to maintain perspective.',
            slideNumber: 2,
            bulletPoints: [
              'What is this image/message trying to sell me?',
              'How does this make me feel about myself?',
              'Is this image realistic or heavily edited?',
              'Does this content align with my recovery values?',
              'What diverse bodies and experiences are missing?'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_2_3',
            title: 'Curating Your Social Media Feed',
            content: 'Your social media environment can either support or hinder your recovery.',
            slideNumber: 3,
            bulletPoints: [
              'Unfollow accounts that trigger comparison or restriction',
              'Follow body-positive and recovery-focused accounts',
              'Use keywords to find diverse, authentic content',
              'Limit time on platforms that consistently trigger you',
              'Remember you have control over what you see'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_2_4',
            title: 'Healthy Social Media Boundaries',
            content: 'Set boundaries around social media use to protect your mental health.',
            slideNumber: 4,
            bulletPoints: [
              'Set specific times for social media use',
              'Take regular breaks from social platforms',
              'Turn off notifications if they feel overwhelming',
              'Don\'t scroll when you\'re feeling vulnerable',
              'Engage mindfully rather than mindlessly scrolling'
            ],
          ),
          LessonSlide(
            id: 'slide_app3_2_5',
            title: 'Creating Positive Content',
            content: 'Consider how your own social media use can promote body positivity and authenticity.',
            slideNumber: 5,
            bulletPoints: [
              'Share diverse, authentic representations of life',
              'Avoid editing photos to change your appearance',
              'Post about interests beyond appearance',
              'Use your platform to support others',
              'Be honest about struggles and growth'
            ],
            additionalInfo: 'Remember: You have the power to create a media environment that supports your recovery and wellbeing. Use it wisely.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // APPENDIX 4: SUPPORTING OTHERS AND ADVOCACY - 2 lessons

      // Appendix 4.1 - 5 slides
      Lesson(
        id: 'appendix_4_1',
        title: 'How to Support a Loved One with an Eating Disorder',
        description: 'Guidance for friends and family members on how to provide helpful support.',
        chapterNumber: 104,
        lessonNumber: 1,
        slides: [
          LessonSlide(
            id: 'slide_app4_1_1',
            title: 'Understanding Your Role',
            content: 'As a supporter, your role is important but has limitations. Understanding boundaries helps both you and your loved one.',
            slideNumber: 1,
            bulletPoints: [
              'You can provide love and support, but you can\'t force recovery',
              'Professional treatment is essential - you\'re not the therapist',
              'Your care and concern matter, even if progress isn\'t visible',
              'Recovery is ultimately your loved one\'s choice',
              'Taking care of yourself helps you support others'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_1_2',
            title: 'What TO Do',
            content: 'These approaches are generally helpful for supporting someone with an eating disorder.',
            slideNumber: 2,
            bulletPoints: [
              'Listen without trying to fix or give advice',
              'Express concern about behaviors, not appearance',
              'Support professional treatment and attend sessions if invited',
              'Learn about eating disorders from reputable sources',
              'Focus on the person beyond their eating disorder'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_1_3',
            title: 'What NOT to Do',
            content: 'Well-meaning actions can sometimes be harmful. Avoid these common mistakes.',
            slideNumber: 3,
            bulletPoints: [
              'Don\'t comment on appearance, weight, or food choices',
              'Don\'t monitor their eating or become the "food police"',
              'Don\'t make assumptions about what they need',
              'Don\'t take their behaviors personally',
              'Don\'t ignore serious warning signs or medical emergencies'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_1_4',
            title: 'Communication Strategies',
            content: 'How you communicate can make a significant difference in your ability to provide support.',
            slideNumber: 4,
            bulletPoints: [
              'Use "I" statements: "I\'m concerned about you"',
              'Avoid food and weight-focused conversations',
              'Ask how you can best support them',
              'Be patient with their recovery process',
              'Focus on their strengths and positive qualities'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_1_5',
            title: 'Taking Care of Yourself',
            content: 'Supporting someone with an eating disorder can be emotionally challenging. Your wellbeing matters too.',
            slideNumber: 5,
            bulletPoints: [
              'Seek your own support through therapy or support groups',
              'Set healthy boundaries around what you can and cannot do',
              'Maintain your own interests and relationships',
              'Practice self-compassion when you make mistakes',
              'Remember that you can\'t control their recovery'
            ],
            additionalInfo: 'Remember: Your love and support matter, even when recovery is difficult. Taking care of yourself enables you to be there for your loved one.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),

      // Appendix 4.2 - 6 slides
      Lesson(
        id: 'appendix_4_2',
        title: 'Advocacy and Raising Awareness',
        description: 'How to advocate for eating disorder awareness, treatment access, and cultural change.',
        chapterNumber: 104,
        lessonNumber: 2,
        slides: [
          LessonSlide(
            id: 'slide_app4_2_1',
            title: 'Why Advocacy Matters',
            content: 'Advocacy helps improve treatment access, reduce stigma, and prevent eating disorders.',
            slideNumber: 1,
            bulletPoints: [
              'Increases understanding and reduces stigma',
              'Improves access to treatment and insurance coverage',
              'Prevents eating disorders through education',
              'Supports research for better treatments',
              'Creates cultural change around body image and food'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_2_2',
            title: 'Personal Advocacy',
            content: 'Advocacy can start with your own daily interactions and choices.',
            slideNumber: 2,
            bulletPoints: [
              'Challenge diet culture in your conversations',
              'Avoid commenting on bodies and food choices',
              'Support body-diverse businesses and media',
              'Share accurate information about eating disorders',
              'Model body acceptance and food freedom'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_2_3',
            title: 'Community Advocacy',
            content: 'Getting involved in your community can create broader change.',
            slideNumber: 3,
            bulletPoints: [
              'Volunteer with eating disorder organizations',
              'Speak at schools or community events',
              'Organize awareness events during National Eating Disorders Week',
              'Support policies that improve mental health access',
              'Advocate for inclusive health education'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_2_4',
            title: 'Policy and Systemic Advocacy',
            content: 'Working to change policies and systems that contribute to eating disorders.',
            slideNumber: 4,
            bulletPoints: [
              'Support insurance parity for mental health treatment',
              'Advocate for eating disorder training for healthcare providers',
              'Push for diverse representation in media',
              'Support research funding for eating disorders',
              'Advocate for weight-neutral approaches in healthcare'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_2_5',
            title: 'Sharing Your Story',
            content: 'Personal stories can be powerful tools for education and inspiration.',
            slideNumber: 5,
            bulletPoints: [
              'Share only what feels comfortable and safe',
              'Focus on hope and recovery rather than details of illness',
              'Consider different platforms: writing, speaking, social media',
              'Protect your privacy and set boundaries',
              'Remember that your story can save lives'
            ],
          ),
          LessonSlide(
            id: 'slide_app4_2_6',
            title: 'Sustainable Advocacy',
            content: 'Making advocacy a sustainable part of your life while protecting your recovery.',
            slideNumber: 6,
            bulletPoints: [
              'Start small and build gradually',
              'Balance advocacy with self-care',
              'Connect with other advocates for support',
              'Take breaks when needed',
              'Remember that any contribution makes a difference'
            ],
            additionalInfo: 'Remember: Your voice and experience matter. Whether you advocate in small or large ways, you\'re contributing to positive change for others.',
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}
