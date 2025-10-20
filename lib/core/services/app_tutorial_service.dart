import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum TutorialStep {
  educationTab,
  firstLesson,
  exercisesTab,
  journalTab,
  weightDiary,
  plantGrowth,
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

  // Show tutorial for exercises tab
  void showExercisesTabTutorial({
    required BuildContext context,
    required GlobalKey exercisesTabKey,
    required VoidCallback onFinish,
    required VoidCallback onTabClick,
  }) {
    _currentStep = TutorialStep.exercisesTab;
    
    final targets = [
      TargetFocus(
        identify: "exercises_tab",
        keyTarget: exercisesTabKey,
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
                      "You've completed your first lesson! Now let's explore the Exercises tab where you'll find practical exercises to support your recovery journey.",
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
                        "Explore Exercises!",
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
        // Allow clicking on the highlighted exercises tab
        if (target.identify == "exercises_tab") {
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

  // Show tutorial for weight diary
  void showWeightDiaryTutorial({
    required BuildContext context,
    required GlobalKey weightDiaryKey,
    required VoidCallback onFinish,
    required VoidCallback onWeightDiaryClick,
  }) {
    _currentStep = TutorialStep.weightDiary;
    
    final targets = [
      TargetFocus(
        identify: "weight_diary",
        keyTarget: weightDiaryKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 40,
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
                      "Track Your Weight 📊",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "This is your Weight Diary! Tap here to log your current weight. Tracking your weight helps you monitor your progress over time.",
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
                        "Log Weight!",
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
        // Allow clicking on the highlighted weight diary
        if (target.identify == "weight_diary") {
          // Navigate and finish immediately - the tutorial will handle the transition
          onWeightDiaryClick();
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

  // Show tutorial for plant growth
  void showPlantGrowthTutorial({
    required BuildContext context,
    required GlobalKey plantKey,
    required VoidCallback onFinish,
    required VoidCallback onNext,
  }) {
    _currentStep = TutorialStep.plantGrowth;
    
    final targets = [
      TargetFocus(
        identify: "plant_growth",
        keyTarget: plantKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 40,
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
                      "Your Growth Journey 🌱",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "This is your personal plant that grows as you progress! Swipe left to see your binge-free timer, or keep building habits to help your plant grow.",
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
                        onNext();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF66BB6A),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        "Next",
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


  // Dispose tutorial
  void dispose() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
    _currentStep = null;
  }

  TutorialStep? get currentStep => _currentStep;
}

