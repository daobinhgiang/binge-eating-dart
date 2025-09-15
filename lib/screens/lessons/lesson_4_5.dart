import 'package:flutter/material.dart';

class Lesson45Screen extends StatelessWidget {
  const Lesson45Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 4.5: A Global Problem'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A Global Problem',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Binge eating disorder is not limited to any one country or culture. It\'s a global phenomenon that affects people worldwide, though its expression may vary across different cultural contexts:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _GlobalAspectCard(
              title: 'Cross-Cultural Prevalence',
              description: 'Binge eating disorder has been identified in diverse cultures and countries around the world.',
              aspects: [
                'Reported in North America, Europe, Asia, and other regions',
                'Prevalence rates vary across different countries and cultures',
                'May be underreported in some cultural contexts',
                'Cultural factors can influence how symptoms are expressed',
                'Globalization may be contributing to increased rates',
              ],
            ),
            _GlobalAspectCard(
              title: 'Cultural Influences',
              description: 'Cultural factors can shape how binge eating disorder is experienced and expressed.',
              aspects: [
                'Food traditions and eating patterns vary across cultures',
                'Body image ideals differ between cultures and societies',
                'Stigma and shame may be expressed differently',
                'Help-seeking behaviors vary across cultural contexts',
                'Treatment approaches may need cultural adaptation',
              ],
            ),
            _GlobalAspectCard(
              title: 'Global Health Impact',
              description: 'The worldwide impact of binge eating disorder on public health.',
              aspects: [
                'Contributes to the global burden of mental health disorders',
                'Associated with increased healthcare costs worldwide',
                'May contribute to rising rates of obesity globally',
                'Affects productivity and quality of life across populations',
                'Requires coordinated global response and resources',
              ],
            ),
            _GlobalAspectCard(
              title: 'International Research',
              description: 'How global research is advancing our understanding of binge eating disorder.',
              aspects: [
                'International studies provide broader perspectives',
                'Cross-cultural research helps identify universal vs. cultural factors',
                'Global collaborations advance treatment development',
                'International guidelines help standardize care',
                'Worldwide awareness campaigns reduce stigma',
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
                        Icons.public,
                        color: Colors.green,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Global Perspective',
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
                    'Recognizing binge eating disorder as a global problem helps us understand that it\'s not a personal failing but a complex condition that affects people worldwide. This perspective can reduce stigma and encourage international cooperation in research and treatment.',
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

class _GlobalAspectCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> aspects;

  const _GlobalAspectCard({
    required this.title,
    required this.description,
    required this.aspects,
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
          ...aspects.map((aspect) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    aspect,
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
