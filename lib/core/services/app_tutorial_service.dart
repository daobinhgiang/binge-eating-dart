import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

enum TutorialStep {
  educationTab,
  firstLesson,
  exercisesTab,
  journalTab,
  weightDiary,
  streakExplanation,
  plantGrowth,
  timerButton,
}

class AppTutorialService {
  static final AppTutorialService _instance = AppTutorialService._internal();
  factory AppTutorialService() => _instance;
  AppTutorialService._internal();

  TutorialCoachMark? _tutorialCoachMark;
  TutorialStep? _currentStep;
  bool _hasShownStreakPopupDuringTutorial = false;

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
                      "Tap here to begin your first lesson!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
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
                      "Tap here learn about your treatment journey and what to expect.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
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
                      "Here are the exercises to support your recovery journey.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
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
                      "Here is the Journal tab where you can track your eating patterns, weight, spendings, and more. This is key to your recovery journey!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
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
                      "Weight Diary 📊",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tap here to log your current weight. This helps you monitor your progress over time!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
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

  // Show tutorial for streak system (highlights the streak animation popup)
  // This tutorial is triggered AFTER the streak animation popup appears and completes its animation.
  // The popup should be shown with isTutorialMode: true to prevent auto-dismissal.
  // This tutorial overlays the streak popup and explains the streak system to the user.
  void showStreakTutorial({
    required BuildContext context,
    required GlobalKey streakPopupKey,
    required VoidCallback onFinish,
    required VoidCallback onReady,
  }) {
    print('🎓 [AppTutorial] showStreakTutorial called');
    print('   🔑 Streak popup key provided: $streakPopupKey');
    
    _currentStep = TutorialStep.streakExplanation;
    print('   ✅ Current step set to: $_currentStep');
    
    final targets = [
      TargetFocus(
        identify: "streak_popup",
        keyTarget: streakPopupKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              print('   🎨 Building streak tutorial overlay content');
              return Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Streak System! 🔥",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "When you complete all of your daily quests/seeds for the day, you extend your streak! Keep it going every day to improve your health and your life!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // "I'm ready!" button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          print('   🖱️  User clicked "I\'m ready!" button');
                          print('   🚪 Closing streak animation popup');
                          // Close the streak popup first
                          Navigator.of(context).pop(); // Close the streak animation popup
                          print('   ✅ Streak popup closed');
                          
                          print('   🏁 Finishing tutorial coach mark');
                          _tutorialCoachMark?.finish();
                          print('   ✅ Tutorial coach mark finished');
                          
                          print('   📞 Calling onReady callback');
                          onReady();
                          print('   ✅ onReady callback completed');
                          
                          print('   📞 Calling onFinish callback');
                          onFinish();
                          print('   ✅ onFinish callback completed');
                          print('   ✅ Streak tutorial fully completed!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'I\'m ready!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
    print('   ✅ Tutorial targets created (1 target: streak_popup)');

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      hideSkip: true,
      onFinish: () {
        print('   ℹ️  Tutorial coach mark onFinish called (handled by button press)');
        // Do nothing here - handled by button press
      },
      onSkip: () {
        print('   ⚠️  Tutorial skip attempted - prevented');
        return false; // Prevent skipping
      },
    );
    print('   ✅ Tutorial coach mark created');

    // Small delay to ensure the streak popup is fully rendered
    print('   ⏰ Scheduling tutorial overlay display in 1500ms');
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        print('   🎭 Context mounted, showing tutorial coach mark');
        _tutorialCoachMark?.show(context: context);
        print('   ✅ Tutorial overlay displayed!');
      } else {
        print('   ❌ Context not mounted - skipping tutorial overlay');
      }
    });
  }

  // Show tutorial for plant growth
  void showPlantGrowthTutorial({
    required BuildContext context,
    required GlobalKey plantKey,
    required GlobalKey carouselKey,
    required VoidCallback onFinish,
    required VoidCallback onNext,
  }) {
    _currentStep = TutorialStep.plantGrowth;
    
    final targets = [
      TargetFocus(
        identify: "plant_growth",
        keyTarget: plantKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.Circle,
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
                      "This seed will grow as you make progress, every time you complete a lesson, activity, and journal entry!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
      onClickTarget: (target) {
        // Allow clicking on the highlighted plant/tree graphic
        if (target.identify == "plant_growth") {
          print('🌱 Plant graphic clicked in tutorial');
          onNext();
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

  // Show tutorial for streak explanation
  void showStreakExplanationTutorial({
    required BuildContext context,
    required VoidCallback onFinish,
  }) {
    _currentStep = TutorialStep.streakExplanation;
    
    // Show full-screen overlay with streak explanation
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Streak icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 40,
                  color: Color(0xFFFF6B6B),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              const Text(
                'Great Job! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Explanation
              const Text(
                'When you complete all of your daily quests/seeds for the day, you extend your streak! Keep it going every day!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // OK button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onFinish();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show tutorial for timer button
  void showTimerButtonTutorial({
    required BuildContext context,
    required GlobalKey timerButtonKey,
    required VoidCallback onFinish,
    required VoidCallback onButtonClick,
  }) {
    _currentStep = TutorialStep.timerButton;
    
    final targets = [
      TargetFocus(
        identify: "timer_button",
        keyTarget: timerButtonKey,
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
                      "Track Your Progress ⏱️",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 24.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Tap 'Start Timer' to track how long you've been binge-free. You can reset it anytime if needed!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                      textAlign: TextAlign.center,
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
      hideSkip: true,
      onClickTarget: (target) {
        // Allow clicking on the highlighted timer button
        if (target.identify == "timer_button") {
          onButtonClick();
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

  // Dispose tutorial
  void dispose() {
    _tutorialCoachMark?.finish();
    _tutorialCoachMark = null;
    _currentStep = null;
  }

  TutorialStep? get currentStep {
    print('🎓 [AppTutorial] currentStep getter called: $_currentStep');
    return _currentStep;
  }
  
  // Check if currently in tutorial flow
  bool get isInTutorialFlow {
    final inFlow = _currentStep != null;
    print('🎓 [AppTutorial] isInTutorialFlow getter called: $inFlow (step: $_currentStep)');
    return inFlow;
  }
  
  // Mark that streak popup was shown during tutorial
  void markStreakPopupShownDuringTutorial() {
    print('🎓 [AppTutorial] markStreakPopupShownDuringTutorial called');
    print('   📝 Previous value: $_hasShownStreakPopupDuringTutorial');
    _hasShownStreakPopupDuringTutorial = true;
    print('   ✅ New value: $_hasShownStreakPopupDuringTutorial');
    print('   ✅ Streak popup shown during tutorial flag is now SET');
  }
  
  // Check if streak popup was shown during tutorial
  bool get hasShownStreakPopupDuringTutorial {
    print('🎓 [AppTutorial] hasShownStreakPopupDuringTutorial getter called: $_hasShownStreakPopupDuringTutorial');
    return _hasShownStreakPopupDuringTutorial;
  }
  
  // Reset streak popup tracking (for testing or restart)
  void resetStreakPopupTracking() {
    print('🎓 [AppTutorial] resetStreakPopupTracking called');
    print('   📝 Previous value: $_hasShownStreakPopupDuringTutorial');
    _hasShownStreakPopupDuringTutorial = false;
    print('   ✅ Streak popup tracking has been RESET');
  }
}

