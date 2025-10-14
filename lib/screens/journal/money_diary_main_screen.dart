import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/money_diary_provider.dart';
import '../../models/money_diary.dart';
import 'money_diary_survey_screen.dart';

class MoneyDiaryMainScreen extends ConsumerWidget {
  const MoneyDiaryMainScreen({super.key});

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

    final currentWeekMoneyDiaries = ref.watch(currentWeekMoneyDiariesProvider(user.id));
    final allMoneyDiaries = ref.watch(allMoneyDiariesProvider(user.id));
    final totalSpent = ref.watch(totalSpentProvider(user.id));

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
                    // Total Money Spent Header
                    _buildTotalSpentHeader(context, totalSpent),
              
                    const SizedBox(height: 24),
                    
                    // Today's Entries Section
                    Text(
                      "Today's Spending",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Today's Entries with Add Entry Card
                    _buildTodaysEntries(context, currentWeekMoneyDiaries),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Entries Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Spending',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Recent Entries (Vertical Scroll)
                    _buildRecentEntries(context, allMoneyDiaries),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToSurvey(context),
        backgroundColor: Colors.amber[600],
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
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber[600]!,
            Colors.amber[500]!,
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
                    'Spending Diary',
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

  Widget _buildTotalSpentHeader(BuildContext context, AsyncValue<double> totalSpent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber[100]!,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.amber[700],
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'Total Money Spent',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              color: Colors.amber[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          totalSpent.when(
            data: (total) => Text(
              '\$${total.toStringAsFixed(2)}',
              style: GoogleFonts.fredoka(
                fontSize: 36,
                color: Colors.amber[800],
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            loading: () => const SizedBox(
              height: 36,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (error, _) => Text(
              'Error loading total',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                color: Colors.amber[700],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Track your spending on binge eating to gain awareness',
            style: GoogleFonts.fredoka(
              fontSize: 14,
              color: Colors.amber[600],
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysEntries(BuildContext context, AsyncValue<List<MoneyDiary>> currentWeekEntries) {
    return currentWeekEntries.when(
      data: (entries) {
        // Filter today's entries
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todaysEntries = entries.where((entry) {
          final entryDate = DateTime(entry.spentAt.year, entry.spentAt.month, entry.spentAt.day);
          return entryDate.isAtSameMomentAs(today);
        }).toList();

        return Column(
          children: [
            // Add Entry Card
            _buildAddEntryCard(context),
            const SizedBox(height: 12),
            
            // Today's entries
            if (todaysEntries.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.money_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No spending recorded today',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Keep up the good work!',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todaysEntries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMoneyEntryCard(context, entry),
              )),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading entries: $error'),
      ),
    );
  }

  Widget _buildAddEntryCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
        color: Colors.amber[50],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToSurvey(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[600],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.add,
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
                        'Add Spending Entry',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track money spent on binge eating',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.amber[700],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.amber[600],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentEntries(BuildContext context, AsyncValue<List<MoneyDiary>> allEntries) {
    return allEntries.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No spending entries yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start tracking your spending to gain insights into your binge eating patterns.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Show recent entries (limit to 10)
        final recentEntries = entries.take(10).toList();
        
        return Column(
          children: recentEntries.map((entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildMoneyEntryCard(context, entry),
          )).toList(),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error loading entries: $error'),
      ),
    );
  }

  Widget _buildMoneyEntryCard(BuildContext context, MoneyDiary entry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.currency}${entry.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
              Text(
                _formatDate(entry.spentAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (entry.notes != null && entry.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              entry.notes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            _formatTime(entry.spentAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(date.year, date.month, date.day);

    if (entryDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (entryDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _navigateToSurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MoneyDiarySurveyScreen(),
      ),
    );
  }
}
