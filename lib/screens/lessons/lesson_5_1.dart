import 'package:flutter/material.dart';

class Lesson51Screen extends StatelessWidget {
  const Lesson51Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.1: The Vicious Circle: How Dieting Drives Binge Eating'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Vicious Circle: How Dieting Drives Binge Eating',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'One of the most important insights about binge eating is how restrictive dieting can actually trigger and maintain binge eating episodes. Understanding this cycle is crucial for breaking free from it:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _CycleStepCard(
              stepNumber: 1,
              title: 'Restrictive Dieting',
              description: 'Attempting to control weight through severe food restriction, calorie counting, or eliminating certain foods.',
              consequences: [
                'Physical hunger and deprivation',
                'Psychological preoccupation with food',
                'Feelings of restriction and deprivation',
                'Increased cravings for "forbidden" foods',
              ],
            ),
            _CycleStepCard(
              stepNumber: 2,
              title: 'Increased Vulnerability',
              description: 'The body and mind become more vulnerable to overeating due to restriction.',
              consequences: [
                'Lowered blood sugar and increased hunger',
                'Reduced willpower and decision-making ability',
                'Increased stress and emotional reactivity',
                'Heightened sensitivity to food cues',
              ],
            ),
            _CycleStepCard(
              stepNumber: 3,
              title: 'Binge Episode',
              description: 'A binge eating episode occurs, often triggered by a small "slip" or emotional stress.',
              consequences: [
                'Loss of control over eating',
                'Consuming large amounts of food',
                'Feelings of guilt and shame',
                'Physical discomfort and distress',
              ],
            ),
            _CycleStepCard(
              stepNumber: 4,
              title: 'Post-Binge Response',
              description: 'The aftermath of the binge often leads to renewed attempts at restriction.',
              consequences: [
                'Vowing to "start over" with stricter dieting',
                'Increased self-criticism and shame',
                'Fear of weight gain',
                'Return to restrictive eating patterns',
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
                        'Breaking the Cycle',
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
                    'The key to breaking this cycle is to stop the restrictive dieting that fuels it. This doesn\'t mean giving up on health, but rather adopting a more balanced, sustainable approach to eating that doesn\'t trigger the binge-restrict cycle.',
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

class _CycleStepCard extends StatelessWidget {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> consequences;

  const _CycleStepCard({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.consequences,
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    stepNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
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
            'Consequences:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...consequences.map((consequence) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    consequence,
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
