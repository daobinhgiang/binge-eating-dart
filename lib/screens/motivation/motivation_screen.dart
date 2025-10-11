import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/comforting_background.dart';

class MotivationScreen extends ConsumerStatefulWidget {
  const MotivationScreen({super.key});

  @override
  ConsumerState<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends ConsumerState<MotivationScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _motivationalQuotes = [
    {
      'quote': 'Recovery is not a race. You don\'t have to feel guilty if it takes you longer than you thought it would.',
      'author': 'Unknown',
      'category': 'Recovery',
      'color': const Color(0xFF4CAF50),
    },
    {
      'quote': 'Every small step you take towards healing is a victory worth celebrating.',
      'author': 'Recovery Community',
      'category': 'Progress',
      'color': const Color(0xFF2196F3),
    },
    {
      'quote': 'You are not your eating disorder. You are so much more than that.',
      'author': 'Mental Health Advocate',
      'category': 'Identity',
      'color': const Color(0xFF9C27B0),
    },
    {
      'quote': 'Healing is not linear. It\'s okay to have setbacks. What matters is that you keep trying.',
      'author': 'Therapist',
      'category': 'Healing',
      'color': const Color(0xFFFF9800),
    },
    {
      'quote': 'Your worth is not determined by your relationship with food.',
      'author': 'Body Positivity Movement',
      'category': 'Self-Worth',
      'color': const Color(0xFFE91E63),
    },
    {
      'quote': 'It\'s okay to ask for help. Seeking support is a sign of strength, not weakness.',
      'author': 'Mental Health Professional',
      'category': 'Support',
      'color': const Color(0xFF00BCD4),
    },
    {
      'quote': 'You have survived 100% of your worst days. You are stronger than you think.',
      'author': 'Recovery Warrior',
      'category': 'Strength',
      'color': const Color(0xFF4CAF50),
    },
    {
      'quote': 'Progress, not perfection. Every step forward counts.',
      'author': 'Recovery Community',
      'category': 'Progress',
      'color': const Color(0xFF2196F3),
    },
    {
      'quote': 'Your body is not the enemy. It\'s your home. Treat it with kindness.',
      'author': 'Body Positivity Advocate',
      'category': 'Self-Care',
      'color': const Color(0xFF9C27B0),
    },
    {
      'quote': 'Recovery is possible. You are not alone in this journey.',
      'author': 'Recovery Community',
      'category': 'Hope',
      'color': const Color(0xFFFF9800),
    },
    {
      'quote': 'Every moment of self-compassion is a step towards healing.',
      'author': 'Mindfulness Teacher',
      'category': 'Self-Compassion',
      'color': const Color(0xFFE91E63),
    },
    {
      'quote': 'You are worthy of love, care, and recovery, regardless of your struggles.',
      'author': 'Mental Health Advocate',
      'category': 'Worthiness',
      'color': const Color(0xFF00BCD4),
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ComfortingBackground(
        child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Motivation',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quote display
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _motivationalQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = _motivationalQuotes[index];
                      return _buildQuoteCard(quote, index);
                    },
                  ),
                ),
                
                // Page indicators
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _motivationalQuotes.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _currentPage > 0 
                            ? () => _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                        icon: const Icon(Icons.arrow_back_ios),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _currentPage < _motivationalQuotes.length - 1
                            ? () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                )
                            : null,
                        icon: const Icon(Icons.arrow_forward_ios),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: quote['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: quote['color'].withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                quote['category'],
                style: TextStyle(
                  color: quote['color'],
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quote text
            Text(
              '"${quote['quote']}"',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Author
            Text(
              '— ${quote['author']}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Quote number
            Text(
              '${index + 1} of ${_motivationalQuotes.length}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
