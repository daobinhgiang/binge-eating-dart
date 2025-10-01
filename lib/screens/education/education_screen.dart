import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/education_background.dart';
import '../../core/services/lesson_service.dart';
import '../../models/lesson.dart' as lesson_model;
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../lessons/lesson_1_1.dart';
import '../lessons/lesson_1_2.dart';
import '../lessons/lesson_1_2_1.dart';
import '../lessons/lesson_1_3.dart';
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
import '../lessons/lesson_s2_2_1.dart';
import '../lessons/lesson_s2_2_2.dart';
import '../lessons/lesson_s2_2_3.dart';
import '../lessons/lesson_s2_2_4.dart';
import '../lessons/lesson_s2_2_5.dart';
import '../lessons/lesson_s2_2_5_1.dart';
import '../lessons/lesson_s3_0_1.dart';
import '../lessons/lesson_s3_0_2.dart';
import '../assessments/assessment_2_1_screen.dart';
import '../assessments/assessment_2_2_screen.dart';
import '../assessments/assessment_2_3_screen.dart';
import '../assessments/assessment_s3_0_3_screen.dart';
import '../assessments/assessment_s3_0_4_screen.dart';
import '../lessons/lesson_s2_3_1.dart';
import '../lessons/lesson_s2_3_2.dart';
import '../lessons/lesson_s2_3_2_1.dart';
import '../lessons/lesson_s2_3_3.dart';
import '../lessons/lesson_s2_3_4.dart';
import '../lessons/lesson_s2_3_5.dart';
import '../lessons/lesson_s2_4_1.dart';
import '../lessons/lesson_s2_4_2.dart';
import '../lessons/lesson_s2_4_2_1.dart';
import '../lessons/lesson_s2_4_3.dart';
import '../lessons/lesson_s2_5_1.dart';
import '../lessons/lesson_s2_5_2.dart';
import '../lessons/lesson_s2_6_1.dart';
import '../lessons/lesson_s2_6_2.dart';
import '../lessons/lesson_s2_6_3.dart';
import '../lessons/lesson_s2_7_1.dart';
import '../lessons/lesson_s2_7_1_1.dart';
import '../lessons/lesson_s2_7_2.dart';
import '../lessons/lesson_s2_7_3.dart';
import '../lessons/lesson_s2_7_4.dart';
import '../lessons/lesson_s2_7_5.dart';
import '../lessons/lesson_s2_7_6.dart';
import '../lessons/lesson_s2_7_7.dart';
import '../lessons/lesson_s2_7_8.dart';
import '../lessons/lesson_s2_2_7.dart';
import '../lessons/lesson_s3_0_2_1.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final LessonService _lessonService = LessonService();
  
  // State management for collapsible sections
  final Map<String, bool> _stageExpanded = {};
  final Map<String, bool> _chapterExpanded = {};

  bool _isStageExpanded(String stageId) {
    return _stageExpanded[stageId] ?? true; // Default to expanded
  }

  bool _isChapterExpanded(String chapterId) {
    return _chapterExpanded[chapterId] ?? true; // Default to expanded
  }

  void _toggleStage(String stageId) {
    setState(() {
      _stageExpanded[stageId] = !_isStageExpanded(stageId);
    });
  }

  void _toggleChapter(String chapterId) {
    setState(() {
      _chapterExpanded[chapterId] = !_isChapterExpanded(chapterId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EducationBackground(
        child: _buildStageHierarchy(context),
      ),
    );
  }

  Widget _buildStageHierarchy(BuildContext context) {
    final stage1 = Stage1Data.getStage1();
    final stage2 = Stage2Data.getStage2();
    final stage3 = Stage3Data.getStage3();
    
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Welcome section
        Container(
          margin: const EdgeInsets.only(bottom: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity( 0.05),
                Theme.of(context).colorScheme.secondary.withOpacity( 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your Learning Journey',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Complete lessons in order to unlock new content and track your progress.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.7),
                ),
              ),
            ],
          ),
        ),
        
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
    final stageId = 'stage_${stage.stageNumber}';
    final isExpanded = _isStageExpanded(stageId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _toggleStage(stageId),
              splashColor: Colors.white.withOpacity( 0.1),
              highlightColor: Colors.white.withOpacity( 0.05),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity( 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity( 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity( 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity( 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'STAGE',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white.withOpacity( 0.8),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${stage.stageNumber}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${stage.chapters.length} chapters • ${stage.chapters.fold(0, (sum, chapter) => sum + chapter.lessons.length)} lessons',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity( 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity( 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Animated collapse/expand for chapters
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isExpanded ? 1.0 : 0.0,
              child: isExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 20),
                        ...stage.chapters.map((chapter) => _buildChapterInStage(context, chapter)),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterInStage(BuildContext context, Chapter chapter) {
    final chapterId = 'chapter_${chapter.chapterNumber}';
    final isExpanded = _isChapterExpanded(chapterId);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _toggleChapter(chapterId),
              splashColor: Theme.of(context).colorScheme.primary.withOpacity( 0.1),
              highlightColor: Theme.of(context).colorScheme.primary.withOpacity( 0.05),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity( 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity( 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withOpacity( 0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'CHAPTER',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${chapter.chapterNumber}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chapter.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${chapter.lessons.length} lessons',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Animated collapse/expand for lessons
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isExpanded ? 1.0 : 0.0,
              child: isExpanded
                  ? Column(
                      children: [
                        const SizedBox(height: 16),
                        ...chapter.lessons.map((lesson) => _buildLessonInChapter(context, lesson)),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonInChapter(BuildContext context, lesson_model.Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: FutureBuilder<bool>(
        future: _checkLessonUnlock(lesson),
        builder: (context, snapshot) {
          final isUnlocked = snapshot.data ?? false;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;
          
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnlocked 
                    ? Theme.of(context).colorScheme.outline.withOpacity( 0.2)
                    : Theme.of(context).colorScheme.outline.withOpacity( 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity( 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: isUnlocked ? () async {
                  await _navigateToLesson(context, lesson);
                } : () {
                  _showLockedLessonDialog(context);
                },
                splashColor: isUnlocked 
                    ? Theme.of(context).colorScheme.primary.withOpacity( 0.1)
                    : Colors.grey.withOpacity( 0.1),
                highlightColor: isUnlocked 
                    ? Theme.of(context).colorScheme.primary.withOpacity( 0.05)
                    : Colors.grey.withOpacity( 0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isUnlocked 
                              ? Theme.of(context).colorScheme.primary.withOpacity( 0.1)
                              : Colors.grey.withOpacity( 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isUnlocked 
                                ? Theme.of(context).colorScheme.primary.withOpacity( 0.3)
                                : Colors.grey.withOpacity( 0.3),
                            width: 1,
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
                                color: isUnlocked 
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                                size: 24,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isUnlocked 
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lesson.description} • ${lesson.slides.length} slides',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isUnlocked 
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity( 0.7)
                                    : Colors.grey.withOpacity( 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isUnlocked)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity( 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.lock,
                            color: Colors.grey[400],
                            size: 16,
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity( 0.4),
                          size: 16,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
      case 'lesson_1_2_1': return const Lesson121Screen();
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
      case 'lesson_s2_2_1': return const LessonS221Screen();
      case 'lesson_s2_2_2': return const LessonS222Screen();
      case 'lesson_s2_2_3': return const LessonS223Screen();
      case 'lesson_s2_2_4': return const LessonS224Screen();
      case 'lesson_s2_2_5': return const LessonS225Screen();
      case 'lesson_s2_2_5_1': return const LessonS2251Screen();
      case 'lesson_s2_2_7': return const LessonS227Screen();
      
      // Chapter 3 lessons
      case 'lesson_s2_3_1': return const LessonS231Screen();
      case 'lesson_s2_3_2': return const LessonS232Screen();
      case 'lesson_s2_3_2_1': return const LessonS2321Screen();
      case 'lesson_s2_3_3': return const LessonS233Screen();
      case 'lesson_s2_3_4': return const LessonS234Screen();
      case 'lesson_s2_3_5': return const LessonS235Screen();
      
      // Chapter 4 lessons
      case 'lesson_s2_4_1': return const LessonS241Screen();
      case 'lesson_s2_4_2': return const LessonS242Screen();
      case 'lesson_s2_4_2_1': return const LessonS2421Screen();
      case 'lesson_s2_4_3': return const LessonS243Screen();
      
      // Chapter 5 lessons
      case 'lesson_s2_5_1': return const LessonS251Screen();
      case 'lesson_s2_5_2': return const LessonS252Screen();
      
      // Chapter 6 lessons
      case 'lesson_s2_6_1': return const LessonS261Screen();
      case 'lesson_s2_6_2': return const LessonS262Screen();
      case 'lesson_s2_6_3': return const LessonS263Screen();
      
      // Chapter 7 lessons
      case 'lesson_s2_7_1': return const LessonS271Screen();
      case 'lesson_s2_7_1_1': return const LessonS2711Screen();
      case 'lesson_s2_7_2': return const LessonS272Screen();
      case 'lesson_s2_7_3': return const LessonS273Screen();
      case 'lesson_s2_7_4': return const LessonS274Screen();
      case 'lesson_s2_7_5': return const LessonS275Screen();
      case 'lesson_s2_7_6': return const LessonS276Screen();
      case 'lesson_s2_7_7': return const LessonS277Screen();
      case 'lesson_s2_7_8': return const LessonS278Screen();
      
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