import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/lesson_provider.dart';
import '../models/lesson.dart';
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

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BED Support App'),
        centerTitle: true,
        actions: [
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
                      backgroundImage: user.photoUrl != null
                          ? NetworkImage(user.photoUrl!)
                          : null,
                      child: user.photoUrl == null
                          ? Text(user.displayName.substring(0, 1).toUpperCase())
                          : null,
                    ),
                  )
                : TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Login'),
                  ),
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Login'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next Lesson Recommendation
            authState.when(
              data: (user) => user != null 
                  ? _buildNextLessonSection()
                  : _buildGuestContentSection(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => _buildGuestContentSection(),
            ),
          ],
        ),
      ),
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
      return Card(
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            child: const Icon(Icons.celebration, color: Colors.green),
          ),
          title: const Text('All lessons completed!'),
          subtitle: const Text('Great job! Explore the education section for more content.'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => context.go('/education'),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToNextLesson(nextLesson),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Theme.of(context).colorScheme.primary,
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
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextLesson.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                nextLesson.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${nextLesson.slides.length} slides',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  ),
                ),
              ],
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
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: const Icon(Icons.psychology),
                ),
                title: const Text('Understanding Binge Eating Disorder'),
                subtitle: const Text('Learn about the causes, symptoms, and impact of BED'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/education'),
              ),
            ),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Icon(Icons.favorite),
                ),
                title: const Text('Self-Care Strategies'),
                subtitle: const Text('Practical techniques for managing difficult moments'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => context.go('/education'),
              ),
            ),
          ],
    );
  }

  Future<void> _navigateToNextLesson(Lesson lesson) async {
    final lessonScreen = _getLessonScreen(lesson);
    
    if (lessonScreen != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => lessonScreen),
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
}
