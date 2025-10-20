import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/onboarding_answer.dart';
import '../../models/onboarding_data.dart';
import '../../core/services/onboarding_service.dart';
// AI-based recommendation service removed
import '../../providers/auth_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final OnboardingService _onboardingService = OnboardingService();
  int _currentQuestionIndex = 0;
  int? _selectedOption;
  bool _isLoading = false;
  bool _showProgressScreen = false;
  bool _showSetupRoutineScreen = false;
  bool _showStartJourneyScreen = false;
  int _dailyGoalMinutes = 0;

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

  final List<OnboardingAnswer> _answers = [];

  @override
  Widget build(BuildContext context) {
    // Show setup routine screen before question 10
    if (_showSetupRoutineScreen) {
      return _buildSetupRoutineScreen();
    }

    // Show progress screen right after question 10
    if (_showProgressScreen) {
      return _buildProgressScreen();
    }

    // Show start journey screen after progress celebration
    if (_showStartJourneyScreen) {
      return _buildStartJourneyScreen();
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Simple header
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (_currentQuestionIndex > 0)
                        IconButton(
                          onPressed: _previousQuestion,
                          icon: const Icon(Icons.arrow_back, size: 24),
                          color: Colors.grey[700],
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
            
            // Question content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question text
                    Text(
                      currentQuestion.question,
                      style: TextStyle(
                        color: Colors.grey[900],
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                    
                    const SizedBox(height: 28),
                      
                    // Options
                    Expanded(
                      child: ListView.builder(
                        itemCount: currentQuestion.options.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedOption == index;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
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
                                  color: isSelected 
                                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                                      : Colors.grey[50],
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF4CAF50)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    // Radio button
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected 
                                              ? const Color(0xFF4CAF50)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        color: isSelected 
                                            ? const Color(0xFF4CAF50)
                                            : Colors.white,
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        currentQuestion.options[index],
                                        style: TextStyle(
                                          color: Colors.grey[800],
                                          fontSize: 15,
                                          fontWeight: isSelected 
                                              ? FontWeight.w600 
                                              : FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                      
                    const SizedBox(height: 24),
                    
                    // Navigation buttons - all questions are required, no skip option
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedOption != null && !_isLoading
                            ? (_currentQuestionIndex == 8 
                                ? _showSetupRoutine
                                : _currentQuestionIndex == _questions.length - 1 
                                    ? _handleLastQuestion 
                                    : _nextQuestion)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
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
                                    ? 'Continue'
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
              ),
            ),
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

  Widget _buildSetupRoutineScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main message
              Text(
                "Let's set up a Daily Routine!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              
              const Spacer(),
              
              // Continue button
                      SizedBox(
                        width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _continueToQuestion10,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                            style: TextStyle(
                      fontSize: 16,
                              fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartJourneyScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main message
              Text(
                "Let's start your recovery journey, shall we?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              
              const Spacer(),
              
              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
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
                      : const Text(
                          'Start Your Journey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressScreen() {
    // Calculate progress percentage based on daily goal
    final progressPercentage = _getProgressPercentage(_dailyGoalMinutes);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Progress message
              Text(
                "That's $progressPercentage% progress in your first month!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[900],
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              
              const Spacer(),
              
              // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                  onPressed: _isLoading ? null : _showProgressCelebration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
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
                              : const Text(
                          'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  double _getProgressPercentage(int minutes) {
    switch (minutes) {
      case 5:
        return 7.5;
      case 10:
        return 15;
      case 15:
        return 22.5;
      case 20:
        return 30;
      default:
        return 0;
    }
  }

  void _nextQuestion() async {
    if (_selectedOption == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save current answer
      final answer = OnboardingAnswer(
        questionNumber: _questions[_currentQuestionIndex].number,
        question: _questions[_currentQuestionIndex].question,
        selectedOption: _selectedOption!,
        selectedText: _questions[_currentQuestionIndex].options[_selectedOption!],
        answeredAt: DateTime.now(),
      );

      _answers.add(answer);

      // Save to Firestore
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        await _onboardingService.saveAnswer(user.id, answer);
      }

      // Move to next question
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
        _isLoading = false;
      });
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

  void _showSetupRoutine() async {
    if (_selectedOption == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save question 9 answer
      final answer = OnboardingAnswer(
        questionNumber: _questions[_currentQuestionIndex].number,
        question: _questions[_currentQuestionIndex].question,
        selectedOption: _selectedOption!,
        selectedText: _questions[_currentQuestionIndex].options[_selectedOption!],
        answeredAt: DateTime.now(),
      );

      _answers.add(answer);

      // Save to Firestore
      final user = ref.read(authNotifierProvider).value;
      if (user != null) {
        await _onboardingService.saveAnswer(user.id, answer);
      }

      // Show setup routine screen
        setState(() {
        _showSetupRoutineScreen = true;
          _isLoading = false;
        });
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

  void _continueToQuestion10() {
    setState(() {
      _showSetupRoutineScreen = false;
      _currentQuestionIndex = 9; // Question 10
      _selectedOption = null;
    });
  }

  void _handleLastQuestion() async {
    if (_selectedOption == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Save the daily goal answer (question 10)
        final answer = OnboardingAnswer(
          questionNumber: _questions[_currentQuestionIndex].number,
          question: _questions[_currentQuestionIndex].question,
          selectedOption: _selectedOption!,
          selectedText: _questions[_currentQuestionIndex].options[_selectedOption!],
          answeredAt: DateTime.now(),
        );

        _answers.add(answer);

        // Save to Firestore
        final user = ref.read(authNotifierProvider).value;
        if (user != null) {
          await _onboardingService.saveAnswer(user.id, answer);
      }

      // Extract the minutes from the selected option
      // Options are: "5 minutes per day", "10 minutes per day", etc.
      final minutes = [5, 10, 15, 20][_selectedOption!];
      _dailyGoalMinutes = minutes;
      
      // Show progress celebration screen
      setState(() {
        _showProgressScreen = true;
        _isLoading = false;
      });
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

  void _showProgressCelebration() {
    setState(() {
      _showProgressScreen = false;
      _showStartJourneyScreen = true;
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = null;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final user = ref.read(authNotifierProvider).value;
      if (user == null) return;

      // Calculate total score
      final totalScore = _answers.fold(0, (total, answer) => total + answer.selectedOption);

      // Create onboarding data
      final onboardingData = OnboardingData(
        userId: user.id,
        answers: _answers,
        completedAt: DateTime.now(),
        totalScore: totalScore,
      );

      // Save complete onboarding data
      await _onboardingService.saveOnboardingData(onboardingData);
      
      // AI-based recommendations removed

      // Update user's onboarding status
      await _updateUserOnboardingStatus(user.id);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing onboarding: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserOnboardingStatus(String userId) async {
    try {
      // Update user's onboarding status via auth provider to refresh local state
      await ref
          .read(authNotifierProvider.notifier)
          .updateOnboardingStatus(onboardingCompleted: true);
    } catch (e) {
      throw 'Failed to update user onboarding status: $e';
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: const Text(
          'Exit Survey?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'You need to complete the survey to continue. Your progress will be saved.',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue Survey',
              style: TextStyle(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: Text(
              'Exit to Login',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
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
