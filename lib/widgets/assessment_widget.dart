import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../models/assessment_question.dart';
import '../models/assessment_response.dart';
import '../core/services/assessment_service.dart';
import '../core/services/exp_service.dart';
import '../providers/exp_provider.dart';
import '../models/quiz_submission.dart';
import '../models/exp_ledger.dart';
import './level_up_dialog.dart';

class AssessmentWidget extends ConsumerStatefulWidget {
  final Assessment assessment;
  final VoidCallback? onCompleted;

  const AssessmentWidget({
    super.key,
    required this.assessment,
    this.onCompleted,
  });

  @override
  ConsumerState<AssessmentWidget> createState() => _AssessmentWidgetState();
}

class _AssessmentWidgetState extends ConsumerState<AssessmentWidget> {
  final AssessmentService _assessmentService = AssessmentService();
  final ExpService _expService = ExpService();
  final Map<String, String> _responses = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  
  // Track if this is a quiz (for EXP system)
  bool get _isQuiz => widget.assessment.lessonId.startsWith('quiz_');

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.assessment.questions[_currentQuestionIndex];
    final isLastQuestion = _currentQuestionIndex == widget.assessment.questions.length - 1;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(context),
            
            // Content Section
            Expanded(
              child: _buildContent(context, currentQuestion),
            ),
            
