import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      'color': const Color(0xFF66BB6A),
    },
    {
      'quote': 'You are not your eating disorder. You are so much more than that.',
      'author': 'Mental Health Advocate',
      'category': 'Identity',
      'color': const Color(0xFF81C784),
    },
    {
      'quote': 'Healing is not linear. It\'s okay to have setbacks. What matters is that you keep trying.',
      'author': 'Therapist',
      'category': 'Healing',
      'color': const Color(0xFF43A047),
    },
    {
      'quote': 'Your worth is not determined by your relationship with food.',
      'author': 'Body Positivity Movement',
      'category': 'Self-Worth',
      'color': const Color(0xFF4CAF50),
    },
    {
      'quote': 'It\'s okay to ask for help. Seeking support is a sign of strength, not weakness.',
      'author': 'Mental Health Professional',
      'category': 'Support',
      'color': const Color(0xFF66BB6A),
    },
    {
      'quote': 'You have survived 100% of your worst days. You are stronger than you think.',
      'author': 'Recovery Warrior',
      'category': 'Strength',
      'color': const Color(0xFF81C784),
    },
    {
      'quote': 'Progress, not perfection. Every step forward counts.',
      'author': 'Recovery Community',
      'category': 'Progress',
      'color': const Color(0xFF43A047),
    },
    {
      'quote': 'Your body is not the enemy. It\'s your home. Treat it with kindness.',
      'author': 'Body Positivity Advocate',
      'category': 'Self-Care',
      'color': const Color(0xFF4CAF50),
    },
    {
      'quote': 'Recovery is possible. You are not alone in this journey.',
      'author': 'Recovery Community',
      'category': 'Hope',
      'color': const Color(0xFF66BB6A),
    },
    {
      'quote': 'Every moment of self-compassion is a step towards healing.',
      'author': 'Mindfulness Teacher',
      'category': 'Self-Compassion',
      'color': const Color(0xFF81C784),
    },
    {
      'quote': 'You are worthy of love, care, and recovery, regardless of your struggles.',
      'author': 'Mental Health Advocate',
      'category': 'Worthiness',
      'color': const Color(0xFF43A047),
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black87,
          ),
        ),
        title: Text(
          'Motivational Quotes',
          style: GoogleFonts.fredoka(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
            
            // Bottom navigation section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _motivationalQuotes.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index 
                              ? const Color(0xFF4CAF50)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Quote counter and navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      _currentPage > 0
                          ? TextButton.icon(
                              onPressed: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: const Icon(Icons.arrow_back_ios, size: 16),
                              label: Text(
                                'Previous',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            )
                          : const SizedBox(width: 90),
                      
                      // Counter
                      Text(
                        '${_currentPage + 1} of ${_motivationalQuotes.length}',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      // Next button
                      _currentPage < _motivationalQuotes.length - 1
                          ? TextButton.icon(
                              onPressed: () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                              icon: Text(
                                'Next',
                                style: GoogleFonts.nunito(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              label: const Icon(Icons.arrow_forward_ios, size: 16),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF4CAF50),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            )
                          : const SizedBox(width: 90),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard(Map<String, dynamic> quote, int index) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category badge with icon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    quote['color'].withOpacity(0.15),
                    quote['color'].withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: quote['color'].withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Text(
                quote['category'],
                style: GoogleFonts.fredoka(
                  color: quote['color'],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Quote text in card
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: quote['color'].withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    quote['quote'],
                    style: GoogleFonts.nunito(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          quote['color'].withOpacity(0.6),
                          quote['color'].withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Author
                  Text(
                    quote['author'],
                    style: GoogleFonts.nunito(
                      color: Colors.grey[600],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
