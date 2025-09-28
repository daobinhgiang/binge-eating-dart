import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'home_screen.dart';
import 'education/education_screen.dart';
import 'tools/tools_screen.dart';
import 'journal/journal_screen.dart';
import 'profile/profile_screen.dart';
import '../widgets/comforting_background.dart';
import '../widgets/forest_background.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;
  bool _notificationServiceInitialized = false;

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
    // Initialize notification service when main navigation loads (user is logged in)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotificationService();
    });
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

  /// Initialize notification service for logged-in users
  Future<void> _initializeNotificationService() async {
    if (_notificationServiceInitialized) return;

    try {
      // Check if user is authenticated
      final authState = ref.read(authNotifierProvider);
      final user = authState.value;
      
      if (user != null) {
        // Initialize notification service
        await ref.read(notificationServiceProvider).initialize();
        
        // Initialize notification settings provider to get Firebase token
        ref.read(notificationSettingsProvider.notifier);
        
        _notificationServiceInitialized = true;
        
        if (mounted) {
          // Optional: Show a subtle success message
          if (kDebugMode) {
            print('✅ Notification service initialized for user: ${user.id}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize notification service: $e');
      }
      // Don't show error to user as this is background initialization
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
                  EducationScreen(),
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
                  EducationScreen(),
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
                
                return Expanded(
                  child: GestureDetector(
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
