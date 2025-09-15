import 'package:flutter/material.dart';

class Lesson53Screen extends StatelessWidget {
  const Lesson53Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.3: "Expressions" of the Core Problem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"Expressions" of the Core Problem',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'The overevaluation of shape and weight can express itself in many different ways. Understanding these "expressions" helps us recognize how the core problem manifests in daily life:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _ExpressionCard(
              title: 'Body Checking',
              description: 'Frequent monitoring and evaluation of your body size, shape, or weight.',
              examples: [
                'Weighing yourself multiple times a day',
                'Checking your reflection in mirrors frequently',
                'Pinching or measuring body parts',
                'Comparing your body to others',
                'Taking photos to assess your appearance',
              ],
            ),
            _ExpressionCard(
              title: 'Body Avoidance',
              description: 'Avoiding situations or activities that draw attention to your body.',
              examples: [
                'Avoiding mirrors or reflective surfaces',
                'Wearing loose or baggy clothing',
                'Avoiding social situations involving food',
                'Skipping activities like swimming or exercise',
                'Avoiding photos or being photographed',
              ],
            ),
            _ExpressionCard(
              title: 'Food Rules and Restrictions',
              description: 'Rigid rules about what, when, and how much you can eat.',
              examples: [
                'Eliminating entire food groups',
                'Setting strict calorie limits',
                'Avoiding eating in front of others',
                'Following specific meal timing rules',
                'Labeling foods as "good" or "bad"',
              ],
            ),
            _ExpressionCard(
              title: 'Compensatory Behaviors',
              description: 'Attempts to "make up for" eating through other behaviors.',
              examples: [
                'Excessive exercise after eating',
                'Skipping meals to compensate for overeating',
                'Using laxatives or diuretics',
                'Vomiting after eating',
                'Fasting for extended periods',
              ],
            ),
            _ExpressionCard(
              title: 'Emotional Responses',
              description: 'Strong emotional reactions related to eating, weight, or body image.',
              examples: [
                'Intense anxiety about weight gain',
                'Depression after eating certain foods',
                'Anger or frustration with your body',
                'Shame about your eating behaviors',
                'Fear of losing control around food',
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.green,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recovery Insight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Recognizing these expressions of the core problem is the first step toward change. By identifying how overevaluation of shape and weight shows up in your life, you can begin to challenge and modify these patterns.',
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

class _ExpressionCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> examples;

  const _ExpressionCard({
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
                    color: Colors.blue,
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