            // Footer Section
            _buildFooter(context, isLastQuestion),
          ],
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
      child: Column(
        children: [
          // Top row with back button and assessment title
          Row(
            children: [
              // Back button
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
              
              // Assessment title
              Expanded(
                child: Text(
                  widget.assessment.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress indicator
          Row(
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1} of ${widget.assessment.questions.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / widget.assessment.questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            minHeight: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AssessmentQuestion currentQuestion) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Text(
              currentQuestion.questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.4,
                fontFamily: 'SF Pro Text',
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Question type specific input
            _buildQuestionInput(currentQuestion),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLastQuestion) {
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
      child: Row(
        children: [
          // Previous button
          if (_currentQuestionIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousQuestion,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Previous',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          
          if (_currentQuestionIndex > 0) const SizedBox(width: 16),
          
          // Next/Submit button
          Expanded(
            child: ElevatedButton(
              onPressed: _canProceed() ? _goToNextQuestion : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isLastQuestion ? 'Submit Assessment' : 'Next',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionInput(AssessmentQuestion question) {
    switch (question.questionType) {
      case 'scale':
        return _buildScaleInput(question);
      case 'multiple_choice':
        return _buildMultipleChoiceInput(question);
      case 'yes_no':
        return _buildYesNoInput(question);
      case 'text':
        return _buildTextInput(question);
      default:
        return const Text('Unsupported question type');
    }
  }

  Widget _buildScaleInput(AssessmentQuestion question) {
    final currentValue = _responses[question.id];
    final intValue = currentValue != null ? int.tryParse(currentValue) : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (question.scaleLabel != null) ...[
          Text(
            question.scaleLabel!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontFamily: 'SF Pro Text',
            ),
          ),
          const SizedBox(height: 20),
        ],
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Theme.of(context).primaryColor,
                  inactiveTrackColor: Colors.grey[300],
                  thumbColor: Theme.of(context).primaryColor,
                  overlayColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  trackHeight: 6,
                ),
                child: Slider(
                  value: intValue?.toDouble() ?? (question.minValue ?? 0).toDouble(),
                  min: (question.minValue ?? 0).toDouble(),
                  max: (question.maxValue ?? 6).toDouble(),
                  divisions: (question.maxValue ?? 6) - (question.minValue ?? 0),
                  onChanged: (value) {
                    setState(() {
                      _responses[question.id] = value.round().toString();
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selected: ${intValue ?? (question.minValue ?? 0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'SF Pro Text',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceInput(AssessmentQuestion question) {
    return Column(
      children: question.options!.map((option) {
        final isSelected = _responses[question.id] == option;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: RadioListTile<String>(
            title: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
            value: option,
            groupValue: _responses[question.id],
            activeColor: Theme.of(context).primaryColor,
            onChanged: (value) {
              setState(() {
                _responses[question.id] = value!;
              });
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildYesNoInput(AssessmentQuestion question) {
    return Row(
      children: [
        Expanded(
          child: _buildYesNoOption(question, 'Yes'),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildYesNoOption(question, 'No'),
        ),
      ],
    );
  }

  Widget _buildYesNoOption(AssessmentQuestion question, String option) {
    final isSelected = _responses[question.id] == option;
    return GestureDetector(
      onTap: () {
        setState(() {
          _responses[question.id] = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                fontFamily: 'SF Pro Text',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInput(AssessmentQuestion question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter your response...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontFamily: 'SF Pro Text',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontFamily: 'SF Pro Text',
        ),
        maxLines: 4,
        onChanged: (value) {
          setState(() {
            _responses[question.id] = value;
          });
        },
        controller: TextEditingController(text: _responses[question.id] ?? ''),
      ),
    );
  }

  bool _canProceed() {
    final currentQuestion = widget.assessment.questions[_currentQuestionIndex];
    if (!currentQuestion.isRequired) return true;
    return _responses.containsKey(currentQuestion.id) && 
           _responses[currentQuestion.id]!.isNotEmpty;
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < widget.assessment.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitAssessment();
    }
  }

  Future<void> _submitAssessment() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert responses to AssessmentResponse objects
      final responses = _responses.entries.map((entry) {
        final question = widget.assessment.questions.firstWhere(
          (q) => q.id == entry.key,
        );
        return AssessmentResponse(
          id: '${entry.key}_${DateTime.now().millisecondsSinceEpoch}',
          questionId: entry.key,
          responseValue: entry.value,
          responseType: question.questionType,
          answeredAt: DateTime.now(),
        );
      }).toList();

      // Save to Firestore
      final success = await _assessmentService.saveAssessmentResponses(
        widget.assessment.lessonId,
        responses,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save assessment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // If this is a quiz, submit for EXP validation
      if (_isQuiz) {
        await _submitQuizForExp();
      } else {
        // For non-quiz assessments, just show success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onCompleted?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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

  Future<void> _submitQuizForExp() async {
    // Convert answers to the format expected by EXP service
    // Multiple choice answers need to be converted to option indices
    final Map<String, int> quizAnswers = {};
    
    for (final entry in _responses.entries) {
      final question = widget.assessment.questions.firstWhere(
        (q) => q.id == entry.key,
      );
      
      if (question.questionType == 'multiple_choice') {
        // Find the index of the selected option
        final selectedOption = entry.value;
        final optionIndex = question.options?.indexOf(selectedOption) ?? -1;
        
        if (optionIndex != -1) {
          quizAnswers[entry.key] = optionIndex;
        }
      }
    }

    if (quizAnswers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid quiz answers to submit'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Get user's current level before submission
    final userExpBefore = ref.read(userExpProvider);
    final oldLevel = userExpBefore?.level ?? 1;
    final oldExp = userExpBefore?.exp ?? 0;

    // Submit quiz for validation
    final submissionRef = await _expService.submitQuizForValidation(
      widget.assessment.lessonId,
      quizAnswers,
    );

    if (submissionRef == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz already completed or submission failed'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onCompleted?.call();
      }
      return;
    }

    // Show loading dialog while waiting for validation
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('quiz submission in progress...'),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Listen for validation result
    final subscription = _expService.listenToSubmissionResult(submissionRef.id).listen(
      (submission) async {
        if (submission.status == SubmissionStatus.validated && mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          // Get updated user data
          final userExpAfter = ref.read(userExpProvider);
          final newLevel = userExpAfter?.level ?? oldLevel;
          final newExp = userExpAfter?.exp ?? oldExp;

          // Show success message with EXP earned
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quiz complete! +${submission.expAwarded} EXP earned!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Check if user leveled up
          if (newLevel > oldLevel) {
            await Future.delayed(const Duration(milliseconds: 500));
            
            if (mounted) {
              await showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => LevelUpDialog(
                  oldLevel: oldLevel,
                  newLevel: newLevel,
                  expEarned: submission.expAwarded ?? 0,
                  totalExp: newExp,
                ),
              );
            }
          }

          widget.onCompleted?.call();
        } else if (submission.status == SubmissionStatus.failed && mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quiz validation failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );

          widget.onCompleted?.call();
        }
      },
      onError: (error) {
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error validating quiz: $error'),
              backgroundColor: Colors.red,
            ),
          );

          widget.onCompleted?.call();
        }
      },
    );

    // Cancel subscription after 30 seconds timeout
    Future.delayed(const Duration(seconds: 30), () {
      subscription.cancel();
      if (mounted && _isSubmitting) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz validation timed out. Please check your progress later.'),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onCompleted?.call();
      }
    });
  }
}

