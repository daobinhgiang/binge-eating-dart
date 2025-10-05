import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/food_diary_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../providers/weight_diary_provider.dart';
import '../../models/food_diary.dart';
import '../../models/body_image_diary.dart';
import '../../models/weight_diary.dart';
import 'food_diary_main_screen.dart';
import 'body_image_diary_main_screen.dart';
import 'weight_diary_survey_screen.dart';

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWeekFoodDiaries = ref.watch(currentWeekFoodDiariesProvider(user.id));
    final currentWeekBodyImageDiaries = ref.watch(currentWeekBodyImageDiariesProvider(user.id));
    final currentWeekWeightDiaries = ref.watch(currentWeekWeightDiariesProvider(user.id));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Light lavender background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Journals',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_getTotalJournalCount(currentWeekFoodDiaries, currentWeekBodyImageDiaries, currentWeekWeightDiaries)} JOURNALS',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  // Add button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63), // Pink color
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E63).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _showAddJournalOptions(context),
                        borderRadius: BorderRadius.circular(24),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Filter Tabs
              Row(
                children: [
                  _buildFilterTab('Published', true),
                  const SizedBox(width: 8),
                  _buildFilterTab('Drafts (1)', false),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Journal Entries
              Expanded(
                child: _buildJournalEntries(context, currentWeekFoodDiaries, currentWeekBodyImageDiaries, currentWeekWeightDiaries),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[600],
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildJournalEntries(
    BuildContext context,
    AsyncValue<List<FoodDiary>> foodDiaries,
    AsyncValue<List<BodyImageDiary>> bodyImageDiaries,
    AsyncValue<List<WeightDiary>> weightDiaries,
  ) {
    return foodDiaries.when(
      data: (foodEntries) {
        return bodyImageDiaries.when(
          data: (bodyImageEntries) {
            return weightDiaries.when(
              data: (weightEntries) {
                final allEntries = <Widget>[];
                
                // Add food diary entries
                for (final entry in foodEntries.take(2)) {
                  allEntries.add(_buildJournalCard(
                    context,
                    _getFoodDiaryTitle(entry),
                    _formatTimeAgo(entry.mealTime),
                    const Color(0xFF8D6E63), // Brownish color
                    Icons.restaurant,
                    entry,
                  ));
                }
                
                // Add weight diary entries
                for (final entry in weightEntries.take(1)) {
                  allEntries.add(_buildJournalCard(
                    context,
                    _getWeightDiaryTitle(entry),
                    _formatTimeAgo(entry.createdAt),
                    const Color(0xFF455A64), // Dark blue-gray
                    Icons.monitor_weight,
                    entry,
                  ));
                }
                
                // Add body image diary entries
                for (final entry in bodyImageEntries.take(1)) {
                  allEntries.add(_buildJournalCard(
                    context,
                    _getBodyImageDiaryTitle(entry),
                    _formatTimeAgo(entry.checkTime),
                    const Color(0xFF4A90E2), // Blue color
                    Icons.visibility,
                    entry,
                  ));
                }
                
                if (allEntries.isEmpty) {
                  return _buildEmptyState(context);
                }
                
                return ListView(
                  children: allEntries,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(context, 'Error loading weight entries: $error'),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, 'Error loading body image entries: $error'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _buildErrorState(context, 'Error loading food entries: $error'),
    );
  }

  Widget _buildJournalCard(BuildContext context, String title, String timeAgo, Color cardColor, IconData icon, dynamic entry) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showJournalEntryDetails(context, entry),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 200,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      onSelected: (value) => _handleMenuAction(context, value, entry),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Illustration area (bottom half)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 120,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'No journal entries yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first journal entry',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading journals',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.red[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.red[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showAddJournalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  children: [
                    Text(
                      'Add New Journal Entry',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildAddOption(
                      context,
                      'Food Diary',
                      'Log your meals and eating behaviors',
                      Icons.restaurant,
                      const Color(0xFF4CAF50),
                      () => _navigateToFoodDiarySurvey(context),
                    ),
                    const SizedBox(height: 12),
                    _buildAddOption(
                      context,
                      'Weight Diary',
                      'Track your weight and progress',
                      Icons.monitor_weight,
                      Colors.orange[600]!,
                      () => _navigateToWeightDiarySurvey(context),
                    ),
                    const SizedBox(height: 12),
                    _buildAddOption(
                      context,
                      'Body Image Diary',
                      'Track body checking behaviors',
                      Icons.visibility,
                      Colors.teal[600]!,
                      () => _navigateToBodyImageDiarySurvey(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFoodDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FoodDiaryMainScreen(),
      ),
    );
  }

  void _navigateToWeightDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeightDiarySurveyScreen(),
      ),
    );
  }

  void _navigateToBodyImageDiarySurvey(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BodyImageDiaryMainScreen(),
      ),
    );
  }

  String _getFoodDiaryTitle(FoodDiary entry) {
    if (entry.isBinge) {
      return 'Binge Episode';
    } else {
      // Use the first part of the food description as title
      final foodText = entry.foodAndDrinks;
      if (foodText.length > 30) {
        return '${foodText.substring(0, 30)}...';
      }
      return foodText;
    }
  }

  String _getWeightDiaryTitle(WeightDiary entry) {
    return 'Weight: ${entry.displayWeight}';
  }

  String _getBodyImageDiaryTitle(BodyImageDiary entry) {
    return 'Body Check: ${entry.displayHowChecked}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  int _getTotalJournalCount(
    AsyncValue<List<FoodDiary>> foodDiaries,
    AsyncValue<List<BodyImageDiary>> bodyImageDiaries,
    AsyncValue<List<WeightDiary>> weightDiaries,
  ) {
    int totalCount = 0;
    
    foodDiaries.whenOrNull(
      data: (entries) => totalCount += entries.length,
    );
    
    bodyImageDiaries.whenOrNull(
      data: (entries) => totalCount += entries.length,
    );
    
    weightDiaries.whenOrNull(
      data: (entries) => totalCount += entries.length,
    );
    
    return totalCount;
  }

  void _showJournalEntryDetails(BuildContext context, dynamic entry) {
    String title = '';
    String content = '';
    String type = '';

    if (entry is FoodDiary) {
      title = entry.isBinge ? 'Binge Episode' : 'Meal Entry';
      content = entry.foodAndDrinks;
      type = 'Food Diary';
    } else if (entry is WeightDiary) {
      title = 'Weight Entry';
      content = 'Weight: ${entry.displayWeight}';
      type = 'Weight Diary';
    } else if (entry is BodyImageDiary) {
      title = 'Body Image Check';
      content = 'How: ${entry.displayHowChecked}\nWhere: ${entry.displayWhereChecked}';
      type = 'Body Image Diary';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: $type',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(content),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatTimeAgo(entry.createdAt)}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
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

  void _handleMenuAction(BuildContext context, String action, dynamic entry) {
    switch (action) {
      case 'edit':
        _editJournalEntry(context, entry);
        break;
      case 'delete':
        _deleteJournalEntry(context, entry);
        break;
    }
  }

  void _editJournalEntry(BuildContext context, dynamic entry) {
    if (entry is FoodDiary) {
      // Navigate to food diary edit screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const FoodDiaryMainScreen(),
        ),
      );
    } else if (entry is WeightDiary) {
      // Navigate to weight diary edit screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const WeightDiarySurveyScreen(),
        ),
      );
    } else if (entry is BodyImageDiary) {
      // Navigate to body image diary edit screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const BodyImageDiaryMainScreen(),
        ),
      );
    }
  }

  void _deleteJournalEntry(BuildContext context, dynamic entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteEntry(context, entry);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEntry(BuildContext context, dynamic entry) async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;

      if (entry is FoodDiary) {
        await ref.read(currentWeekFoodDiariesProvider(user.id).notifier).deleteEntry(entry.week, entry.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Food diary entry deleted')),
          );
        }
      } else if (entry is WeightDiary) {
        await ref.read(currentWeekWeightDiariesProvider(user.id).notifier).deleteEntry(entry.week, entry.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Weight diary entry deleted')),
          );
        }
      } else if (entry is BodyImageDiary) {
        await ref.read(currentWeekBodyImageDiariesProvider(user.id).notifier).deleteEntry(entry.week, entry.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Body image diary entry deleted')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting entry: $e')),
        );
      }
    }
  }
}
