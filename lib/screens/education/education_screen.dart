import 'package:flutter/material.dart';
import '../lessons/lesson_1_1.dart';
import '../lessons/lesson_1_2.dart';
import '../lessons/lesson_1_3.dart';
import '../lessons/lesson_2_1.dart';
import '../lessons/lesson_2_2.dart';
import '../lessons/lesson_2_3.dart';
import '../lessons/lesson_2_4.dart';
import '../lessons/lesson_2_5.dart';
import '../lessons/lesson_2_6.dart';
import '../lessons/lesson_3_1.dart';
import '../lessons/lesson_3_2.dart';
import '../lessons/lesson_3_3.dart';
import '../lessons/lesson_3_4.dart';
import '../lessons/lesson_4_1.dart';
import '../lessons/lesson_4_2.dart';
import '../lessons/lesson_4_3.dart';
import '../lessons/lesson_4_4.dart';
import '../lessons/lesson_4_5.dart';
import '../lessons/lesson_5_1.dart';
import '../lessons/lesson_5_2.dart';
import '../lessons/lesson_5_3.dart';
import '../lessons/lesson_5_4.dart';
import '../lessons/lesson_5_5.dart';
import '../lessons/lesson_5_6.dart';
import '../lessons/lesson_6_1.dart';
import '../lessons/lesson_6_2.dart';
import '../lessons/lesson_6_3.dart';
import '../lessons/lesson_6_4.dart';
import '../lessons/lesson_6_5.dart';
import '../lessons/lesson_6_6.dart';
import '../lessons/lesson_7_1.dart';
import '../lessons/lesson_7_2.dart';
import '../lessons/lesson_7_3.dart';
import '../lessons/lesson_7_4.dart';
import '../lessons/lesson_8_1.dart';
import '../lessons/lesson_8_2.dart';
import '../lessons/lesson_8_3.dart';
import '../lessons/lesson_8_4.dart';
import '../lessons/lesson_9_1.dart';
import '../lessons/lesson_9_2.dart';
import '../lessons/lesson_9_3.dart';
import '../lessons/lesson_9_4.dart';
import '../lessons/lesson_9_5.dart';
import '../lessons/lesson_9_6.dart';
import '../lessons/lesson_10_1.dart';
import '../lessons/lesson_10_2.dart';
import '../lessons/lesson_10_3.dart';
import '../lessons/lesson_10_4.dart';
import '../lessons/lesson_10_5.dart';
import '../lessons/lesson_11_1.dart';
import '../lessons/lesson_11_2.dart';
import '../lessons/lesson_11_3.dart';
import '../lessons/lesson_12_1.dart';
import '../lessons/lesson_12_2.dart';
import '../lessons/lesson_12_3.dart';
import '../lessons/lesson_12_4.dart';
import '../lessons/lesson_13_1.dart';
import '../lessons/lesson_13_2.dart';
import '../lessons/lesson_13_3.dart';
import '../lessons/lesson_13_4.dart';
import '../lessons/lesson_14_1.dart';
import '../lessons/lesson_14_2.dart';
import '../lessons/lesson_14_3.dart';
import '../lessons/lesson_14_4.dart';
import '../lessons/lesson_15_1.dart';
import '../lessons/lesson_15_2.dart';
import '../lessons/lesson_16_1.dart';
import '../lessons/lesson_16_2.dart';
import '../lessons/lesson_16_3.dart';
import '../lessons/lesson_17_1.dart';
import '../lessons/lesson_17_2.dart';
import '../lessons/lesson_17_3.dart';
import '../lessons/lesson_17_4.dart';
import '../lessons/lesson_18_1.dart';
import '../lessons/lesson_18_2.dart';
import '../lessons/lesson_18_3.dart';
import '../lessons/lesson_18_4.dart';
import '../lessons/appendix_1_1.dart';
import '../lessons/appendix_1_2.dart';
import '../lessons/appendix_1_3.dart';
import '../lessons/appendix_2_1.dart';
import '../lessons/appendix_2_2.dart';
import '../lessons/appendix_2_3.dart';
import '../lessons/appendix_2_4.dart';
import '../lessons/appendix_3_1.dart';
import '../lessons/appendix_3_2.dart';
import '../lessons/appendix_4_1.dart';
import '../lessons/appendix_4_2.dart';

