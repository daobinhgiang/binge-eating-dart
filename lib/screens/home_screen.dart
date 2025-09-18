import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/lesson_provider.dart';
import '../providers/journal_provider.dart';
import '../models/lesson.dart';

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
            // Welcome back message
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Journal Entry Card
            authState.when(
              data: (user) => user != null 
                  ? _buildJournalEntryCard()
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
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

  Widget _buildJournalEntryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: _navigateToJournalEntry,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How have you been?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add journal entry',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
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

  void _navigateToJournalEntry() {
    // Navigate to journal tab
    context.go('/journal');
    
    // Show the add journal entry dialog after a short delay
    // to ensure the journal screen is loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _showAddJournalEntryDialog();
      }
    });
  }

  void _showAddJournalEntryDialog() {
    final TextEditingController journalController = TextEditingController();
    final TextEditingController moodController = TextEditingController();
    
    // Common mood suggestions
    final List<String> moodSuggestions = [
      'Happy', 'Sad', 'Anxious', 'Excited', 'Calm', 'Frustrated',
      'Grateful', 'Lonely', 'Confident', 'Worried', 'Peaceful', 'Angry',
      'Hopeful', 'Overwhelmed', 'Content', 'Stressed', 'Joyful', 'Nervous',
      'Relaxed', 'Disappointed', 'Proud', 'Confused', 'Motivated', 'Tired',
      'Energized', 'Melancholy', 'Optimistic', 'Pessimistic', 'Serene', 'Restless'
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add Journal Entry'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content field
                  Text(
                    'How are you feeling today?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: journalController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Mood field
                  Row(
                    children: [
                      Text(
                        'Mood (optional)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Searchable',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return moodSuggestions.take(5);
                      }
                      return moodSuggestions.where((String option) {
                        return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      }).take(5);
                    },
                    onSelected: (String selection) {
                      moodController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          hintText: 'How are you feeling? (e.g., Happy, Sad, Anxious...)',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return InkWell(
                                  onTap: () => onSelected(option),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      option,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  journalController.dispose();
                  moodController.dispose();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (journalController.text.trim().isNotEmpty) {
                    final user = ref.read(currentUserDataProvider);
                    if (user != null) {
                      // Get the mood value from the autocomplete field
                      final moodValue = moodController.text.trim();
                      await ref.read(journalEntriesProvider.notifier)
                          .createEntry(
                            user.id, 
                            journalController.text.trim(),
                            mood: moodValue.isEmpty ? null : moodValue,
                          );
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                      journalController.dispose();
                      moodController.dispose();
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _navigateToNextLesson(Lesson lesson) async {
    // Navigate to lesson using GoRouter with custom transitions
    context.go('/lesson/${lesson.chapterNumber}/${lesson.lessonNumber}');
    
    // Trigger refresh of next lesson recommendation
    ref.read(lessonCompletionProvider.notifier).notifyLessonCompleted();
  }

}
