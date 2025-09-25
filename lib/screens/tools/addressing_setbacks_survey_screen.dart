import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/addressing_setbacks_provider.dart';
import '../../models/addressing_setbacks.dart';

class AddressingSetbacksSurveyScreen extends ConsumerStatefulWidget {
  final AddressingSetbacks? existingExercise;

  const AddressingSetbacksSurveyScreen({super.key, this.existingExercise});

  @override
  ConsumerState<AddressingSetbacksSurveyScreen> createState() => _AddressingSetbacksSurveyScreenState();
}

class _AddressingSetbacksSurveyScreenState extends ConsumerState<AddressingSetbacksSurveyScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _problemCauseController = TextEditingController();
  final _triggerController = TextEditingController();
  final _addressPlanController = TextEditingController();
  
  DateTime _setbackDate = DateTime.now();
  int _currentPage = 0;
  bool _isSubmitting = false;
  
  final int _totalPages = 3;

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      _problemCauseController.text = widget.existingExercise!.problemCause;
      _triggerController.text = widget.existingExercise!.trigger;
      _addressPlanController.text = widget.existingExercise!.addressPlan;
      _setbackDate = widget.existingExercise!.setbackDate;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _problemCauseController.dispose();
    _triggerController.dispose();
    _addressPlanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingExercise != null ? 'Edit Setback Log' : 'New Setback Log'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (_currentPage == _totalPages - 1)
            TextButton(
              onPressed: _isSubmitting ? null : _submitSurvey,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
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
                        'Step ${_currentPage + 1} of $_totalPages',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${((_currentPage + 1) / _totalPages * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentPage + 1) / _totalPages,
                    backgroundColor: Colors.red[100],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
                  ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildSetbackDetailsPage(),
                  _buildProblemCausePage(),
                  _buildTriggerAndPlanPage(),
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
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentPage == _totalPages - 1 ? _submitSurvey : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_currentPage == _totalPages - 1 ? 'Save Log' : 'Next'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetbackDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(
            'When did the setback occur?',
            'Record the date when your binge eating returned or became more frequent.',
            Icons.calendar_today,
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setback Date',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: _selectDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.red[600]),
                          const SizedBox(width: 12),
                          Text(
                            _formatDisplayDate(_setbackDate),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change date',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildInfoBox(
            'Remember: Setbacks are part of recovery. The important thing is to learn from them and move forward.',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildProblemCausePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(
            'What do you believe to be the problem causing this?',
            'If your binge eating has returned or become more frequent, what underlying issue do you think led to this setback?',
            Icons.help_outline,
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Problem Analysis',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _problemCauseController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Think about what might have changed in your life, mindset, or circumstances that could have contributed to this setback...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe what you believe caused the problem';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildInfoBox(
            'Consider factors like: stress levels, life changes, relationship issues, work pressure, neglecting self-care, or stopping techniques that were working.',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerAndPlanPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(
            'What triggered the setback and how will you address it?',
            'Identify the specific trigger and create a plan to handle it better in the future.',
            Icons.psychology,
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trigger Identification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _triggerController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'What specific event, feeling, or situation triggered the setback?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please identify the trigger';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Action Plan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressPlanController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'How will you address this trigger in the future? What strategies will you use?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please describe how you will address this trigger';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildInfoBox(
            'Create specific, actionable steps. Consider: coping strategies, support systems, environmental changes, or professional help.',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(String question, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red[600]!, Colors.red[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: color[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplayDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                   'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _setbackDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red[600],
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        _setbackDate = selectedDate;
      });
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _submitSurvey() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(currentUserDataProvider);
      if (user == null) {
        throw 'User not found';
      }

      if (widget.existingExercise != null) {
        // Update existing exercise
        await ref.read(userAddressingSetbacksExercisesProvider(user.id).notifier).updateExercise(
          exerciseId: widget.existingExercise!.id,
          problemCause: _problemCauseController.text.trim(),
          trigger: _triggerController.text.trim(),
          addressPlan: _addressPlanController.text.trim(),
          setbackDate: _setbackDate,
        );
      } else {
        // Create new exercise
        await ref.read(userAddressingSetbacksExercisesProvider(user.id).notifier).createExercise(
          problemCause: _problemCauseController.text.trim(),
          trigger: _triggerController.text.trim(),
          addressPlan: _addressPlanController.text.trim(),
          setbackDate: _setbackDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Setback log ${widget.existingExercise != null ? 'updated' : 'created'} successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving setback log: $e'),
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

