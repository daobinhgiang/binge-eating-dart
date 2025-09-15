import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ema_survey_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/ema_survey.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  final List<JournalEntry> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    // Initialize today's survey when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserDataProvider);
      if (user != null) {
        ref.read(emaSurveyNotifierProvider.notifier)
            .createOrGetTodaySurvey(user.id);
      }
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    final todaySurvey = ref.watch(todaySurveyProvider(user?.id ?? ''));
    final userName = user?.firstName ?? 'User';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header with date and greeting
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  _formatDate(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hello, $userName!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // EMA Survey Section
                todaySurvey.when(
                  data: (survey) {
                    if (survey == null) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startEMASurvey,
                          child: const Text('Start Today\'s EMA Survey'),
                        ),
                      );
                    } else if (survey.isCompleted) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.green[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'EMA Survey completed today!',
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _viewEMASurvey,
                              child: const Text('View Today\'s Survey'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.schedule, color: Colors.orange[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'EMA Survey in progress (${(survey.completionPercentage * 100).round()}% complete)',
                                    style: TextStyle(color: Colors.orange[800]),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _continueEMASurvey,
                              child: const Text('Continue EMA Survey'),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) {
                    print('❌ Journal Screen Error (todaySurveyProvider): $error');
                    print('🔗  ');
                    print('   https://console.firebase.google.com/v1/r/project/bed-app-ef8f8/firestore/indexes');
                    return Text('Error: $error');
                  },
                ),
                
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _showAddEntryDialog,
                    child: const Text('Add Journal Entry'),
                  ),
                ),
              ],
            ),
          ),
          
          // Journal entries and surveys section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatMonthYear(DateTime.now()),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildContentList(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showAddEntryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Journal Entry'),
        content: TextField(
          controller: _journalController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'How are you feeling today?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _journalController.clear();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_journalController.text.trim().isNotEmpty) {
                setState(() {
                  _journalEntries.insert(
                    0,
                    JournalEntry(
                      date: DateTime.now(),
                      content: _journalController.text.trim(),
                    ),
                  );
                });
                Navigator.of(context).pop();
                _journalController.clear();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.year}';
  }

  // EMA Survey methods
  void _startEMASurvey() async {
    final user = ref.read(currentUserDataProvider);
    if (user == null) return;

    await ref.read(emaSurveyNotifierProvider.notifier)
        .createOrGetTodaySurvey(user.id);

    if (mounted) {
      context.go('/ema-survey');
    }
  }

  void _continueEMASurvey() async {
    if (mounted) {
      context.go('/ema-survey/resume');
    }
  }

  void _viewEMASurvey() async {
    if (mounted) {
      context.go('/ema-survey/resume');
    }
  }

  void _deleteEMASurvey(EMASurvey survey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure you want to delete this survey? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(emaSurveyNotifierProvider.notifier)
          .deleteSurvey(survey.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey deleted successfully')),
        );
      }
    }
  }

  // Build content list with both journal entries and surveys
  Widget _buildContentList(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    final surveys = ref.watch(userSurveysProvider(user?.id ?? ''));

    return surveys.when(
      data: (surveyList) {
        // Combine journal entries and surveys
        final allItems = <Widget>[];
        
        // Add surveys
        for (final survey in surveyList) {
          allItems.add(_buildSurveyCard(context, survey));
        }
        
        // Add journal entries
        for (final entry in _journalEntries) {
          allItems.add(_JournalEntryCard(entry: entry));
        }
        
        // Sort by date (most recent first)
        allItems.sort((a, b) {
          DateTime dateA, dateB;
          
          if (a is _SurveyCard) {
            dateA = a.survey.surveyDate;
          } else if (a is _JournalEntryCard) {
            dateA = a.entry.date;
          } else {
            // Fallback for other widget types
            dateA = DateTime.now();
          }
          
          if (b is _SurveyCard) {
            dateB = b.survey.surveyDate;
          } else if (b is _JournalEntryCard) {
            dateB = b.entry.date;
          } else {
            // Fallback for other widget types
            dateB = DateTime.now();
          }
          
          return dateB.compareTo(dateA);
        });

        if (allItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journaling journey today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: allItems.length,
          itemBuilder: (context, index) => allItems[index],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) {
        print('❌ Journal Screen Error (userSurveysProvider): $error');
        return Center(
          child: Text('Error loading content: $error'),
        );
      },
    );
  }

  Widget _buildSurveyCard(BuildContext context, EMASurvey survey) {
    return _SurveyCard(
      survey: survey,
      onTap: () => _viewEMASurvey(),
      onDelete: () => _deleteEMASurvey(survey),
    );
  }
}

// Survey card widget
class _SurveyCard extends StatelessWidget {
  final EMASurvey survey;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SurveyCard({
    required this.survey,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date box
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: survey.isCompleted ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: survey.isCompleted ? Colors.green[200]! : Colors.orange[200]!,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      survey.isCompleted ? Icons.check_circle : Icons.schedule,
                      color: survey.isCompleted ? Colors.green[600] : Colors.orange[600],
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${survey.surveyDate.day}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: survey.isCompleted ? Colors.green[800] : Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMA Survey',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      survey.isCompleted 
                          ? 'Completed' 
                          : 'In Progress (${(survey.completionPercentage * 100).round()}%)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: survey.isCompleted ? Colors.green[700] : Colors.orange[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(survey.surveyDate),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Delete button
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// Journal entry card widget
class _JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const _JournalEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Date box
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayAbbreviation(entry.date.weekday),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${entry.date.day}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayAbbreviation(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

class JournalEntry {
  final DateTime date;
  final String content;

  JournalEntry({
    required this.date,
    required this.content,
  });
}
