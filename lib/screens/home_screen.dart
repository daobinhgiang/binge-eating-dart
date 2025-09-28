import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/comforting_background.dart';
import '../providers/auth_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/analytics_provider.dart';
import '../models/lesson.dart';
import '../models/todo_item.dart';
import '../screens/lessons/lesson_1_1.dart';
import '../screens/lessons/lesson_1_2.dart';
import '../screens/lessons/lesson_1_3.dart';
import '../screens/lessons/lesson_2_1.dart';
import '../screens/lessons/lesson_2_2.dart';
import '../screens/lessons/lesson_2_3.dart';
import '../screens/lessons/lesson_2_4.dart';
import '../screens/lessons/lesson_2_5.dart';
import '../screens/lessons/lesson_2_6.dart';
import '../screens/lessons/lesson_3_1.dart';
import '../screens/lessons/lesson_3_2.dart';
import '../screens/lessons/lesson_3_3.dart';
import '../screens/lessons/lesson_3_4.dart';
import '../screens/lessons/lesson_4_1.dart';
import '../screens/lessons/lesson_4_2.dart';
import '../screens/lessons/lesson_4_3.dart';
import '../screens/lessons/lesson_4_4.dart';
import '../screens/lessons/lesson_4_5.dart';
import '../screens/lessons/lesson_5_1.dart';
import '../screens/lessons/lesson_5_2.dart';
import '../screens/lessons/lesson_5_3.dart';
import '../screens/lessons/lesson_5_4.dart';
import '../screens/lessons/lesson_5_5.dart';
import '../screens/lessons/lesson_5_6.dart';
import '../screens/lessons/lesson_6_1.dart';
import '../screens/lessons/lesson_6_2.dart';
import '../screens/lessons/lesson_6_3.dart';
import '../screens/lessons/lesson_6_4.dart';
import '../screens/lessons/lesson_6_5.dart';
import '../screens/lessons/lesson_6_6.dart';
import '../screens/lessons/lesson_7_1.dart';
import '../screens/lessons/lesson_7_2.dart';
import '../screens/lessons/lesson_7_3.dart';
import '../screens/lessons/lesson_7_4.dart';
import '../screens/lessons/lesson_8_1.dart';
import '../screens/lessons/lesson_8_2.dart';
import '../screens/lessons/lesson_8_3.dart';
import '../screens/lessons/lesson_8_4.dart';
import '../screens/lessons/lesson_9_1.dart';
import '../screens/lessons/lesson_9_2.dart';
import '../screens/lessons/lesson_9_3.dart';
import '../screens/lessons/lesson_9_4.dart';
import '../screens/lessons/lesson_9_5.dart';
import '../screens/lessons/lesson_9_6.dart';
import '../screens/lessons/lesson_10_1.dart';
import '../screens/lessons/lesson_10_2.dart';
import '../screens/lessons/lesson_10_3.dart';
import '../screens/lessons/lesson_10_4.dart';
import '../screens/lessons/lesson_10_5.dart';
import '../screens/lessons/lesson_11_1.dart';
import '../screens/lessons/lesson_11_2.dart';
import '../screens/lessons/lesson_11_3.dart';
import '../screens/lessons/lesson_12_1.dart';
import '../screens/lessons/lesson_12_2.dart';
import '../screens/lessons/lesson_12_3.dart';
import '../screens/lessons/lesson_12_4.dart';
import '../screens/lessons/lesson_13_1.dart';
import '../screens/lessons/lesson_13_2.dart';
import '../screens/lessons/lesson_13_3.dart';
import '../screens/lessons/lesson_13_4.dart';
import '../screens/lessons/lesson_14_1.dart';
import '../screens/lessons/lesson_14_2.dart';
import '../screens/lessons/lesson_14_3.dart';
import '../screens/lessons/lesson_14_4.dart';
import '../screens/lessons/lesson_15_1.dart';
import '../screens/lessons/lesson_15_2.dart';
import '../screens/lessons/lesson_16_1.dart';
import '../screens/lessons/lesson_16_2.dart';
import '../screens/lessons/lesson_16_3.dart';
import '../screens/lessons/lesson_17_1.dart';
import '../screens/lessons/lesson_17_2.dart';
import '../screens/lessons/lesson_17_3.dart';
import '../screens/lessons/lesson_17_4.dart';
import '../screens/lessons/lesson_18_1.dart';
import '../screens/lessons/lesson_18_2.dart';
import '../screens/lessons/lesson_18_3.dart';
import '../screens/lessons/lesson_18_4.dart';
import '../screens/lessons/appendix_1_1.dart';
import '../screens/lessons/appendix_1_2.dart';
import '../screens/lessons/appendix_1_3.dart';
import '../screens/lessons/appendix_2_1.dart';
import '../screens/lessons/appendix_2_2.dart';
import '../screens/lessons/appendix_2_3.dart';
import '../screens/lessons/appendix_2_4.dart';
import '../screens/lessons/appendix_3_1.dart';
import '../screens/lessons/appendix_3_2.dart';
import '../screens/lessons/appendix_4_1.dart';
import '../screens/lessons/appendix_4_2.dart';

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
    
    _fadeController!.forward();
    _scaleController!.forward();
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
        scrollController: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
              slivers: [
            // Beautiful translucent app bar with comforting background
            SliverAppBar(
              expandedHeight: 140, // Slightly increased for better visual balance
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false, // Prevent back arrow from appearing
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF7fb781).withValues(alpha:0.15), // Very light green
                        const Color(0xFF7ea66f).withValues(alpha:0.12), // Slightly darker
                        const Color(0xFF6e955f).withValues(alpha:0.08), // Even lighter
                        const Color(0xFF5a7f4f).withValues(alpha:0.05), // Very subtle
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
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row with welcome message on left, profile and notifications on right
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left side: Welcome message
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back!',
                                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2D5016), // Dark green for better contrast
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Ready to continue your journey?',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: const Color(0xFF4A6741), // Medium green
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Right side: Profile and notifications container
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha:0.8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF7fb781).withValues(alpha:0.3),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha:0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                        BoxShadow(
                                          color: const Color(0xFF7fb781).withValues(alpha:0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // User avatar and name
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
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 18,
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
                                                      const SizedBox(width: 8),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            user.displayName,
                                                            style: const TextStyle(
                                                              color: Color(0xFF2D5016),
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Profile',
                                                            style: TextStyle(
                                                              color: const Color(0xFF4A6741).withValues(alpha:0.8),
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Row(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor: const Color(0xFF7fb781).withValues(alpha:0.2),
                                                      child: const Icon(
                                                        Icons.person,
                                                        color: Color(0xFF2D5016),
                                                        size: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    TextButton(
                                                      onPressed: () => context.go('/login'),
                                                      child: const Text(
                                                        'Login',
                                                        style: TextStyle(color: Color(0xFF2D5016)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          loading: () => const CircularProgressIndicator(color: Color(0xFF2D5016)),
                                          error: (_, __) => Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: const Color(0xFF7fb781).withValues(alpha:0.2),
                                                child: const Icon(
                                                  Icons.person,
                                                  color: Color(0xFF2D5016),
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              TextButton(
                                                onPressed: () => context.go('/login'),
                                                child: const Text(
                                                  'Login',
                                                  style: TextStyle(color: Color(0xFF2D5016)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Notification bell
                                        GestureDetector(
                                          onTap: () => _showNotifications(context),
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
                                                // Notification badge
                                                Positioned(
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
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              
                            ],
                          ),
                        ],
                      ),
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
                        onTap: _showUrgeHelpDialog,
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
                  
                  // Inquiries button with beautiful gradient and colorful accents
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
                      border: Border.all(
                        color: const Color(0xFF7fb781).withValues(alpha:0.15),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7fb781).withValues(alpha:0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/chatbot'),
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
                                  Icons.question_answer,
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
                                      'Inquiries',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Chat with our assistant to find helpful resources',
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
                  
                  // Progress Section inspired by Mindify
                  _buildProgressSection(),
                  
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
        _buildAnalyticsSection(),
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
        Consumer(
          builder: (context, ref, child) {
            final nextLessonAsync = ref.watch(nextSuggestedLessonProvider);
            
            return nextLessonAsync.when(
              data: (nextLesson) => _buildLessonRecommendationCard(context, nextLesson),
              loading: () => _buildLoadingCard(context),
              error: (error, stack) => _buildErrorCard(context),
            );
          },
        ),
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
      
      // Trigger refresh of next lesson recommendation
      ref.read(lessonCompletionProvider.notifier).notifyLessonCompleted();
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
    final chapterNumber = lesson.chapterNumber;
    final lessonNumber = lesson.lessonNumber;
    
    // Handle appendices (101-104)
    if (chapterNumber >= 101 && chapterNumber <= 104) {
      final appendixNumber = chapterNumber - 100;
      switch (appendixNumber) {
        case 1:
          switch (lessonNumber) {
            case 1: return const Appendix11Screen();
            case 2: return const Appendix12Screen();
            case 3: return const Appendix13Screen();
          }
        case 2:
          switch (lessonNumber) {
            case 1: return const Appendix21Screen();
            case 2: return const Appendix22Screen();
            case 3: return const Appendix23Screen();
            case 4: return const Appendix24Screen();
          }
        case 3:
          switch (lessonNumber) {
            case 1: return const Appendix31Screen();
            case 2: return const Appendix32Screen();
          }
        case 4:
          switch (lessonNumber) {
            case 1: return const Appendix41Screen();
            case 2: return const Appendix42Screen();
          }
      }
      return null;
    }
    
    // Handle regular chapters (1-18)
    switch (chapterNumber) {
      case 1:
        switch (lessonNumber) {
          case 1: return const Lesson11Screen();
          case 2: return const Lesson12Screen();
          case 3: return const Lesson13Screen();
        }
      case 2:
        switch (lessonNumber) {
          case 1: return const Lesson21Screen();
          case 2: return const Lesson22Screen();
          case 3: return const Lesson23Screen();
          case 4: return const Lesson24Screen();
          case 5: return const Lesson25Screen();
          case 6: return const Lesson26Screen();
        }
      case 3:
        switch (lessonNumber) {
          case 1: return const Lesson31Screen();
          case 2: return const Lesson32Screen();
          case 3: return const Lesson33Screen();
          case 4: return const Lesson34Screen();
        }
      case 4:
        switch (lessonNumber) {
          case 1: return const Lesson41Screen();
          case 2: return const Lesson42Screen();
          case 3: return const Lesson43Screen();
          case 4: return const Lesson44Screen();
          case 5: return const Lesson45Screen();
        }
      case 5:
        switch (lessonNumber) {
          case 1: return const Lesson51Screen();
          case 2: return const Lesson52Screen();
          case 3: return const Lesson53Screen();
          case 4: return const Lesson54Screen();
          case 5: return const Lesson55Screen();
          case 6: return const Lesson56Screen();
        }
      case 6:
        switch (lessonNumber) {
          case 1: return const Lesson61Screen();
          case 2: return const Lesson62Screen();
          case 3: return const Lesson63Screen();
          case 4: return const Lesson64Screen();
          case 5: return const Lesson65Screen();
          case 6: return const Lesson66Screen();
        }
      case 7:
        switch (lessonNumber) {
          case 1: return const Lesson71Screen();
          case 2: return const Lesson72Screen();
          case 3: return const Lesson73Screen();
          case 4: return const Lesson74Screen();
        }
      case 8:
        switch (lessonNumber) {
          case 1: return const Lesson81Screen();
          case 2: return const Lesson82Screen();
          case 3: return const Lesson83Screen();
          case 4: return const Lesson84Screen();
        }
      case 9:
        switch (lessonNumber) {
          case 1: return const Lesson91Screen();
          case 2: return const Lesson92Screen();
          case 3: return const Lesson93Screen();
          case 4: return const Lesson94Screen();
          case 5: return const Lesson95Screen();
          case 6: return const Lesson96Screen();
        }
      case 10:
        switch (lessonNumber) {
          case 1: return const Lesson101Screen();
          case 2: return const Lesson102Screen();
          case 3: return const Lesson103Screen();
          case 4: return const Lesson104Screen();
          case 5: return const Lesson105Screen();
        }
      case 11:
        switch (lessonNumber) {
          case 1: return const Lesson111Screen();
          case 2: return const Lesson112Screen();
          case 3: return const Lesson113Screen();
        }
      case 12:
        switch (lessonNumber) {
          case 1: return const Lesson121Screen();
          case 2: return const Lesson122Screen();
          case 3: return const Lesson123Screen();
          case 4: return const Lesson124Screen();
        }
      case 13:
        switch (lessonNumber) {
          case 1: return const Lesson131Screen();
          case 2: return const Lesson132Screen();
          case 3: return const Lesson133Screen();
          case 4: return const Lesson134Screen();
        }
      case 14:
        switch (lessonNumber) {
          case 1: return const Lesson141Screen();
          case 2: return const Lesson142Screen();
          case 3: return const Lesson143Screen();
          case 4: return const Lesson144Screen();
        }
      case 15:
        switch (lessonNumber) {
          case 1: return const Lesson151Screen();
          case 2: return const Lesson152Screen();
        }
      case 16:
        switch (lessonNumber) {
          case 1: return const Lesson161Screen();
          case 2: return const Lesson162Screen();
          case 3: return const Lesson163Screen();
        }
      case 17:
        switch (lessonNumber) {
          case 1: return const Lesson171Screen();
          case 2: return const Lesson172Screen();
          case 3: return const Lesson173Screen();
          case 4: return const Lesson174Screen();
        }
      case 18:
        switch (lessonNumber) {
          case 1: return const Lesson181Screen();
          case 2: return const Lesson182Screen();
          case 3: return const Lesson183Screen();
          case 4: return const Lesson184Screen();
        }
    }
    
    return null;
  }

  Widget _buildAnalyticsSection() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);
        
        return authState.when(
          data: (user) {
            if (user == null) return const SizedBox.shrink();
            
            final analyticsAsync = ref.watch(analyticsNotifierProvider(user.id));
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analytics',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                analyticsAsync.when(
                  data: (analysis) => _buildAnalyticsCard(context, ref, user.id, analysis),
                  loading: () => _buildAnalyticsLoadingCard(context),
                  error: (error, stack) => _buildAnalyticsErrorCard(context, error.toString()),
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

  Widget _buildAnalyticsCard(BuildContext context, WidgetRef ref, String userId, Map<String, dynamic>? analysis) {
    if (analysis == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Analysis Available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate insights from your journal entries to see patterns and recommendations',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.go('/journal'),
                icon: const Icon(Icons.note_add),
                label: const Text('Go to Journal'),
              ),
            ],
          ),
        ),
      );
    }

    final analysisSummary = analysis['analysis'] as String? ?? 'No analysis available';
    final insights = (analysis['insights'] as List?)?.cast<String>() ?? [];
    final recommendations = (analysis['recommendations'] as List?)?.cast<String>() ?? [];
    final weekNumber = analysis['weekNumber'] as int?;
    final entriesAnalyzed = analysis['entriesAnalyzed'] as int?;
    final recommendedTodos = analysis['recommendedTodos'] as int? ?? 0;
    final todosGenerated = analysis['todosGenerated'] as bool? ?? false;

    return Card(
      elevation: 4,
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
                      colors: [Color(0xFF7fb781), Color(0xFF7ea66f)],
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
                    Icons.analytics,
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
                        'Journal Analysis',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7fb781),
                        ),
                      ),
                      if (weekNumber != null && entriesAnalyzed != null)
                        Text(
                          'Week $weekNumber • $entriesAnalyzed entries analyzed${todosGenerated ? " • $recommendedTodos todos added" : ""}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Analysis summary (truncated)
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analysisSummary.length > 200 
                  ? '${analysisSummary.substring(0, 200)}...'
                  : analysisSummary,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Key Insights',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...insights.take(2).map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        insight,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              if (insights.length > 2)
                Text(
                  '+ ${insights.length - 2} more insights',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            if (recommendations.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...recommendations.take(2).map((recommendation) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        recommendation,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              if (recommendations.length > 2)
                Text(
                  '+ ${recommendations.length - 2} more recommendations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
            
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showFullAnalysis(context, analysis),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Full'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Refresh todos and navigate to todo list if todos were generated
                      if (todosGenerated && recommendedTodos > 0) {
                        ref.read(userTodosProvider(userId).notifier).refreshTodos();
                        context.go('/todos');
                      } else {
                        context.go('/journal');
                      }
                    },
                    icon: Icon(todosGenerated && recommendedTodos > 0 ? Icons.list : Icons.note_add, size: 16),
                    label: Text(todosGenerated && recommendedTodos > 0 ? 'View Todos' : 'Add Entries'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading analytics...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsErrorCard(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load analytics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Journal to generate your first analysis',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/journal'),
              icon: const Icon(Icons.note_add),
              label: const Text('Go to Journal'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullAnalysis(BuildContext context, Map<String, dynamic> analysis) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full Analysis'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Overview',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(analysis['analysis'] as String? ?? 'No analysis available'),
              
              if ((analysis['insights'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Key Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['insights'] as List).cast<String>().map(
                  (insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $insight'),
                  ),
                ),
              ],
              
              if ((analysis['patterns'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Patterns',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['patterns'] as List).cast<String>().map(
                  (pattern) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $pattern'),
                  ),
                ),
              ],
              
              if ((analysis['recommendations'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                Text(
                  'Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...(analysis['recommendations'] as List).cast<String>().map(
                  (recommendation) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('• $recommendation'),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
              _buildHelpOptionCard(
                context,
                'Lesson 13.1: Nutrition Basics for Recovery',
                'Understanding proper nutrition helps manage urges',
                Icons.book,
                Colors.blue,
                () => _navigateToLesson131(),
              ),
              const SizedBox(height: 8),
              _buildHelpOptionCard(
                context,
                'Lesson 13.2: Understanding Your Body\'s Needs',
                'Learn to interpret your body\'s signals',
                Icons.book,
                Colors.blue,
                () => _navigateToLesson132(),
              ),
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
            onPressed: () => Navigator.of(context).pop(),
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
  
  void _navigateToLesson131() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Lesson131Screen(),
        settings: const RouteSettings(name: '/lesson'),
      ),
    );
  }
  
  void _navigateToLesson132() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Lesson132Screen(),
        settings: const RouteSettings(name: '/lesson'),
      ),
    );
  }
  
  void _navigateToUrgeSurfing() {
    context.push('/tools/urge-surfing');
  }
  
  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.notifications, color: const Color(0xFF7fb781)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Notifications'),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sample notifications
              _buildNotificationItem(
                context,
                'New lesson available',
                'Lesson 5.3: Building Healthy Relationships with Food is now ready',
                Icons.book,
                Colors.blue,
                '2 hours ago',
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                context,
                'Journal reminder',
                'Don\'t forget to log your thoughts and feelings today',
                Icons.note,
                Colors.orange,
                '1 day ago',
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                context,
                'Progress update',
                'Great job! You\'ve completed 3 lessons this week',
                Icons.celebration,
                const Color(0xFF7fb781),
                '2 days ago',
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                context,
                'Wellness tip',
                'Remember to practice mindfulness during meal times',
                Icons.favorite,
                Colors.pink,
                '3 days ago',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to notifications screen if you have one
              // context.push('/notifications');
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationItem(BuildContext context, String title, String description, IconData icon, Color color, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha:0.05),
            color.withValues(alpha:0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha:0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha:0.3),
                  color.withValues(alpha:0.15),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
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
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: color.withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7fb781), // Main color
            Color(0xFF7ea66f), // Slightly darker shade
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7fb781).withValues(alpha:0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Colorful Statistics Row inspired by the image
          _buildColorfulStatsRow(),
          
          const SizedBox(height: 20),
          
          // Dashed Progress Component inspired by Mindify
          _buildDashedProgress(
            title: 'Personal Development',
            progress: 0.68,
            total: 100,
            current: 68,
            color: Colors.white,
            icon: Icons.trending_up,
          ),
          
          const SizedBox(height: 16),
          
          _buildDashedProgress(
            title: 'Recovery Journey',
            progress: 0.45,
            total: 50,
            current: 23,
            color: Colors.white.withValues(alpha:0.9),
            icon: Icons.healing,
          ),
          
          const SizedBox(height: 16),
          
          _buildDashedProgress(
            title: 'Weekly Goals',
            progress: 0.8,
            total: 5,
            current: 4,
            color: Colors.white.withValues(alpha:0.8),
            icon: Icons.flag,
          ),
          
          const SizedBox(height: 20),
          
          // Colorful Emotion Bars inspired by the image
          _buildEmotionBars(),
        ],
      ),
    );
  }
  
  Widget _buildDashedProgress({
    required String title,
    required double progress,
    required int total,
    required int current,
    required Color color,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              '$current/$total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color.withValues(alpha:0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Dashed Progress Bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Colors.white.withValues(alpha:0.2),
          ),
          child: Stack(
            children: [
              // Background dashes
              CustomPaint(
                painter: DashedLinePainter(
                  color: Colors.white.withValues(alpha:0.3),
                  strokeWidth: 2,
                  dashWidth: 8,
                  dashSpace: 4,
                ),
                size: Size.infinite,
              ),
              // Progress fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Colorful Emotion Bars inspired by the image
  Widget _buildEmotionBars() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Emotion Insights',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        _buildEmotionBar('Happy', 0.8, const Color(0xFF4CAF50), Icons.sentiment_very_satisfied),
        const SizedBox(height: 8),
        _buildEmotionBar('Calm', 0.6, const Color(0xFF2196F3), Icons.sentiment_neutral),
        const SizedBox(height: 8),
        _buildEmotionBar('Sad', 0.3, const Color(0xFF9C27B0), Icons.sentiment_dissatisfied),
        const SizedBox(height: 8),
        _buildEmotionBar('Anxious', 0.4, const Color(0xFFFF9800), Icons.sentiment_very_dissatisfied),
        const SizedBox(height: 8),
        _buildEmotionBar('Stressed', 0.2, const Color(0xFFE53E3E), Icons.warning),
      ],
    );
  }

  Widget _buildEmotionBar(String emotion, double progress, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emotion,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withValues(alpha:0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha:0.8)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Colorful Statistics Row inspired by the image
  Widget _buildColorfulStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCircle(
            'Total Journals',
            '257',
            const Color(0xFF4A90E2), // Blue
            Icons.book,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCircle(
            'Positive',
            '99',
            const Color(0xFF4CAF50), // Green
            Icons.sentiment_very_satisfied,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCircle(
            'Negative',
            '115',
            const Color(0xFFE53E3E), // Red
            Icons.sentiment_very_dissatisfied,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCircle(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha:0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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
