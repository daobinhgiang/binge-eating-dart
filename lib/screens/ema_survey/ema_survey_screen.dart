import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/ema_survey.dart';
import '../../providers/ema_survey_provider.dart';
import '../../providers/auth_provider.dart';
import '../urge_event/urge_event_form_screen.dart';

class EMASurveyScreen extends ConsumerStatefulWidget {
  final String? surveyId;
  final bool isResuming;

  const EMASurveyScreen({
    super.key,
    this.surveyId,
    this.isResuming = false,
  });

  @override
  ConsumerState<EMASurveyScreen> createState() => _EMASurveyScreenState();
}

class _EMASurveyScreenState extends ConsumerState<EMASurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final Map<String, dynamic> _answers = {};
  bool _isSaving = false;

  // Question definitions
  final List<EMAQuestion> _questions = [
    EMAQuestion(
      id: EMAQuestionId.location,
      text: "Where are you right now?",
      type: EMAQuestionType.singleChoice,
      options: [
        "Home",
        "Work/School",
        "In transit",
        "Restaurant/Store",
        "Outdoors",
        "Other"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.companions,
      text: "Who are you with? (check all that apply)",
      type: EMAQuestionType.multipleChoice,
      options: [
        "Alone",
        "Partner",
        "Family",
        "Friends",
        "Coworkers/Peers",
        "Strangers",
        "Other"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.ateSinceLastPrompt,
      text: "Since the last prompt, did you eat?",
      type: EMAQuestionType.singleChoice,
      options: ["Yes", "No"],
    ),
    EMAQuestion(
      id: EMAQuestionId.eatingContext,
      text: "Eating context?",
      type: EMAQuestionType.singleChoice,
      options: [
        "Meal",
        "Snack",
        "Grazing",
        "Take-out",
        "Restaurant",
        "Social eating"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.hungerBefore,
      text: "How hungry were you before eating?",
      type: EMAQuestionType.slider,
      minValue: 0,
      maxValue: 100,
      hintText: "0 = not at all, 100 = extremely",
    ),
    EMAQuestion(
      id: EMAQuestionId.fullnessAfter,
      text: "How full were you after eating?",
      type: EMAQuestionType.slider,
      minValue: 0,
      maxValue: 100,
      hintText: "0 = not at all, 100 = extremely",
    ),
    EMAQuestion(
      id: EMAQuestionId.urgeToBinge,
      text: "Current urge to binge",
      type: EMAQuestionType.slider,
      minValue: 0,
      maxValue: 100,
      hintText: "0 = none, 100 = extreme",
    ),
    EMAQuestion(
      id: EMAQuestionId.emotions,
      text: "Emotions right now (rate each 0-100)",
      type: EMAQuestionType.multiSlider,
      minValue: 0,
      maxValue: 100,
      hintText: "Select all the emotions you're experiencing and rate each one 0-100",
      options: [
        "Sad",
        "Anxious", 
        "Stressed",
        "Ashamed",
        "Angry",
        "Lonely",
        "Positive",
        "Calm"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.bodyThoughts,
      text: "Body/shape thoughts (rate each 0-100)",
      type: EMAQuestionType.multiSlider,
      minValue: 0,
      maxValue: 100,
      hintText: "Select all the thoughts you're having and rate each one 0-100",
      options: [
        "I feel dissatisfied with my body",
        "I feel fat",
        "I'm preoccupied with weight/shape"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.eatingThoughts,
      text: "Eating-related thoughts (rate each 0-100)",
      type: EMAQuestionType.multiSlider,
      minValue: 0,
      maxValue: 100,
      hintText: "Select all the thoughts you're having and rate each one 0-100",
      options: [
        "I must restrict later",
        "I've already blown it today",
        "I can't control eating"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.triggers,
      text: "Triggers in the last hour? (check all that apply)",
      type: EMAQuestionType.multipleChoice,
      options: [
        "Skipped/Delayed eating",
        "Conflict",
        "Criticism",
        "Work/School stress",
        "Boredom",
        "Exposure to tempting foods",
        "Alcohol",
        "Being alone",
        "Tired/poor sleep",
        "Other"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.coping,
      text: "Coping used in the last hour? (check all that apply)",
      type: EMAQuestionType.multipleChoice,
      options: [
        "Urge surfing",
        "Opposite action",
        "Mindful grounding",
        "Reaching out to someone",
        "Distraction (activity)",
        "Ate a planned meal/snack",
        "Left cue situation",
        "Other"
      ],
    ),
    EMAQuestion(
      id: EMAQuestionId.copingHelpfulness,
      text: "Helpfulness of coping",
      type: EMAQuestionType.slider,
      minValue: 0,
      maxValue: 100,
      hintText: "0 = not helpful, 100 = very helpful",
    ),
    EMAQuestion(
      id: EMAQuestionId.confidence,
      text: "Confidence to avoid binge next few hours",
      type: EMAQuestionType.slider,
      minValue: 0,
      maxValue: 100,
      hintText: "0 = not confident, 100 = very confident",
    ),
    EMAQuestion(
      id: EMAQuestionId.bingedSinceLastPrompt,
      text: "Since last prompt, did you binge?",
      type: EMAQuestionType.singleChoice,
      options: ["Yes", "No"],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingAnswers();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadExistingAnswers() {
    final survey = ref.read(currentSurveyProvider);
    if (survey != null) {
      for (final answer in survey.answers) {
        _answers[answer.questionId] = answer.answer;
      }
    }
  }

  void _saveAnswer(String questionId, dynamic answer) {
    setState(() {
      _answers[questionId] = answer;
    });
  }

  Future<void> _saveToFirebase() async {
    if (_isSaving) return;
    
    setState(() {
      _isSaving = true;
    });

    try {
      final survey = ref.read(currentSurveyProvider);
      if (survey == null) return;

      final userId = ref.read(currentUserDataProvider)?.id;
      if (userId == null) return;

      // Save each answer
      for (final entry in _answers.entries) {
        final question = _questions.firstWhere(
          (q) => q.id.name == entry.key,
          orElse: () => throw Exception('Question not found: ${entry.key}'),
        );

        final answer = EMASurveyAnswer(
          questionId: entry.key,
          questionText: question.text,
          answer: entry.value,
          answerType: question.type.name,
          answeredAt: DateTime.now(),
        );

        await ref.read(emaSurveyNotifierProvider.notifier)
            .saveAnswer(survey.id, answer);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _nextPage() {
    // Check if current question is urge to binge and value is >= 50
    final currentQuestion = _questions[_currentPage];
    if (currentQuestion.id == EMAQuestionId.urgeToBinge) {
      final urgeLevel = _answers[EMAQuestionId.urgeToBinge.name] as num?;
      if (urgeLevel != null && urgeLevel >= 50) {
        _showUrgeEventDialog();
        return; // Don't proceed to next page yet
      }
    }
    
    if (_currentPage < _questions.length - 1) {
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

  void _completeSurvey() async {
    await _saveToFirebase();
    
    final survey = ref.read(currentSurveyProvider);
    if (survey != null) {
      await ref.read(emaSurveyNotifierProvider.notifier)
          .completeSurvey(survey.id);
    }

    if (mounted) {
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('EMA Survey completed successfully!')),
      );
      context.go('/journal');
    }
  }

  void _exitSurvey() async {
    await _saveToFirebase();
    
    if (mounted) {
      context.go('/journal');
    }
  }

  void _showUrgeEventDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log an URGE event?'),
          content: const Text(
            'You indicated a high urge to binge (≥50). Would you like to log this as an URGE event?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _proceedToNextPage(); // Continue to next question
              },
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _openUrgeForm();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _proceedToNextPage() {
    if (_currentPage < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openUrgeForm() {
    // Get the current urge level from the answers
    final urgeLevel = _answers[EMAQuestionId.urgeToBinge.name] as num?;
    final currentUrgeLevel = urgeLevel?.toInt() ?? 50;
    
    // Navigate to URGE form
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UrgeEventFormScreen(
          initialUrgeLevel: currentUrgeLevel,
          returnRoute: null, // Will return to current survey
        ),
      ),
    ).then((_) {
      // After returning from URGE form, proceed to next page
      _proceedToNextPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final survey = ref.watch(currentSurveyProvider);
    final isLoading = ref.watch(isSurveyLoadingProvider);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (survey == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('EMA Survey')),
        body: const Center(
          child: Text('No survey found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('EMA Survey'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _exitSurvey,
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / _questions.length,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentPage + 1} of ${_questions.length}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          
          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(_questions[index]);
              },
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _previousPage,
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                
                if (_currentPage < _questions.length - 1)
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: _completeSurvey,
                    child: const Text('Complete Survey'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(EMAQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (question.hintText != null) ...[
            const SizedBox(height: 8),
            Text(
              question.hintText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 24),
          
          _buildQuestionWidget(question),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(EMAQuestion question) {
    switch (question.type) {
      case EMAQuestionType.singleChoice:
        return _buildSingleChoiceWidget(question);
      case EMAQuestionType.multipleChoice:
        return _buildMultipleChoiceWidget(question);
      case EMAQuestionType.slider:
        return _buildSliderWidget(question);
      case EMAQuestionType.multiSlider:
        return _buildMultiSliderWidget(question);
      case EMAQuestionType.text:
        return _buildTextWidget(question);
    }
  }

  Widget _buildSingleChoiceWidget(EMAQuestion question) {
    final currentAnswer = _answers[question.id.name] as String?;
    
    return RadioGroup<String>(
      groupValue: currentAnswer,
      onChanged: (value) {
        if (value != null) {
          _saveAnswer(question.id.name, value);
        }
      },
      child: Column(
        children: question.options!.map((option) {
          return RadioListTile<String>(
            title: Text(option),
            value: option,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMultipleChoiceWidget(EMAQuestion question) {
    final rawAnswers = _answers[question.id.name];
    final currentAnswers = rawAnswers is List
        ? rawAnswers.cast<String>()
        : <String>[];
    
    return Column(
      children: question.options!.map((option) {
        final isSelected = currentAnswers.contains(option);
        return CheckboxListTile(
          title: Text(option),
          value: isSelected,
          onChanged: (value) {
            final newAnswers = List<String>.from(currentAnswers);
            if (value == true) {
              newAnswers.add(option);
            } else {
              newAnswers.remove(option);
            }
            _saveAnswer(question.id.name, newAnswers);
          },
        );
      }).toList(),
    );
  }

  Widget _buildSliderWidget(EMAQuestion question) {
    final rawValue = _answers[question.id.name];
    final currentValue = rawValue is num 
        ? rawValue.toDouble()
        : (question.minValue ?? 0).toDouble();
    
    return Column(
      children: [
        Text(
          '${currentValue.round()}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Slider(
          value: currentValue,
          min: (question.minValue ?? 0).toDouble(),
          max: (question.maxValue ?? 100).toDouble(),
          divisions: (question.maxValue ?? 100) - (question.minValue ?? 0),
          onChanged: (value) {
            _saveAnswer(question.id.name, value);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${question.minValue ?? 0}'),
            Text('${question.maxValue ?? 100}'),
          ],
        ),
      ],
    );
  }

  Widget _buildTextWidget(EMAQuestion question) {
    final currentAnswer = _answers[question.id.name] as String? ?? '';
    
    return TextField(
      onChanged: (value) {
        _saveAnswer(question.id.name, value);
      },
      controller: TextEditingController(text: currentAnswer),
      maxLines: 5,
      decoration: const InputDecoration(
        hintText: 'Enter your response...',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMultiSliderWidget(EMAQuestion question) {
    final rawAnswers = _answers[question.id.name];
    final currentAnswers = rawAnswers is Map<String, dynamic>
        ? Map<String, dynamic>.from(rawAnswers)
        : <String, dynamic>{};
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can select multiple options and rate each one 0-100',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Checkboxes for options
          ...question.options!.map((option) {
            final isSelected = currentAnswers.containsKey(option);
            final currentValue = currentAnswers[option] as num? ?? 0.0;
            
            return Column(
              children: [
                CheckboxListTile(
                  title: Text(option),
                  value: isSelected,
                  onChanged: (value) {
                    final newAnswers = Map<String, dynamic>.from(currentAnswers);
                    if (value == true) {
                      newAnswers[option] = 0.0; // Default value
                    } else {
                      newAnswers.remove(option);
                    }
                    _saveAnswer(question.id.name, newAnswers);
                  },
                ),
                
                // Show slider only if option is selected
                if (isSelected) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                    child: Column(
                      children: [
                        Text(
                          '${currentValue.round()}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: currentValue.toDouble(),
                          min: (question.minValue ?? 0).toDouble(),
                          max: (question.maxValue ?? 100).toDouble(),
                          divisions: (question.maxValue ?? 100) - (question.minValue ?? 0),
                          onChanged: (value) {
                            final newAnswers = Map<String, dynamic>.from(currentAnswers);
                            newAnswers[option] = value;
                            _saveAnswer(question.id.name, newAnswers);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${question.minValue ?? 0}'),
                            Text('${question.maxValue ?? 100}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }).toList(),
      ],
    );
  }
}
