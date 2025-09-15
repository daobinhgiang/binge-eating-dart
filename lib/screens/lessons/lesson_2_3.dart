import 'package:flutter/material.dart';

class Lesson23Screen extends StatelessWidget {
  const Lesson23Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 2.3: The "What" and "How" of Bingeing'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The "What" and "How" of Bingeing',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Understanding both what you eat during a binge and how you eat it provides crucial insights into the nature of binge eating:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _SectionCard(
              title: 'The "What" - Types of Foods',
              content: [
                'Often high-calorie, "forbidden" foods',
                'Foods typically avoided during normal eating',
                'Comfort foods or "trigger" foods',
                'Large quantities of any available food',
                'Sometimes unusual food combinations',
              ],
            ),
            _SectionCard(
              title: 'The "How" - Eating Behaviors',
              content: [
                'Eating rapidly without chewing properly',
                'Eating until uncomfortably full',
                'Continuing to eat despite feeling full',
                'Eating without awareness or mindfulness',
                'Mechanical, automatic eating patterns',
              ],
            ),
            _SectionCard(
              title: 'Common Patterns',
              content: [
                'Starting with "just a little" and escalating',
                'Eating in a trance-like state',
                'Feeling disconnected from the eating process',
                'Unable to stop despite wanting to',
                'Eating past the point of physical comfort',
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Recognizing these patterns helps in developing strategies to interrupt the binge cycle and build healthier eating behaviors.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<String> content;

  const _SectionCard({
    required this.title,
    required this.content,
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
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
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
