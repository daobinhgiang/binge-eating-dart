import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'education/lessons_screen.dart';
import 'tools/tools_screen.dart';
import 'journal/journal_screen.dart';
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
  bool _hasShownToolsTutorial = false;
  bool _hasShownJournalTutorial = false;

  // Global keys for tutorial targets
  final GlobalKey _educationTabKey = GlobalKey();
  final GlobalKey _toolsTabKey = GlobalKey();
  final GlobalKey _journalTabKey = GlobalKey();
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
      label: 'Tools',
      route: '/tools',
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
    // Show tools tutorial if user has completed first lesson
    else if (user.hasCompletedFirstLesson && 
             user.hasSeenAppTutorial && 
             !user.hasSeenToolsTutorial &&
             !_hasShownToolsTutorial) {
      _showToolsTutorial();
    }
    // Show journal tutorial if user has completed tools tutorial
    else if (user.hasSeenToolsTutorial && 
             !user.hasSeenJournalTutorial &&
             !_hasShownJournalTutorial) {
      _showJournalTutorial();
    }
  }

  void _showToolsTutorial() {
    if (_hasShownToolsTutorial || !mounted) return;
    
    _hasShownToolsTutorial = true;
    
    AppTutorialService().showToolsTabTutorial(
      context: context,
      toolsTabKey: _toolsTabKey,
      onFinish: () async {
        // Mark that user has seen the tools tutorial
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenToolsTutorial: true,
        );
      },
      onTabClick: () async {
        // Update the status BEFORE navigating to prevent tutorial from showing again
        await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
          hasSeenToolsTutorial: true,
        );
        // Small delay to ensure state update propagates
        await Future.delayed(const Duration(milliseconds: 100));
        // Navigate to tools tab when user clicks the highlighted tab
        if (mounted) {
          context.go('/tools');
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
        
        // Show completion tutorial after a short delay
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 1500));
          if (mounted) {
            _showCompletionTutorial();
          }
        }
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
        
        // Show completion tutorial after navigation
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          _showCompletionTutorial();
        }
      },
    );
  }

  void _showCompletionTutorial() {
    if (!mounted) return;
    
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
      case '/tools':
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
    // This ensures the tools tutorial shows immediately after completing the first lesson
    ref.listen<AsyncValue<UserModel?>>(authNotifierProvider, (previous, next) {
      next.whenData((user) {
        if (user != null && mounted) {
          // Check if we should show tools tutorial
          if (user.hasCompletedFirstLesson && 
              user.hasSeenAppTutorial && 
              !user.hasSeenToolsTutorial &&
              !_hasShownToolsTutorial) {
            // Small delay to ensure the navigation animation completes
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _showToolsTutorial();
              }
            });
          }
          // Check if we should show journal tutorial
          else if (user.hasSeenToolsTutorial && 
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
    
    // Get current location and update index
    final location = GoRouterState.of(context).uri.path;
    _updateCurrentIndex(location);
    
    return Scaffold(
      key: _completionKey,
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          LessonsScreen(),
          ToolsScreen(),
          JournalScreen(),
          ProfileScreen(),
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
                
                // Add keys to education, tools, and journal tabs for tutorial
                GlobalKey? tabKey;
                if (index == 1) { // Education tab
                  tabKey = _educationTabKey;
                } else if (index == 2) { // Tools tab
                  tabKey = _toolsTabKey;
                } else if (index == 3) { // Journal tab
                  tabKey = _journalTabKey;
                }
                
                return Expanded(
                  child: _NavigationButton(
                    key: tabKey,
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
        scale: _isPressed ? 0.92 : 1.0,
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


