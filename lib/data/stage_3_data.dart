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
            // Lesson 0.1: Making Your Progress Last
            Lesson(
              id: 'lesson_s3_0_1',
              title: '0.1: Making Your Progress Last',
              description: 'Learning strategies to maintain your recovery gains and prevent relapse',
              chapterNumber: 0,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_1_1',
                  title: 'Module 1: Making Your New Skills a Habit',
                  content: 'After your initial improvement, the focus shifts to making your progress last. Continue to use the most helpful parts of the program to build lasting, positive habits.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Keep what works: Think about the skills and strategies that made the biggest difference for you.',
                    'Continued improvement: By sticking with these helpful tools, you\'re likely to see even more improvement over time.',
                    'Stay consistent: The goal is to make these new, healthy behaviors feel like second nature.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_2',
                  title: 'Module 2: Your Most Important Long-Term Tools',
                  content: 'While not everything from the program needs to be done forever, a few key skills are especially powerful for long-term success and staying well.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Stick with Regular Eating: This is perhaps the single most important habit to maintain, possibly indefinitely. It\'s your foundation for stable, balanced eating.',
                    'Keep Your Problem-Solving Skills Sharp: Life will always have its challenges. Continuing to use your problem-solving skills will help you navigate difficulties without turning to food.',
                    'Hold Regular Check-Ins: For the next three months or so, continue to have regular review sessions with yourself to keep an eye on your progress and catch any small slips before they become bigger issues.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_3',
                  title: 'Module 3: When to Ease Off Monitoring',
                  content: 'If your eating habits are stable and satisfactory, you can start easing off detailed, daily monitoring. It\'s important to be honest about the reasons for stopping.',
                  slideNumber: 3,
                  bulletPoints: [
                    'You can stop if: Your eating is stable and you feel in control.',
                    'Be careful if: You find you\'re stopping because you don\'t want to face up to any ongoing difficulties.',
                    'It\'s always there if you need it: Remember, monitoring is a tool you can always pick back up if you feel yourself slipping.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_1_4',
                  title: 'Module 4: When to Ease Off Weekly Weighing',
                  content: 'Similarly, you can stop weighing yourself every week once your weight feels stable and you\'re comfortable. However, it\'s still a good idea to check in from time to time as part of a healthy lifestyle.',
                  slideNumber: 4,
                  bulletPoints: [
                    'You can stop if: Your weight is stable and it no longer causes you distress.',
                    'A healthy habit: It\'s generally a good idea for everyone to check their weight at regular intervals (e.g., once a month) to stay aware of their overall health.',
                    'The choice is yours: You get to decide what feels right and supportive for you in the long term.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.2: How to Handle Setbacks
            Lesson(
              id: 'lesson_s3_0_2',
              title: '0.2: How to Handle Setbacks',
              description: 'Understanding that setbacks are normal and learning how to respond effectively',
              chapterNumber: 0,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s3_0_2_1',
                  title: 'Module 1: Expect Bumps in the Road',
                  content: 'It\'s important to have realistic expectations. Hoping to never binge again is understandable, but it\'s not helpful. Think of your eating problems as old habits that might resurface during stressful times.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Perfection isn\'t the goal: Everyone has setbacks. It\'s a normal part of any long-term change.',
                    'Think of it as your Achilles\' heel: You\'ll still be prone to react to difficulties with old eating patterns, just as other people might get irritable or have a drink.',
                    'Setbacks are inevitable: They are especially likely in the first few months after you\'ve made big changes, but they can happen at any time. Expecting them means you can prepare for them.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_2',
                  title: 'Module 2: Know Your Triggers',
                  content: 'Setbacks are not random. They are usually triggered by specific events or feelings. Knowing your personal triggers makes it easier to anticipate and address setbacks.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Common Triggers Include:',
                    'Stressful life events, especially anything that makes you doubt yourself.',
                    'Feeling very down or depressed.',
                    'Gaining weight, or feeling like you have.',
                    'Negative comments from other people about your shape or weight.',
                    'Restarting strict dieting or breaking one of your own food rules.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_3',
                  title: 'Module 3: A Lapse is Not a Relapse',
                  content: 'It\'s crucial to distinguish between a "lapse" (a temporary slip) and a "relapse" (returning to square one). Confusing them can make a small slip feel like a total failure, which can make things worse.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Avoid all-or-nothing thinking: One binge doesn\'t erase all your progress.',
                    'A lapse is a slip: It\'s a single event or a short period of difficulty. It\'s a chance to learn and get back on track.',
                    'A relapse is a return to old patterns: This is what can happen if you view a lapse as a catastrophe and give up.',
                    'Your mindset matters: Seeing a slip as a "lapse" helps you take action. Seeing it as a "relapse" can make you feel hopeless.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s3_0_2_4',
                  title: 'Module 4: Your 3-Step Action Plan for Lapses',
                  content: 'Since setbacks are normal, having a clear plan for what to do when they happen is your best defense. When you feel yourself slipping, don\'t panic. Just follow these three simple steps to get back on track quickly.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Step 1: Spot the problem early. The "head in the sand" approach doesn\'t work. If you think you\'re having a setback, you probably are. Act as soon as you can.',
                    'Step 2: Do the right thing. Go back to the basics of the program. Restart monitoring, focus on regular eating, and use any other skills that helped you before. Be your own therapist.',
                    'Step 3: Identify and address the trigger. Think hard about what caused the slip. Once you know the "why," you can use your problem-solving skills to deal with the root cause.'
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
