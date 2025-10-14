import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../models/body_image_diary.dart';
import 'body_image_diary_survey_screen.dart';
import 'all_body_image_diary_entries_screen.dart';

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
                    
                    // Add Entry Button
                    _buildAddEntryButton(context),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Entries (Organized by Date)
                    _buildRecentEntries(context, currentWeekBodyImageDiaries, allBodyImageDiaries),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.cyan[600]!,
            Colors.cyan[500]!,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: Text(
                    'Body Image Diary',
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance the back button width
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalHeader(BuildContext context, int weekNumber) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.cyan[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.cyan[100]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.visibility,
            color: Colors.cyan[600],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Week $weekNumber',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              color: Colors.cyan[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your body checking behaviors',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: Colors.cyan[600],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddEntryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.teal[600],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.teal[600]!.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSurvey(context),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Add New Entry',
                style: GoogleFonts.fredoka(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.visibility_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'No entries yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap "Add New Entry" to start tracking',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Sort by date (most recent first)
    final sortedEntries = List<BodyImageDiary>.from(currentWeekEntries);
    sortedEntries.sort((a, b) => b.checkTime.compareTo(a.checkTime));

    // Categorize entries
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayEntries = <BodyImageDiary>[];
    final yesterdayEntries = <BodyImageDiary>[];
    final beforeEntries = <BodyImageDiary>[];

    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.checkTime.year, entry.checkTime.month, entry.checkTime.day);
      
      if (entryDate == today) {
        todayEntries.add(entry);
      } else if (entryDate == yesterday) {
        yesterdayEntries.add(entry);
      } else {
        beforeEntries.add(entry);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Today's Entries
        if (todayEntries.isNotEmpty) ...[
          Text(
            'Today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ...todayEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildRecentBodyImageDiaryCard(context, entry),
          )),
          const SizedBox(height: 16),
        ],
        
        // Yesterday's Entries
        if (yesterdayEntries.isNotEmpty) ...[
          Text(
            'Yesterday',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ...yesterdayEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildRecentBodyImageDiaryCard(context, entry),
          )),
          const SizedBox(height: 16),
        ],
        
        // Before (Earlier) Entries
        if (beforeEntries.isNotEmpty) ...[
          Text(
            'Before',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          ...beforeEntries.map((entry) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildRecentBodyImageDiaryCard(context, entry),
          )),
        ],
      ],
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllBodyImageDiaryEntriesScreen(),
      ),
    );
  }

}
