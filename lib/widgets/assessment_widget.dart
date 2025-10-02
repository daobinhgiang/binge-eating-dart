import 'package:flutter/material.dart';
import '../models/assessment.dart';
import '../models/assessment_question.dart';
import '../models/assessment_response.dart';
import '../core/services/assessment_service.dart';

class AssessmentWidget extends StatefulWidget {
  final Assessment assessment;
  final VoidCallback? onCompleted;

  const AssessmentWidget({
    super.key,
    required this.assessment,
    this.onCompleted,
  });

  @override
  State<AssessmentWidget> createState() => _AssessmentWidgetState();
}

class _AssessmentWidgetState extends State<AssessmentWidget> {
  final AssessmentService _assessmentService = AssessmentService();
  final Map<String, String> _responses = {};
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;

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

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Assessment completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onCompleted?.call();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save assessment. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
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
}

