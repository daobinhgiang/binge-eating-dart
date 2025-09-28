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
      appBar: AppBar(
        title: Text(widget.assessment.title),
        backgroundColor: Colors.blue[50],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.assessment.questions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 16),
            
            // Question counter
            Text(
              'Question ${_currentQuestionIndex + 1} of ${widget.assessment.questions.length}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Question text
            Text(
              currentQuestion.questionText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Question type specific input
            _buildQuestionInput(currentQuestion),
            
            const Spacer(),
            
            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _goToPreviousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                
                ElevatedButton(
                  onPressed: _canProceed() ? _goToNextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isLastQuestion ? 'Submit' : 'Next'),
                ),
              ],
            ),
          ],
        ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Slider(
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
        Text(
          'Selected: ${intValue ?? (question.minValue ?? 0)}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceInput(AssessmentQuestion question) {
    return Column(
      children: question.options!.map((option) {
        final isSelected = _responses[question.id] == option;
        return RadioListTile<String>(
          title: Text(option),
          value: option,
          groupValue: _responses[question.id],
          onChanged: (value) {
            setState(() {
              _responses[question.id] = value!;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildYesNoInput(AssessmentQuestion question) {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Yes'),
            value: 'Yes',
            groupValue: _responses[question.id],
            onChanged: (value) {
              setState(() {
                _responses[question.id] = value!;
              });
            },
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('No'),
            value: 'No',
            groupValue: _responses[question.id],
            onChanged: (value) {
              setState(() {
                _responses[question.id] = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(AssessmentQuestion question) {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your response...',
      ),
      maxLines: 3,
      onChanged: (value) {
        setState(() {
          _responses[question.id] = value;
        });
      },
      controller: TextEditingController(text: _responses[question.id] ?? ''),
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
