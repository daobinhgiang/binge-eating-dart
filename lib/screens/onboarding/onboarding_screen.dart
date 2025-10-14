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

  final List<OnboardingQuestion> _questions = [
    // First 4 questions (required) - reordered to 1, 4, 8, 16
    OnboardingQuestion(
      number: 1,
      question: "How self-conscious do you feel about your weight or body size around others?",
      options: [
        "I don't feel self-conscious about my weight or body size when I'm with others.",
        "I feel concerned about how I look to others, but it normally does not make me feel disappointed with myself.",
        "I do get self-conscious about my appearance and weight which makes me feel disappointed in myself.",
        "I feel very self-conscious about my weight and frequently feel intense shame and disgust for myself. I try to avoid social contact because of this.",
      ],
    ),
    OnboardingQuestion(
      number: 2,
      question: "How often do you eat when you are bored?",
      options: [
        "I don't have the habit of eating when I'm bored.",
        "I sometimes eat when I'm bored, but can usually distract myself.",
        "I regularly eat when I'm bored, though occasionally I can resist.",
        "I strongly eat when I'm bored, and nothing seems to break the habit.",
      ],
    ),
    OnboardingQuestion(
      number: 3,
      question: "How often do you eat until uncomfortably stuffed?",
      options: [
        " I rarely eat so much food that I feel uncomfortably stuffed afterwards.",
        "Usually about once a month, I eat such a quantity of food, I end up feeling very stuffed.",
        "I have regular periods during the month when I eat large amounts of food, either at mealtime or at snacks.",
        "I eat so much food that I regularly feel quite uncomfortable after eating and sometimes a bit nauseous.",
      ],
    ),
    OnboardingQuestion(
      number: 4,
      question: "How certain are you about recognizing physical hunger?",
      options: [
        "I usually know when I'm physically hungry and eat the right portion.",
        "Occasionally I'm uncertain and don't know how much food I need.",
        "Even if I know the calories, I don't know what's a \"normal\" amount for me.",
      ],
    ),
    // Remaining questions (optional) - 2, 3, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15
    OnboardingQuestion(
      number: 5,
      question: "How would you describe your eating speed and fullness?",
      options: [
        "I don't have any difficulty eating slowly in the proper manner.",
        "Although I seem to \"gobble down\" foods, I don't end up feeling stuffed.",
        "At times, I tend to eat quickly and then feel uncomfortably full afterwards.",
        "I bolt down food without really chewing, and usually feel stuffed afterwards.",
      ],
    ),
    OnboardingQuestion(
      number: 6,
      question: "How capable do you feel in controlling your eating urges?",
      options: [
        "I feel capable of controlling my eating urges when I want to.",
        "I feel like I have failed to control my eating more than the average person.",
        "I feel utterly helpless when it comes to controlling my eating urges.",
        "I feel so helpless about controlling eating that I have become desperate about it.",
      ],
    ),
    OnboardingQuestion(
      number: 7,
      question: "Do you eat when you are not physically hungry?",
      options: [
        "I'm usually physically hungry when I eat.",
        "Occasionally, I eat on impulse when I'm not hungry.",
        "I regularly eat foods I may not enjoy, just to satisfy a hungry feeling even when I don't need it.",
        "I get \"mouth hunger\" when not physically hungry and eat foods to fill it. Sometimes I spit the food out afterward.",
      ],
    ),
    OnboardingQuestion(
      number: 8,
      question: "How do you feel after overeating?",
      options: [
        "I don't feel any guilt or self-hate after I overeat.",
        "Occasionally, I feel guilt or self-hate after overeating.",
        "Almost always, I feel strong guilt or self-hate after overeating.",
      ],
    ),
    OnboardingQuestion(
      number: 9,
      question: "How do you react when dieting and overeating occurs?",
      options: [
        "I don't lose control when dieting even after overeating.",
        "Sometimes, after eating a \"forbidden food,\" I feel I blew it and eat more.",
        "Frequently, I say \"I've blown it, might as well go all the way\" and binge.",
        "I often start strict diets but break them with binges. My life feels like \"feast or famine.\"",
      ],
    ),
    OnboardingQuestion(
      number: 10,
      question: "How does your calorie intake fluctuate?",
      options: [
        "My calorie intake doesn't fluctuate much.",
        "Sometimes after overeating, I cut intake to almost nothing.",
        "I regularly overeat at night but skip mornings.",
        "I've had week-long periods of near starvation after overeating (\"feast or famine\").",
      ],
    ),
    OnboardingQuestion(
      number: 11,
      question: "How well can you stop eating once you've started?",
      options: [
        "I usually stop when I've had enough.",
        "Sometimes I feel a compulsion to keep eating.",
        "Frequently I can't control urges, though sometimes I can.",
        "I feel incapable of stopping once I start and fear losing control.",
      ],
    ),
    OnboardingQuestion(
      number: 12,
      question: "Do you stop eating when full?",
      options: [
        "I stop eating when full.",
        "Usually I stop, but occasionally overeat.",
        "Often I cannot stop and feel stuffed.",
        "Sometimes I must induce vomiting after overeating.",
      ],
    ),
    OnboardingQuestion(
      number: 13,
      question: "How do you eat when with others compared to being alone?",
      options: [
        "I eat the same with others as when alone.",
        "Sometimes I eat less with others because I feel self-conscious.",
        "Frequently, I eat only small amounts with others because I'm embarrassed.",
        "I secretly overeat when no one can see (\"closet eating\").",
      ],
    ),
    OnboardingQuestion(
      number: 14,
      question: "What is your eating pattern during the day?",
      options: [
        "I eat 3 meals a day with only occasional snacks.",
        "I eat 3 meals plus regular snacks.",
        "When snacking heavily, I sometimes skip meals.",
        "There are times I continuously snack without planned meals.",
      ],
    ),
    OnboardingQuestion(
      number: 15,
      question: "How preoccupied are you with controlling your eating?",
      options: [
        "I don't think much about controlling eating.",
        "Sometimes I think about controlling urges.",
        "Frequently, I spend much time thinking about food or not eating.",
        "Most of the day I feel consumed by thoughts of food and the struggle not to eat.",
      ],
    ),
    OnboardingQuestion(
      number: 16,
      question: "How much do you think about food in general?",
      options: [
        "I don't think about food much.",
        "I have strong cravings but they're brief.",
        "I have days when I can't think about anything but food.",
        "Most days, I feel like I live to eat.",
      ],
    ),
  ];

  final List<OnboardingAnswer> _answers = [];

  @override
  Widget build(BuildContext context) {
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
                        child: Text(
                          'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showExitDialog(),
                        icon: const Icon(Icons.close, size: 24),
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Simple progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                    ),
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
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? const Color(0xFF6366F1).withOpacity(0.1)
                                      : Colors.grey[50],
                                  border: Border.all(
                                    color: isSelected 
                                        ? const Color(0xFF6366F1)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
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
                                              ? const Color(0xFF6366F1)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        color: isSelected 
                                            ? const Color(0xFF6366F1)
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
                    
                    // Navigation buttons
                    if (_currentQuestionIndex >= 4) ...[
                      // Two buttons for question 5+ (index 4+)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue[200]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Complete all questions for personalized insights',
                                style: TextStyle(
                                  color: Colors.blue[900],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedOption != null && !_isLoading
                              ? _continueSurvey
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                      ? 'Complete Survey'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Skip button
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: !_isLoading ? _skipToApp : null,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Skip to App',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Single button for first 4 questions
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedOption != null && !_isLoading
                              ? _nextQuestion
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.grey[500],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                  'Next',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
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
        return 'Self-consciousness';
      case 2:
        return 'Eating speed';
      case 3:
        return 'Control over eating';
      case 4:
        return 'Boredom eating';
      case 5:
        return 'Physical hunger';
      case 6:
        return 'Post-overeating feelings';
      case 7:
        return 'Dieting reactions';
      case 8:
        return 'Overeating frequency';
      case 9:
        return 'Calorie fluctuation';
      case 10:
        return 'Stopping ability';
      case 11:
        return 'Fullness recognition';
      case 12:
        return 'Social eating';
      case 13:
        return 'Eating patterns';
      case 14:
        return 'Eating preoccupation';
      case 15:
        return 'Food thoughts';
      case 16:
        return 'Hunger recognition';
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

      // Move to next question (for first 4 questions only)
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

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedOption = null;
      });
    }
  }

  void _continueSurvey() async {
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

      if (_currentQuestionIndex == _questions.length - 1) {
        // Complete onboarding
        await _completeOnboarding();
      } else {
        // Move to next question
        setState(() {
          _currentQuestionIndex++;
          _selectedOption = null;
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

  void _skipToApp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save current answer only if an option was selected
      if (_selectedOption != null) {
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
      }

      // Complete partial onboarding and skip to app
      await _completePartialOnboarding();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving progress: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _completePartialOnboarding() async {
    try {
      final user = ref.read(authNotifierProvider).value;
      if (user == null) return;

      // Calculate total score from first 4 questions
      final totalScore = _answers.fold(0, (total, answer) => total + answer.selectedOption);

      // Create partial onboarding data
      final onboardingData = OnboardingData(
        userId: user.id,
        answers: _answers,
        completedAt: DateTime.now(),
        totalScore: totalScore,
      );

      // Save partial onboarding data
      await _onboardingService.saveOnboardingData(onboardingData);
      
      // AI-based recommendations removed

      // Update user's partial onboarding status to allow app access
      await _updateUserPartialOnboardingStatus(user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome! You can always complete the remaining questions later from your profile.'),
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
            content: Text('Error saving progress: $e'),
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

  Future<void> _updateUserPartialOnboardingStatus(String userId) async {
    try {
      // Update user's partial onboarding status via auth provider to refresh local state
      await ref
          .read(authNotifierProvider.notifier)
          .updateOnboardingStatus(onboardingPartiallyCompleted: true);
    } catch (e) {
      throw 'Failed to update user partial onboarding status: $e';
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Exit Survey?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Your progress will be saved. You can return anytime to complete the survey.',
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
              'Continue',
              style: TextStyle(
                color: const Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completePartialOnboarding();
            },
            child: Text(
              'Exit',
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
