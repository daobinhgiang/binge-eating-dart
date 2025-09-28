import '../models/stage.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_slide.dart';

class Stage3Data {
  static Stage getStage3() {
    final now = DateTime.now();
    
    return Stage(
      stageNumber: 3,
      title: 'Ending Well',
      chapters: [
        // Chapter 0: Moving Forward
        Chapter(
          chapterNumber: 0,
          title: 'Moving Forward',
          lessons: [
            // Lesson 0.1: Maintaining Your Progress
            Lesson(
              id: 'lesson_s3_0_1',
              title: '0.1 Maintaining Your Progress',
              description: 'Learning strategies to maintain your recovery gains and prevent relapse',
              chapterNumber: 0,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_1_1',
                  title: 'The Importance of Maintenance',
                  content: 'Maintaining your progress requires ongoing attention and commitment to the skills you\'ve learned.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Recovery is an ongoing process, not a destination',
                    'Regular practice of skills prevents relapse',
                    'Maintenance becomes easier with time and practice',
                    'Small consistent efforts prevent larger problems'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_2',
                  title: 'Key Skills to Continue',
                  content: 'Certain skills are essential to continue practicing for long-term success.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Regular eating patterns and meal planning',
                    'Self-monitoring when stressed or triggered',
                    'Using alternative activities when urges arise',
                    'Problem-solving skills for life challenges'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_3',
                  title: 'Building a Support System',
                  content: 'Ongoing support from others is crucial for maintaining your progress.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Maintain connections with understanding friends and family',
                    'Consider ongoing therapy or support groups',
                    'Build relationships that don\'t center around food or weight',
                    'Have people you can contact during difficult times'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_4',
                  title: 'Creating a Maintenance Plan',
                  content: 'Develop a specific plan for maintaining your recovery over the long term.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Schedule regular check-ins with yourself about your progress',
                    'Plan how to handle high-risk situations and stressful periods',
                    'Set up systems for early detection of warning signs',
                    'Know when and how to seek additional help if needed'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.2: Dealing with Setbacks
            Lesson(
              id: 'lesson_s3_0_2',
              title: '0.2 Dealing with Setbacks',
              description: 'Understanding that setbacks are normal and learning how to respond effectively',
              chapterNumber: 0,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_2_1',
                  title: 'Understanding Setbacks',
                  content: 'Setbacks are a normal part of recovery and don\'t mean you\'ve failed or lost all progress.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Setbacks are temporary and don\'t erase your progress',
                    'They provide opportunities to learn and strengthen your skills',
                    'Everyone experiences setbacks during recovery',
                    'How you respond to setbacks is more important than avoiding them'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_2',
                  title: 'Common Triggers for Setbacks',
                  content: 'Certain situations and life events commonly trigger temporary returns to old behaviors.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Major life stresses like job changes, relationship issues, or loss',
                    'Physical illness or medication changes',
                    'Holiday seasons or special events centered around food',
                    'Times when support systems are less available'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_3',
                  title: 'Responding to Setbacks',
                  content: 'How you respond to a setback can turn it into a learning opportunity and prevent further problems.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Acknowledge the setback without shame or self-blame',
                    'Return to your regular eating and self-care routines immediately',
                    'Review what led to the setback and what you can learn',
                    'Reach out for support from your network or professionals'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_4',
                  title: 'Preventing Future Setbacks',
                  content: 'Use insights from setbacks to strengthen your recovery and prevent future problems.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Identify early warning signs that preceded the setback',
                    'Develop specific plans for handling similar situations in the future',
                    'Strengthen coping skills in areas where you struggled',
                    'Consider whether you need additional support or resources'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.2.1: Practice Addressing Setbacks Exercise
            Lesson(
              id: 'lesson_s3_0_2_1',
              title: '0.2.1 Practice Addressing Setbacks Exercise',
              description: 'Complete an interactive exercise to practice effective strategies for managing and learning from setbacks',
              chapterNumber: 0,
              lessonNumber: 21, // Using 21 to represent 2.1
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_2_1_1',
                  title: 'Preparing for Setback Recovery',
                  content: 'Learning to respond to setbacks with self-compassion and effective action can turn them into growth opportunities.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Recognize setbacks as learning opportunities, not failures',
                    'Develop a compassionate inner voice to replace self-criticism',
                    'Create action plans for common setback scenarios',
                    'Build resilience through structured response strategies'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_1_2',
                  title: 'The Recovery Mindset',
                  content: 'Adopting a growth mindset helps you bounce back stronger from temporary setbacks in your recovery journey.',
                  slideNumber: 2,
                  bulletPoints: [
                    'View setbacks as temporary disruptions, not permanent failures',
                    'Focus on what you can learn rather than what went wrong',
                    'Remember that recovery is rarely a straight line',
                    'Celebrate getting back on track as quickly as possible'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_1_3',
                  title: 'Building Your Support Network',
                  content: 'Having strong support systems in place makes it easier to navigate setbacks and return to healthy patterns.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Identify trusted people you can reach out to during difficult times',
                    'Practice asking for help before you desperately need it',
                    'Create emergency contact lists for crisis moments',
                    'Build regular check-ins with supportive people'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_1_4',
                  title: 'Creating Your Setback Action Plan',
                  content: 'Having a concrete plan for responding to setbacks removes guesswork and helps you act quickly and effectively.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Identify your early warning signs and triggers',
                    'Create specific steps to take within 24 hours of a setback',
                    'Prepare self-care activities that help you reset',
                    'Plan how to reconnect with your support systems'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Assessment 0.3: Eating Disorder Examination Questionnaire (EDE-Q)
            Lesson(
              id: 'lesson_s3_0_3',
              title: '0.3 Eating Disorder Examination Questionnaire (EDE-Q)',
              description: 'Complete this standardized assessment to evaluate your current eating disorder symptoms and behaviors',
              chapterNumber: 0,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_3_1',
                  title: 'EDE-Q Assessment',
                  content: 'The Eating Disorder Examination Questionnaire (EDE-Q) is a standardized tool used to assess eating disorder symptoms.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This assessment helps track your progress over time',
                    'It covers restraint, eating concern, shape concern, and weight concern',
                    'Your responses are confidential and stored securely',
                    'Complete all questions honestly for accurate results'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_3_2',
                  title: 'How to Complete the Assessment',
                  content: 'Take your time to answer each question thoughtfully and accurately.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Answer based on your experiences over the past 28 days',
                    'Use the scale provided for each question',
                    'There are no right or wrong answers',
                    'Be honest about your thoughts, feelings, and behaviors'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_3_3',
                  title: 'Understanding Your Results',
                  content: 'Your assessment results will help you and your treatment team understand your current status.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Results are used to track your progress over time',
                    'Higher scores indicate more severe symptoms',
                    'Regular assessments help monitor your recovery',
                    'Results can guide treatment planning and adjustments'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_3_4',
                  title: 'Ready to Begin',
                  content: 'When you\'re ready, tap "Start Assessment" to begin the EDE-Q questionnaire.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The assessment will take approximately 10-15 minutes',
                    'You can pause and return to it if needed',
                    'All your responses will be saved automatically',
                    'Contact your treatment team if you have any questions'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Assessment 0.4: Clinical Impairment Assessment (CIA)
            Lesson(
              id: 'lesson_s3_0_4',
              title: '0.4 Clinical Impairment Assessment (CIA)',
              description: 'Complete this assessment to evaluate how your eating disorder symptoms affect your daily life and functioning',
              chapterNumber: 0,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_4_1',
                  title: 'CIA Assessment',
                  content: 'The Clinical Impairment Assessment (CIA) measures how your eating disorder affects your daily functioning.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This assessment focuses on functional impairment',
                    'It covers relationships, work, mood, and quality of life',
                    'Your responses help track improvements in daily functioning',
                    'Results are used to monitor your recovery progress'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_4_2',
                  title: 'Assessment Focus Areas',
                  content: 'The CIA evaluates how your eating disorder impacts various areas of your life.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Personal relationships and social connections',
                    'Work, school, or daily responsibilities',
                    'Mood, self-esteem, and emotional well-being',
                    'Leisure activities and quality of life'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_4_3',
                  title: 'Completing the Assessment',
                  content: 'Answer each question based on how your eating disorder has affected you over the past 28 days.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Consider the impact on your daily life and relationships',
                    'Rate the severity of impairment in each area',
                    'Be honest about the challenges you\'ve experienced',
                    'Remember that improvement in these areas indicates recovery progress'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_4_4',
                  title: 'Using Your Results',
                  content: 'Your CIA results help track improvements in your daily functioning and quality of life.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Lower scores indicate better daily functioning',
                    'Regular assessments show your recovery progress',
                    'Results help identify areas that may need additional focus',
                    'Share results with your treatment team for guidance'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
      ],
    );
  }
}
