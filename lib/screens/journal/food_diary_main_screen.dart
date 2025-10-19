import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../models/food_diary.dart';
import 'food_diary_survey_screen.dart';
import 'all_food_diary_entries_screen.dart';

class FoodDiaryMainScreen extends ConsumerWidget {
  const FoodDiaryMainScreen({super.key});

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
    final currentWeekFoodDiaries = ref.watch(currentWeekFoodDiariesProvider(user.id));
    final allFoodDiaries = ref.watch(allFoodDiariesProvider(user.id));

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
            // Navigation Bar
            _buildNavigationBar(context),
            
            // Main Content
            Expanded(
              child: SafeArea(
                top: false,
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40.0),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _showAllEntries(context, user.id),
                              borderRadius: BorderRadius.circular(40.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        color: const Color(0xFF4CAF50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: const Color(0xFF4CAF50),
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
                    _buildRecentEntries(context, currentWeekFoodDiaries, allFoodDiaries),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            Colors.green[600]!,
            Colors.green[500]!,
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
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Food Diary',
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
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(
          color: Colors.green[100]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant,
            color: Colors.green[600],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Week $weekNumber',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your eating patterns and behaviors',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: Colors.green[600],
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
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
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
          borderRadius: BorderRadius.circular(40.0),
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

  Widget _buildRecentEntries(BuildContext context, AsyncValue<List<FoodDiary>> currentWeekFoodDiaries, AsyncValue<Map<int, List<FoodDiary>>> allFoodDiaries) {
    // Use current week entries as primary source (auto-refreshes)
    return currentWeekFoodDiaries.when(
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

  Widget _buildRecentEntriesFromCurrentWeek(BuildContext context, List<FoodDiary> currentWeekEntries) {
    if (currentWeekEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
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
    final sortedEntries = List<FoodDiary>.from(currentWeekEntries);
    sortedEntries.sort((a, b) => b.mealTime.compareTo(a.mealTime));

    // Categorize entries
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayEntries = <FoodDiary>[];
    final yesterdayEntries = <FoodDiary>[];
    final beforeEntries = <FoodDiary>[];

    for (final entry in sortedEntries) {
      final entryDate = DateTime(entry.mealTime.year, entry.mealTime.month, entry.mealTime.day);
      
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
            child: _buildRecentFoodDiaryCard(context, entry),
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
            child: _buildRecentFoodDiaryCard(context, entry),
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
            child: _buildRecentFoodDiaryCard(context, entry),
          )),
        ],
      ],
    );
  }






  Widget _buildRecentFoodDiaryCard(BuildContext context, FoodDiary entry) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40.0),
        border: Border.all(color: Colors.grey[300]!),
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
          borderRadius: BorderRadius.circular(40.0),
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
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Color(0xFF4CAF50),
                        size: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: entry.isBinge ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Text(
                        entry.isBinge ? 'Binge' : 'Normal',
                        style: TextStyle(
                          color: entry.isBinge ? Colors.red[700] : Colors.green[700],
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
                    entry.foodAndDrinks,
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
                  '${_formatTime(entry.mealTime)} • ${_formatDate(entry.mealTime)}',
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

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
        builder: (context) => const FoodDiarySurveyScreen(),
      ),
    );
  }

  void _showEntryDetails(BuildContext context, FoodDiary entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Entry Details - ${_formatTime(entry.mealTime)}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Food & Drinks:', entry.foodAndDrinks),
              _buildDetailRow('Time:', _formatTime(entry.mealTime)),
              _buildDetailRow('Date:', '${entry.mealTime.month}/${entry.mealTime.day}/${entry.mealTime.year}'),
              _buildDetailRow('Location:', entry.displayLocation),
              _buildDetailRow('Type:', entry.isBinge ? 'Binge Episode' : 'Normal Eating'),
              if (entry.isBinge) _buildDetailRow('Purge Method:', entry.purgeMethod),
              if (entry.contextAndComments.isNotEmpty) 
                _buildDetailRow('Comments:', entry.contextAndComments),
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
        builder: (context) => const AllFoodDiaryEntriesScreen(),
      ),
    );
  }
}

