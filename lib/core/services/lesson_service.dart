import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/lesson.dart';
import '../../models/lesson_slide.dart';

class LessonService {
  static const String _collectionName = 'lessons';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await _firestore
          .collection(_collectionName)
          .doc(lessonId)
          .update({
        'isCompleted': true,
        'completedAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('Failed to mark lesson as completed: $e');
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
      // Check if lessons already exist by trying to get a specific lesson
      try {
        final existingLesson = await getLessonByChapterAndNumber(1, 1);
        if (existingLesson != null) {
          return; // Lessons already exist
        }
      } catch (e) {
        // If there's an error checking for existing lessons, continue with initialization
        print('Warning: Could not check for existing lessons: $e');
      }

      // Create default lessons with specific IDs
      final defaultLessons = _getDefaultLessons();
      
      for (final lesson in defaultLessons) {
        try {
          await createLessonWithId(lesson.id, lesson);
        } catch (e) {
          print('Warning: Could not create lesson ${lesson.id}: $e');
          // Continue with other lessons even if one fails
        }
      }
    } catch (e) {
      throw Exception('Failed to initialize default lessons: $e');
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
    ];
  }
}
