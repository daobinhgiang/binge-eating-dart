import 'package:flutter/material.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
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
import '../lessons/lesson_s2_2_6.dart';
import '../lessons/lesson_s2_2_7.dart';
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
import '../lessons/lesson_s2_7_2_1.dart';
import '../lessons/lesson_s2_7_3.dart';
import '../lessons/lesson_s2_7_4.dart';
import '../lessons/lesson_s2_7_5.dart';
import '../lessons/lesson_s2_7_6.dart';
import '../lessons/lesson_s2_7_7.dart';
import '../lessons/lesson_s2_7_8.dart';
import '../lessons/lesson_s3_0_1.dart';
import '../lessons/lesson_s3_0_2.dart';
import '../lessons/lesson_s3_0_2_1.dart';
import '../assessments/assessment_2_1_screen.dart';
import '../assessments/assessment_2_2_screen.dart';
import '../assessments/assessment_2_3_screen.dart';
import '../assessments/assessment_s3_0_3_screen.dart';
import '../assessments/assessment_s3_0_4_screen.dart';
import '../../core/services/user_learning_service.dart';

class LessonsScreen extends StatefulWidget {
  final int? stageNumber;
  final int? chapterNumber;

  const LessonsScreen({
    super.key,
    this.stageNumber,
    this.chapterNumber,
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  Stage? _currentStage;
  Chapter? _currentChapter;
  List<Stage> _stages = [];

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

  void _loadStages() {
    setState(() {
      _stages = [
        Stage1Data.getStage1(),
        Stage2Data.getStage2(),
        Stage3Data.getStage3(),
      ];
      
      if (widget.stageNumber != null) {
        _currentStage = _stages.firstWhere(
          (stage) => stage.stageNumber == widget.stageNumber,
          orElse: () => _stages.first,
        );
        
        if (widget.chapterNumber != null) {
          _currentChapter = _currentStage!.chapters.firstWhere(
            (chapter) => chapter.chapterNumber == widget.chapterNumber,
            orElse: () => _currentStage!.chapters.first,
          );
        }
      }
    });
  }

  void _navigateToLesson(Lesson lesson) {
    // Get the appropriate lesson screen widget based on lesson ID
    Widget? lessonScreen = _getLessonScreen(lesson.id);
    
    if (lessonScreen != null) {
      // Save last clicked lesson for user
      UserLearningService().saveLastLesson(lesson.id);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => lessonScreen,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
    } else {
      // Fallback to a generic lesson screen if specific route not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lesson ${lesson.title} not yet implemented')),
      );
    }
  }

  Widget? _getLessonScreen(String lessonId) {
    // Map lesson IDs to their corresponding screen widgets
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1':
        return const Lesson11Screen();
      case 'lesson_1_2':
        return const Lesson12Screen();
      case 'lesson_1_2_1':
        return const Lesson121Screen();
      case 'lesson_1_3':
        return const Lesson13Screen();
      case 'lesson_2_1':
        return const Assessment21Screen();
      case 'lesson_2_2':
        return const Assessment22Screen();
      case 'lesson_2_3':
        return const Assessment23Screen();
      case 'lesson_3_1':
        return const Lesson31Screen();
      case 'lesson_3_2':
        return const Lesson32Screen();
      case 'lesson_3_3':
        return const Lesson33Screen();
      case 'lesson_3_4':
        return const Lesson34Screen();
      case 'lesson_3_5':
        return const Lesson35Screen();
      case 'lesson_3_6':
        return const Lesson36Screen();
      case 'lesson_3_7':
        return const Lesson37Screen();
      case 'lesson_3_8':
        return const Lesson38Screen();
      case 'lesson_3_9':
        return const Lesson39Screen();
      case 'lesson_3_10':
        return const Lesson310Screen();
      
      // Stage 2 lessons
      case 'lesson_s2_0_1':
        return const LessonS201Screen();
      case 'lesson_s2_0_2':
        return const LessonS202Screen();
      case 'lesson_s2_0_3':
        return const LessonS203Screen();
      case 'lesson_s2_0_4':
        return const LessonS204Screen();
      case 'lesson_s2_0_5':
        return const LessonS205Screen();
      case 'lesson_s2_0_6':
        return const LessonS206Screen();
      case 'lesson_s2_1_1':
        return const LessonS211Screen();
      case 'lesson_s2_1_2':
        return const LessonS212Screen();
      case 'lesson_s2_1_3':
        return const LessonS213Screen();
      case 'lesson_s2_2_1':
        return const LessonS221Screen();
      case 'lesson_s2_2_2':
        return const LessonS222Screen();
      case 'lesson_s2_2_3':
        return const LessonS223Screen();
      case 'lesson_s2_2_4':
        return const LessonS224Screen();
      case 'lesson_s2_2_5':
        return const LessonS225Screen();
      case 'lesson_s2_2_5_1':
        return const LessonS2251Screen();
      case 'lesson_s2_2_6':
        return const LessonS226Screen();
      case 'lesson_s2_2_7':
        return const LessonS227Screen();
      case 'lesson_s2_3_1':
        return const LessonS231Screen();
      case 'lesson_s2_3_2':
        return const LessonS232Screen();
      case 'lesson_s2_3_2_1':
        return const LessonS2321Screen();
      case 'lesson_s2_3_3':
        return const LessonS233Screen();
      case 'lesson_s2_3_4':
        return const LessonS234Screen();
      case 'lesson_s2_3_5':
        return const LessonS235Screen();
      case 'lesson_s2_4_1':
        return const LessonS241Screen();
      case 'lesson_s2_4_2':
        return const LessonS242Screen();
      case 'lesson_s2_4_2_1':
        return const LessonS2421Screen();
      case 'lesson_s2_4_3':
        return const LessonS243Screen();
      case 'lesson_s2_5_1':
        return const LessonS251Screen();
      case 'lesson_s2_5_2':
        return const LessonS252Screen();
      case 'lesson_s2_6_1':
        return const LessonS261Screen();
      case 'lesson_s2_6_2':
        return const LessonS262Screen();
      case 'lesson_s2_6_3':
        return const LessonS263Screen();
      case 'lesson_s2_7_1':
        return const LessonS271Screen();
      case 'lesson_s2_7_1_1':
        return const LessonS2711Screen();
      case 'lesson_s2_7_2':
        return const LessonS272Screen();
      case 'lesson_s2_7_2_1':
        return const LessonS2721Screen();
      case 'lesson_s2_7_3':
        return const LessonS273Screen();
      case 'lesson_s2_7_4':
        return const LessonS274Screen();
      case 'lesson_s2_7_5':
        return const LessonS275Screen();
      case 'lesson_s2_7_6':
        return const LessonS276Screen();
      case 'lesson_s2_7_7':
        return const LessonS277Screen();
      case 'lesson_s2_7_8':
        return const LessonS278Screen();
      
      // Stage 3 lessons
      case 'lesson_s3_0_1':
        return const LessonS301Screen();
      case 'lesson_s3_0_2':
        return const LessonS302Screen();
      case 'lesson_s3_0_2_1':
        return const LessonS3021Screen();
      case 'lesson_s3_0_3':
        return const AssessmentS303Screen();
      case 'lesson_s3_0_4':
        return const AssessmentS304Screen();
      
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentStage == null) {
      // If no stage is provided, navigate back to EducationScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (_currentChapter == null) {
      return _buildChaptersView();
    } else {
      return _buildLessonsView();
    }
  }


