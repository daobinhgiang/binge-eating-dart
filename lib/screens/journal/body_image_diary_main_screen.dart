import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../models/body_image_diary.dart';
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Navigation Bar
            _buildNavigationBar(context),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with current week
                    currentWeekNumber.when(
                      data: (weekNumber) => _buildJournalHeader(context, weekNumber),
                      loading: () => const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (error, _) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error loading week: $error'),
                      ),
                    ),
              
                    const SizedBox(height: 24),
                    
                    // Today's Entries Section
                    Text(
                      "Today's Entries",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Today's Entries with Add Entry Card
                    _buildTodaysEntries(context, currentWeekBodyImageDiaries),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Entries Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Entries',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.teal[200]!,
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showAllEntries(context, user.id),
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        color: Colors.teal[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.teal[700],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recent Entries (Vertical Scroll)
                    _buildRecentEntries(context, currentWeekBodyImageDiaries, allBodyImageDiaries),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSurvey(context),
        backgroundColor: Colors.teal[600],
        foregroundColor: Colors.white,
        elevation: 8,
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.teal[600],
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal[600]!.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(8),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Body Image Diary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalHeader(BuildContext context, int weekNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.teal[600],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal[600]!.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.visibility,
              color: Colors.teal,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Week $weekNumber',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Track your body checking behaviors',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysEntries(BuildContext context, AsyncValue<List<BodyImageDiary>> bodyImageDiaries) {
    return bodyImageDiaries.when(
      data: (entries) {
        final today = DateTime.now();
        final todayEntries = entries.where((entry) {
          final entryDate = DateTime(entry.checkTime.year, entry.checkTime.month, entry.checkTime.day);
          final todayDate = DateTime(today.year, today.month, today.day);
          return entryDate == todayDate;
        }).toList();

        if (todayEntries.isEmpty) {
          return _buildTodaysEmptyState(context);
        }

        return _buildTodaysEntriesWithAddCard(context, todayEntries);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading entries: $error'),
      ),
    );
  }

  Widget _buildTodaysEmptyState(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSurvey(context),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysEntriesWithAddCard(BuildContext context, List<BodyImageDiary> entries) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length + 1, // +1 for the add card
        itemBuilder: (context, index) {
          if (index == entries.length) {
            // Add entry card at the end
            return Container(
              width: 200,
              margin: const EdgeInsets.only(left: 12),
              child: _buildAddEntryCard(context),
            );
          }
          
          return Container(
            width: 280,
            margin: const EdgeInsets.only(right: 12),
            child: _buildBodyImageDiaryCard(context, entries[index]),
          );
        },
      ),
    );
  }

  Widget _buildAddEntryCard(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSurvey(context),
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, AsyncValue<List<BodyImageDiary>> currentWeekBodyImageDiaries, AsyncValue<Map<int, List<BodyImageDiary>>> allBodyImageDiaries) {
    // Use current week entries as primary source (auto-refreshes)
    return currentWeekBodyImageDiaries.when(
      data: (currentWeekEntries) {
        // For now, just show current week entries to ensure immediate refresh
        // TODO: Add historical entries back when provider refresh is implemented
        return _buildRecentEntriesFromCurrentWeek(context, currentWeekEntries);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading recent entries: $error'),
      ),
    );
  }

  Widget _buildRecentEntriesFromCurrentWeek(BuildContext context, List<BodyImageDiary> currentWeekEntries) {
    if (currentWeekEntries.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by date (most recent first)
    final sortedEntries = List<BodyImageDiary>.from(currentWeekEntries);
    sortedEntries.sort((a, b) => b.checkTime.compareTo(a.checkTime));

    // Limit to 5 latest entries
    final limitedEntries = sortedEntries.take(5).toList();

    return Column(
      children: limitedEntries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: _buildRecentBodyImageDiaryCard(context, entry),
        );
      }).toList(),
    );
  }

  Widget _buildRecentBodyImageDiaryCard(BuildContext context, BodyImageDiary entry) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEntryDetails(context, entry),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.teal[600]!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: Colors.teal,
                        size: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Body Check',
                        style: TextStyle(
                          color: Colors.teal[700],
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    '${entry.displayHowChecked} • ${entry.displayWhereChecked}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entry.displayCheckTime} • ${_formatDate(entry.checkTime)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyImageDiaryCard(BuildContext context, BodyImageDiary entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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

}
