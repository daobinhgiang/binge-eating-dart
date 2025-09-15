import 'package:flutter/material.dart';

class Lesson56Screen extends StatelessWidget {
  const Lesson56Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.6: Reflection Questions'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reflection Questions',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Take time to reflect on what you\'ve learned about the core engine of binge eating disorder. These questions will help you apply the concepts to your own experience and begin to identify areas for change:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _ReflectionSection(
              title: 'Understanding the Vicious Circle',
              questions: [
                'Can you identify the diet-binge cycle in your own experience?',
                'What role has restrictive dieting played in your binge eating?',
                'How do you typically respond after a binge episode?',
                'What triggers have you noticed that lead to binge episodes?',
                'How has the cycle affected your relationship with food?',
              ],
            ),
            _ReflectionSection(
              title: 'Recognizing Overevaluation',
              questions: [
                'How much of your self-worth is tied to your weight or appearance?',
                'What thoughts go through your mind when you look in the mirror?',
                'How do you feel about yourself when you gain or lose weight?',
                'What activities do you avoid because of body image concerns?',
                'How does your mood change based on what you eat or weigh?',
              ],
            ),
            _ReflectionSection(
              title: 'Identifying Expressions of the Problem',
              questions: [
                'Do you engage in body checking behaviors? If so, which ones?',
                'Are there situations you avoid because of body image concerns?',
                'What food rules or restrictions do you follow?',
                'Do you use any compensatory behaviors after eating?',
                'How do your emotions change in response to eating or body image?',
              ],
            ),
            _ReflectionSection(
              title: 'Assessing the Impact',
              questions: [
                'How has binge eating affected your physical health?',
                'What impact has it had on your mental health and mood?',
                'How has it affected your relationships with others?',
                'What impact has it had on your work or daily activities?',
                'What activities or experiences have you missed out on?',
              ],
            ),
            _ReflectionSection(
              title: 'Moving Forward',
              questions: [
                'What would you like to change about your relationship with food?',
                'How would you like to feel about your body and appearance?',
                'What activities would you like to participate in again?',
                'What support do you need to make these changes?',
                'What are your hopes for recovery?',
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
                      'Remember: Reflection is a powerful tool for change. Take your time with these questions and be honest with yourself. Consider keeping a journal to track your thoughts and progress over time.',
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
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
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
              color: Colors.blue,
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
                          color: Colors.blue,
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
