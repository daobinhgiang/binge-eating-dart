import 'package:flutter/material.dart';

class Lesson31Screen extends StatelessWidget {
  const Lesson31Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 3.1: Eating Problem vs. Eating Disorder: What\'s the Difference?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Eating Problem vs. Eating Disorder: What\'s the Difference?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Understanding the distinction between eating problems and eating disorders is crucial for recognizing when professional help may be needed:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _ComparisonCard(
              title: 'Eating Problems',
              color: Colors.blue,
              characteristics: [
                'Occasional episodes of overeating or undereating',
                'Mild to moderate distress about eating or body image',
                'Some impact on daily functioning',
                'May be temporary or situational',
                'Can often be managed with self-help strategies',
                'May not meet clinical diagnostic criteria',
              ],
            ),
            _ComparisonCard(
              title: 'Eating Disorders',
              color: Colors.red,
              characteristics: [
                'Persistent, severe disturbances in eating behavior',
                'Significant distress and impairment in daily life',
                'Meet specific diagnostic criteria',
                'Often require professional treatment',
                'Can have serious physical and psychological consequences',
                'May involve life-threatening behaviors',
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Important Note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The line between eating problems and eating disorders can be blurry. If you\'re concerned about your eating behaviors, it\'s always best to consult with a healthcare professional for proper assessment and guidance.',
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

class _ComparisonCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<String> characteristics;

  const _ComparisonCard({
    required this.title,
    required this.color,
    required this.characteristics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          ...characteristics.map((characteristic) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    characteristic,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
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
