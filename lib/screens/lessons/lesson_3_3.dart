import 'package:flutter/material.dart';

class Lesson33Screen extends StatelessWidget {
  const Lesson33Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 3.3: A Note on Atypical Eating Disorders'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A Note on Atypical Eating Disorders',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Not all eating disorders fit neatly into the main diagnostic categories. Atypical eating disorders are more common than you might think and deserve recognition and treatment:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _AtypicalCard(
              title: 'Night Eating Syndrome',
              description: 'Characterized by excessive eating in the evening and nighttime, often with little appetite in the morning.',
              features: [
                'Consuming 25% or more of daily calories after dinner',
                'Waking up during the night to eat',
                'Little to no appetite in the morning',
                'Feeling that eating is necessary to fall asleep',
                'Distress about the eating pattern',
              ],
            ),
            _AtypicalCard(
              title: 'Pica',
              description: 'Persistent eating of non-food substances that are not nutritionally appropriate.',
              features: [
                'Eating substances like dirt, clay, ice, or paper',
                'Behavior persists for at least one month',
                'Not developmentally appropriate (not in children under 2)',
                'Not part of a culturally supported practice',
                'May be associated with nutritional deficiencies',
              ],
            ),
            _AtypicalCard(
              title: 'Rumination Disorder',
              description: 'Repeated regurgitation of food that may be re-chewed, re-swallowed, or spit out.',
              features: [
                'Repeated regurgitation of food',
                'Behavior occurs for at least one month',
                'Not due to a medical condition',
                'Not associated with other eating disorders',
                'May lead to weight loss or nutritional problems',
              ],
            ),
            _AtypicalCard(
              title: 'Avoidant/Restrictive Food Intake Disorder (ARFID)',
              description: 'Avoidance or restriction of food intake not related to body image concerns.',
              features: [
                'Avoidance or restriction of food intake',
                'Significant weight loss or nutritional deficiency',
                'Dependence on nutritional supplements',
                'Marked interference with psychosocial functioning',
                'Not related to body image or weight concerns',
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
                        'Key Insight',
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
                    'Atypical eating disorders are just as serious and deserving of treatment as the more well-known disorders. If you recognize any of these patterns in yourself, don\'t hesitate to seek professional help.',
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

class _AtypicalCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> features;

  const _AtypicalCard({
    required this.title,
    required this.description,
    required this.features,
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
            'Characteristics:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                    feature,
                    style: const TextStyle(
                      fontSize: 13,
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
