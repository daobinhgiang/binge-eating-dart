import 'package:flutter/material.dart';

class Lesson44Screen extends StatelessWidget {
  const Lesson44Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 4.4: The Findings of Community Studies'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Findings of Community Studies',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Community-based studies have provided crucial insights into the prevalence, characteristics, and impact of binge eating disorder. These studies help us understand the scope of the problem:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _StudyFindingCard(
              title: 'Prevalence Rates',
              description: 'How common binge eating disorder is in the general population.',
              findings: [
                'BED affects approximately 2-3% of adults in the United States',
                'More common than anorexia nervosa and bulimia nervosa combined',
                'Affects both men and women, though more common in women',
                'Can occur at any age, including childhood and older adulthood',
                'Rates may be higher in certain populations and communities',
              ],
            ),
            _StudyFindingCard(
              title: 'Demographic Patterns',
              description: 'Who is most likely to be affected by binge eating disorder.',
              findings: [
                'More common in women than men (approximately 2:1 ratio)',
                'Often begins in late adolescence or early adulthood',
                'Affects people of all racial and ethnic backgrounds',
                'Can occur across all socioeconomic levels',
                'May be more common in certain cultural contexts',
              ],
            ),
            _StudyFindingCard(
              title: 'Health Impact',
              description: 'The physical and psychological consequences of binge eating disorder.',
              findings: [
                'Associated with increased risk of obesity and related health problems',
                'Linked to higher rates of depression and anxiety',
                'May contribute to cardiovascular disease and diabetes risk',
                'Associated with reduced quality of life and functioning',
                'Can lead to social isolation and relationship difficulties',
              ],
            ),
            _StudyFindingCard(
              title: 'Treatment Seeking',
              description: 'Patterns of help-seeking behavior among people with BED.',
              findings: [
                'Many people with BED do not seek professional treatment',
                'Average delay of 8-10 years before seeking help',
                'Often seek treatment for other conditions first',
                'May not recognize their eating patterns as problematic',
                'Barriers to treatment include stigma, cost, and access',
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
                        Icons.analytics,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Research Implications',
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
                    'These findings highlight the need for increased awareness, early intervention, and accessible treatment options for binge eating disorder. They also underscore the importance of reducing stigma and improving recognition of the condition.',
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

class _StudyFindingCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> findings;

  const _StudyFindingCard({
    required this.title,
    required this.description,
    required this.findings,
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
          ...findings.map((finding) => Padding(
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
                    finding,
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
