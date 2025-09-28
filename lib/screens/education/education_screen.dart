import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart' as lesson_model;
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../lessons/lesson_1_1.dart';
import '../lessons/lesson_1_2.dart';
import '../lessons/lesson_1_3.dart';
import '../lessons/lesson_2_1.dart';
import '../lessons/lesson_2_2.dart';
import '../lessons/lesson_2_3.dart';
import '../lessons/lesson_3_1.dart';
import '../lessons/lesson_3_2.dart';
import '../lessons/lesson_3_3.dart';
import '../lessons/lesson_3_4.dart';
import '../lessons/lesson_3_5.dart';
import '../lessons/lesson_3_6.dart';
import '../lessons/lesson_3_7.dart';
import '../lessons/lesson_3_8.dart';
import '../lessons/lesson_3_9.dart';
import '../lessons/lesson_3_10.dart';
import '../lessons/lesson_s2_0_1.dart';
import '../lessons/lesson_s2_0_2.dart';
import '../lessons/lesson_s2_0_3.dart';
import '../lessons/lesson_s2_0_4.dart';
import '../lessons/lesson_s2_0_5.dart';
import '../lessons/lesson_s2_0_6.dart';
import '../lessons/lesson_s2_1_1.dart';
import '../lessons/lesson_s2_1_2.dart';
import '../lessons/lesson_s2_1_3.dart';
import '../lessons/lesson_s3_0_1.dart';
import '../lessons/lesson_s3_0_2.dart';
import '../assessments/assessment_2_1_screen.dart';
import '../assessments/assessment_2_2_screen.dart';
import '../assessments/assessment_2_3_screen.dart';
import '../assessments/assessment_s3_0_3_screen.dart';
import '../assessments/assessment_s3_0_4_screen.dart';
import '../lessons/lesson_s2_4_3.dart';
import '../lessons/lesson_s2_2_7.dart';
import '../lessons/lesson_s2_3_5.dart';
import '../lessons/lesson_s2_7_2_1.dart';
import '../lessons/lesson_s3_0_2_1.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final LessonService _lessonService = LessonService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildStageHierarchy(context),
    );
  }

  Widget _buildStageHierarchy(BuildContext context) {
    final stage1 = Stage1Data.getStage1();
    final stage2 = Stage2Data.getStage2();
    final stage3 = Stage3Data.getStage3();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Display Stage 1 with new hierarchy
        _buildStageCard(context, stage1),
        
        const SizedBox(height: 24),
        
        // Display Stage 2 with new hierarchy
        _buildStageCard(context, stage2),
        
                  const SizedBox(height: 24),
        
        // Display Stage 3 with new hierarchy
        _buildStageCard(context, stage3),
      ],
    );
  }

  Widget _buildStageCard(BuildContext context, Stage stage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Header
          Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Stage ${stage.stageNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ),
                const SizedBox(width: 16),
                Expanded(
            child: Text(
                    stage.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chapters within the stage
          ...stage.chapters.map((chapter) => _buildChapterInStage(context, chapter)),
        ],
      ),
    );
  }

  Widget _buildChapterInStage(BuildContext context, Chapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header (simpler than stage header)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${chapter.chapterNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter ${chapter.chapterNumber}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      Text(
                        chapter.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Lessons within the chapter
          ...chapter.lessons.map((lesson) => _buildLessonInChapter(context, lesson)),
        ],
      ),
    );
  }

  Widget _buildLessonInChapter(BuildContext context, lesson_model.Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: FutureBuilder<bool>(
          future: _checkLessonUnlock(lesson),
          builder: (context, snapshot) {
            final isUnlocked = snapshot.data ?? false;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
                        color: isUnlocked 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
              ),
              title: Text(
                lesson.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                '${lesson.description} | ${lesson.slides.length} slides',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              trailing: isUnlocked ? null : Icon(
                Icons.lock,
                color: Colors.grey[400],
                size: 16,
              ),
              onTap: isUnlocked ? () async {
                await _navigateToLesson(context, lesson);
              } : () {
                _showLockedLessonDialog(context);
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _checkLessonUnlock(lesson_model.Lesson lesson) async {
    try {
      return await _lessonService.isLessonUnlocked(lesson.id);
    } catch (e) {
      print('Error checking lesson unlock: $e');
      return false;
    }
  }

  Future<void> _navigateToLesson(BuildContext context, lesson_model.Lesson lesson) async {
    final lessonScreen = _getLessonScreenByLessonId(lesson.id);
    
    if (lessonScreen != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => lessonScreen,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
      
      // Refresh the UI to show updated lock status after returning from lesson
      if (mounted) {
        setState(() {});
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLockedLessonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lesson Locked'),
          content: const Text(
            'This lesson is locked. Complete the previous lesson in this chapter to unlock it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Get lesson screen by lesson ID (supports all stages)
  Widget? _getLessonScreenByLessonId(String lessonId) {
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1': return const Lesson11Screen();
      case 'lesson_1_2': return const Lesson12Screen();
      case 'lesson_1_3': return const Lesson13Screen();
      case 'lesson_2_1': return const Assessment21Screen();
      case 'lesson_2_2': return const Assessment22Screen();
      case 'lesson_2_3': return const Assessment23Screen();
      case 'lesson_3_1': return const Lesson31Screen();
      case 'lesson_3_2': return const Lesson32Screen();
      case 'lesson_3_3': return const Lesson33Screen();
      case 'lesson_3_4': return const Lesson34Screen();
      case 'lesson_3_5': return const Lesson35Screen();
      case 'lesson_3_6': return const Lesson36Screen();
      case 'lesson_3_7': return const Lesson37Screen();
      case 'lesson_3_8': return const Lesson38Screen();
      case 'lesson_3_9': return const Lesson39Screen();
      case 'lesson_3_10': return const Lesson310Screen();
      
      // Stage 2 lessons
      case 'lesson_s2_0_1': return const LessonS201Screen();
      case 'lesson_s2_0_2': return const LessonS202Screen();
      case 'lesson_s2_0_3': return const LessonS203Screen();
      case 'lesson_s2_0_4': return const LessonS204Screen();
      case 'lesson_s2_0_5': return const LessonS205Screen();
      case 'lesson_s2_0_6': return const LessonS206Screen();
      case 'lesson_s2_1_1': return const LessonS211Screen();
      case 'lesson_s2_1_2': return const LessonS212Screen();
      case 'lesson_s2_1_3': return const LessonS213Screen();
      case 'lesson_s2_2_7': return const LessonS227Screen();
      case 'lesson_s2_3_5': return const LessonS235Screen();
      case 'lesson_s2_4_3': return const LessonS243Screen();
      case 'lesson_s2_7_2_1': return const LessonS2721Screen();
      
      // Stage 3 lessons
      case 'lesson_s3_0_1': return const LessonS301Screen();
      case 'lesson_s3_0_2': return const LessonS302Screen();
      case 'lesson_s3_0_2_1': return const LessonS3021Screen();
      case 'lesson_s3_0_3': return const AssessmentS303Screen();
      case 'lesson_s3_0_4': return const AssessmentS304Screen();
    }
    
    return null;
  }
}