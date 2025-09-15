import 'package:flutter/material.dart';

class Lesson26Screen extends StatelessWidget {
  const Lesson26Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 2.6: Worksheet & Reflection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Worksheet & Reflection',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Take time to reflect on what you\'ve learned about binge eating. This worksheet will help you apply the concepts to your own experience:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _ReflectionSection(
              title: 'Understanding Your Binge Episodes',
              questions: [
                'What does "binge" mean to you personally?',
                'Can you identify the key characteristics of your binge episodes?',
                'What types of foods do you typically consume during a binge?',
                'How do you feel during a binge episode?',
                'What behaviors do you notice in yourself during binges?',
              ],
            ),
            _ReflectionSection(
              title: 'Identifying Your Triggers',
              questions: [
                'What emotional states often precede your binge episodes?',
                'Are there specific situations or environments that trigger binges?',
                'What physical sensations do you notice before bingeing?',
                'What thoughts or beliefs contribute to binge episodes?',
                'Are there certain times of day or week when binges are more likely?',
              ],
            ),
            _ReflectionSection(
              title: 'The Aftermath Experience',
              questions: [
                'How do you feel physically after a binge episode?',
                'What emotions do you experience in the aftermath?',
                'What thoughts go through your mind after bingeing?',
                'How do you typically respond to the aftermath?',
                'What behaviors do you engage in after a binge?',
              ],
            ),
            _ReflectionSection(
              title: 'Patterns and Insights',
              questions: [
                'What patterns do you notice in your binge eating?',
                'What have you learned about yourself from this reflection?',
                'What would you like to change about your relationship with food?',
                'What strengths do you have that could help in recovery?',
                'What support do you need to make positive changes?',
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: Colors.green,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Consider keeping a journal to track your reflections. Writing can help clarify your thoughts and identify patterns over time.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
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

class _ReflectionSection extends StatelessWidget {
  final String title;
  final List<String> questions;

  const _ReflectionSection({
    required this.title,
    required this.questions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 12),
          ...questions.asMap().entries.map((entry) {
            int index = entry.key;
            String question = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Your reflection space...',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
