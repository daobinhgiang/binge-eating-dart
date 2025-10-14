import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/exp_provider.dart';
import '../widgets/level_badge.dart';
import 'home/resources_section.dart';
import 'home/todo_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController? _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  String _getTimeBasedGreeting(String? firstName) {
    final hour = DateTime.now().hour;
    String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    
    if (firstName != null && firstName.isNotEmpty) {
      return '$timeGreeting, $firstName!';
    } else {
      return '$timeGreeting!';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final weekday = _getWeekdayName(now.weekday);
    final day = now.day;
    final month = _getMonthName(now.month);
    final year = now.year;
    
    return '$weekday, $month $day, $year';
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildCombinedHeaderAndLearningSection(authState),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -90),
                child: Column(
                  children: [
                    const ResourcesSection(),
                    const SizedBox(height: 24),
                    authState.when(
                      data: (user) => user != null 
                          ? const TodoSection()
                          : _buildGuestContentSection(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => _buildGuestContentSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedHeaderAndLearningSection(AsyncValue authState) {
    return Consumer(
      builder: (context, ref, child) {
        final user = authState.valueOrNull;
        final shouldShowLearningSection = user != null;
        
        return Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 40),
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Row(
                    children: [
                      _buildAppLogo(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTimeBasedGreeting(authState.valueOrNull?.displayName.split(' ').first),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getCurrentDate(),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildProfileSection(authState),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppLogo() {
    return RepaintBoundary(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
            cacheWidth: 112, // 2x for retina displays
            cacheHeight: 112,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF64B5F6),
                      Color(0xFF4CAF50),
                      Color(0xFFFFB74D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(AsyncValue authState) {
    return authState.when(
      data: (user) {
        if (user == null) return const SizedBox.shrink();
        
        return Consumer(
          builder: (context, ref, child) {
            final userExp = ref.watch(userExpProvider);
            if (userExp == null) return const SizedBox.shrink();
            
            return RepaintBoundary(
              child: LevelBadge(
                level: userExp.level,
                size: 48,
                showLabel: false,
              ),
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildGuestContentSection() {
    return const SizedBox.shrink(); // Simplified for optimization
  }
}

class CurvedHeaderClipper extends CustomClipper<Path> {
  final double depth;
  
  const CurvedHeaderClipper({this.depth = 80});
  
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - depth);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - depth * 2,
      0,
      size.height - depth,
    );
    path.lineTo(0, 0);
    path.close();
    return path;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

