import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/lesson_service.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson.dart' as lesson_model;
import '../lessons/lesson_1_1.dart';
import '../lessons/lesson_1_2.dart';
import '../lessons/lesson_1_3.dart';
import '../lessons/lesson_2_1.dart';
import '../lessons/lesson_2_2.dart';
import '../lessons/lesson_2_3.dart';
import '../lessons/lesson_2_4.dart';
import '../lessons/lesson_2_5.dart';
import '../lessons/lesson_2_6.dart';
import '../lessons/lesson_3_1.dart';
import '../lessons/lesson_3_2.dart';
import '../lessons/lesson_3_3.dart';
import '../lessons/lesson_3_4.dart';
import '../lessons/lesson_4_1.dart';
import '../lessons/lesson_4_2.dart';
import '../lessons/lesson_4_3.dart';
import '../lessons/lesson_4_4.dart';
import '../lessons/lesson_4_5.dart';
import '../lessons/lesson_5_1.dart';
import '../lessons/lesson_5_2.dart';
import '../lessons/lesson_5_3.dart';
import '../lessons/lesson_5_4.dart';
import '../lessons/lesson_5_5.dart';
import '../lessons/lesson_5_6.dart';
import '../lessons/lesson_6_1.dart';
import '../lessons/lesson_6_2.dart';
import '../lessons/lesson_6_3.dart';
import '../lessons/lesson_6_4.dart';
import '../lessons/lesson_6_5.dart';
import '../lessons/lesson_6_6.dart';
import '../lessons/lesson_7_1.dart';
import '../lessons/lesson_7_2.dart';
import '../lessons/lesson_7_3.dart';
import '../lessons/lesson_7_4.dart';
import '../lessons/lesson_8_1.dart';
import '../lessons/lesson_8_2.dart';
import '../lessons/lesson_8_3.dart';
import '../lessons/lesson_8_4.dart';
import '../lessons/lesson_9_1.dart';
import '../lessons/lesson_9_2.dart';
import '../lessons/lesson_9_3.dart';
import '../lessons/lesson_9_4.dart';
import '../lessons/lesson_9_5.dart';
import '../lessons/lesson_9_6.dart';
import '../lessons/lesson_10_1.dart';
import '../lessons/lesson_10_2.dart';
import '../lessons/lesson_10_3.dart';
import '../lessons/lesson_10_4.dart';
import '../lessons/lesson_10_5.dart';
import '../lessons/lesson_11_1.dart';
import '../lessons/lesson_11_2.dart';
import '../lessons/lesson_11_3.dart';
import '../lessons/lesson_12_1.dart';
import '../lessons/lesson_12_2.dart';
import '../lessons/lesson_12_3.dart';
import '../lessons/lesson_12_4.dart';
import '../lessons/lesson_13_1.dart';
import '../lessons/lesson_13_2.dart';
import '../lessons/lesson_13_3.dart';
import '../lessons/lesson_13_4.dart';
import '../lessons/lesson_14_1.dart';
import '../lessons/lesson_14_2.dart';
import '../lessons/lesson_14_3.dart';
import '../lessons/lesson_14_4.dart';
import '../lessons/lesson_15_1.dart';
import '../lessons/lesson_15_2.dart';
import '../lessons/lesson_16_1.dart';
import '../lessons/lesson_16_2.dart';
import '../lessons/lesson_16_3.dart';
import '../lessons/lesson_17_1.dart';
import '../lessons/lesson_17_2.dart';
import '../lessons/lesson_17_3.dart';
import '../lessons/lesson_17_4.dart';
import '../lessons/lesson_18_1.dart';
import '../lessons/lesson_18_2.dart';
import '../lessons/lesson_18_3.dart';
import '../lessons/lesson_18_4.dart';
import '../lessons/appendix_1_1.dart';
import '../lessons/appendix_1_2.dart';
import '../lessons/appendix_1_3.dart';
import '../lessons/appendix_2_1.dart';
import '../lessons/appendix_2_2.dart';
import '../lessons/appendix_2_3.dart';
import '../lessons/appendix_2_4.dart';
import '../lessons/appendix_3_1.dart';
import '../lessons/appendix_3_2.dart';
import '../lessons/appendix_4_1.dart';
import '../lessons/appendix_4_2.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final LessonService _lessonService = LessonService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Education'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<int, List<lesson_model.Lesson>>>(
        future: _lessonService.getAllLessonsGroupedByChapter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading lessons',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final lessonsByChapter = snapshot.data ?? {};
          if (lessonsByChapter.isEmpty) {
            return const Center(
              child: Text('No lessons available'),
            );
          }

          // Get sorted chapter numbers
          final chapterNumbers = lessonsByChapter.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: chapterNumbers.length,
            itemBuilder: (context, index) {
              final chapterNumber = chapterNumbers[index];
              final lessons = lessonsByChapter[chapterNumber]!;
              final chapterTitle = LessonService.getChapterTitle(chapterNumber);

              return _buildChapterCard(context, chapterNumber, chapterTitle, lessons);
            },
          );
        },
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, int chapterNumber, String chapterTitle, List<lesson_model.Lesson> lessons) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$chapterNumber',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chapter $chapterNumber',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        chapterTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Lessons List
          ...lessons.map((lesson) => _buildLessonCard(context, lesson)).toList(),
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, lesson_model.Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: FutureBuilder<bool>(
          future: _checkLessonUnlock(lesson),
          builder: (context, snapshot) {
            final isUnlocked = snapshot.data ?? false;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isUnlocked ? Icons.play_circle_outline : Icons.lock_outline,
                        color: isUnlocked 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
              ),
              title: Text(
                lesson.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              subtitle: Text(
                '${lesson.description} | ${lesson.slides.length} slides',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              trailing: isUnlocked ? null : Icon(
                Icons.lock,
                color: Colors.grey[400],
                size: 16,
              ),
              onTap: isUnlocked ? () async {
                await _navigateToLesson(context, lesson);
              } : () {
                _showLockedLessonDialog(context);
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _checkLessonUnlock(lesson_model.Lesson lesson) async {
    try {
      return await _lessonService.isLessonUnlocked(lesson.id);
    } catch (e) {
      print('Error checking lesson unlock: $e');
      return false;
    }
  }

  Future<void> _navigateToLesson(BuildContext context, lesson_model.Lesson lesson) async {
    final lessonScreen = _getLessonScreen(lesson.chapterNumber, lesson.lessonNumber);
    
    if (lessonScreen != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => lessonScreen),
      );
      
      // Refresh the UI to show updated lock status after returning from lesson
      if (mounted) {
        setState(() {});
        // Notify the lesson completion provider to update the Home tab
        ref.read(lessonCompletionProvider.notifier).notifyLessonCompleted();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLockedLessonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lesson Locked'),
          content: const Text(
            'This lesson is locked. Complete the previous lesson in this chapter to unlock it.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget? _getLessonScreen(int chapterNumber, int lessonNumber) {
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
