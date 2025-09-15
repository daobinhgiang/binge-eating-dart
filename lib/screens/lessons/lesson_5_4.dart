import 'package:flutter/material.dart';

class Lesson54Screen extends StatelessWidget {
  const Lesson54Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.4: Extreme Weight Control Methods'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extreme Weight Control Methods',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'When the overevaluation of shape and weight becomes extreme, people may resort to dangerous weight control methods. Understanding these behaviors is crucial for recognizing when help is needed:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _MethodCard(
              title: 'Purging Behaviors',
              description: 'Attempts to rid the body of food after eating to prevent weight gain.',
              methods: [
                'Self-induced vomiting',
                'Misuse of laxatives',
                'Abuse of diuretics or water pills',
                'Use of enemas',
                'Excessive use of diet pills',
              ],
              risks: [
                'Electrolyte imbalances',
                'Dehydration and kidney problems',
                'Digestive system damage',
                'Dental problems from vomiting',
                'Heart rhythm disturbances',
              ],
            ),
            _MethodCard(
              title: 'Excessive Exercise',
              description: 'Compulsive or excessive exercise as a way to control weight or compensate for eating.',
              methods: [
                'Exercising for hours each day',
                'Exercising despite injury or illness',
                'Exercising in secret or isolation',
                'Feeling anxious when unable to exercise',
                'Exercising to "earn" the right to eat',
              ],
              risks: [
                'Overuse injuries and chronic pain',
                'Weakened immune system',
                'Hormonal imbalances',
                'Social isolation and relationship problems',
                'Increased risk of eating disorders',
              ],
            ),
            _MethodCard(
              title: 'Severe Food Restriction',
              description: 'Extreme limiting of food intake, often to dangerous levels.',
              methods: [
                'Eating very few calories per day',
                'Eliminating entire food groups',
                'Fasting for extended periods',
                'Using appetite suppressants',
                'Following extreme or fad diets',
              ],
              risks: [
                'Malnutrition and nutrient deficiencies',
                'Muscle loss and weakness',
                'Organ damage and failure',
                'Cognitive impairment',
                'Increased risk of binge eating',
              ],
            ),
            _MethodCard(
              title: 'Other Dangerous Methods',
              description: 'Additional extreme weight control methods that pose serious health risks.',
              methods: [
                'Smoking to suppress appetite',
                'Abusing prescription medications',
                'Using illegal drugs for weight loss',
                'Extreme temperature exposure',
                'Surgery or medical procedures',
              ],
              risks: [
                'Addiction and substance abuse',
                'Serious medical complications',
                'Financial and legal problems',
                'Social and relationship damage',
                'Life-threatening health consequences',
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.red.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: Colors.red,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Seek Help Immediately',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you recognize any of these extreme weight control methods in yourself, it\'s important to seek professional help immediately. These behaviors can be life-threatening and require specialized treatment. Recovery is possible with the right support.',
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

class _MethodCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> methods;
  final List<String> risks;

  const _MethodCard({
    required this.title,
    required this.description,
    required this.methods,
    required this.risks,
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
            'Common Methods:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...methods.map((method) => Padding(
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
                    method,
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
          const SizedBox(height: 12),
          const Text(
            'Health Risks:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          ...risks.map((risk) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
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
                    risk,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.red,
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
