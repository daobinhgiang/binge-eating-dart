import 'package:flutter/material.dart';

class Lesson24Screen extends StatelessWidget {
  const Lesson24Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 2.4: How Binges Begin: Common Triggers'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How Binges Begin: Common Triggers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Binge episodes don\'t happen randomly. They\'re often triggered by specific situations, emotions, or thoughts. Understanding these triggers is key to prevention:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _TriggerCategory(
              title: 'Emotional Triggers',
              icon: Icons.psychology,
              triggers: [
                'Stress from work, school, or relationships',
                'Feeling overwhelmed or anxious',
                'Sadness, loneliness, or depression',
                'Anger or frustration',
                'Boredom or emptiness',
                'Feeling out of control in other areas of life',
              ],
            ),
            _TriggerCategory(
              title: 'Physical Triggers',
              icon: Icons.fitness_center,
              triggers: [
                'Extreme hunger from restrictive dieting',
                'Fatigue or lack of sleep',
                'Hormonal changes',
                'Physical discomfort or pain',
                'Dehydration',
                'Low blood sugar',
              ],
            ),
            _TriggerCategory(
              title: 'Environmental Triggers',
              icon: Icons.home,
              triggers: [
                'Being alone at home',
                'Having "forbidden" foods available',
                'Social situations involving food',
                'Certain times of day or week',
                'Specific locations or routines',
                'Holidays or special occasions',
              ],
            ),
            _TriggerCategory(
              title: 'Cognitive Triggers',
              icon: Icons.psychology,
              triggers: [
                'All-or-nothing thinking about food',
                '"I\'ve already blown it" mentality',
                'Perfectionist expectations',
                'Negative self-talk',
                'Body image concerns',
                'Feeling like a failure',
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
                    Icons.lightbulb_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Start keeping a trigger journal to identify your personal patterns. Awareness is the first step toward change.',
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

class _TriggerCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> triggers;

  const _TriggerCategory({
    required this.title,
    required this.icon,
    required this.triggers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...triggers.map((trigger) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    trigger,
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
