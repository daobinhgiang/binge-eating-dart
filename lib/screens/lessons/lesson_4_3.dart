import 'package:flutter/material.dart';

class Lesson43Screen extends StatelessWidget {
  const Lesson43Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 4.3: Why People Delay Getting Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Why People Delay Getting Help',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Many people with binge eating disorder wait years before seeking help. Understanding the barriers to treatment can help us address them and encourage earlier intervention:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _BarrierCard(
              title: 'Stigma and Shame',
              icon: Icons.visibility_off,
              description: 'The shame associated with binge eating often prevents people from seeking help.',
              factors: [
                'Fear of judgment from others',
                'Internalized shame about eating behaviors',
                'Belief that binge eating is a personal failing',
                'Concern about being labeled as "weak" or "lazy"',
                'Worry about being seen as lacking willpower',
              ],
            ),
            _BarrierCard(
              title: 'Lack of Recognition',
              icon: Icons.help_outline,
              description: 'Many people don\'t recognize their eating patterns as a treatable disorder.',
              factors: [
                'Not knowing that BED is a recognized disorder',
                'Believing that binge eating is just "overeating"',
                'Thinking that only thin people have eating disorders',
                'Not understanding that treatment is available',
                'Minimizing the severity of their symptoms',
              ],
            ),
            _BarrierCard(
              title: 'Access to Care',
              icon: Icons.location_on,
              description: 'Practical barriers can make it difficult to access appropriate treatment.',
              factors: [
                'Limited availability of specialized treatment',
                'High cost of treatment and insurance coverage',
                'Geographic barriers to accessing care',
                'Long waiting lists for treatment programs',
                'Lack of culturally competent providers',
              ],
            ),
            _BarrierCard(
              title: 'Fear of Treatment',
              icon: Icons.psychology,
              description: 'Concerns about the treatment process itself can be a barrier.',
              factors: [
                'Fear of being forced to change eating habits',
                'Worry about weight gain during treatment',
                'Concern about being judged by healthcare providers',
                'Fear of confronting difficult emotions',
                'Belief that treatment won\'t work for them',
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
                        'Breaking Down Barriers',
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
                    'Understanding these barriers is the first step toward addressing them. If you\'re struggling with binge eating, remember that seeking help is a sign of strength, not weakness. Professional treatment can make a significant difference in your recovery.',
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

class _BarrierCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> factors;

  const _BarrierCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.factors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
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
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
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
          ...factors.map((factor) => Padding(
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
                    factor,
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
