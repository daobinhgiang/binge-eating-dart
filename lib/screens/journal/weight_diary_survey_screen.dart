import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/todo_provider.dart';
import '../../models/weight_diary.dart';
import '../../models/todo_item.dart';
import '../../providers/weight_diary_provider.dart';
import '../../widgets/weight_graph_widget.dart';
import '../../widgets/quest_completion_dialog.dart';
import '../../core/services/app_tutorial_service.dart';

class WeightDiarySurveyScreen extends ConsumerStatefulWidget {
   const WeightDiarySurveyScreen({super.key});

  @override
  ConsumerState<WeightDiarySurveyScreen> createState() => _WeightDiarySurveyScreenState();
}

class _WeightDiarySurveyScreenState extends ConsumerState<WeightDiarySurveyScreen> {
  final TextEditingController _weightController = TextEditingController();
  String _unit = WeightDiary.weightUnits.first; // default 'kg'
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _markWeightDiaryVisit();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _markWeightDiaryVisit() async {
    final user = ref.read(currentUserDataProvider);
    if (user != null && !user.hasVisitedWeightDiary) {
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasVisitedWeightDiary: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent(context)),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black87,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: Text(
                'Weight Diary',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the back button width
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full-history Weight Graph
            _buildFullHistoryGraph(context),
            const SizedBox(height: 24),
            Text(
              'Log your current weight',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enter your weight and select the unit. This will be saved with the current time.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Weight',
                      hintText: 'e.g., 68.5',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    items: WeightDiary.weightUnits.map((u) => DropdownMenuItem(value: u, child: Text(u.toUpperCase()))).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _unit = v);
                    },
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40.0),
                        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullHistoryGraph(BuildContext context) {
    final user = ref.watch(currentUserDataProvider);
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Icon(
                Icons.timeline,
                size: 18,
                color: Colors.orange[600],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weight over time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: WeightGraphWidget(
            userId: user.id,
            height: 300,
            showTitle: false,
            showAxisLabels: true,
            showTimeFrameSelector: true,
          ),
        ),
      ],
    );
  }


  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                )
              : const Text('Save Weight', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        ),
      ),
    );
  }

  bool _validate() {
    final text = _weightController.text.trim();
    if (text.isEmpty) {
      _showError('Please enter your weight.');
      return false;
    }
    final value = double.tryParse(text);
    if (value == null || value <= 0) {
      _showError('Please enter a valid positive number.');
      return false;
    }
    if (value > 635) { // heavier than world record, likely an error
      _showError('That value seems too high. Please check and try again.');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Handle quest completion for weight diary activity
  Future<void> _handleActivityCompletion({
    VoidCallback? onDismiss,
    VoidCallback? onStreakAnimationShown,
  }) async {
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) return;
      
      final questCompletionService = ref.read(questCompletionServiceProvider);
      final result = await questCompletionService.handleActivityCompletion(
        userId: user.id,
        activityId: 'weight_diary',
        type: TodoType.journal,
        ref: ref,
      );
      
      if (result.questCompleted && mounted) {
        showQuestCompletionDialog(
          context, 
          result,
          onDismiss: onDismiss ?? () {},
          onStreakAnimationShown: onStreakAnimationShown,
        );
      } else if (onDismiss != null) {
        // No quest completed, but we have a callback to execute
        onDismiss();
      }
    } catch (e) {
      print('Error checking quest completion: $e');
      // On error, still execute callback to continue tutorial flow
      if (onDismiss != null) {
        onDismiss();
      }
    }
  }

  /// Update tutorial status and navigate to closing slides (after streak tutorial)
  Future<void> _updateTutorialStatusAndNavigate() async {
    try {
      // Mark that user has logged weight during tutorial
      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
        hasLoggedWeightDuringTutorial: true,
      );
      
      // Navigate to tutorial closing slides after a short delay
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        Navigator.of(context).pop();
        // Navigate to closing slides to complete the tutorial
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.go('/tutorial-closing-slides');
        }
      }
    } catch (e) {
      // Silently fail - this is not critical to weight logging
      debugPrint('Error updating tutorial status: $e');
    }
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final weight = double.parse(_weightController.text.trim());
      final entry = await ref.read(currentWeekWeightDiariesProvider(user.id).notifier).createEntry(
        weight: weight,
        unit: _unit,
      );

      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Weight saved successfully!'), backgroundColor: Colors.green),
        );
        
        // Check if user is in tutorial and hasn't logged weight yet
        if (user.hasSeenJournalTutorial && !user.hasLoggedWeightDuringTutorial) {
          // Check for quest completion with callback for tutorial flow
          await _handleActivityCompletion(
            onDismiss: () async {
              // This callback is called when quest dialog dismisses
              // If no streak animation shows (e.g., not all daily tasks complete yet),
              // we still need to show streak tutorial and proceed with tutorial flow
              
              final currentUser = ref.read(currentUserDataProvider);
              if (mounted && currentUser != null && !currentUser.hasLoggedWeightDuringTutorial) {
                // Show streak explanation tutorial even if streak didn't increment
                if (!currentUser.hasSeenStreakTutorial) {
                  AppTutorialService().showStreakExplanationTutorial(
                    context: context,
                    onFinish: () async {
                      // Mark that user has seen streak tutorial
                      await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
                        hasSeenStreakTutorial: true,
                      );
                      // Then proceed with navigation
                      await _updateTutorialStatusAndNavigate();
                    },
                  );
                } else {
                  // Already saw streak tutorial, just navigate
                  await _updateTutorialStatusAndNavigate();
                }
              }
            },
            onStreakAnimationShown: () async {
              // This callback is triggered after the streak animation completes
              final currentUser = ref.read(currentUserDataProvider);
              if (currentUser != null && !currentUser.hasSeenStreakTutorial && mounted) {
                // Show streak tutorial
                AppTutorialService().showStreakExplanationTutorial(
                  context: context,
                  onFinish: () async {
                    // Mark that user has seen streak tutorial
                    await ref.read(authNotifierProvider.notifier).updateTutorialStatus(
                      hasSeenStreakTutorial: true,
                    );
                    // Then proceed with navigation
                    await _updateTutorialStatusAndNavigate();
                  },
                );
              } else {
                // User already saw streak tutorial, proceed with navigation
                await _updateTutorialStatusAndNavigate();
              }
            },
          );
        } else {
          // Not in tutorial flow, just check for quest completion without navigation
          await _handleActivityCompletion();
          // Clear the form after successful submission
          _weightController.clear();
          // Don't navigate away - let user stay on the weight diary page
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving weight: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}


