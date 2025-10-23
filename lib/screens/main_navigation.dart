import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'education/lessons_screen.dart';
import 'exercises/exercises_screen.dart';
import 'journal/journal_screen.dart';
import 'journal/weight_diary_survey_screen.dart';
import 'profile/profile_screen.dart';
import '../core/services/app_tutorial_service.dart';
import '../providers/auth_provider.dart';
import '../providers/exp_provider.dart';
import '../models/user_model.dart';
import '../widgets/binge_free_timer_carousel_widget.dart';
import '../widgets/level_up_dialog.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  bool _hasShownEducationTutorial = false;
  bool _hasShownExercisesTutorial = false;
  bool _hasShownJournalTutorial = false;
  bool _hasShownWeightDiaryTutorial = false;
  bool _hasShownPlantGrowthTutorial = false;

  // Global keys for tutorial targets
  final GlobalKey _educationTabKey = GlobalKey();
  final GlobalKey _exercisesTabKey = GlobalKey();
  final GlobalKey _journalTabKey = GlobalKey();
  final GlobalKey _weightDiaryKey = GlobalKey();
  final GlobalKey _treeWidgetKey = GlobalKey();
  final GlobalKey<BingeFreeTimerCarouselWidgetState> _carouselKey = GlobalKey<BingeFreeTimerCarouselWidgetState>();

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Lessons',
      route: '/education',
    ),
    NavigationItem(
      icon: Icons.psychology_outlined,
      activeIcon: Icons.psychology_rounded,
      label: 'Exercises',
      route: '/exercises',
    ),
    NavigationItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories_rounded,
      label: 'Journal',
      route: '/journal',
    ),
    NavigationItem(
      icon: Icons.account_circle_outlined,
      activeIcon: Icons.account_circle_rounded,
      label: 'You',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Show tutorial after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }


  void _checkAndShowTutorial() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null || !mounted) return;

    // Show plant growth tutorial first (on home page, right after onboarding)
    if (!user.hasSeenPlantGrowthTutorial && !_hasShownPlantGrowthTutorial) {
      _showPlantGrowthTutorial();
    }
    // Show education tutorial if user has seen plant growth tutorial but not app tutorial
    else if (user.hasSeenPlantGrowthTutorial && !user.hasSeenAppTutorial && !_hasShownEducationTutorial) {
      _hasShownEducationTutorial = true;
      AppTutorialService().showEducationTabTutorial(
        context: context,
        educationTabKey: _educationTabKey,
        onFinish: () async {
          // Mark that user has seen the education tutorial
          // This allows the first lesson tutorial to show when they navigate to lessons
          await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
            hasSeenAppTutorial: true,
          );
        },
        onTabClick: () async {
          // Update the status BEFORE navigating to prevent tutorial from showing again
          await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
            hasSeenAppTutorial: true,
          );
          // Longer delay to ensure state update fully propagates to all listeners
          await Future.delayed(const Duration(milliseconds: 100));
          // Navigate to education tab when user clicks the highlighted tab
          if (mounted) {
            context.go('/education');
          }
        },
      );
    }
    // Show exercises tutorial if user has completed first lesson
    else if (user.hasCompletedFirstLesson && 
             user.hasSeenAppTutorial && 
             !user.hasSeenExercisesTutorial &&
             !_hasShownExercisesTutorial) {
      _showExercisesTutorial();
    }
    // Show journal tutorial if user has completed exercises tutorial
    else if (user.hasSeenExercisesTutorial && 
             !user.hasSeenJournalTutorial &&
             !_hasShownJournalTutorial) {
      _showJournalTutorial();
    }
    // Don't trigger weight diary tutorial here - it's handled in _showJournalTutorial's onTabClick callback
  }

  void _showExercisesTutorial() {
    if (_hasShownExercisesTutorial || !mounted) return;
    
    _hasShownExercisesTutorial = true;
    
    AppTutorialService().showExercisesTabTutorial(
      context: context,
      exercisesTabKey: _exercisesTabKey,
      onFinish: () async {
        // Mark that user has seen the exercises tutorial
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenExercisesTutorial: true,
        );
      },
      onTabClick: () async {
        // Update the status BEFORE navigating to prevent tutorial from showing again
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenExercisesTutorial: true,
        );
        // Small delay to ensure state update propagates
        await Future.delayed(const Duration(milliseconds: 100));
        // Navigate to exercises tab when user clicks the highlighted tab
        if (mounted) {
          context.go('/exercises');
        }
      },
    );
  }

  void _showJournalTutorial() {
    if (_hasShownJournalTutorial || !mounted) return;
    
    _hasShownJournalTutorial = true;
    
    AppTutorialService().showJournalTabTutorial(
      context: context,
      journalTabKey: _journalTabKey,
      onFinish: () async {
        // Mark that user has seen the journal tutorial
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenJournalTutorial: true,
        );
      },
      onTabClick: () async {
        // Update the status BEFORE navigating to prevent tutorial from showing again
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenJournalTutorial: true,
        );
        // Small delay to ensure state update propagates
        await Future.delayed(const Duration(milliseconds: 100));
        // Navigate to journal tab when user clicks the highlighted tab
        if (mounted) {
          context.go('/journal');
        }
        
        // Show weight diary tutorial after navigation (only if not already seen)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          final currentUser = ref.read(authNotifierProvider).valueOrNull;
          if (currentUser != null && !currentUser.hasSeenWeightDiaryTutorial) {
            _showWeightDiaryTutorial();
          }
        }
      },
    );
  }
  
  void _showWeightDiaryTutorial() {
    if (_hasShownWeightDiaryTutorial || !mounted) return;
    
    _hasShownWeightDiaryTutorial = true;
    
    // Mark that user has seen the weight diary tutorial
    ref.read(authNotifierProvider.notifier).updateTutorialStatus(
      hasSeenWeightDiaryTutorial: true,
    );
    
    AppTutorialService().showWeightDiaryTutorial(
      context: context,
      weightDiaryKey: _weightDiaryKey,
      onFinish: () {
        // Tutorial dismissed or completed
      },
      onWeightDiaryClick: () {
        // User clicked on the weight diary - navigate to weight logging screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const WeightDiarySurveyScreen(),
          ),
        );
      },
    );
  }
  
  void _showPlantGrowthTutorial() {
    print('🌱 _showPlantGrowthTutorial called');
    print('🌱 _hasShownPlantGrowthTutorial: $_hasShownPlantGrowthTutorial');
    print('🌱 mounted: $mounted');
    
    if (_hasShownPlantGrowthTutorial || !mounted) {
      print('❌ Returning early: hasShownPlantGrowthTutorial=$_hasShownPlantGrowthTutorial, mounted=$mounted');
      return;
    }
    
    _hasShownPlantGrowthTutorial = true;
    print('✅ Setting _hasShownPlantGrowthTutorial = true');
    
    // Mark that user has seen the plant growth tutorial
    ref.read(authNotifierProvider.notifier).updateTutorialStatus(
      hasSeenPlantGrowthTutorial: true,
    );
    print('✅ Marked tutorial status in Firebase');
    
    // Use post-frame callback to ensure the widget with the key is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🌱 Post-frame callback executing');
      if (!mounted) {
        print('❌ Not mounted in post-frame callback');
        return;
      }
      
      print('🌱 Calling AppTutorialService.showPlantGrowthTutorial');
      AppTutorialService().showPlantGrowthTutorial(
        context: context,
        plantKey: _treeWidgetKey,
        carouselKey: _carouselKey,
        onFinish: () {
          // Tutorial dismissed
        },
        onNext: () {
          print('🎯 Tutorial onNext callback triggered!');
          // Trigger swipe to timer page after a short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            print('🎯 Delayed callback executing...');
            if (mounted) {
              print('🎯 Widget is mounted, accessing carousel state');
              // Access the carousel state directly through the typed GlobalKey
              final carouselState = _carouselKey.currentState;
              print('🎯 Carousel state is null: ${carouselState == null}');
              if (carouselState != null) {
                print('🎯 Calling navigateToPage on carousel state');
                carouselState.navigateToPage(1); // Page 1 is the timer
              } else {
                print('❌ Carousel state is null!');
              }
            } else {
              print('❌ Widget not mounted!');
            }
          });
          
          // Show timer button tutorial after swipe animation
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              print('🎉 Starting timer button tutorial!');
              _showTimerButtonTutorial();
            }
          });
        },
      );
    });
  }

  void _showTimerButtonTutorial() {
    print('⏱️ _showTimerButtonTutorial called');
    
    if (!mounted) {
      print('❌ Not mounted in timer tutorial');
      return;
    }
    
    // Get the timer button key from the carousel
    final carouselState = _carouselKey.currentState;
    if (carouselState == null) {
      print('❌ Carousel state is null for timer tutorial');
      return;
    }
    
    print('✅ Calling AppTutorialService.showTimerButtonTutorial');
    AppTutorialService().showTimerButtonTutorial(
      context: context,
      timerButtonKey: carouselState.timerButtonKey,
      onFinish: () async {
        print('✅ Timer button tutorial completed');
        // After timer tutorial completes, trigger the education tab tutorial
        // This connects the home tutorials to the rest of the tutorial flow
        final user = ref.read(authNotifierProvider).value;
        if (user != null && !user.hasSeenAppTutorial && !_hasShownEducationTutorial) {
          // Small delay to ensure smooth transition
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _hasShownEducationTutorial = true;
            AppTutorialService().showEducationTabTutorial(
              context: context,
              educationTabKey: _educationTabKey,
              onFinish: () async {
                await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
                  hasSeenAppTutorial: true,
                );
              },
              onTabClick: () async {
                await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
                  hasSeenAppTutorial: true,
                );
                await Future.delayed(const Duration(milliseconds: 100));
                if (mounted) {
                  context.go('/education');
                }
              },
            );
          }
        }
      },
      onButtonClick: () {
        print('✅ User clicked timer button during tutorial');
        // Actually trigger the timer button programmatically
        final carouselState = _carouselKey.currentState;
        if (carouselState != null) {
          print('🎯 Triggering timer button programmatically');
          // Call the public method to start/reset the timer
          carouselState.triggerTimerButton();
        }
      },
    );
  }

  void _updateCurrentIndex(String location) {
    switch (location) {
      case '/':
      case '/home':
        _currentIndex = 0;
        break;
      case '/education':
        _currentIndex = 1;
        break;
      case '/exercises':
        _currentIndex = 2;
        break;
      case '/journal':
        _currentIndex = 3;
        break;
      case '/profile':
        _currentIndex = 4;
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes and check for tutorial
    // This ensures the exercises tutorial shows immediately after completing the first lesson
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          // Check if we should show exercises tutorial
          if (user.hasCompletedFirstLesson && 
              user.hasSeenAppTutorial && 
              !user.hasSeenExercisesTutorial &&
              !_hasShownExercisesTutorial) {
            // Small delay to ensure the navigation animation completes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showExercisesTutorial();
              }
            });
          }
          // Check if we should show journal tutorial
          else if (user.hasSeenExercisesTutorial && 
                   !user.hasSeenJournalTutorial &&
                   !_hasShownJournalTutorial) {
            // Small delay to ensure the navigation animation completes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showJournalTutorial();
              }
            });
          }
        }
      });
    });

    // GLOBAL LEVEL UP LISTENER - Works everywhere in the app
    // Listen for level changes and show level up celebration
    ref.listen(userExpProvider, (previous, next) {
      if (previous != null && next != null && next.level > previous.level) {
        print('🎉 [MainNavigation] Level up detected: ${previous.level} → ${next.level}');
        
        // Show level up celebration dialog in next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LevelUpDialog(
                oldLevel: previous.level,
                newLevel: next.level,
                expEarned: next.exp - previous.exp,
                totalExp: next.exp,
                shouldNavigateToHome: false, // Don't navigate, stay on current screen
              ),
            );
          }
        });
      }
    });
    
    // Get current location and update index
    final location = GoRouterState.of(context).uri.path;
    _updateCurrentIndex(location);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            treeWidgetKey: _treeWidgetKey,
            carouselKey: _carouselKey,
          ),
          const LessonsScreen(),
          const ExercisesScreen(),
          JournalScreen(weightDiaryKey: _weightDiaryKey),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                // Add keys to education, exercises, and journal tabs for tutorial
                GlobalKey? tabKey;
                if (index == 1) { // Education tab
                  tabKey = _educationTabKey;
                } else if (index == 2) { // Exercises tab
                  tabKey = _exercisesTabKey;
                } else if (index == 3) { // Journal tab
                  tabKey = _journalTabKey;
                }
                
                return Expanded(
                  child: tabKey != null
                      ? _NavigationButton(
                          key: tabKey,
                          item: item,
                          isSelected: isSelected,
                          onTap: () {
                            context.go(item.route);
                          },
                        )
                      : _NavigationButton(
                          item: item,
                          isSelected: isSelected,
                          onTap: () {
                            context.go(item.route);
                          },
                        ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationButton({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        // Trigger medium strength haptic feedback on iOS
        HapticFeedback.mediumImpact();
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.70 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected ? widget.item.activeIcon : widget.item.icon,
                color: widget.isSelected 
                    ? const Color(0xFF4CAF50)
                    : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                widget.item.label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: widget.isSelected 
                      ? const Color(0xFF4CAF50)
                      : Colors.grey[600],
                  fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}


