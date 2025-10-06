import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/body_image_diary_provider.dart';
import '../../models/body_image_diary.dart';

class BodyImageDiarySurveyScreen extends ConsumerStatefulWidget {
  const BodyImageDiarySurveyScreen({super.key});

  @override
  ConsumerState<BodyImageDiarySurveyScreen> createState() => _BodyImageDiarySurveyScreenState();
}

class _BodyImageDiarySurveyScreenState extends ConsumerState<BodyImageDiarySurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSubmitting = false;

  // Form controllers and values
  String _selectedHowChecked = BodyImageDiary.howCheckedOptions.first;
  final TextEditingController _customHowController = TextEditingController();
  DateTime _selectedTime = DateTime.now();
  String _selectedWhereChecked = BodyImageDiary.whereCheckedOptions.first;
  final TextEditingController _customWhereController = TextEditingController();
  final TextEditingController _contextController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _customHowController.dispose();
    _customWhereController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Image Diary'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentPage + 1} of 4',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${((_currentPage + 1) / 4 * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentPage + 1) / 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.teal[600]!,
                  ),
                ),
              ],
            ),
          ),
          
          // Survey questions
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildHowCheckedQuestion(),
                _buildWhenCheckedQuestion(),
                _buildWhereCheckedQuestion(),
                _buildContextQuestion(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : (_currentPage < 3 ? _nextPage : _submitSurvey),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentPage < 3 ? 'Next' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowCheckedQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How did you check your shape?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the method you used to check your body shape or appearance.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...BodyImageDiary.howCheckedOptions.map((method) {
                    return RadioListTile<String>(
                      title: Text(method),
                      value: method,
                      groupValue: _selectedHowChecked,
                      onChanged: (value) {
                        setState(() {
                          _selectedHowChecked = value!;
                        });
                      },
                      activeColor: Colors.teal[600],
                    );
                  }),
                  if (_selectedHowChecked == 'Other') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customHowController,
                      decoration: const InputDecoration(
                        labelText: 'Please specify how you checked',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhenCheckedQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'When did you check your shape?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the time when you checked your body shape.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal[200]!),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.teal[50],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 64,
                      color: Colors.teal[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Selected Time',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDisplayTime(_selectedTime),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Time'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhereCheckedQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where did you check your shape?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select the location where you checked your body shape.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...BodyImageDiary.whereCheckedOptions.map((location) {
                    return RadioListTile<String>(
                      title: Text(location),
                      value: location,
                      groupValue: _selectedWhereChecked,
                      onChanged: (value) {
                        setState(() {
                          _selectedWhereChecked = value!;
                        });
                      },
                      activeColor: Colors.teal[600],
                    );
                  }),
                  if (_selectedWhereChecked == 'Other') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _customWhereController,
                      decoration: const InputDecoration(
                        labelText: 'Please specify where you checked',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextQuestion() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Context, thoughts, and feelings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Please describe the context around checking your body shape - what you were thinking, how you were feeling, what triggered it, etc.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TextField(
              controller: _contextController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'e.g., I was feeling anxious about how I looked before going out. I noticed my reflection in the mirror and started examining my stomach area. I felt disappointed and kept checking for several minutes...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      // Validate current page before proceeding
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // How checked
        if (_selectedHowChecked == 'Other' && _customHowController.text.trim().isEmpty) {
          _showValidationError('Please specify how you checked your shape.');
          return false;
        }
        break;
      case 2: // Where checked
        if (_selectedWhereChecked == 'Other' && _customWhereController.text.trim().isEmpty) {
          _showValidationError('Please specify where you checked your shape.');
          return false;
        }
        break;
      case 3: // Context
        if (_contextController.text.trim().isEmpty) {
          _showValidationError('Please provide some context about your thoughts and feelings.');
          return false;
        }
        break;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  String _formatDisplayTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submitSurvey() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      final entry = await ref.read(currentWeekBodyImageDiariesProvider(user.id).notifier).createEntry(
        howChecked: _selectedHowChecked,
        customHowChecked: _selectedHowChecked == 'Other' ? _customHowController.text.trim() : null,
        checkTime: _selectedTime,
        whereChecked: _selectedWhereChecked,
        customWhereChecked: _selectedWhereChecked == 'Other' ? _customWhereController.text.trim() : null,
        contextAndFeelings: _contextController.text.trim(),
      );

      if (entry != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Body image diary entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back to the journal tab after successful submission
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
