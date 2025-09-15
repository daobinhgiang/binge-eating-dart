import 'package:flutter/material.dart';

class Lesson25Screen extends StatelessWidget {
  const Lesson25Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 2.5: How Binges End: The Aftermath'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Binges End: The Aftermath',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'The end of a binge episode often brings a cascade of physical and emotional responses. Understanding these reactions is crucial for breaking the cycle:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _AftermathSection(
              title: 'Physical Aftermath',
              icon: Icons.health_and_safety,
              items: [
                'Feeling uncomfortably full or bloated',
                'Physical discomfort or pain',
                'Nausea or digestive upset',
                'Fatigue or lethargy',
                'Headaches or body aches',
                'Sleep disturbances',
              ],
            ),
            _AftermathSection(
              title: 'Emotional Aftermath',
              icon: Icons.sentiment_very_dissatisfied,
              items: [
                'Intense guilt and shame',
                'Self-criticism and negative self-talk',
                'Feeling like a failure',
                'Depression or sadness',
                'Anxiety about weight gain',
                'Fear of judgment from others',
              ],
            ),
            _AftermathSection(
              title: 'Behavioral Aftermath',
              icon: Icons.psychology,
              items: [
                'Vowing to "start over" or "be good"',
                'Making extreme diet plans',
                'Avoiding social situations',
                'Hiding evidence of the binge',
                'Compensatory behaviors (restriction, exercise)',
                'Isolation or withdrawal',
              ],
            ),
            _AftermathSection(
              title: 'Cognitive Aftermath',
              icon: Icons.psychology,
              items: [
                'All-or-nothing thinking',
                '"I\'ve ruined everything" mentality',
                'Catastrophic thinking about consequences',
                'Rumination about the binge',
                'Self-blame and criticism',
                'Hopelessness about recovery',
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
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
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recovery Insight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'The aftermath of a binge is often the most challenging part. Remember that these feelings are temporary and don\'t define your worth. Self-compassion and understanding are essential for breaking the cycle.',
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

class _AftermathSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _AftermathSection({
    required this.title,
    required this.icon,
    required this.items,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
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
