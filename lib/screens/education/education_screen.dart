import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/lesson_service.dart';
import '../../providers/lesson_provider.dart';
import '../../models/lesson.dart' as lesson_model;

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
    // Navigate to lesson using GoRouter with custom transitions
    context.go('/lesson/${lesson.chapterNumber}/${lesson.lessonNumber}');
    
    // Refresh the UI to show updated lock status after returning from lesson
    if (mounted) {
      setState(() {});
      // Notify the lesson completion provider to update the Home tab
      ref.read(lessonCompletionProvider.notifier).notifyLessonCompleted();
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

}
