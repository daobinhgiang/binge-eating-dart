import 'package:flutter/material.dart';

class Lesson22Screen extends StatelessWidget {
  const Lesson22Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 2.2: The Experience of a Binge: Key Characteristics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Experience of a Binge: Key Characteristics',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Understanding the key characteristics of a binge episode can help you recognize patterns and work toward recovery:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _CharacteristicCard(
              icon: Icons.speed,
              title: 'Rapid Eating',
              description: 'Eating much more quickly than normal, often without truly tasting or enjoying the food.',
            ),
            _CharacteristicCard(
              icon: Icons.warning,
              title: 'Loss of Control',
              description: 'Feeling unable to stop eating or control what or how much you\'re consuming.',
            ),
            _CharacteristicCard(
              icon: Icons.visibility_off,
              title: 'Secretive Behavior',
              description: 'Eating alone or in secret, often hiding evidence of the binge episode.',
            ),
            _CharacteristicCard(
              icon: Icons.psychology,
              title: 'Emotional Triggers',
              description: 'Binges often occur in response to stress, anxiety, sadness, or other emotional states.',
            ),
            _CharacteristicCard(
              icon: Icons.schedule,
              title: 'Discrete Time Period',
              description: 'The binge typically occurs within a specific timeframe, usually less than 2 hours.',
            ),
            _CharacteristicCard(
              icon: Icons.sentiment_very_dissatisfied,
              title: 'Post-Binge Distress',
              description: 'Feelings of guilt, shame, or disgust following the binge episode.',
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
              child: const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remember: Recognizing these characteristics is the first step toward understanding and changing binge eating patterns.',
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

class _CharacteristicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _CharacteristicCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
