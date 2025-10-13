import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'education/lessons_screen.dart';
import 'tools/tools_screen.dart';
import 'journal/journal_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/comforting_background.dart';
import '../widgets/forest_background.dart';
import '../core/services/app_tutorial_service.dart';
import '../providers/auth_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  bool _hasShownEducationTutorial = false;
  bool _hasShownToolsTutorial = false;

  // Global keys for tutorial targets
  final GlobalKey _educationTabKey = GlobalKey();
  final GlobalKey _toolsTabKey = GlobalKey();

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavigationItem(
      icon: Icons.school_outlined,
      activeIcon: Icons.school,
      label: 'Lessons',
      route: '/education',
    ),
    NavigationItem(
      icon: Icons.build_outlined,
      activeIcon: Icons.build,
      label: 'Tools',
      route: '/tools',
    ),
    NavigationItem(
      icon: Icons.edit_note_outlined,
      activeIcon: Icons.edit_note,
      label: 'Journal',
      route: '/journal',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
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
        onFinish: () {},
      );
    }
    // Show tools tutorial if user has completed first lesson but hasn't seen the tutorial yet
    else if (user.hasCompletedFirstLesson && 
             user.hasSeenAppTutorial && 
             !_hasShownToolsTutorial) {
      _hasShownToolsTutorial = true;
      
      // Mark tutorial as fully seen after tools tutorial
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasSeenAppTutorial: true,
      );
      
      AppTutorialService().showToolsTabTutorial(
        context: context,
        toolsTabKey: _toolsTabKey,
        onFinish: () {},
      );
    }
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
    // Get current location and update index
    final location = GoRouterState.of(context).uri.path;
    _updateCurrentIndex(location);
    
    return Scaffold(
      body: _currentIndex == 2 
          ? ForestBackground(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  LessonsScreen(),
                  ToolsScreen(),
                  JournalScreen(),
                  ProfileScreen(),
                ],
              ),
            )
          : ComfortingBackground(
              child: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  LessonsScreen(),
                  ToolsScreen(),
                  JournalScreen(),
                  ProfileScreen(),
                ],
              ),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                // Add keys to education and tools tabs for tutorial
                GlobalKey? tabKey;
                if (index == 1) { // Education tab
                  tabKey = _educationTabKey;
                } else if (index == 2) { // Tools tab
                  tabKey = _toolsTabKey;
                }
                
                return Expanded(
                  child: GestureDetector(
                    key: tabKey,
                    onTap: () {
                      context.go(item.route);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey[600],
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[600],
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
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
