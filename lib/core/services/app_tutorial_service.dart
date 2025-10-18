import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum TutorialStep {
  educationTab,
  firstLesson,
  toolsTab,
  journalTab,
  completion,
}

class AppTutorialService {
  static final AppTutorialService _instance = AppTutorialService._internal();
  factory AppTutorialService() => _instance;
  AppTutorialService._internal();

  TutorialCoachMark? _tutorialCoachMark;
  TutorialStep? _currentStep;

  // Show tutorial for education tab
  void showEducationTabTutorial({
    required BuildContext context,
    required GlobalKey educationTabKey,
    required VoidCallback onFinish,
    required VoidCallback onTabClick,
  }) {
    _currentStep = TutorialStep.educationTab;
    
    final targets = [
      TargetFocus(
        identify: "education_tab",
        keyTarget: educationTabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome to Nurtra! 🎓",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Let's start your journey by learning about your treatment path. Tap the Lessons tab to begin your first lesson.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Got it!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: (target) {
        // Allow clicking on the highlighted education tab
        if (target.identify == "education_tab") {
          // Navigate and finish immediately - the tutorial will handle the transition
          onTabClick();
          _tutorialCoachMark?.finish();
          onFinish();
        }
      },
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _tutorialCoachMark?.show(context: context);
    });
  }

  // Show tutorial for first lesson
  void showFirstLessonTutorial({
    required BuildContext context,
    required GlobalKey firstLessonKey,
    required VoidCallback onFinish,
    required VoidCallback onLessonClick,
  }) {
    _currentStep = TutorialStep.firstLesson;
    
    final targets = [
      TargetFocus(
        identify: "first_lesson",
        keyTarget: firstLessonKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Your First Lesson 📚",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "This is your first lesson: \"Your Path to Change\". Tap on it to learn about your treatment journey and what to expect. It will take just a few minutes!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Start Learning!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: (target) {
        // Allow clicking on the highlighted first lesson
        if (target.identify == "first_lesson") {
          // Navigate and finish immediately - the tutorial will handle the transition
          onLessonClick();
          _tutorialCoachMark?.finish();
          onFinish();
        }
      },
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _tutorialCoachMark?.show(context: context);
    });
  }

  // Show tutorial for tools tab
  void showToolsTabTutorial({
    required BuildContext context,
    required GlobalKey toolsTabKey,
    required VoidCallback onFinish,
    required VoidCallback onTabClick,
  }) {
    _currentStep = TutorialStep.toolsTab;
    
    final targets = [
      TargetFocus(
        identify: "tools_tab",
        keyTarget: toolsTabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Great Job! 🎉",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "You've completed your first lesson! Now let's explore the Tools tab where you'll find practical exercises to support your recovery journey.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Explore Tools!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: (target) {
        // Allow clicking on the highlighted tools tab
        if (target.identify == "tools_tab") {
          // Navigate and finish immediately - the tutorial will handle the transition
          onTabClick();
          _tutorialCoachMark?.finish();
          onFinish();
        }
      },
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _tutorialCoachMark?.show(context: context);
    });
  }

  // Show tutorial for journal tab
  void showJournalTabTutorial({
    required BuildContext context,
    required GlobalKey journalTabKey,
    required VoidCallback onFinish,
    required VoidCallback onTabClick,
  }) {
    _currentStep = TutorialStep.journalTab;
    
    final targets = [
      TargetFocus(
        identify: "journal_tab",
        keyTarget: journalTabKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Excellent Progress! 🌟",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Now let's explore the Journal tab where you can track your daily progress, mood, and eating patterns. This is a key part of your recovery journey.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        controller.next();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Explore Journal!",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: (target) {
        // Allow clicking on the highlighted journal tab
        if (target.identify == "journal_tab") {
          // Navigate and finish immediately - the tutorial will handle the transition
          onTabClick();
          _tutorialCoachMark?.finish();
          onFinish();
        }
      },
      onFinish: onFinish,
      onSkip: () {
        onFinish();
        return true;
      },
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _tutorialCoachMark?.show(context: context);
    });
  }

  // Show completion tutorial (full screen celebration)
  void showCompletionTutorial({
    required BuildContext context,
    required GlobalKey completionKey,
    required VoidCallback onFinish,
  }) {
    _currentStep = TutorialStep.completion;
    
    // Show a full-screen overlay with completion message
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.8), // Full-screen black overlay
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Scale elements based on screen height
                  final screenHeight = constraints.maxHeight;
                  final isSmallScreen = screenHeight < 600;
                  final isMediumScreen = screenHeight < 700;
                  
                  // Responsive sizing
                  final iconSize = isSmallScreen ? 100.0 : (isMediumScreen ? 120.0 : 140.0);
                  final iconInnerSize = isSmallScreen ? 50.0 : (isMediumScreen ? 60.0 : 70.0);
                  final titleFontSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 32.0);
                  final subtitleFontSize = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
                  final bodyFontSize = isSmallScreen ? 15.0 : (isMediumScreen ? 16.0 : 18.0);
                  final smallFontSize = isSmallScreen ? 14.0 : 16.0;
                  final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
                  
                  final verticalPadding = isSmallScreen ? 16.0 : (isMediumScreen ? 24.0 : 32.0);
                  final spacing1 = isSmallScreen ? 20.0 : (isMediumScreen ? 30.0 : 40.0);
                  final spacing2 = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 24.0);
                  final spacing3 = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
                  final spacing4 = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 32.0);
                  
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Celebration icon
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: const Color(0xFF66BB6A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF66BB6A).withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.celebration,
                              size: iconInnerSize,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: spacing1),
                          
                          // Main title
                          Text(
                            "🎉 Tutorial Complete! 🎉",
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing2),
                          
                          // Success message
                          Text(
                            "Congratulations!",
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing3),
                          
                          // Encouraging message
                          Text(
                            "You've completed the tutorial and learned about all the key features of Nurtra.",
                            style: TextStyle(
                              fontSize: bodyFontSize,
                              color: Colors.white,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: spacing3),
                          
                          // Simplified empowering message (no box to save space)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Now you're ready to start your recovery journey!",
                              style: TextStyle(
                                fontSize: smallFontSize,
                                color: Colors.white,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: spacing4),
                          
                          // Call to action button
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              onFinish();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF66BB6A),
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? 32 : 48,
                                vertical: isSmallScreen ? 12 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 8,
                            ),
                            child: Text(
                              "Start Your Journey",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: buttonFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Dispose tutorial
  void dispose() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
    _currentStep = null;
  }

  TutorialStep? get currentStep => _currentStep;
}

