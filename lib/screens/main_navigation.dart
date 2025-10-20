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
import '../models/user_model.dart';

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
  bool _hasShownCompletionTutorial = false;

  // Global keys for tutorial targets
  final GlobalKey _educationTabKey = GlobalKey();
  final GlobalKey _exercisesTabKey = GlobalKey();
  final GlobalKey _journalTabKey = GlobalKey();
  final GlobalKey _weightDiaryKey = GlobalKey();
  final GlobalKey _treeWidgetKey = GlobalKey();
  final GlobalKey _completionKey = GlobalKey();

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

    // Show education tutorial if user hasn't seen app tutorial
    if (!user.hasSeenAppTutorial && !_hasShownEducationTutorial) {
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
    if (_hasShownPlantGrowthTutorial || !mounted) return;
    
    _hasShownPlantGrowthTutorial = true;
    
    // Mark that user has seen the plant growth tutorial
    ref.read(authNotifierProvider.notifier).updateTutorialStatus(
      hasSeenPlantGrowthTutorial: true,
    );
    
    // Use post-frame callback to ensure the widget with the key is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      AppTutorialService().showPlantGrowthTutorial(
        context: context,
        plantKey: _treeWidgetKey,
        onFinish: () {
          // Tutorial dismissed
        },
        onNext: () {
          // User clicked next - show completion tutorial
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showCompletionTutorial();
            }
          });
        },
      );
    });
  }

  void _showCompletionTutorial() {
    if (!mounted || _hasShownCompletionTutorial) return;
    
    _hasShownCompletionTutorial = true;
    
    AppTutorialService().showCompletionTutorial(
      context: context,
      completionKey: _completionKey, // Still pass the key but it won't be used for spotlight
      onFinish: () {
        print('🎉 Tutorial flow complete! User is ready to start their journey.');
        // Navigate back to home tab
        if (mounted) {
          context.go('/');
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
          // Plant growth tutorial is triggered separately when on home tab
        }
      });
    });
    
    // Get current location and update index
    final location = GoRouterState.of(context).uri.path;
    _updateCurrentIndex(location);
    
    // Check if we should show plant growth tutorial (when on home tab)
    final user = ref.watch(authNotifierProvider).valueOrNull;
    if (user != null &&
        user.hasSeenJournalTutorial &&
        user.hasLoggedWeightDuringTutorial &&
        !user.hasSeenPlantGrowthTutorial &&
        !_hasShownPlantGrowthTutorial &&
        _currentIndex == 0) {
      // Trigger tutorial after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentIndex == 0) {
            _showPlantGrowthTutorial();
          }
        });
      });
    }
    
    return Scaffold(
      key: _completionKey,
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(treeWidgetKey: _treeWidgetKey),
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
      child: AnimatedScale(
        scale: _isPressed ? 0.70 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
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


