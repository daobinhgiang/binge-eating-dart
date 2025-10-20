import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../../models/stage.dart';
import '../../models/chapter.dart';
import '../../models/lesson.dart';
import '../../providers/lesson_progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/app_tutorial_service.dart';
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

class LessonsScreen extends ConsumerStatefulWidget {
  const LessonsScreen({super.key});

  @override
  ConsumerState<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends ConsumerState<LessonsScreen> {
  List<Stage> _stages = [];
  final ScrollController _scrollController = ScrollController();
  Stage? _currentStage;
  Chapter? _currentChapter;
  final Map<String, GlobalKey> _sectionKeys = {};
  final GlobalKey _firstLessonKey = GlobalKey();
  bool _hasShownTutorial = false;

  @override
  void initState() {
    super.initState();
    _loadStages();
    _scrollController.addListener(_onScroll);
    
    // Show tutorial after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  void _checkAndShowTutorial() async {
    if (!mounted || _hasShownTutorial) return;
    
    // Wait a bit longer to ensure state has propagated from main_navigation
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;
    
    final user = ref.read(authNotifierProvider).value;
    if (user == null) {
      print('❌ Tutorial check: User is null');
      return;
    }

    print('✅ Tutorial check: hasSeenAppTutorial=${user.hasSeenAppTutorial}, hasCompletedFirstLesson=${user.hasCompletedFirstLesson}');

    // Show first lesson tutorial ONLY if:
    // 1. User HAS seen the app tutorial (meaning they clicked on the education tab)
    // 2. User has NOT completed the first lesson yet
    if (user.hasSeenAppTutorial && !user.hasCompletedFirstLesson) {
      _hasShownTutorial = true;
      
      print('🎯 Showing first lesson tutorial...');
      
      // Wait a bit more for the layout to settle and stages to load
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (!mounted) return;
      
      print('🎓 Calling AppTutorialService.showFirstLessonTutorial()');
      
      AppTutorialService().showFirstLessonTutorial(
        context: context,
        firstLessonKey: _firstLessonKey,
        onFinish: () {
          print('✅ First lesson tutorial finished');
          // Tutorial completed - no need to update status here
          // The hasSeenAppTutorial is already true from the education tab tutorial
        },
        onLessonClick: () {
          print('👆 First lesson clicked from tutorial');
          // Navigate to the first lesson when user clicks the highlighted lesson card
          final firstLesson = _stages.isNotEmpty && 
                             _stages.first.chapters.isNotEmpty && 
                             _stages.first.chapters.first.lessons.isNotEmpty
              ? _stages.first.chapters.first.lessons.first
              : null;
          if (firstLesson != null) {
            _navigateToLesson(firstLesson);
          }
        },
      );
    } else {
      print('⏭️  Skipping tutorial: hasSeenAppTutorial=${user.hasSeenAppTutorial}, hasCompletedFirstLesson=${user.hasCompletedFirstLesson}');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Update the current stage and chapter based on scroll position
    _updateCurrentSection();
  }

  void _updateCurrentSection() {
    // Calculate the threshold position (Sticky header)
    const double headerHeight = 129.0; // Sticky header height (enlarged by 1.5x)
    
    for (var stage in _stages) {
      for (var chapter in stage.chapters) {
        final keyString = '${stage.stageNumber}_${chapter.chapterNumber}';
        if (!_sectionKeys.containsKey(keyString)) {
          continue;
        }
        final key = _sectionKeys[keyString];
        if (key?.currentContext != null) {
          final RenderBox? box = key!.currentContext!.findRenderObject() as RenderBox?;
          if (box != null) {
            final position = box.localToGlobal(Offset.zero);
            // Update header when the section divider line reaches the sticky header divider line
            // Position.dy represents the top of the section (where the divider line is)
            if (position.dy <= headerHeight && position.dy + box.size.height >= headerHeight - 50) {
              if (_currentStage != stage || _currentChapter != chapter) {
                setState(() {
                  _currentStage = stage;
                  _currentChapter = chapter;
                });
              }
              return;
            }
          }
        }
      }
    }
  }

  void _loadStages() {
    setState(() {
      _stages = [
        Stage1Data.getStage1(),
        Stage2Data.getStage2(),
        Stage3Data.getStage3(),
      ];
      // Initialize section keys for each chapter
      for (var stage in _stages) {
        for (var chapter in stage.chapters) {
          final keyString = '${stage.stageNumber}_${chapter.chapterNumber}';
          if (!_sectionKeys.containsKey(keyString)) {
            _sectionKeys[keyString] = GlobalKey();
          }
        }
      }
      // Set initial stage and chapter
      if (_stages.isNotEmpty && _stages[0].chapters.isNotEmpty) {
        _currentStage = _stages[0];
        _currentChapter = _stages[0].chapters[0];
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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sticky header showing current stage and chapter
              if (_currentStage != null && _currentChapter != null)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: _buildStickyHeader(_currentStage!, _currentChapter!),
                  ),
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
              const               SliverToBoxAdapter(
                child: SizedBox(height: 50),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // Build sticky header for current section with chapter tile only
  Widget _buildStickyHeader(Stage stage, Chapter chapter) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              color: _getStageColor(stage.stageNumber),
              borderRadius: BorderRadius.circular(18.0),
              boxShadow: [
                BoxShadow(
                  color: _getStageColor(stage.stageNumber).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'STAGE ${stage.stageNumber}, CHAPTER ${chapter.chapterNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        chapter.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.menu_book,
                  color: Colors.white.withOpacity(0.8),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
        // Divider line below sticky header (hidden)
        const SizedBox(height: 0),
      ],
      ),
    );
  }

  // Build the storyline path with all stages, chapters, and lessons
  List<Widget> _buildStorylinePath() {
    List<Widget> widgets = [];
    int lessonIndex = 0;

    for (var stage in _stages) {
      for (var i = 0; i < stage.chapters.length; i++) {
        final chapter = stage.chapters[i];
        // Wrap chapter section with a key for tracking
        final keyString = '${stage.stageNumber}_${chapter.chapterNumber}';
        
        // Ensure key exists before accessing
        if (!_sectionKeys.containsKey(keyString)) {
          _sectionKeys[keyString] = GlobalKey();
        }
        final sectionKey = _sectionKeys[keyString];
        
        widgets.add(
          Column(
            key: sectionKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add spacing before divider (except for first chapter)
              if (i > 0 || stage.stageNumber > 1)
                const SizedBox(height: 100),
              // Section divider line to mark the start of each section (hidden)
              const SizedBox(height: 100),
              // Add lessons in the chapter with Duolingo-style layout
              _buildChapterLessons(chapter, stage, lessonIndex),
            ],
          ),
        );
        
        lessonIndex += chapter.lessons.length;
      }

      // Add spacing between stages
      widgets.add(const SizedBox(height: 50));
    }

    return widgets;
  }


  // Build all lessons for a chapter in Duolingo-style winding path
  Widget _buildChapterLessons(Chapter chapter, Stage stage, int startIndex) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Consumer(
      builder: (context, ref, child) {
        final completedLessonsAsync = ref.watch(completedLessonsStreamProvider(user.uid));
        
        return completedLessonsAsync.when(
          data: (completedLessons) {
            return Column(
              children: List.generate(chapter.lessons.length, (index) {
                final lesson = chapter.lessons[index];
                final lessonNumber = startIndex + index + 1;
                final isCompleted = completedLessons.contains(lesson.id);
                final isLocked = false; // Implement lock logic as needed
                
                // Calculate position (0 = center, -1 = left, 1 = right)
                final position = _getLessonPosition(index);
                
                return Column(
                  children: [
                    _buildDuolingoLessonButton(
                      lesson: lesson,
                      lessonNumber: lessonNumber,
                      isCompleted: isCompleted,
                      isLocked: isLocked,
                      position: position,
                      stageColor: _getStageColor(stage.stageNumber),
                      // Attach the first lesson key for tutorial highlighting
                      lessonKey: lesson.id == 'lesson_1_1' ? _firstLessonKey : null,
                    ),
                    if (index < chapter.lessons.length - 1)
                      _buildConnectingPath(position, _getLessonPosition(index + 1)),
                  ],
                );
              }),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  // Get lesson position in the path (uses fractional values for ultra-smooth S-curve)
  // Returns position as fraction: -1.0 = most left, 0 = center, 1.0 = most right
  double _getLessonPosition(int index) {
    // Create an ultra-smooth S-curve pattern with gradual transitions
    // This creates a flowing wave that moves smoothly through multiple positions
    final pattern = [0.0, -0.75, -1.0, -0.75, 0.0, 0.75, 1.0, 0.75];
    return pattern[index % pattern.length];
  }

  // Build a single Duolingo-style lesson button with lesson number
  Widget _buildDuolingoLessonButton({
    required Lesson lesson,
    required int lessonNumber,
    required bool isCompleted,
    required bool isLocked,
    required double position,
    required Color stageColor,
    GlobalKey? lessonKey,
  }) {
    Color buttonColor = isCompleted 
        ? stageColor
        : isLocked 
            ? Colors.grey.shade400
            : Colors.grey.shade500; // Grey for uncompleted lessons

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final buttonRadius = 35.0; // Half of button width (70/2)
        
        // Calculate positions based on fractional position value
        // position = -1.0 (most left): 55 from left edge
        // position = 0.0 (center): width/2
        // position = 1.0 (most right): width - 55 from left edge
        
        final mostLeftPos = 55.0;
        final mostRightPos = screenWidth - 55.0;
        final centerPos = screenWidth / 2;
        
        // Calculate the actual X position by interpolating based on the position value
        double targetXPos;
        if (position < 0) {
          // Interpolate between most left and center
          targetXPos = centerPos + (position * (centerPos - mostLeftPos));
        } else {
          // Interpolate between center and most right
          targetXPos = centerPos + (position * (mostRightPos - centerPos));
        }
        
        // Calculate padding based on position
        double leftPadding = 0;
        double rightPadding = 0;
        Alignment alignment;
        
        if (position < -0.01) {
          // Left side
          leftPadding = targetXPos - buttonRadius;
          rightPadding = 0;
          alignment = Alignment.centerLeft;
        } else if (position > 0.01) {
          // Right side
          leftPadding = 0;
          rightPadding = screenWidth - targetXPos - buttonRadius;
          alignment = Alignment.centerRight;
        } else {
          // Center
          leftPadding = 0;
          rightPadding = 0;
          alignment = Alignment.center;
        }

    return Align(
      alignment: alignment,
      child: Padding(
        padding: EdgeInsets.only(
          left: leftPadding,
          right: rightPadding,
        ),
        child: GestureDetector(
          key: lessonKey,
          onTap: isLocked ? null : () => _navigateToLesson(lesson),
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: buttonColor,
              boxShadow: [
                BoxShadow(
                  color: buttonColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 32,
                    )
                  : isLocked
                      ? const Icon(
                          Icons.lock,
                          color: Colors.white,
                          size: 28,
                        )
                      : Text(
                          '$lessonNumber',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
            ),
          ),
        ),
      ),
    );
      },
    );
  }

  // Build connecting path between lessons
  Widget _buildConnectingPath(double fromPosition, double toPosition) {
    return CustomPaint(
      size: const Size(double.infinity, 50),
      painter: PathPainter(
        fromPosition: fromPosition,
        toPosition: toPosition,
        color: Colors.transparent, // Make lines invisible
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

// Delegate for sticky header
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 129.0; // Enlarged by 1.5x for larger padding and font sizes

  @override
  double get maxExtent => 129.0; // Enlarged by 1.5x for larger padding and font sizes

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

// Custom painter for drawing paths between lesson buttons
class PathPainter extends CustomPainter {
  final double fromPosition;
  final double toPosition;
  final Color color;

  PathPainter({
    required this.fromPosition,
    required this.toPosition,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Calculate positions using same interpolation logic as button positioning
    final mostLeftPos = 55.0;
    final mostRightPos = size.width - 55.0;
    final centerPos = size.width / 2;

    // Calculate start X position by interpolating based on fromPosition value
    double startX;
    if (fromPosition < 0) {
      // Interpolate between most left and center
      startX = centerPos + (fromPosition * (centerPos - mostLeftPos));
    } else {
      // Interpolate between center and most right
      startX = centerPos + (fromPosition * (mostRightPos - centerPos));
    }

    // Calculate end X position by interpolating based on toPosition value
    double endX;
    if (toPosition < 0) {
      // Interpolate between most left and center
      endX = centerPos + (toPosition * (centerPos - mostLeftPos));
    } else {
      // Interpolate between center and most right
      endX = centerPos + (toPosition * (mostRightPos - centerPos));
    }

    // Draw smooth S-curve path like Duolingo
    path.moveTo(startX, 0);
    
    // Create smooth bezier curve that flows naturally
    // Use dynamic control points based on the distance between start and end
    final midX = (startX + endX) / 2;
    final controlPoint1X = startX + (midX - startX) * 0.5;
    final controlPoint2X = endX - (endX - midX) * 0.5;
    
    path.cubicTo(
      controlPoint1X, size.height * 0.25,
      controlPoint2X, size.height * 0.75,
      endX, size.height,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
