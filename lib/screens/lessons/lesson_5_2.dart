import 'package:flutter/material.dart';

class Lesson52Screen extends StatelessWidget {
  const Lesson52Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.2: The Core Engine: Overevaluation of Shape and Weight'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Core Engine: Overevaluation of Shape and Weight',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'At the heart of binge eating disorder lies the overevaluation of shape and weight. This means that how you look and what you weigh becomes the primary way you judge your self-worth:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _CoreConceptCard(
              title: 'What is Overevaluation?',
              description: 'Overevaluation means placing excessive importance on shape and weight in determining your self-worth.',
              examples: [
                'Feeling like a failure if you gain weight',
                'Believing that being thin will solve all your problems',
                'Judging your entire day based on what you ate',
                'Feeling worthless when you can\'t control your eating',
                'Avoiding social situations because of body image concerns',
              ],
            ),
            _CoreConceptCard(
              title: 'How It Drives Binge Eating',
              description: 'The overevaluation of shape and weight creates a cycle that maintains binge eating behaviors.',
              examples: [
                'Dieting to change your shape and weight',
                'Feeling like a failure when dieting doesn\'t work',
                'Using food to cope with negative feelings about your body',
                'Bingeing as a way to escape body image distress',
                'Increased shame and self-criticism after bingeing',
              ],
            ),
            _CoreConceptCard(
              title: 'The Impact on Your Life',
              description: 'Overevaluation of shape and weight can affect many areas of your life beyond eating.',
              examples: [
                'Avoiding activities you enjoy because of body image concerns',
                'Straining relationships due to preoccupation with appearance',
                'Missing out on social opportunities',
                'Reduced self-esteem and confidence',
                'Limited life experiences due to body image anxiety',
              ],
            ),
            _CoreConceptCard(
              title: 'Challenging Overevaluation',
              description: 'Recovery involves developing a more balanced view of self-worth that doesn\'t depend solely on appearance.',
              examples: [
                'Recognizing your worth beyond your appearance',
                'Developing other sources of self-esteem',
                'Practicing self-compassion and acceptance',
                'Focusing on health rather than weight',
                'Building a more balanced relationship with your body',
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.psychology,
                        color: Colors.purple,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recovery Insight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Challenging the overevaluation of shape and weight is one of the most important aspects of recovery. It\'s about recognizing that your worth as a person is not determined by your appearance or your ability to control your eating.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
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

class _CoreConceptCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> examples;

  const _CoreConceptCard({
    required this.title,
    required this.description,
    required this.examples,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withOpacity(0.2),
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
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Examples:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...examples.map((example) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    example,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
