import 'package:flutter/material.dart';

class Lesson32Screen extends StatelessWidget {
  const Lesson32Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 3.2: The Main Eating Disorders Involving Binge Eating'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Main Eating Disorders Involving Binge Eating',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Several eating disorders involve binge eating as a key symptom. Understanding these different conditions can help in recognizing patterns and seeking appropriate treatment:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _DisorderCard(
              title: 'Binge Eating Disorder (BED)',
              icon: Icons.restaurant,
              description: 'The most common eating disorder in the United States, characterized by recurrent episodes of binge eating without compensatory behaviors.',
              keyFeatures: [
                'Recurrent binge eating episodes',
                'No regular use of compensatory behaviors',
                'Marked distress about binge eating',
                'Binge episodes occur at least once a week for 3 months',
                'Feelings of loss of control during episodes',
              ],
            ),
            _DisorderCard(
              title: 'Bulimia Nervosa',
              icon: Icons.refresh,
              description: 'Characterized by episodes of binge eating followed by compensatory behaviors to prevent weight gain.',
              keyFeatures: [
                'Recurrent binge eating episodes',
                'Regular use of compensatory behaviors (vomiting, laxatives, exercise)',
                'Self-evaluation unduly influenced by body shape and weight',
                'Binge and purge cycles occur at least once a week for 3 months',
                'Normal to slightly above normal weight range',
              ],
            ),
            _DisorderCard(
              title: 'Anorexia Nervosa - Binge/Purge Type',
              icon: Icons.warning,
              description: 'A subtype of anorexia nervosa that includes episodes of binge eating and purging behaviors.',
              keyFeatures: [
                'Significantly low body weight',
                'Intense fear of gaining weight',
                'Distorted body image',
                'Episodes of binge eating and purging',
                'Restriction of food intake',
              ],
            ),
            _DisorderCard(
              title: 'Other Specified Feeding or Eating Disorder (OSFED)',
              icon: Icons.help_outline,
              description: 'Eating disorders that don\'t meet the full criteria for other specific disorders but still cause significant distress.',
              keyFeatures: [
                'Atypical presentations of eating disorders',
                'Subthreshold symptoms that still cause impairment',
                'May include binge eating behaviors',
                'Significant distress or impairment in functioning',
                'Doesn\'t meet full criteria for other disorders',
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
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Remember: Only a qualified healthcare professional can provide an accurate diagnosis. If you\'re concerned about your eating behaviors, seek professional evaluation.',
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

class _DisorderCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> keyFeatures;

  const _DisorderCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.keyFeatures,
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
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.purple,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
            'Key Features:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...keyFeatures.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.purple,
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
