import 'package:flutter/material.dart';

class Lesson41Screen extends StatelessWidget {
  const Lesson41Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 4.1: The Emergence of a "New" Disorder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Emergence of a "New" Disorder',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Binge Eating Disorder (BED) was officially recognized as a distinct eating disorder relatively recently. Understanding its history helps us appreciate how our understanding of eating disorders has evolved:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _TimelineCard(
              year: '1959',
              title: 'First Description',
              description: 'Albert Stunkard first described "binge eating" as a distinct pattern of overeating in obese individuals.',
            ),
            _TimelineCard(
              year: '1994',
              title: 'DSM-IV Recognition',
              description: 'BED was included in the DSM-IV as a research category, acknowledging it as a distinct condition requiring further study.',
            ),
            _TimelineCard(
              year: '2013',
              title: 'Official Diagnosis',
              description: 'BED was officially recognized as a distinct eating disorder in the DSM-5, giving it the same status as anorexia and bulimia.',
            ),
            _TimelineCard(
              year: 'Present',
              title: 'Growing Awareness',
              description: 'BED is now recognized as the most common eating disorder in the United States, affecting millions of people.',
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
                        Icons.history_edu,
                        color: Colors.green,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Historical Context',
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
                    'The recognition of BED as a distinct disorder represents a significant shift in our understanding of eating disorders. It acknowledges that binge eating can occur independently of other eating disorder symptoms and deserves specialized treatment.',
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

class _TimelineCard extends StatelessWidget {
  final String year;
  final String title;
  final String description;

  const _TimelineCard({
    required this.year,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                year,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
