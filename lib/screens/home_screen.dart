import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/comforting_background.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/firebase_analytics_provider.dart';
import '../providers/app_notification_provider.dart';
import '../core/services/openai_service.dart';
import '../models/lesson.dart';
import '../models/todo_item.dart';
import '../screens/lessons/lesson_1_1.dart';
import '../screens/lessons/lesson_1_2.dart';
import '../screens/lessons/lesson_1_2_1.dart';
import '../screens/lessons/lesson_1_3.dart';
import '../screens/lessons/lesson_3_1.dart';
import '../screens/lessons/lesson_3_2.dart';
import '../screens/lessons/lesson_3_3.dart';
import '../screens/lessons/lesson_3_4.dart';
import '../screens/lessons/lesson_3_5.dart';
import '../screens/lessons/lesson_3_6.dart';
import '../screens/lessons/lesson_3_7.dart';
import '../screens/lessons/lesson_3_8.dart';
import '../screens/lessons/lesson_3_9.dart';
import '../screens/lessons/lesson_3_10.dart';
import '../screens/lessons/lesson_s2_0_1.dart';
import '../screens/lessons/lesson_s2_0_2.dart';
import '../screens/lessons/lesson_s2_0_3.dart';
import '../screens/lessons/lesson_s2_0_4.dart';
import '../screens/lessons/lesson_s2_0_5.dart';
import '../screens/lessons/lesson_s2_0_6.dart';
import '../screens/lessons/lesson_s2_1_1.dart';
import '../screens/lessons/lesson_s2_1_2.dart';
import '../screens/lessons/lesson_s2_1_3.dart';
import '../screens/lessons/lesson_s2_2_1.dart';
import '../screens/lessons/lesson_s2_2_2.dart';
import '../screens/lessons/lesson_s2_2_3.dart';
import '../screens/lessons/lesson_s2_2_4.dart';
import '../screens/lessons/lesson_s2_2_5.dart';
import '../screens/lessons/lesson_s2_2_5_1.dart';
import '../screens/lessons/lesson_s3_0_1.dart';
import '../screens/lessons/lesson_s3_0_2.dart';
import '../screens/assessments/assessment_2_1_screen.dart';
import '../screens/assessments/assessment_2_2_screen.dart';
import '../screens/assessments/assessment_2_3_screen.dart';
import '../screens/assessments/assessment_s3_0_3_screen.dart';
import '../screens/assessments/assessment_s3_0_4_screen.dart';
import '../screens/lessons/lesson_s2_3_1.dart';
import '../screens/lessons/lesson_s2_3_2.dart';
import '../screens/lessons/lesson_s2_3_2_1.dart';
import '../screens/lessons/lesson_s2_3_3.dart';
import '../screens/lessons/lesson_s2_3_4.dart';
import '../screens/lessons/lesson_s2_3_5.dart';
import '../screens/lessons/lesson_s2_4_1.dart';
import '../screens/lessons/lesson_s2_4_2.dart';
import '../screens/lessons/lesson_s2_4_2_1.dart';
import '../screens/lessons/lesson_s2_4_3.dart';
import '../screens/lessons/lesson_s2_5_1.dart';
import '../screens/lessons/lesson_s2_5_2.dart';
import '../screens/lessons/lesson_s2_6_1.dart';
import '../screens/lessons/lesson_s2_6_2.dart';
import '../screens/lessons/lesson_s2_6_3.dart';
import '../screens/lessons/lesson_s2_7_1.dart';
import '../screens/lessons/lesson_s2_7_1_1.dart';
import '../screens/lessons/lesson_s2_7_2.dart';
import '../screens/lessons/lesson_s2_7_3.dart';
import '../screens/lessons/lesson_s2_7_4.dart';
import '../screens/lessons/lesson_s2_7_5.dart';
import '../screens/lessons/lesson_s2_7_6.dart';
import '../screens/lessons/lesson_s2_7_7.dart';
import '../screens/lessons/lesson_s2_7_8.dart';
import '../screens/lessons/lesson_s2_2_7.dart';
import '../screens/lessons/lesson_s2_7_2_1.dart';
import '../screens/lessons/lesson_s3_0_2_1.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  AnimationController? _fadeController;
  AnimationController? _scaleController;
  ScrollController? _scrollController;
  Animation<double>? _fadeAnimation;
  Animation<double>? _scaleAnimation;
  
  // Insights section state
  String _insightsText = '';
  bool _isGeneratingInsights = false;
  List<Map<String, dynamic>> _insightsRecommendations = [];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController!,
      curve: Curves.elasticOut,
    ));
    
    _fadeController?.forward();
    _scaleController?.forward();
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    _fadeController?.dispose();
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: ScrollAwareComfortingBackground(
        scrollController: _scrollController ?? ScrollController(),
        child: CustomScrollView(
          controller: _scrollController ?? ScrollController(),
          slivers: [
            // Simplified header to avoid layout issues
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF7fb781).withValues(alpha:0.15),
                      const Color(0xFF7ea66f).withValues(alpha:0.12),
                      const Color(0xFF6e955f).withValues(alpha:0.08),
                      const Color(0xFF5a7f4f).withValues(alpha:0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Welcome message
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Welcome back!',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D5016),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ready to continue your journey?',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF4A6741),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Profile and notifications
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // User avatar
                            authState.when(
                              data: (user) => user != null
                                  ? PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'logout') {
                                          ref.read(authNotifierProvider.notifier).signOut();
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'logout',
                                          child: Text('Logout'),
                                        ),
                                      ],
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: const Color(0xFF7fb781).withValues(alpha:0.2),
                                        backgroundImage: user.photoUrl != null
                                            ? NetworkImage(user.photoUrl!)
                                            : null,
                                        child: user.photoUrl == null
                                            ? Text(
                                                user.displayName.substring(0, 1).toUpperCase(),
                                                style: const TextStyle(
                                                  color: Color(0xFF2D5016),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : null,
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF7fb781).withValues(alpha:0.2),
                                      child: const Icon(
                                        Icons.person,
                                        color: Color(0xFF2D5016),
                                        size: 20,
                                      ),
                                    ),
                              loading: () => const CircularProgressIndicator(color: Color(0xFF2D5016)),
                              error: (_, __) => CircleAvatar(
                                radius: 20,
                                backgroundColor: const Color(0xFF7fb781).withValues(alpha:0.2),
                                child: const Icon(
                                  Icons.person,
                                  color: Color(0xFF2D5016),
                                  size: 20,
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 12),
                            
                            // Notification bell
                            Consumer(
                              builder: (context, ref, child) {
                                final user = ref.watch(authNotifierProvider).value;
                                if (user == null) return const SizedBox.shrink();
                                
                                final unreadCountAsync = ref.watch(unreadNotificationsCountProvider(user.id));
                                
                                return GestureDetector(
                                  onTap: () => context.go('/notifications'),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7fb781).withValues(alpha:0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Stack(
                                      children: [
                                        const Icon(
                                          Icons.notifications_outlined,
                                          color: Color(0xFF2D5016),
                                          size: 20,
                                        ),
                                        unreadCountAsync.when(
                                          data: (count) => count > 0
                                              ? Positioned(
                                                  right: 0,
                                                  top: 0,
                                                  child: Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                          loading: () => const SizedBox.shrink(),
                                          error: (_, __) => const SizedBox.shrink(),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Animated content wrapper
                  FadeTransition(
                    opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
                    child: ScaleTransition(
                      scale: _scaleAnimation ?? const AlwaysStoppedAnimation(1.0),
                      child: Column(
                        children: [
                          // Urge help button with beautiful gradient and colorful accents
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0F8F0), // Very light green tint
                          Color(0xFFE8F5E8), // Light green tint
                          Color(0xFFE0F2E0), // Slightly more green
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7fb781).withValues(alpha:0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7fb781).withValues(alpha:0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          // Track analytics for urge-relapse button usage
                          final trackUrgeButton = ref.read(urgeRelapseButtonTrackingProvider);
                          trackUrgeButton();
                          _showUrgeHelpDialog();
                        },
                        borderRadius: BorderRadius.circular(16),
                        splashColor: const Color(0xFF7fb781).withValues(alpha:0.1),
                        highlightColor: const Color(0xFF7fb781).withValues(alpha:0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7fb781), Color(0xFF7ea66f), Color(0xFF6e955f)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7fb781).withValues(alpha:0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'I have an urge to relapse',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Get immediate help and coping strategies',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF7fb781),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // AI Support Chat button
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0F8F0), // Very light green tint
                          Color(0xFFE8F5E8), // Light green tint
                          Color(0xFFE0F2E0), // Slightly more green
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF7fb781).withValues(alpha:0.2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7fb781).withValues(alpha:0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.go('/chat'),
                        borderRadius: BorderRadius.circular(16),
                        splashColor: const Color(0xFF7fb781).withValues(alpha:0.1),
                        highlightColor: const Color(0xFF7fb781).withValues(alpha:0.05),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7fb781), Color(0xFF7ea66f), Color(0xFF6e955f)],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7fb781).withValues(alpha:0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chat,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'AI Support Chat',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Get personalized support and guidance',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha:0.8),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF7fb781),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Insights Section
                  _buildInsightsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Next Lesson Recommendation
                  authState.when(
                    data: (user) => user != null 
                        ? _buildAuthenticatedContent()
                        : _buildGuestContentSection(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => _buildGuestContentSection(),
                  ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAuthenticatedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNextLessonSection(),
        const SizedBox(height: 32),
        _buildTodoSection(),
      ],
    );
  }

  Widget _buildNextLessonSection() {
    return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
          'Continue Learning',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
        // Lesson recommendations removed with old system
      ],
    );
  }

  Widget _buildLessonRecommendationCard(BuildContext context, Lesson? nextLesson) {
    if (nextLesson == null) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF0F8F0), // Very light green tint
              Color(0xFFE8F5E8), // Light green tint
              Color(0xFFE0F2E0), // Slightly more green
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7fb781).withValues(alpha:0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.go('/education'),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7fb781), Color(0xFF7ea66f)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7fb781).withValues(alpha:0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All lessons completed!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Great job! Explore the education section for more content.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF7fb781),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F9F5), // Very light green tint
            Color(0xFFEDF5ED), // Light green tint
            Color(0xFFE5F0E5), // Slightly more green
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7fb781).withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToNextLesson(nextLesson),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7fb781), Color(0xFF7fb781)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7fb781).withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Lesson',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            nextLesson.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF7fb781),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  nextLesson.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7fb781), Color(0xFF7ea66f)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${nextLesson.slides.length} slides',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading your next lesson...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.orange),
        title: const Text('Unable to load next lesson'),
        subtitle: const Text('Tap to explore all lessons'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.go('/education'),
      ),
    );
  }

  Widget _buildGuestContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Content',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        
        // Understanding BED card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0F8F0), // Very light green tint
                Color(0xFFE8F5E8), // Light green tint
                Color(0xFFE0F2E0), // Slightly more green
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7fb781).withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7fb781), Color(0xFF7fb781)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7fb781).withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Understanding Binge Eating Disorder',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Learn about the causes, symptoms, and impact of BED',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF7fb781),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Self-Care Strategies card
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF5F9F5), // Very light green tint
                Color(0xFFEDF5ED), // Light green tint
                Color(0xFFE5F0E5), // Slightly more green
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7fb781).withValues(alpha:0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.go('/education'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7fb781), Color(0xFF7ea66f)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7fb781).withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Self-Care Strategies',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Practical techniques for managing difficult moments',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Color(0xFF7fb781),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }



  Future<void> _navigateToNextLesson(Lesson lesson) async {
    final lessonScreen = _getLessonScreen(lesson);
    
    if (lessonScreen != null) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => lessonScreen,
          settings: const RouteSettings(name: '/lesson'),
        ),
      );
      
      // Lesson completed - no additional action needed for new system
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lesson not available yet'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget? _getLessonScreen(Lesson lesson) {
    // Use lesson ID for direct mapping (supports all stages)
    switch (lesson.id) {
      // Stage 1 lessons
      case 'lesson_1_1': return const Lesson11Screen();
      case 'lesson_1_2': return const Lesson12Screen();
      case 'lesson_1_2_1': return const Lesson121Screen();
      case 'lesson_1_3': return const Lesson13Screen();
      case 'lesson_2_1': return const Assessment21Screen();
      case 'lesson_2_2': return const Assessment22Screen();
      case 'lesson_2_3': return const Assessment23Screen();
      case 'lesson_3_1': return const Lesson31Screen();
      case 'lesson_3_2': return const Lesson32Screen();
      case 'lesson_3_3': return const Lesson33Screen();
      case 'lesson_3_4': return const Lesson34Screen();
      case 'lesson_3_5': return const Lesson35Screen();
      case 'lesson_3_6': return const Lesson36Screen();
      case 'lesson_3_7': return const Lesson37Screen();
      case 'lesson_3_8': return const Lesson38Screen();
      case 'lesson_3_9': return const Lesson39Screen();
      case 'lesson_3_10': return const Lesson310Screen();
      
      // Stage 2 lessons
      case 'lesson_s2_0_1': return const LessonS201Screen();
      case 'lesson_s2_0_2': return const LessonS202Screen();
      case 'lesson_s2_0_3': return const LessonS203Screen();
      case 'lesson_s2_0_4': return const LessonS204Screen();
      case 'lesson_s2_0_5': return const LessonS205Screen();
      case 'lesson_s2_0_6': return const LessonS206Screen();
      case 'lesson_s2_1_1': return const LessonS211Screen();
      case 'lesson_s2_1_2': return const LessonS212Screen();
      case 'lesson_s2_1_3': return const LessonS213Screen();
      case 'lesson_s2_2_1': return const LessonS221Screen();
      case 'lesson_s2_2_2': return const LessonS222Screen();
      case 'lesson_s2_2_3': return const LessonS223Screen();
      case 'lesson_s2_2_4': return const LessonS224Screen();
      case 'lesson_s2_2_5': return const LessonS225Screen();
      case 'lesson_s2_2_5_1': return const LessonS2251Screen();
      case 'lesson_s2_2_7': return const LessonS227Screen();
      
      // Chapter 3 lessons
      case 'lesson_s2_3_1': return const LessonS231Screen();
      case 'lesson_s2_3_2': return const LessonS232Screen();
      case 'lesson_s2_3_2_1': return const LessonS2321Screen();
      case 'lesson_s2_3_3': return const LessonS233Screen();
      case 'lesson_s2_3_4': return const LessonS234Screen();
      case 'lesson_s2_3_5': return const LessonS235Screen();
      
      // Chapter 4 lessons
      case 'lesson_s2_4_1': return const LessonS241Screen();
      case 'lesson_s2_4_2': return const LessonS242Screen();
      case 'lesson_s2_4_2_1': return const LessonS2421Screen();
      case 'lesson_s2_4_3': return const LessonS243Screen();
      
      // Chapter 5 lessons
      case 'lesson_s2_5_1': return const LessonS251Screen();
      case 'lesson_s2_5_2': return const LessonS252Screen();
      
      // Chapter 6 lessons
      case 'lesson_s2_6_1': return const LessonS261Screen();
      case 'lesson_s2_6_2': return const LessonS262Screen();
      case 'lesson_s2_6_3': return const LessonS263Screen();
      
      // Chapter 7 lessons
      case 'lesson_s2_7_1': return const LessonS271Screen();
      case 'lesson_s2_7_1_1': return const LessonS2711Screen();
      case 'lesson_s2_7_2': return const LessonS272Screen();
      case 'lesson_s2_7_3': return const LessonS273Screen();
      case 'lesson_s2_7_4': return const LessonS274Screen();
      case 'lesson_s2_7_5': return const LessonS275Screen();
      case 'lesson_s2_7_6': return const LessonS276Screen();
      case 'lesson_s2_7_7': return const LessonS277Screen();
      case 'lesson_s2_7_8': return const LessonS278Screen();
      
      // Stage 3 lessons
      case 'lesson_s3_0_1': return const LessonS301Screen();
      case 'lesson_s3_0_2': return const LessonS302Screen();
      case 'lesson_s3_0_2_1': return const LessonS3021Screen();
      case 'lesson_s3_0_3': return const AssessmentS303Screen();
      case 'lesson_s3_0_4': return const AssessmentS304Screen();
    }
    
    return null;
  }



  Widget _buildTodoSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return authState.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            
            final userTodosAsync = ref.watch(userTodosProvider(user.id));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your To-Do List',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/todos'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                userTodosAsync.when(
                  data: (todos) => _buildTodoListPreview(context, todos),
                  loading: () => _buildTodoLoadingCard(context),
                  error: (error, stack) => _buildTodoErrorCard(context),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildTodoListPreview(BuildContext context, List<TodoItem> todos) {
    if (todos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.task_alt,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No tasks yet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add lessons, tools, or journal activities to your to-do list',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/todos/add'),
                icon: const Icon(Icons.add),
                label: const Text('Add Task'),
              ),
            ],
          ),
        ),
      );
    }

    // Show summary stats and preview of tasks
    final pendingTodos = todos.where((todo) => !todo.isCompleted).toList();
    final dueTodayTodos = pendingTodos.where((todo) => todo.isDueToday).toList();
    final overdueTodos = pendingTodos.where((todo) => todo.isOverdue).toList();
    
    final previewTodos = [
      ...overdueTodos.take(2),
      ...dueTodayTodos.take(2),
      ...pendingTodos.where((todo) => !todo.isOverdue && !todo.isDueToday).take(2),
    ].take(3).toList();

    return Card(
      child: InkWell(
        onTap: () => context.go('/todos'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary row
              Row(
                children: [
                  _buildTodoStat(context, 'Total', todos.length.toString(), Colors.blue),
                  const SizedBox(width: 16),
                  _buildTodoStat(context, 'Pending', pendingTodos.length.toString(), Colors.orange),
                  const SizedBox(width: 16),
                  if (overdueTodos.isNotEmpty)
                    _buildTodoStat(context, 'Overdue', overdueTodos.length.toString(), Colors.red),
                ],
              ),
              
              if (previewTodos.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                
                // Preview todos
                ...previewTodos.map((todo) => _buildTodoPreviewItem(context, todo)),
                
                if (pendingTodos.length > 3) ...[
                  const SizedBox(height: 8),
                  Text(
                    '+ ${pendingTodos.length - 3} more tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
              
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/todos/add'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Task'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/todos'),
                      icon: const Icon(Icons.list, size: 16),
                      label: const Text('View All'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoStat(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha:0.15),
            color.withValues(alpha:0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha:0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoPreviewItem(BuildContext context, TodoItem todo) {
    Color statusColor;
    IconData statusIcon;
    
    if (todo.isOverdue) {
      statusColor = const Color(0xFFE53E3E); // Red
      statusIcon = Icons.warning;
    } else if (todo.isDueToday) {
      statusColor = const Color(0xFFFF9500); // Orange
      statusIcon = Icons.schedule;
    } else {
      statusColor = const Color(0xFF4A90E2); // Blue
      statusIcon = Icons.check_circle_outline;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha:0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor.withValues(alpha:0.3),
                width: 1,
              ),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTypeColor(todo.type).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getTypeColor(todo.type).withValues(alpha:0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        todo.typeDisplayName,
                        style: TextStyle(
                          color: _getTypeColor(todo.type),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Due ${_formatDueDate(todo.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TodoType type) {
    switch (type) {
      case TodoType.lesson:
        return const Color(0xFF4CAF50); // Green
      case TodoType.journal:
        return const Color(0xFF9C27B0); // Purple
      case TodoType.tool:
        return const Color(0xFF2196F3); // Blue
    }
  }

  Widget _buildTodoLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading your tasks...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoErrorCard(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.orange),
        title: const Text('Unable to load tasks'),
        subtitle: const Text('Tap to try again'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => context.go('/todos'),
      ),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(date.year, date.month, date.day);
    
    if (dueDate.isBefore(today)) {
      final daysAgo = today.difference(dueDate).inDays;
      return '$daysAgo day${daysAgo == 1 ? '' : 's'} ago';
    } else if (dueDate.isAtSameMomentAs(today)) {
      return 'today';
    } else {
      final daysFromNow = dueDate.difference(today).inDays;
      if (daysFromNow == 1) {
        return 'tomorrow';
      } else {
        return 'in $daysFromNow days';
      }
    }
  }
  
  void _showUrgeHelpDialog() {
    // Track dialog opening
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('dialog_opened');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.psychology, color: Colors.red[700]),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Coping with Urges'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'When you experience urges to relapse, these resources can help:',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Text(
                '1. Learn about urges and coping strategies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Old lesson navigation options removed
              const SizedBox(height: 16),
              const Text(
                '2. Practice practical coping skills:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHelpOptionCard(
                context,
                'Urge Surfing Activity',
                'Practical exercises to manage urges as they arise',
                Icons.waves,
                Colors.teal,
                () => _navigateToUrgeSurfing(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Track dialog close
              final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
              trackDialog('dialog_closed');
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpOptionCard(BuildContext context, String title, String description, IconData icon, MaterialColor color, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.zero,
      color: color[50],
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop(); // Close dialog first
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color[700], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color[700],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: color[700],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Old lesson navigation methods removed
  
  void _navigateToUrgeSurfing() {
    // Track urge surfing navigation from help dialog
    final trackDialog = ref.read(urgeHelpDialogTrackingProvider);
    trackDialog('urge_surfing_navigation');
    context.push('/tools/urge-surfing');
  }
  
  Widget _buildInsightsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA), // Light gray
            Color(0xFFF1F3F4), // Slightly darker gray
            Color(0xFFE8EAED), // More gray
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7fb781).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.insights,
                    color: Color(0xFF7fb781),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personalized Insights',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D5016),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Get AI-powered insights about your progress',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4A6741),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              constraints: const BoxConstraints(
                minHeight: 120,
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main insights text
                      Text(
                        _insightsText.isEmpty 
                            ? 'Click "Generate insights" to get personalized recommendations based on your progress...'
                            : _insightsText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _insightsText.isEmpty 
                              ? const Color(0xFF9E9E9E)
                              : const Color(0xFF2D5016),
                          height: 1.4,
                        ),
                      ),
                      
                      // Recommendations section
                      if (_insightsRecommendations.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Recommended Resources:',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D5016),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ..._insightsRecommendations.map((recommendation) => 
                          _buildInsightRecommendationCard(recommendation)
                        ).toList(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingInsights ? null : _generateInsights,
                icon: _isGeneratingInsights 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _isGeneratingInsights ? 'Generating...' : 'Generate insights',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7fb781),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _generateInsights() async {
    setState(() {
      _isGeneratingInsights = true;
    });
    
    try {
      // Get the current user ID
      final authState = ref.read(authNotifierProvider);
      final user = authState.valueOrNull;
      
      if (user == null) {
        setState(() {
          _insightsText = 'Please log in to generate personalized insights.';
        });
        return;
      }
      
      final openaiService = OpenAIService();
      final response = await openaiService.generateInsights(user.id);
      
      setState(() {
        _insightsText = response['response'] ?? 'No insights available.';
        _insightsRecommendations = List<Map<String, dynamic>>.from(response['recommendations'] ?? []);
      });
    } catch (e) {
      setState(() {
        _insightsText = 'Sorry, I couldn\'t generate insights at the moment. Please try again later.';
      });
    } finally {
      setState(() {
        _isGeneratingInsights = false;
      });
    }
  }
  
  Widget _buildInsightRecommendationCard(Map<String, dynamic> recommendation) {
    final type = recommendation['type'] as String? ?? '';
    final title = recommendation['title'] as String? ?? '';
    final description = recommendation['description'] as String? ?? '';
    final priority = recommendation['priority'] as String? ?? 'medium';

    Color priorityColor;
    IconData priorityIcon;
    
    switch (priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      case 'low':
        priorityColor = Colors.green;
        priorityIcon = Icons.keyboard_arrow_down;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.remove;
    }

    IconData typeIcon;
    Color typeColor;
    
    switch (type) {
      case 'lesson':
        typeIcon = Icons.school;
        typeColor = Colors.blue;
        break;
      case 'tool':
        typeIcon = Icons.build;
        typeColor = Colors.green;
        break;
      case 'journal':
        typeIcon = Icons.edit_note;
        typeColor = Colors.purple;
        break;
      case 'assessment':
        typeIcon = Icons.quiz;
        typeColor = Colors.orange;
        break;
      default:
        typeIcon = Icons.help;
        typeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToInsightRecommendation(recommendation),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Icon(typeIcon, color: typeColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: typeColor,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(priorityIcon, color: priorityColor, size: 12),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  color: typeColor,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _navigateToInsightRecommendation(Map<String, dynamic> recommendation) {
    final type = recommendation['type'] ?? '';
    final id = recommendation['id'] ?? '';
    
    switch (type) {
      case 'lesson':
        _navigateToInsightLesson(id);
        break;
      case 'tool':
        _navigateToInsightTool(id);
        break;
      case 'journal':
        _navigateToInsightJournal(id);
        break;
      case 'assessment':
        _navigateToInsightAssessment(id);
        break;
      default:
        // Fallback to home
        break;
    }
  }
  
  void _navigateToInsightLesson(String lessonId) {
    // Navigate to specific lesson based on lesson ID (same logic as chatbot)
    switch (lessonId) {
      // Stage 1 lessons
      case 'lesson_1_1':
        context.push('/lesson/1_1');
        break;
      case 'lesson_1_2':
        context.push('/lesson/1_2');
        break;
      case 'lesson_1_2_1':
        context.push('/lesson/1_2_1');
        break;
      case 'lesson_1_3':
        context.push('/lesson/1_3');
        break;
      case 'lesson_2_1':
        context.push('/lesson/2_1');
        break;
      case 'lesson_2_2':
        context.push('/lesson/2_2');
        break;
      case 'lesson_2_3':
        context.push('/lesson/2_3');
        break;
      case 'lesson_3_1':
        context.push('/lesson/3_1');
        break;
      case 'lesson_3_2':
        context.push('/lesson/3_2');
        break;
      case 'lesson_3_3':
        context.push('/lesson/3_3');
        break;
      case 'lesson_3_4':
        context.push('/lesson/3_4');
        break;
      case 'lesson_3_5':
        context.push('/lesson/3_5');
        break;
      case 'lesson_3_6':
        context.push('/lesson/3_6');
        break;
      case 'lesson_3_7':
        context.push('/lesson/3_7');
        break;
      case 'lesson_3_8':
        context.push('/lesson/3_8');
        break;
      case 'lesson_3_9':
        context.push('/lesson/3_9');
        break;
      case 'lesson_3_10':
        context.push('/lesson/3_10');
        break;
      
      // Stage 2 lessons
      case 'lesson_s2_0_1':
        context.push('/lesson/s2_0_1');
        break;
      case 'lesson_s2_0_2':
        context.push('/lesson/s2_0_2');
        break;
      case 'lesson_s2_0_3':
        context.push('/lesson/s2_0_3');
        break;
      case 'lesson_s2_0_4':
        context.push('/lesson/s2_0_4');
        break;
      case 'lesson_s2_0_5':
        context.push('/lesson/s2_0_5');
        break;
      case 'lesson_s2_0_6':
        context.push('/lesson/s2_0_6');
        break;
      case 'lesson_s2_1_1':
        context.push('/lesson/s2_1_1');
        break;
      case 'lesson_s2_1_2':
        context.push('/lesson/s2_1_2');
        break;
      case 'lesson_s2_1_3':
        context.push('/lesson/s2_1_3');
        break;
      case 'lesson_s2_2_1':
        context.push('/lesson/s2_2_1');
        break;
      case 'lesson_s2_2_2':
        context.push('/lesson/s2_2_2');
        break;
      case 'lesson_s2_2_3':
        context.push('/lesson/s2_2_3');
        break;
      case 'lesson_s2_2_4':
        context.push('/lesson/s2_2_4');
        break;
      case 'lesson_s2_2_5':
        context.push('/lesson/s2_2_5');
        break;
      case 'lesson_s2_2_5_1':
        context.push('/lesson/s2_2_5_1');
        break;
      case 'lesson_s2_2_7':
        context.push('/lesson/s2_2_7');
        break;
      case 'lesson_s2_3_1':
        context.push('/lesson/s2_3_1');
        break;
      case 'lesson_s2_3_2':
        context.push('/lesson/s2_3_2');
        break;
      case 'lesson_s2_3_2_1':
        context.push('/lesson/s2_3_2_1');
        break;
      case 'lesson_s2_3_3':
        context.push('/lesson/s2_3_3');
        break;
      case 'lesson_s2_3_4':
        context.push('/lesson/s2_3_4');
        break;
      case 'lesson_s2_3_5':
        context.push('/lesson/s2_3_5');
        break;
      case 'lesson_s2_4_1':
        context.push('/lesson/s2_4_1');
        break;
      case 'lesson_s2_4_2':
        context.push('/lesson/s2_4_2');
        break;
      case 'lesson_s2_4_2_1':
        context.push('/lesson/s2_4_2_1');
        break;
      case 'lesson_s2_4_3':
        context.push('/lesson/s2_4_3');
        break;
      case 'lesson_s2_5_1':
        context.push('/lesson/s2_5_1');
        break;
      case 'lesson_s2_5_2':
        context.push('/lesson/s2_5_2');
        break;
      case 'lesson_s2_6_1':
        context.push('/lesson/s2_6_1');
        break;
      case 'lesson_s2_6_2':
        context.push('/lesson/s2_6_2');
        break;
      case 'lesson_s2_6_3':
        context.push('/lesson/s2_6_3');
        break;
      case 'lesson_s2_7_1':
        context.push('/lesson/s2_7_1');
        break;
      case 'lesson_s2_7_1_1':
        context.push('/lesson/s2_7_1_1');
        break;
      case 'lesson_s2_7_2':
        context.push('/lesson/s2_7_2');
        break;
      case 'lesson_s2_7_3':
        context.push('/lesson/s2_7_3');
        break;
      case 'lesson_s2_7_4':
        context.push('/lesson/s2_7_4');
        break;
      case 'lesson_s2_7_5':
        context.push('/lesson/s2_7_5');
        break;
      case 'lesson_s2_7_6':
        context.push('/lesson/s2_7_6');
        break;
      case 'lesson_s2_7_7':
        context.push('/lesson/s2_7_7');
        break;
      case 'lesson_s2_7_8':
        context.push('/lesson/s2_7_8');
        break;
      case 'lesson_s2_7_2_1':
        context.push('/lesson/s2_7_2_1');
        break;
      
      // Stage 3 lessons
      case 'lesson_s3_0_1':
        context.push('/lesson/s3_0_1');
        break;
      case 'lesson_s3_0_2':
        context.push('/lesson/s3_0_2');
        break;
      case 'lesson_s3_0_2_1':
        context.push('/lesson/s3_0_2_1');
        break;
      default:
        _showInsightLessonNotAvailable(lessonId);
    }
  }
  
  void _navigateToInsightTool(String toolName) {
    // Use the same logic as the chatbot for tool navigation
    // Handle different formats: "Problem Solving", "problem solving", "problem_solving", etc.
    final normalizedName = toolName.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedName) {
      case 'problem solving':
        context.push('/tools/problem-solving');
        break;
      case 'meal planning':
        context.push('/tools/meal-planning');
        break;
      case 'urge surfing activities':
        context.push('/tools/urge-surfing');
        break;
      case 'addressing overconcern':
        context.push('/tools/addressing-overconcern');
        break;
      case 'addressing setbacks':
        context.push('/tools/addressing-setbacks');
        break;
      default:
        // Try to match partial names for better compatibility
        if (normalizedName.contains('problem') && normalizedName.contains('solving')) {
          context.push('/tools/problem-solving');
        } else if (normalizedName.contains('meal') && normalizedName.contains('planning')) {
          context.push('/tools/meal-planning');
        } else if (normalizedName.contains('urge') && (normalizedName.contains('surfing') || normalizedName.contains('activities'))) {
          context.push('/tools/urge-surfing');
        } else if (normalizedName.contains('overconcern')) {
          context.push('/tools/addressing-overconcern');
        } else if (normalizedName.contains('setbacks')) {
          context.push('/tools/addressing-setbacks');
        } else {
          _showInsightToolNotAvailable(toolName);
        }
    }
  }
  
  void _navigateToInsightJournal(String journalType) {
    // Use the same logic as the chatbot for journal navigation
    // Handle different formats: "Food Diary", "food diary", "food_diary", etc.
    final normalizedType = journalType.toLowerCase().replaceAll('_', ' ');
    
    switch (normalizedType) {
      case 'food diary':
        context.push('/journal/food-diary');
        break;
      case 'weight diary':
        context.push('/journal/weight-diary');
        break;
      case 'body image diary':
        context.push('/journal/body-image-diary');
        break;
      default:
        // Try to match partial names
        if (normalizedType.contains('food')) {
          context.push('/journal/food-diary');
        } else if (normalizedType.contains('weight')) {
          context.push('/journal/weight-diary');
        } else if (normalizedType.contains('body') || normalizedType.contains('image')) {
          context.push('/journal/body-image-diary');
        } else {
          context.push('/journal');
        }
    }
  }
  
  void _navigateToInsightAssessment(String assessmentName) {
    switch (assessmentName.toLowerCase()) {
      case 'ede-q':
        context.push('/lesson/2_1'); // EDE-Q assessment
        break;
      case 'cia':
        context.push('/lesson/2_2'); // CIA assessment
        break;
      case 'general psychiatric':
        context.push('/lesson/2_3'); // General psychiatric assessment
        break;
      default:
        _showInsightAssessmentNotAvailable(assessmentName);
    }
  }
  
  void _showInsightLessonNotAvailable(String lessonId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Lesson "$lessonId" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightToolNotAvailable(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tool "$toolName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _showInsightAssessmentNotAvailable(String assessmentName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assessment "$assessmentName" is not available yet. Please try another recommendation.'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  
}

// Custom painter for dashed lines
class DashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for comforting background with subtle nature elements
class ComfortingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Draw subtle circles for a calming effect
    paint.color = const Color(0xFF7fb781).withValues(alpha:0.03);
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.2),
      size.width * 0.15,
      paint,
    );
    
    paint.color = const Color(0xFF7ea66f).withValues(alpha:0.02);
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.3),
      size.width * 0.2,
      paint,
    );
    
    paint.color = const Color(0xFF6e955f).withValues(alpha:0.025);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.7),
      size.width * 0.12,
      paint,
    );
    
    paint.color = const Color(0xFF5a7f4f).withValues(alpha:0.02);
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      size.width * 0.18,
      paint,
    );
    
    // Draw subtle organic shapes for a nature-inspired feel
    paint.color = const Color(0xFF7fb781).withValues(alpha:0.015);
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.5, size.height * 0.05,
      size.width * 0.7, size.height * 0.1,
    );
    path.quadraticBezierTo(
      size.width * 0.8, size.height * 0.15,
      size.width * 0.6, size.height * 0.2,
    );
    path.quadraticBezierTo(
      size.width * 0.4, size.height * 0.18,
      size.width * 0.3, size.height * 0.1,
    );
    canvas.drawPath(path, paint);
    
    // Draw gentle hills at the bottom
    paint.color = const Color(0xFF7ea66f).withValues(alpha:0.02);
    final hillsPath = Path();
    hillsPath.moveTo(0, size.height);
    hillsPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.95,
      size.width * 0.4, size.height,
    );
    hillsPath.quadraticBezierTo(
      size.width * 0.6, size.height * 0.98,
      size.width * 0.8, size.height,
    );
    hillsPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.97,
      size.width, size.height,
    );
    canvas.drawPath(hillsPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
