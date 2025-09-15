import 'package:flutter/material.dart';

class Lesson42Screen extends StatelessWidget {
  const Lesson42Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 4.2: Uncovering a Hidden Problem: The Cosmopolitan Study'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uncovering a Hidden Problem: The Cosmopolitan Study',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'The Cosmopolitan study was a groundbreaking research project that helped reveal the hidden prevalence of binge eating disorder. This study played a crucial role in bringing attention to a previously overlooked problem:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _StudyCard(
              title: 'Study Overview',
              description: 'A large-scale survey conducted through Cosmopolitan magazine to assess eating behaviors in women.',
              keyFindings: [
                'Over 4,000 women participated in the survey',
                'Conducted in the 1980s when BED was not yet recognized',
                'Revealed high rates of binge eating behaviors',
                'Helped identify patterns that didn\'t fit existing categories',
                'Brought public attention to the problem',
              ],
            ),
            _StudyCard(
              title: 'Key Discoveries',
              description: 'The study uncovered important patterns that challenged existing assumptions about eating disorders.',
              keyFindings: [
                'Many women experienced binge eating without purging',
                'Binge eating was more common than previously thought',
                'The behavior caused significant distress and impairment',
                'Traditional treatment approaches were inadequate',
                'There was a need for specialized recognition and treatment',
              ],
            ),
            _StudyCard(
              title: 'Impact on the Field',
              description: 'The study\'s findings had lasting effects on how we understand and treat eating disorders.',
              keyFindings: [
                'Helped establish BED as a distinct condition',
                'Influenced diagnostic criteria development',
                'Led to increased research funding and attention',
                'Improved public awareness and understanding',
                'Paved the way for specialized treatment approaches',
              ],
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
                    Icons.science,
                    color: Colors.orange,
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Research Insight: The Cosmopolitan study demonstrated the power of community-based research in uncovering hidden health problems and driving change in the medical field.',
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

class _StudyCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> keyFindings;

  const _StudyCard({
    required this.title,
    required this.description,
    required this.keyFindings,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
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
            'Key Findings:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          ...keyFindings.map((finding) => Padding(
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
                    finding,
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