class Chapter {
  final int number;
  final String title;
  final List<Lesson> lessons;

  const Chapter({
    required this.number,
    required this.title,
    this.lessons = const [],
  });
}

class Lesson {
  final String title;
  final String duration;
  final String description;

  const Lesson({
    required this.title,
    required this.duration,
    required this.description,
  });
}

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  // Define all 22 chapters with their titles and lessons
  static const List<Chapter> chapters = [
    Chapter(
      number: 1,
      title: "Introduction to Binge Eating Recovery",
      lessons: [
        Lesson(
          title: "Who Is Nurtra For?",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Why Trust Nurtra?",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "How to Use Nurtra for Best Results",
          duration: "6 minutes",
          description: "Lesson 3",
        ),
      ],
    ),
    Chapter(
      number: 2,
      title: "Understanding Binge Eating Disorder",
      lessons: [
        Lesson(
          title: "What Does \"Binge\" Really Mean?",
          duration: "4 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "The Experience of a Binge: Key Characteristics",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "The \"What\" and \"How\" of Bingeing",
          duration: "5 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "How Binges Begin: Common Triggers",
          duration: "7 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "How Binges End: The Aftermath",
          duration: "6 minutes",
          description: "Lesson 5",
        ),
        Lesson(
          title: "Worksheet & Reflection",
          duration: "10 minutes",
          description: "Lesson 6",
        ),
      ],
    ),
    Chapter(
      number: 3,
      title: "Eating Problem vs. Eating Disorder: What's the Difference?",
      lessons: [
        Lesson(
          title: "Eating Problem vs. Eating Disorder: What's the Difference?",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "The Main Eating Disorders Involving Binge Eating",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "A Note on Atypical Eating Disorders",
          duration: "6 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "The \"Transdiagnostic\" Perspective: Seeing the Big Picture",
          duration: "7 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 4,
      title: "The Emergence of a \"New\" Disorder",
      lessons: [
        Lesson(
          title: "The Emergence of a \"New\" Disorder",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Uncovering a Hidden Problem: The Cosmopolitan Study",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Why People Delay Getting Help",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "The Findings of Community Studies",
          duration: "6 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "A Global Problem",
          duration: "5 minutes",
          description: "Lesson 5",
        ),
      ],
    ),
    Chapter(
      number: 5,
      title: "The Vicious Circle: How Dieting Drives Binge Eating",
      lessons: [
        Lesson(
          title: "The Vicious Circle: How Dieting Drives Binge Eating",
          duration: "8 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "The Core Engine: Overevaluation of Shape and Weight",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "\"Expressions\" of the Core Problem",
          duration: "6 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Extreme Weight Control Methods",
          duration: "8 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "The Wider Impact on Your Life",
          duration: "7 minutes",
          description: "Lesson 5",
        ),
        Lesson(
          title: "Reflection Questions",
          duration: "10 minutes",
          description: "Lesson 6",
        ),
      ],
    ),
    Chapter(
      number: 6,
      title: "The Physical Aspects of Binge Eating",
      lessons: [
        Lesson(
          title: "Key Facts You Need to Know About Body Weight",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "The Physical Impact of Binge Eating",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "The Dangers of Compensatory Behaviors (\"Purging\")",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "The System-Wide Effects of Being Underweight",
          duration: "5 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "At a Glance: The Ineffectiveness of Purging",
          duration: "4 minutes",
          description: "Lesson 5",
        ),
        Lesson(
          title: "Reflection Questions",
          duration: "10 minutes",
          description: "Lesson 6",
        ),
      ],
    ),
    Chapter(
      number: 7,
      title: "A Crucial Distinction: Starting vs Continuing",
      lessons: [
        Lesson(
          title: "A Crucial Distinction: Starting vs Continuing",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Why Binge Eating Problems Start: A Mix of Risk Factors",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Why Binge Eating Problems Continue: The Vicious Maintenance Cycles",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Reflection Questions",
          duration: "10 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 8,
      title: "Binge Eating and Addiction - A Critical Look",
      lessons: [
        Lesson(
          title: "The \"Food Addiction\" Theory",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Three Crucial Differences: Why Binge Eating Isn't a Classic Addiction",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Why This Distinction Is VITAL for Treatment",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Reflection Questions",
          duration: "10 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 9,
      title: "The Treatment of Binge Eating Problems",
      lessons: [
        Lesson(
          title: "Is Hospitalization Necessary?",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "What About Medication?",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "The Gold Standard: Cognitive Behavior Therapy (CBT)",
          duration: "8 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "An Effective First Step: Guided Self-Help",
          duration: "6 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "The Recommended Path to Recovery: Stepped Care",
          duration: "7 minutes",
          description: "Lesson 5",
        ),
        Lesson(
          title: "Reflection Questions",
          duration: "10 minutes",
          description: "Lesson 6",
        ),
      ],
    ),
    Chapter(
      number: 10,
      title: "Getting Ready to Overcome Binge Eating",
      lessons: [
        Lesson(
          title: "Why Change? The First Big Question",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Your Options for Change",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Is This Program Right for You? When to Start and When to Pause",
          duration: "8 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Frequently Asked Question: What Will Happen to My Weight?",
          duration: "6 minutes",
          description: "Lesson 4",
        ),
        Lesson(
          title: "How to Use This Program for Success",
          duration: "7 minutes",
          description: "Lesson 5",
        ),
      ],
    ),
    Chapter(
      number: 11,
      title: "Starting Well",
      lessons: [
        Lesson(
          title: "Part 1: Self-Monitoring",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Weekly Weighing",
          duration: "5 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Your First Review Sessions",
          duration: "8 minutes",
          description: "Lesson 3",
        ),
      ],
    ),
    Chapter(
      number: 12,
      title: "Regular Eating",
      lessons: [
        Lesson(
          title: "Part 1: Establishing Your Pattern of Regular Eating",
          duration: "8 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Addressing Purging Behaviors",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: Practical Advice for Mealtimes, Shopping, and Cooking",
          duration: "6 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Your Step 2 Review Sessions",
          duration: "8 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 13,
      title: "Alternatives to Binge Eating",
      lessons: [
        Lesson(
          title: "Part 1: Prepare Your List of Alternative Activities",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: \"Urge Surfing\" – Substituting an Alternative Activity",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: What Is Happening to My Weight?",
          duration: "5 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Your Step 3 Review Sessions",
          duration: "8 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 14,
      title: "Problem Solving",
      lessons: [
        Lesson(
          title: "Part 1: The Six Steps of Effective Problem Solving",
          duration: "8 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: The Crucial Seventh Step – Review Your Process",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: Proactive Problem Solving",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Your Step 4 Review Sessions",
          duration: "8 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 15,
      title: "Taking Stock",
      lessons: [
        Lesson(
          title: "Part 1: Should I Continue with the Program?",
          duration: "7 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: What's Next? Planning the Final Modules",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
      ],
    ),
    Chapter(
      number: 16,
      title: "The Dieting Module",
      lessons: [
        Lesson(
          title: "Part 1: Are You a Strict Dieter?",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Addressing the Three Types of Dieting",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Your Dieting Module Review Sessions",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
      ],
    ),
    Chapter(
      number: 17,
      title: "The Body Image Module",
      lessons: [
        Lesson(
          title: "Part 1: Identifying Overconcern with Shape and Weight",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Addressing Overconcern – A Two-Part Strategy",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: Tackling the Expressions of Overconcern",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Your Body Image Module Review Sessions",
          duration: "8 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 18,
      title: "Ending Well",
      lessons: [
        Lesson(
          title: "Part 1: Your Final Review",
          duration: "7 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: How to Maintain Your Progress",
          duration: "8 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: How to Deal with Setbacks",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Part 4: Your Three-Step Plan for Handling a Lapse",
          duration: "6 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 19,
      title: "Appendix I: Obtaining Professional Help for an Eating Problem",
      lessons: [
        Lesson(
          title: "Part 1: Why Finding the Right Professional Matters",
          duration: "5 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Where to Start Your Search",
          duration: "6 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: What to Look For",
          duration: "7 minutes",
          description: "Lesson 3",
        ),
      ],
    ),
    Chapter(
      number: 20,
      title: "Appendix II: Calculating Your Body Mass Index (BMI)",
      lessons: [
        Lesson(
          title: "Part 1: What is BMI?",
          duration: "4 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: How to Calculate Your BMI",
          duration: "5 minutes",
          description: "Lesson 2",
        ),
        Lesson(
          title: "Part 3: Understanding Your BMI Result",
          duration: "6 minutes",
          description: "Lesson 3",
        ),
        Lesson(
          title: "Part 4: Health Risks of a High BMI",
          duration: "5 minutes",
          description: "Lesson 4",
        ),
      ],
    ),
    Chapter(
      number: 21,
      title: "Appendix III: If You Are Also Overweight",
      lessons: [
        Lesson(
          title: "Part 1: Address the Eating Problem First",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Your Action Plan for Weight Management",
          duration: "7 minutes",
          description: "Lesson 2",
        ),
      ],
    ),
    Chapter(
      number: 22,
      title: "Appendix IV: Tackling \"Other Problems\"",
      lessons: [
        Lesson(
          title: "Part 1: Should I Seek Professional Help or Use Self-Help?",
          duration: "6 minutes",
          description: "Lesson 1",
        ),
        Lesson(
          title: "Part 2: Recommended Self-Help Books",
          duration: "5 minutes",
          description: "Lesson 2",
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          return _buildChapterSection(context, chapters[index]);
        },
      ),
    );
  }

  Widget _buildChapterSection(BuildContext context, Chapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Chapter Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              'Chapter ${chapter.number}: ${chapter.title}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          // Lessons under the chapter
          if (chapter.lessons.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...chapter.lessons.map((lesson) => _buildLessonCard(context, chapter, lesson)),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, Chapter chapter, Lesson lesson) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.play_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            lesson.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${lesson.description} | ${lesson.duration}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
            onTap: () {
              _navigateToLesson(context, chapter, lesson);
            },
        ),
      ),
    );
  }

  void _navigateToLesson(BuildContext context, Chapter chapter, Lesson lesson) {
    final lessonNumber = lesson.description.replaceAll('Lesson ', '');
    
    // Map appendix chapters (19-22) to their special navigation numbers (101-104)
    int chapterNumber = chapter.number;
    if (chapter.number >= 19 && chapter.number <= 22) {
      chapterNumber = 100 + (chapter.number - 18); // Maps 19->101, 20->102, 21->103, 22->104
    }
    
    final lessonScreen = _getLessonScreen(chapterNumber, lessonNumber);
    
    if (lessonScreen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => lessonScreen),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lesson not available yet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget? _getLessonScreen(int chapterNumber, String lessonNumber) {
    switch (chapterNumber) {
      case 1:
        switch (lessonNumber) {
          case '1':
            return const Lesson11Screen();
          case '2':
            return const Lesson12Screen();
          case '3':
            return const Lesson13Screen();
        }
        break;
      case 2:
        switch (lessonNumber) {
          case '1':
            return const Lesson21Screen();
          case '2':
            return const Lesson22Screen();
          case '3':
            return const Lesson23Screen();
          case '4':
            return const Lesson24Screen();
          case '5':
            return const Lesson25Screen();
          case '6':
            return const Lesson26Screen();
        }
        break;
      case 3:
        switch (lessonNumber) {
          case '1':
            return const Lesson31Screen();
          case '2':
            return const Lesson32Screen();
          case '3':
            return const Lesson33Screen();
          case '4':
            return const Lesson34Screen();
        }
        break;
      case 4:
        switch (lessonNumber) {
          case '1':
            return const Lesson41Screen();
          case '2':
            return const Lesson42Screen();
          case '3':
            return const Lesson43Screen();
          case '4':
            return const Lesson44Screen();
          case '5':
            return const Lesson45Screen();
        }
        break;
      case 5:
        switch (lessonNumber) {
          case '1':
            return const Lesson51Screen();
          case '2':
            return const Lesson52Screen();
          case '3':
            return const Lesson53Screen();
          case '4':
            return const Lesson54Screen();
          case '5':
            return const Lesson55Screen();
          case '6':
            return const Lesson56Screen();
        }
        break;
      case 6:
        switch (lessonNumber) {
          case '1':
            return const Lesson61Screen();
          case '2':
            return const Lesson62Screen();
          case '3':
            return const Lesson63Screen();
          case '4':
            return const Lesson64Screen();
          case '5':
            return const Lesson65Screen();
          case '6':
            return const Lesson66Screen();
        }
        break;
      case 7:
        switch (lessonNumber) {
          case '1':
            return const Lesson71Screen();
          case '2':
            return const Lesson72Screen();
          case '3':
            return const Lesson73Screen();
          case '4':
            return const Lesson74Screen();
        }
        break;
      case 8:
        switch (lessonNumber) {
          case '1':
            return const Lesson81Screen();
          case '2':
            return const Lesson82Screen();
          case '3':
            return const Lesson83Screen();
          case '4':
            return const Lesson84Screen();
        }
        break;
      case 9:
        switch (lessonNumber) {
          case '1':
            return const Lesson91Screen();
          case '2':
            return const Lesson92Screen();
          case '3':
            return const Lesson93Screen();
          case '4':
            return const Lesson94Screen();
          case '5':
            return const Lesson95Screen();
          case '6':
            return const Lesson96Screen();
        }
        break;
      case 10:
        switch (lessonNumber) {
          case '1':
            return const Lesson101Screen();
          case '2':
            return const Lesson102Screen();
          case '3':
            return const Lesson103Screen();
          case '4':
            return const Lesson104Screen();
          case '5':
            return const Lesson105Screen();
        }
        break;
      case 11:
        switch (lessonNumber) {
          case '1':
            return const Lesson111Screen();
          case '2':
            return const Lesson112Screen();
          case '3':
            return const Lesson113Screen();
        }
        break;
      case 12:
        switch (lessonNumber) {
          case '1':
            return const Lesson121Screen();
          case '2':
            return const Lesson122Screen();
          case '3':
            return const Lesson123Screen();
          case '4':
            return const Lesson124Screen();
        }
        break;
      case 13:
        switch (lessonNumber) {
          case '1':
            return const Lesson131Screen();
          case '2':
            return const Lesson132Screen();
          case '3':
            return const Lesson133Screen();
          case '4':
            return const Lesson134Screen();
        }
        break;
      case 14:
        switch (lessonNumber) {
          case '1':
            return const Lesson141Screen();
          case '2':
            return const Lesson142Screen();
          case '3':
            return const Lesson143Screen();
          case '4':
            return const Lesson144Screen();
        }
        break;
      case 15:
        switch (lessonNumber) {
          case '1':
            return const Lesson151Screen();
          case '2':
            return const Lesson152Screen();
        }
        break;
      case 16:
        switch (lessonNumber) {
          case '1':
            return const Lesson161Screen();
          case '2':
            return const Lesson162Screen();
          case '3':
            return const Lesson163Screen();
        }
        break;
      case 17:
        switch (lessonNumber) {
          case '1':
            return const Lesson171Screen();
          case '2':
            return const Lesson172Screen();
          case '3':
            return const Lesson173Screen();
          case '4':
            return const Lesson174Screen();
        }
        break;
      case 18:
        switch (lessonNumber) {
          case '1':
            return const Lesson181Screen();
          case '2':
            return const Lesson182Screen();
          case '3':
            return const Lesson183Screen();
          case '4':
            return const Lesson184Screen();
        }
        break;
      // Handle appendices
      case 101: // Appendix I
        switch (lessonNumber) {
          case '1':
            return const Appendix11Screen();
          case '2':
            return const Appendix12Screen();
          case '3':
            return const Appendix13Screen();
        }
        break;
      case 102: // Appendix II
        switch (lessonNumber) {
          case '1':
            return const Appendix21Screen();
          case '2':
            return const Appendix22Screen();
          case '3':
            return const Appendix23Screen();
          case '4':
            return const Appendix24Screen();
        }
        break;
      case 103: // Appendix III
        switch (lessonNumber) {
          case '1':
            return const Appendix31Screen();
          case '2':
            return const Appendix32Screen();
        }
        break;
      case 104: // Appendix IV
        switch (lessonNumber) {
          case '1':
            return const Appendix41Screen();
          case '2':
            return const Appendix42Screen();
        }
        break;
      // Add more chapters as needed
    }
    return null;
  }
}
