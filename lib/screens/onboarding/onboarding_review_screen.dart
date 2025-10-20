import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/onboarding_answer.dart';
import '../../models/onboarding_data.dart';
import '../../core/services/onboarding_service.dart';
import '../../providers/auth_provider.dart';

class OnboardingReviewScreen extends ConsumerStatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  ConsumerState<OnboardingReviewScreen> createState() => _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState extends ConsumerState<OnboardingReviewScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isLoading = false;
  List<OnboardingAnswer> _answers = [];

  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      number: 1,
      question: "How often do you binge?",
      options: [
        "Rarely or never",
        "Once or twice a month",
        "Several times a week",
        "Daily or multiple times a day",
      ],
    ),
    OnboardingQuestion(
      number: 2,
      question: "Have the binges gotten more intense?",
      options: [
        "No, they've stayed the same",
        "Slightly more intense",
        "Moderately more intense",
        "Much more intense",
      ],
    ),
    OnboardingQuestion(
      number: 3,
      question: "When did you start binging?",
      options: [
        "Within the past few months",
        "Within the past year",
        "1-5 years ago",
        "More than 5 years ago",
      ],
    ),
    OnboardingQuestion(
      number: 4,
      question: "Do you find it difficult to cope with urges to binge?",
      options: [
        "I can usually cope with the urges",
        "Sometimes I struggle but can manage",
        "I find it very difficult most of the time",
        "I feel completely overwhelmed by the urges",
      ],
    ),
    OnboardingQuestion(
      number: 5,
      question: "When you binge, what emotions are involved?",
      options: [
        "Primarily emotional pain",
        "Physical discomfort",
        "Stress",
        "Boredom or a mix of several emotions",
      ],
    ),
    OnboardingQuestion(
      number: 6,
      question: "Why do you want to overcome binge eating?",
      options: [
        "To improve my physical health",
        "To improve my mental well-being",
        "To feel more in control of my life",
        "All of the above",
      ],
    ),
    OnboardingQuestion(
      number: 7,
      question: "What are your top 1–2 goals related to your eating habits?",
      options: [
        "Reduce frequency of binges",
        "Develop healthier coping mechanisms",
        "Improve relationship with food",
        "Build consistent eating patterns",
      ],
    ),
    OnboardingQuestion(
      number: 8,
      question: "What would success look like for you in the next 30 days?",
      options: [
        "Fewer binge episodes",
        "Better emotional regulation",
        "More mindful eating",
        "Increased self-compassion",
      ],
    ),
    OnboardingQuestion(
      number: 9,
      question: "On a scale of 1–10, how motivated do you feel to make changes right now?",
      options: [
        "1-3 (Low motivation)",
        "4-6 (Moderate motivation)",
        "7-8 (High motivation)",
        "9-10 (Very high motivation)",
      ],
    ),
    OnboardingQuestion(
      number: 10,
      question: "What's your daily goal for time spent on your recovery with the app?",
      options: [
        "5 minutes per day",
        "10 minutes per day",
        "15 minutes per day",
        "20 minutes per day",
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    try {
      final data = await _onboardingService.getOnboardingData(user.id);
      if (data != null) {
        setState(() {
          _answers = List.from(data.answers);
          _loadCurrentQuestionAnswer();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading existing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadCurrentQuestionAnswer() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final existingAnswer = _answers.firstWhere(
      (answer) => answer.questionNumber == currentQuestion.number,
      orElse: () => OnboardingAnswer(
        questionNumber: currentQuestion.number,
        question: currentQuestion.question,
        selectedOption: 0,
        selectedText: '',
        answeredAt: DateTime.now(),
      ),
    );
    
    setState(() {
      _selectedOption = existingAnswer.selectedOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        foregroundColor: Colors.white,
        title: const Text(
          'Review Assessment',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Question content
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question label
                      Text(
                        _getQuestionLabel(currentQuestion.number),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Question text
                      Text(
                        currentQuestion.question,
                        style: const TextStyle(
                          color: Color(0xFF1C1C1E),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Options
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQuestion.options.length,
                          itemBuilder: (context, index) {
                            final isSelected = _selectedOption == index;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedOption = index;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isSelected 
                                            ? const Color(0xFF007AFF)
                                            : Colors.grey[300]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                      color: isSelected 
                                          ? const Color(0xFF007AFF).withOpacity(0.1)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: isSelected 
                                                ? const Color(0xFF007AFF)
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            currentQuestion.options[index],
                                            style: TextStyle(
                                              color: isSelected 
                                                  ? const Color(0xFF1C1C1E)
                                                  : Colors.grey[700],
                                              fontSize: 16,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Navigation buttons
                      Row(
                        children: [
                          if (_currentQuestionIndex > 0)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _previousQuestion,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                                child: const Text('Previous'),
                              ),
                            ),
                          if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _selectedOption != null && !_isLoading
                                  ? _nextQuestion
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007AFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _currentQuestionIndex == _questions.length - 1
                                          ? 'Save Changes'
                                          : 'Next',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getQuestionLabel(int questionNumber) {
    switch (questionNumber) {
      case 1:
        return 'Binge frequency';
      case 2:
        return 'Binge intensity';
      case 3:
        return 'Binge history';
      case 4:
        return 'Coping with urges';
      case 5:
        return 'Emotions involved';
      case 6:
        return 'Motivation for change';
      case 7:
        return 'Personal goals';
      case 8:
        return 'Success vision';
      case 9:
        return 'Motivation level';
      case 10:
        return 'Daily goal';
      default:
        return 'Question';
    }
  }

  void _nextQuestion() async {
    if (_selectedOption == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Update or create answer
      final answer = OnboardingAnswer(
        questionNumber: _questions[_currentQuestionIndex].number,
        question: _questions[_currentQuestionIndex].question,
        selectedOption: _selectedOption!,
        selectedText: _questions[_currentQuestionIndex].options[_selectedOption!],
        answeredAt: DateTime.now(),
      );

      // Update existing answer or add new one
      final existingIndex = _answers.indexWhere(
        (a) => a.questionNumber == answer.questionNumber,
      );
      
      if (existingIndex != -1) {
        _answers[existingIndex] = answer;
      } else {
        _answers.add(answer);
      }

      // Save to Firestore
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        await _onboardingService.saveAnswer(user.id, answer);
      }

      if (_currentQuestionIndex == _questions.length - 1) {
        // Complete review
        await _completeReview();
      } else {
        // Move to next question
        setState(() {
          _currentQuestionIndex++;
          _loadCurrentQuestionAnswer();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving answer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _loadCurrentQuestionAnswer();
      });
    }
  }

  Future<void> _completeReview() async {
    try {
      final user = ref.read(authNotifierProvider).value;
      if (user == null) return;

      // Calculate total score
      final totalScore = _answers.fold(0, (total, answer) => total + answer.selectedOption);

      // Create updated onboarding data
      final onboardingData = OnboardingData(
        userId: user.id,
        answers: _answers,
        completedAt: DateTime.now(),
        totalScore: totalScore,
      );

      // Save updated onboarding data
      await _onboardingService.saveOnboardingData(onboardingData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assessment updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating assessment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Review'),
        content: const Text(
          'Are you sure you want to exit? Your changes will be saved up to this point.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/profile');
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class OnboardingQuestion {
  final int number;
  final String question;
  final List<String> options;

  OnboardingQuestion({
    required this.number,
    required this.question,
    required this.options,
  });
}
