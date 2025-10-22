import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      question: "🌀 How often do you find yourself spiraling into a binge?",
      description: "Be honest — your future self depends on it.",
      options: [
        "😩 Daily or multiple times a day",
        "😣 Several times a week",
        "😕 Once or twice a month",
        "😇 Rarely or never",
      ],
    ),
    OnboardingQuestion(
      number: 2,
      question: "🔥 Have your binges become more intense over time?",
      description: "Pain doesn't just go away... it grows if ignored.",
      options: [
        "🚨 Much more intense",
        "⚠️ Moderately more intense",
        "📈 Slightly more intense",
        "🛑 No, they've stayed about the same",
      ],
    ),
    OnboardingQuestion(
      number: 3,
      question: "⏳ When did this pattern begin for you?",
      description: "Knowing when the pain started is the first step toward healing.",
      options: [
        "🌳 More than 5 years ago",
        "🌿 1–5 years ago",
        "🌱 Within the past year",
        "🐣 Within the past few months",
      ],
    ),
    OnboardingQuestion(
      number: 4,
      question: "😣 How hard is it for you to resist the urge to binge?",
      description: "Every moment you fight is a battle for your peace.",
      options: [
        "😖 I feel completely overwhelmed",
        "🥵 Most of the time, it's really difficult",
        "🤹 Sometimes I struggle, but I get by",
        "💪 I can usually manage the urges",
      ],
    ),
    OnboardingQuestion(
      number: 5,
      question: "💔 What emotions fuel your binges the most?",
      description: "Your emotions are valid — but they don't have to control you.",
      options: [
        "😢 Deep emotional pain",
        "🤢 Physical discomfort",
        "😤 High stress or anxiety",
        "😶‍🌫️ Boredom or a mix of heavy feelings",
      ],
    ),
    OnboardingQuestion(
      number: 6,
      question: "🌈 Why is it important for you to stop binge eating?",
      description: "You deserve more than shame and guilt after every meal.",
      options: [
        "❤️ To feel healthier physically",
        "🧠 To feel better mentally",
        "🕊️ To take back control of my life",
        "💫 All of the above — I want real change",
      ],
    ),
    OnboardingQuestion(
      number: 7,
      question: "🎯 What are the 1–2 goals that matter most to you right now?",
      description: "If not now... then when?",
      options: [
        "🚫 Reduce how often I binge",
        "🧘 Learn better coping tools",
        "🥗 Make peace with food",
        "🧩 Build a consistent, balanced routine",
      ],
    ),
    OnboardingQuestion(
      number: 8,
      question: "🔮 If the next 30 days were wildly successful, what would that look like?",
      description: "You're closer to this version of yourself than you think.",
      options: [
        "📉 Fewer binge episodes",
        "🧘‍♀️ More emotional control",
        "🥄 Mindful, conscious eating",
        "💞 Greater self-compassion",
      ],
    ),
    OnboardingQuestion(
      number: 9,
      question: "🔥 Right now, how motivated are you to take control back? (Scale of 1–10)",
      description: "No one else can do this for you.",
      options: [
        "💤 1–3 (Barely motivated)",
        "⚙️ 4–6 (Warming up)",
        "⚡ 7–8 (Pretty motivated)",
        "🚀 9–10 (I'm ready for real change!)",
      ],
    ),
    OnboardingQuestion(
      number: 10,
      question: "⏱️ How much time can you truly commit daily to your recovery journey?",
      description: "Even 5 minutes is better than nothing — but be real with yourself.",
      options: [
        "🧭 20 minutes — I'm all in",
        "⏱️ 15 minutes — I'm invested",
        "🕰️ 10 minutes — I owe myself that",
        "⏳ Just 5 minutes a day",
      ],
    ),
  ];

  final List<OnboardingAnswer> _answers = [];

  /// Triggers maximum intensity haptic feedback for the most severe options
  void _triggerMaximumHapticFeedback() {
    // Triple heavy impact with delays for maximum intensity
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 30), () {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 30), () {
        HapticFeedback.heavyImpact();
      });
    });
  }

  /// Triggers haptic feedback based on the severity of the selected option
  /// For questions with severity-based options, index 0 is most severe, index 3 is least severe
  void _triggerHapticFeedback(int questionNumber, int optionIndex) {
    // Only trigger haptic feedback on iOS
    if (Theme.of(context).platform != TargetPlatform.iOS) return;
    
    // Debug print to ensure function is being called
    print('Haptic feedback triggered: Question $questionNumber, Option $optionIndex');
    
    switch (questionNumber) {
      case 1: // "How often do you find yourself spiraling into a binge?"
        // Most severe (daily) = strongest haptic, least severe (rarely) = lightest
        switch (optionIndex) {
          case 0: 
            // Daily or multiple times - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // Several times a week - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // Once or twice a month - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // Rarely or never - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 2: // "Have your binges become more intense over time?"
        // Most severe (much more intense) = strongest haptic
        switch (optionIndex) {
          case 0: 
            // Much more intense - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // Moderately more intense - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // Slightly more intense - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // No, they've stayed about the same - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 3: // "When did this pattern begin for you?"
        // Most severe (longer struggle) = stronger haptic
        switch (optionIndex) {
          case 0: 
            // More than 5 years ago - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // 1-5 years ago - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // Within the past year - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // Within the past few months - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 4: // "How hard is it for you to resist the urge to binge?"
        // Most severe (completely overwhelmed) = strongest haptic
        switch (optionIndex) {
          case 0: 
            // I feel completely overwhelmed - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // Most of the time, it's really difficult - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // Sometimes I struggle, but I get by - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // I can usually manage the urges - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 5: // "What emotions fuel your binges the most?"
        // Most severe (emotional pain) = strongest haptic
        switch (optionIndex) {
          case 0: 
            // Deep emotional pain - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // Physical discomfort - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // High stress or anxiety - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // Boredom or a mix of heavy feelings - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 9: // "Right now, how motivated are you to take control back?"
        // Most severe (low motivation) = stronger haptic
        switch (optionIndex) {
          case 0: 
            // 1-3 (Barely motivated) - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // 4-6 (Warming up) - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // 7-8 (Pretty motivated) - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // 9-10 (I'm ready for real change!) - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      case 10: // "How much time can you truly commit daily to your recovery journey?"
        // Higher commitment (more time) = stronger haptic
        switch (optionIndex) {
          case 0: 
            // 20 minutes — I'm all in - MAXIMUM intensity
            _triggerMaximumHapticFeedback();
            break;
          case 1: 
            // 15 minutes — I'm invested - Strong impact
            HapticFeedback.heavyImpact();
            break;
          case 2: 
            // 10 minutes — I owe myself that - Medium impact
            HapticFeedback.mediumImpact();
            break;
          case 3: 
            // Just 5 minutes a day - Very light impact
            HapticFeedback.selectionClick();
            break;
        }
        break;
        
      default:
        // For questions without severity (6, 7, 8), use medium impact
        HapticFeedback.mediumImpact();
        break;
    }
  }

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
                      const SizedBox(width: 16),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
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
                    
                    const SizedBox(height: 8),
                    
                    // Description text
                    Text(
                      currentQuestion.description,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
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
                                // Trigger haptic feedback based on option severity
                                _triggerHapticFeedback(currentQuestion.number, index);
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
        child: Stack(
          children: [
            // Centered images like the intro screen
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/onboarding/daily_routine_dialogue.png'),
                    const SizedBox(height: 16),
                    Image.asset('assets/onboarding/daily_routine.png'),
                  ],
                ),
              ),
            ),

            // Continue button pinned to bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SizedBox(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartJourneyScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Centered images like the intro screen
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Start recovery dialogue image
                    Image.asset('assets/onboarding/start_recovery_dialogue.png'),
                    const SizedBox(height: 16),
                    // Character image
                    Image.asset('assets/onboarding/start_recovery.png'),
                  ],
                ),
              ),
            ),

            // Continue button pinned to bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SizedBox(
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
                ),
              ),
            ),
          ],
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
        child: Stack(
          children: [
            // Centered images like the intro screen
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Progress dialogue image
                    Image.asset('assets/onboarding/progress_${progressPercentage}%.png'),
                    const SizedBox(height: 16),
                    // Character image (using the same character from daily routine)
                    Image.asset('assets/onboarding/progress.png'),
                  ],
                ),
              ),
            ),

            // Continue button pinned to bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SizedBox(
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getProgressPercentage(int minutes) {
    switch (minutes) {
      case 5:
        return '7.5';
      case 10:
        return '15.0';
      case 15:
        return '22.5';
      case 20:
        return '30.0';
      default:
        return '0';
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
      // Options are now: "20 minutes — I'm all in", "15 minutes — I'm invested", "10 minutes — I owe myself that", "Just 5 minutes a day"
      final minutes = [20, 15, 10, 5][_selectedOption!];
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
  final String description;
  final List<String> options;

  OnboardingQuestion({
    required this.number,
    required this.question,
    required this.description,
    required this.options,
  });
}
