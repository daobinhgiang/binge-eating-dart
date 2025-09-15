import 'package:flutter/material.dart';

class Lesson55Screen extends StatelessWidget {
  const Lesson55Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson 5.5: The Wider Impact on Your Life'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The Wider Impact on Your Life',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Binge eating disorder doesn\'t just affect your relationship with food. It can have far-reaching effects on many areas of your life, impacting your physical health, mental well-being, relationships, and daily functioning:',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _ImpactAreaCard(
              title: 'Physical Health',
              icon: Icons.health_and_safety,
              description: 'The physical consequences of binge eating disorder can be significant and long-lasting.',
              impacts: [
                'Weight fluctuations and potential obesity',
                'Digestive problems and gastrointestinal issues',
                'Increased risk of diabetes and heart disease',
                'Sleep disturbances and fatigue',
                'Hormonal imbalances and menstrual irregularities',
                'Joint pain and mobility issues',
              ],
            ),
            _ImpactAreaCard(
              title: 'Mental Health',
              icon: Icons.psychology,
              description: 'The psychological effects of binge eating disorder can be profound and debilitating.',
              impacts: [
                'Depression and anxiety disorders',
                'Low self-esteem and self-worth',
                'Feelings of shame and guilt',
                'Social anxiety and isolation',
                'Difficulty concentrating and making decisions',
                'Increased risk of substance abuse',
              ],
            ),
            _ImpactAreaCard(
              title: 'Relationships',
              icon: Icons.people,
              description: 'Binge eating disorder can strain and damage important relationships in your life.',
              impacts: [
                'Avoiding social situations involving food',
                'Straining family relationships',
                'Difficulty in romantic relationships',
                'Isolation from friends and loved ones',
                'Hiding behaviors and feeling disconnected',
                'Increased conflict and misunderstandings',
              ],
            ),
            _ImpactAreaCard(
              title: 'Work and Education',
              icon: Icons.work,
              description: 'The disorder can significantly impact your professional and academic performance.',
              impacts: [
                'Difficulty concentrating at work or school',
                'Increased absenteeism and tardiness',
                'Reduced productivity and performance',
                'Avoiding work-related social events',
                'Financial strain from food costs',
                'Limited career advancement opportunities',
              ],
            ),
            _ImpactAreaCard(
              title: 'Daily Life',
              icon: Icons.home,
              description: 'Binge eating disorder can interfere with basic daily activities and routines.',
              impacts: [
                'Disrupted eating patterns and meal times',
                'Avoiding activities you once enjoyed',
                'Difficulty with self-care and hygiene',
                'Problems with sleep and daily routines',
                'Limited participation in hobbies and interests',
                'Reduced quality of life and life satisfaction',
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
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recovery Brings Hope',
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
                    'While the impact of binge eating disorder can be significant, recovery is possible. With proper treatment and support, you can rebuild your health, relationships, and quality of life. The first step is recognizing the problem and seeking help.',
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

class _ImpactAreaCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> impacts;

  const _ImpactAreaCard({
    required this.title,
    required this.icon,
    required this.description,
    required this.impacts,
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
                    color: Colors.purple,
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
          ...impacts.map((impact) => Padding(
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
                    impact,
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