  Widget _buildChaptersView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stage ${_currentStage!.stageNumber}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF66BB6A), // Brighter, more vibrant green
                    Color(0xFF4CAF50), // Material green
                    Color(0xFF43A047), // Slightly darker green
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stage ${_currentStage!.stageNumber} Chapters',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _currentStage!.chapters.map((chapter) => _buildChapterCard(context, chapter)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonsView() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chapter ${_currentChapter!.chapterNumber}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _currentChapter = null;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF66BB6A), // Brighter, more vibrant green
                    Color(0xFF4CAF50), // Material green
                    Color(0xFF43A047), // Slightly darker green
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: const Icon(
                            Icons.play_lesson,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter ${_currentChapter!.chapterNumber} Lessons',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _currentChapter!.lessons.map((lesson) => _buildLessonCard(context, lesson)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildChapterCard(BuildContext context, Chapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ] : [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    this.setState(() {
                      _currentChapter = chapter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.menu_book,
                                color: Color(0xFF4CAF50),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chapter ${chapter.chapterNumber}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF4CAF50).withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    chapter.title,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.play_arrow,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 2,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 0.0, // This would be updated with actual progress
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ] : [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _navigateToLesson(lesson),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_lesson,
                            color: Color(0xFF4CAF50),
                            size: 20,
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
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              if (lesson.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  lesson.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
