import 'package:flutter/material.dart';

class Lesson34Screen extends StatelessWidget {
  const Lesson34Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 3.4: The "Transdiagnostic" Perspective: Seeing the Big Picture'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The "Transdiagnostic" Perspective: Seeing the Big Picture',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'The transdiagnostic approach recognizes that eating disorders share common underlying mechanisms, regardless of their specific diagnostic labels. This perspective offers a more unified understanding of treatment:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _TransdiagnosticCard(
              title: 'Core Psychopathology',
              description: 'The fundamental psychological processes that underlie all eating disorders.',
              elements: [
                'Overevaluation of eating, weight, and shape',
                'Perfectionism and high standards',
                'Low self-esteem and self-worth',
                'Difficulty with emotional regulation',
                'Interpersonal difficulties',
              ],
            ),
            _TransdiagnosticCard(
              title: 'Common Maintaining Factors',
              description: 'Processes that keep eating disorders going, regardless of the specific diagnosis.',
              elements: [
                'Dietary restriction and food rules',
                'Body checking and avoidance behaviors',
                'Negative self-talk and self-criticism',
                'Social isolation and withdrawal',
                'Rigid thinking patterns',
              ],
            ),
            _TransdiagnosticCard(
              title: 'Shared Treatment Targets',
              description: 'Areas that can be addressed across different eating disorder presentations.',
              elements: [
                'Challenging overevaluation of weight and shape',
                'Developing flexible eating patterns',
                'Building emotional regulation skills',
                'Improving self-esteem and self-compassion',
                'Addressing perfectionism and rigid thinking',
              ],
            ),
            _TransdiagnosticCard(
              title: 'Benefits of This Approach',
              description: 'Why the transdiagnostic perspective is valuable for treatment and recovery.',
              elements: [
                'More personalized treatment approaches',
                'Focus on underlying processes rather than symptoms',
                'Greater flexibility in treatment planning',
                'Recognition of individual differences',
                'More comprehensive understanding of recovery',
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
                        Icons.psychology,
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
                    'The transdiagnostic approach reminds us that recovery is about addressing the underlying psychological processes that drive eating disorders, not just managing specific symptoms. This can lead to more lasting and meaningful change.',
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

class _TransdiagnosticCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> elements;

  const _TransdiagnosticCard({
    required this.title,
    required this.description,
    required this.elements,
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
          ...elements.map((element) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    element,
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
