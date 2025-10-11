import 'package:flutter/material.dart';
import 'dart:math' as math;
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
import '../assessments/quiz_chapter_1_screen.dart';
import '../assessments/quiz_chapter_3_screen.dart';
import '../assessments/quiz_chapter_0_screen.dart';
import '../assessments/quiz_chapter_1_stage_2_screen.dart';
import '../assessments/quiz_chapter_2_stage_2_screen.dart';
import '../assessments/quiz_chapter_3_stage_2_screen.dart';
import '../assessments/quiz_chapter_4_stage_2_screen.dart';
import '../assessments/quiz_chapter_5_stage_2_screen.dart';
import '../assessments/quiz_chapter_6_stage_2_screen.dart';
import '../assessments/quiz_chapter_7_stage_2_screen.dart';
import '../../core/services/user_learning_service.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
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
      case 'quiz_1_chapter_1':
        return const QuizChapter1Screen();
      case 'quiz_3_chapter_3':
        return const QuizChapter3Screen();
      case 'quiz_0_chapter_0':
        return const QuizChapter0Screen();
      case 'quiz_1_stage_2':
        return const QuizChapter1Stage2Screen();
      case 'quiz_2_stage_2':
        return const QuizChapter2Stage2Screen();
      case 'quiz_3_stage_2':
        return const QuizChapter3Stage2Screen();
      case 'quiz_4_stage_2':
        return const QuizChapter4Stage2Screen();
      case 'quiz_5_stage_2':
        return const QuizChapter5Stage2Screen();
      case 'quiz_6_stage_2':
        return const QuizChapter6Stage2Screen();
      case 'quiz_7_stage_2':
        return const QuizChapter7Stage2Screen();
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
    if (_stages.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF66BB6A).withOpacity(0.1),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                title: const Text(
                  'Learning Path',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                centerTitle: true,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildStorylinePath(),
                  ),
                ),
              ),
              // Add some bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Build the storyline path with all stages, chapters, and lessons
  List<Widget> _buildStorylinePath() {
    List<Widget> widgets = [];
    int lessonIndex = 0;

    for (var stage in _stages) {
      // Add stage header
      widgets.add(_buildStageHeader(stage));
      widgets.add(const SizedBox(height: 30));

      for (var chapter in stage.chapters) {
        // Add chapter header
        widgets.add(_buildChapterHeader(chapter, stage));
        widgets.add(const SizedBox(height: 20));

        // Add lessons in the chapter
        for (var i = 0; i < chapter.lessons.length; i++) {
          var lesson = chapter.lessons[i];
          bool isLeft = lessonIndex % 2 == 0;
          
          widgets.add(_buildLessonNode(lesson, isLeft, lessonIndex));
          
          // Add connecting line if not the last lesson in this chapter
          if (i < chapter.lessons.length - 1) {
            widgets.add(_buildConnectingLine());
          }
          
          lessonIndex++;
        }

        // Add spacing between chapters
        widgets.add(const SizedBox(height: 40));
      }

      // Add spacing between stages
      widgets.add(const SizedBox(height: 20));
    }

    return widgets;
  }

  // Build stage header
  Widget _buildStageHeader(Stage stage) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStageColor(stage.stageNumber),
            _getStageColor(stage.stageNumber).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStageColor(stage.stageNumber).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStageIcon(stage.stageNumber),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stage ${stage.stageNumber}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build chapter header
  Widget _buildChapterHeader(Chapter chapter, Stage stage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _getStageColor(stage.stageNumber).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStageColor(stage.stageNumber).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getStageColor(stage.stageNumber).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_stories,
              color: _getStageColor(stage.stageNumber),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chapter ${chapter.chapterNumber}',
                  style: TextStyle(
                    color: _getStageColor(stage.stageNumber).withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  chapter.title,
                  style: TextStyle(
                    color: _getStageColor(stage.stageNumber),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build lesson node (circle)
  Widget _buildLessonNode(Lesson lesson, bool isLeft, int index) {
    bool isCompleted = lesson.isCompleted;
    bool isLocked = false; // You can implement lock logic based on your requirements
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (isLeft) ...[
            Expanded(
              child: _buildLessonInfo(lesson, isLeft),
            ),
            const SizedBox(width: 16),
            _buildLessonCircle(lesson, isCompleted, isLocked),
            const SizedBox(width: 16),
            const Expanded(child: SizedBox()),
          ] else ...[
            const Expanded(child: SizedBox()),
            const SizedBox(width: 16),
            _buildLessonCircle(lesson, isCompleted, isLocked),
            const SizedBox(width: 16),
            Expanded(
              child: _buildLessonInfo(lesson, isLeft),
            ),
          ],
        ],
      ),
    );
  }

  // Build lesson circle button
  Widget _buildLessonCircle(Lesson lesson, bool isCompleted, bool isLocked) {
    Color circleColor = isCompleted 
        ? const Color(0xFF4CAF50)
        : isLocked 
            ? Colors.grey.shade400
            : const Color(0xFF66BB6A);

    return GestureDetector(
      onTap: isLocked ? null : () => _navigateToLesson(lesson),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: circleColor,
          boxShadow: [
            BoxShadow(
              color: circleColor.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Icon(
          isCompleted 
              ? Icons.check_circle
              : isLocked
                  ? Icons.lock
                  : Icons.play_arrow,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }

  // Build lesson info card
  Widget _buildLessonInfo(Lesson lesson, bool isLeft) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: isLeft ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
            textAlign: isLeft ? TextAlign.right : TextAlign.left,
          ),
          if (lesson.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              lesson.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: isLeft ? TextAlign.right : TextAlign.left,
            ),
          ],
        ],
      ),
    );
  }

  // Build connecting line between lessons
  Widget _buildConnectingLine() {
    return Center(
      child: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF66BB6A).withOpacity(0.5),
              const Color(0xFF66BB6A).withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  // Get stage color
  Color _getStageColor(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return const Color(0xFF66BB6A); // Green
      case 2:
        return const Color(0xFF42A5F5); // Blue
      case 3:
        return const Color(0xFFAB47BC); // Purple
      default:
        return const Color(0xFF66BB6A);
    }
  }

  // Get stage icon
  IconData _getStageIcon(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return Icons.flag;
      case 2:
        return Icons.trending_up;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.flag;
    }
  }
}
