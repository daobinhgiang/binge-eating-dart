import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../models/body_image_diary.dart';
import '../../widgets/tropical_forest_background.dart';
import 'body_image_diary_survey_screen.dart';

class BodyImageDiaryMainScreen extends ConsumerWidget {
  const BodyImageDiaryMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWeekNumber = ref.watch(currentWeekNumberProvider(user.id));
    final currentWeekBodyImageDiaries = ref.watch(currentWeekBodyImageDiariesProvider(user.id));
    final allBodyImageDiaries = ref.watch(allBodyImageDiariesProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Image Diary'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(currentWeekBodyImageDiariesProvider(user.id).notifier).loadCurrentWeekEntries();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: TropicalForestBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with current week
              currentWeekNumber.when(
                data: (weekNumber) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.teal[600]!,
                        Colors.teal[600]!.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal[600]!.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.visibility,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Week $weekNumber',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your body checking behaviors',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                loading: () => const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading week: $error'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Log New Entry Button
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToSurvey(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Log New Entry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Past Entries Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Past Entries',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllEntries(context, user.id),
                    child: const Text('View All'),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Current Week Entries
              _buildCurrentWeekEntries(context, currentWeekBodyImageDiaries),
              
              const SizedBox(height: 24),
              
              // All Entries by Week
              _buildAllEntriesByWeek(context, allBodyImageDiaries),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeekEntries(BuildContext context, AsyncValue<List<BodyImageDiary>> bodyImageDiaries) {
    return bodyImageDiaries.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.visibility_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No entries this week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start tracking your body checking behaviors',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: entries.take(3).map((entry) => _buildBodyImageDiaryCard(context, entry)).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading entries: $error'),
      ),
    );
  }

  Widget _buildAllEntriesByWeek(BuildContext context, AsyncValue<Map<int, List<BodyImageDiary>>> allBodyImageDiaries) {
    return allBodyImageDiaries.when(
      data: (entriesByWeek) {
        if (entriesByWeek.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Entries by Week',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...entriesByWeek.entries.map((entry) {
              final weekNumber = entry.key;
              final entries = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week $weekNumber (${entries.length} entries)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...entries.take(2).map((entry) => _buildBodyImageDiaryCard(context, entry)).toList(),
                    if (entries.length > 2)
                      TextButton(
                        onPressed: () => _showWeekEntries(context, weekNumber, entries),
                        child: Text('View all ${entries.length} entries'),
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading all entries: $error'),
      ),
    );
  }

  Widget _buildBodyImageDiaryCard(BuildContext context, BodyImageDiary entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEntryDetails(context, entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.displayCheckTime,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[600],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Body Check',
                      style: TextStyle(
                        color: Colors.teal[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${entry.displayHowChecked} • ${entry.displayWhereChecked}',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.contextAndFeelings.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.contextAndFeelings,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    entry.displayWhereChecked,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(entry.checkTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
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

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (entryDate == today) {
      return 'Today';
    } else if (entryDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _navigateToSurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BodyImageDiarySurveyScreen(),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, BodyImageDiary entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entry Details - ${entry.displayCheckTime}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('How Checked:', entry.displayHowChecked),
              _buildDetailRow('Where Checked:', entry.displayWhereChecked),
              _buildDetailRow('Time:', entry.displayCheckTime),
              _buildDetailRow('Date:', '${entry.checkTime.month}/${entry.checkTime.day}/${entry.checkTime.year}'),
              if (entry.contextAndFeelings.isNotEmpty) 
                _buildDetailRow('Context & Feelings:', entry.contextAndFeelings),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showAllEntries(BuildContext context, String userId) {
    // TODO: Navigate to a detailed view of all entries
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All entries view coming soon!')),
    );
  }

  void _showWeekEntries(BuildContext context, int weekNumber, List<BodyImageDiary> entries) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Week $weekNumber Entries'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return ListTile(
                title: Text(entry.displayCheckTime),
                subtitle: Text('${entry.displayHowChecked} • ${entry.displayWhereChecked}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Body Check',
                    style: TextStyle(
                      color: Colors.teal[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEntryDetails(context, entry);
                },
              );
            },
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
}
