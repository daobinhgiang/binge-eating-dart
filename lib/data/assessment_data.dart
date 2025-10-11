import '../models/assessment.dart';
import '../models/assessment_question.dart';

class AssessmentData {
  // EDE-Q (Eating Disorder Examination Questionnaire)
  static Assessment getEDEQAssessment() {
    return Assessment(
      id: 'edeq_assessment',
      title: 'Eating Disorder Examination Questionnaire (EDE-Q)',
      description: 'This questionnaire asks about your eating habits, thoughts, and feelings over the past 28 days. Please answer all questions honestly.',
      lessonId: 'lesson_2_1',
      questions: [
        // Restraint subscale
        AssessmentQuestion(
          id: 'edeq_1',
          questionText: 'Over the past 28 days, how many days have you been deliberately trying to limit the amount of food you eat to influence your shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_2',
          questionText: 'Over the past 28 days, how many days have you gone for long periods of time (8 waking hours or more) without eating anything at all in order to influence your shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_3',
          questionText: 'Over the past 28 days, how many days have you tried to exclude from your diet any foods that you like in order to influence your shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_4',
          questionText: 'Over the past 28 days, how many days have you tried to follow definite rules regarding your eating (for example, a calorie limit) in order to influence your shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_5',
          questionText: 'Over the past 28 days, how many days have you had a definite desire to have an empty stomach with the aim of influencing your shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_6',
          questionText: 'Over the past 28 days, how many days have you had a definite desire to have a totally flat stomach?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        
        // Eating concern subscale
        AssessmentQuestion(
          id: 'edeq_7',
          questionText: 'Over the past 28 days, how many days have you had a definite fear of losing control over eating?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_8',
          questionText: 'Over the past 28 days, how many days have you had a definite fear of gaining weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_9',
          questionText: 'Over the past 28 days, how many days have you felt fat?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_10',
          questionText: 'Over the past 28 days, how many days have you had a definite desire to lose weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        
        // Shape concern subscale
        AssessmentQuestion(
          id: 'edeq_11',
          questionText: 'Over the past 28 days, how many days have you had a definite preoccupation with shape or weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_12',
          questionText: 'Over the past 28 days, how many days have you had a definite dissatisfaction with your shape?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_13',
          questionText: 'Over the past 28 days, how many days have you had a definite discomfort seeing your body?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_14',
          questionText: 'Over the past 28 days, how many days have you had a definite feeling of being ashamed of your body?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        
        // Weight concern subscale
        AssessmentQuestion(
          id: 'edeq_15',
          questionText: 'Over the past 28 days, how many days have you had a definite dissatisfaction with your weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_16',
          questionText: 'Over the past 28 days, how many days have you had a definite preoccupation with weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_17',
          questionText: 'Over the past 28 days, how many days have you had a definite desire to lose weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
        AssessmentQuestion(
          id: 'edeq_18',
          questionText: 'Over the past 28 days, how many days have you had a definite fear of gaining weight?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 6,
          scaleLabel: 'No days (0) to Every day (6)',
        ),
      ],
    );
  }

  // CIA (Clinical Impairment Assessment)
  static Assessment getCIAAssessment() {
    return Assessment(
      id: 'cia_assessment',
      title: 'Clinical Impairment Assessment (CIA)',
      description: 'This questionnaire asks about how your eating habits, thoughts, and feelings have affected your life over the past 28 days.',
      lessonId: 'lesson_2_2',
      questions: [
        AssessmentQuestion(
          id: 'cia_1',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your personal relationships?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_2',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your social life?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_3',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your family life?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_4',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your work or studies?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_5',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your leisure activities?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_6',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your ability to concentrate?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_7',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your sleep?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_8',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your mood?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_9',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your self-esteem?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
        AssessmentQuestion(
          id: 'cia_10',
          questionText: 'Over the past 28 days, how much has your eating habits, thoughts, or feelings about food, eating, or your body interfered with your ability to cope with stress?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 3,
          scaleLabel: 'Not at all (0) to A lot (3)',
        ),
      ],
    );
  }

  // General Psychiatric Features Measure
  static Assessment getGeneralPsychiatricAssessment() {
    return Assessment(
      id: 'general_psychiatric_assessment',
      title: 'General Psychiatric Features Assessment',
      description: 'This questionnaire asks about your general mental health and well-being over the past 28 days.',
      lessonId: 'lesson_2_3',
      questions: [
        AssessmentQuestion(
          id: 'gpf_1',
          questionText: 'Over the past 28 days, how often have you felt depressed or sad?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_2',
          questionText: 'Over the past 28 days, how often have you felt anxious or worried?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_3',
          questionText: 'Over the past 28 days, how often have you felt irritable or angry?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_4',
          questionText: 'Over the past 28 days, how often have you had trouble sleeping?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_5',
          questionText: 'Over the past 28 days, how often have you felt overwhelmed by daily tasks?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_6',
          questionText: 'Over the past 28 days, how often have you felt like you had little control over your life?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_7',
          questionText: 'Over the past 28 days, how often have you felt hopeless about the future?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_8',
          questionText: 'Over the past 28 days, how often have you felt like you were a burden to others?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_9',
          questionText: 'Over the past 28 days, how often have you had thoughts of hurting yourself?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
        AssessmentQuestion(
          id: 'gpf_10',
          questionText: 'Over the past 28 days, how often have you felt like you needed professional help for your mental health?',
          questionType: 'scale',
          minValue: 0,
          maxValue: 4,
          scaleLabel: 'Never (0) to Always (4)',
        ),
      ],
    );
  }

  // Chapter 1 Quiz - Stage 1
  static Assessment getChapter1Quiz() {
    return Assessment(
      id: 'quiz_chapter_1',
      title: 'Chapter 1 Review Quiz',
      description: 'Test your understanding of the key concepts from Chapter 1: Introduction to treatment, monitoring, and regular eating.',
      lessonId: 'quiz_1_chapter_1',
      questions: [
        AssessmentQuestion(
          id: 'quiz_1_q1',
          questionText: 'What are the four main stages of this treatment program?',
          questionType: 'multiple_choice',
          options: [
            'Starting Well, Taking Stock, The Core Work, Ending Well',
            'Introduction, Practice, Mastery, Maintenance',
            'Assessment, Planning, Implementation, Review',
            'Understanding, Accepting, Changing, Maintaining'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q2',
          questionText: 'Which of the following is the MOST important tool for becoming aware of your eating patterns?',
          questionType: 'multiple_choice',
          options: [
            'Real-time monitoring in your Food Diary',
            'Weekly check-ins with your therapist',
            'Counting calories at the end of each day',
            'Taking photos of all your meals'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q3',
          questionText: 'According to the program, what is the PRIMARY goal of self-monitoring?',
          questionType: 'multiple_choice',
          options: [
            'To become aware of your patterns and gain control',
            'To feel guilty about what you eat',
            'To restrict your food intake',
            'To track calories and lose weight'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q4',
          questionText: 'What is the recommended frequency for weighing yourself?',
          questionType: 'multiple_choice',
          options: [
            'Once a week at the same time',
            'Every day to track progress',
            'Never, to avoid triggering feelings',
            'Multiple times per day to stay aware'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q5',
          questionText: 'What is the purpose of establishing a pattern of regular eating?',
          questionType: 'multiple_choice',
          options: [
            'To reduce binge eating and regain control',
            'To lose weight quickly',
            'To eat as much as possible',
            'To avoid feeling hungry'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q6',
          questionText: 'According to the regular eating plan, what is the maximum time you should go without eating?',
          questionType: 'multiple_choice',
          options: [
            '4 hours',
            '2 hours',
            '6 hours',
            '8 hours'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q7',
          questionText: 'What should you do if you don\'t feel hungry at a planned meal time?',
          questionType: 'multiple_choice',
          options: [
            'Eat anyway, as your hunger signals may be unreliable',
            'Skip the meal and wait until you feel hungry',
            'Eat double at the next meal',
            'Only drink water or tea'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q8',
          questionText: 'What does CBT-E focus on?',
          questionType: 'multiple_choice',
          options: [
            'The things that are keeping the problem going right now',
            'Uncovering childhood trauma',
            'Analyzing your dreams and subconscious',
            'Understanding your family history'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q9',
          questionText: 'When should you record information in your Food Diary?',
          questionType: 'multiple_choice',
          options: [
            'As soon as possible after eating (in real-time)',
            'At the end of each day',
            'Once a week during review',
            'Only after binge episodes'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_1_q10',
          questionText: 'True or False: Most people find that regular eating actually decreases the frequency of binge eating.',
          questionType: 'multiple_choice',
          options: [
            'True',
            'False'
          ],
        ),
      ],
    );
  }

  // Chapter 3 Quiz - Stage 1
  static Assessment getChapter3Quiz() {
    return Assessment(
      id: 'quiz_chapter_3',
      title: 'Chapter 3 Review Quiz',
      description: 'Test your understanding of the key psychoeducational concepts about dieting, self-worth, binge eating, and recovery.',
      lessonId: 'quiz_3_chapter_3',
      questions: [
        AssessmentQuestion(
          id: 'quiz_3_q1',
          questionText: 'According to the program, what is the PRIMARY cause of binge eating?',
          questionType: 'multiple_choice',
          options: [
            'Strict dieting and food restriction',
            'Lack of willpower',
            'Emotional problems',
            'Genetic predisposition'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q2',
          questionText: 'What are the three main types of problematic dieting mentioned in the program?',
          questionType: 'multiple_choice',
          options: [
            'Delaying eating, drastic restriction, and avoiding forbidden foods',
            'Counting calories, weighing food, and meal timing',
            'Low-carb, low-fat, and high-protein diets',
            'Intermittent fasting, keto, and paleo diets'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q3',
          questionText: 'What is the "all-or-nothing" mindset in relation to dieting?',
          questionType: 'multiple_choice',
          options: [
            'Viewing foods as either "good" or "bad" with no middle ground',
            'Eating either very little or very much',
            'Following diets perfectly or not at all',
            'All of the above'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q4',
          questionText: 'What does "overevaluation of shape and weight" mean?',
          questionType: 'multiple_choice',
          options: [
            'Judging self-worth largely based on body shape and weight',
            'Being overly concerned about health',
            'Having realistic body image goals',
            'Following a balanced exercise routine'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q5',
          questionText: 'What are the two key ingredients that define a true binge?',
          questionType: 'multiple_choice',
          options: [
            'Excessive amount of food AND a sense of loss of control',
            'Eating quickly AND feeling guilty',
            'Eating alone AND feeling ashamed',
            'Eating at night AND feeling out of control'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q6',
          questionText: 'What type of foods are most commonly eaten during binges?',
          questionType: 'multiple_choice',
          options: [
            'Foods that the person is trying to avoid (forbidden foods)',
            'High-protein foods',
            'Low-calorie foods',
            'Raw vegetables'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q7',
          questionText: 'How effective is vomiting at removing calories from a binge?',
          questionType: 'multiple_choice',
          options: [
            'Only about 50% of calories are removed',
            '100% of calories are removed',
            '75% of calories are removed',
            '25% of calories are removed'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q8',
          questionText: 'What does the program say about "feeling fat"?',
          questionType: 'multiple_choice',
          options: [
            'It\'s often a disguised emotion, not actually about body size',
            'It\'s always a sign of being overweight',
            'It\'s a normal feeling everyone has',
            'It\'s only related to actual weight gain'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q9',
          questionText: 'Why is the "food addiction" model considered harmful for binge eating?',
          questionType: 'multiple_choice',
          options: [
            'It suggests abstinence from foods, which actually makes binges worse',
            'It focuses on the wrong causes and solutions',
            'It ignores the role of dieting in causing binges',
            'All of the above'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_3_q10',
          questionText: 'What does CBT-E focus on to help with recovery?',
          questionType: 'multiple_choice',
          options: [
            'Breaking current cycles that maintain the problem',
            'Understanding childhood trauma',
            'Finding the root cause in the past',
            'Medication management'
          ],
        ),
      ],
    );
  }

  // Chapter 0 Quiz - Stage 2
  static Assessment getChapter0Quiz() {
    return Assessment(
      id: 'quiz_chapter_0',
      title: 'Chapter 0 Review Quiz',
      description: 'Test your understanding of the foundational concepts for beginning your recovery journey.',
      lessonId: 'quiz_0_chapter_0',
      questions: [
        AssessmentQuestion(
          id: 'quiz_0_q1',
          questionText: 'What is the most important factor for lasting change in eating habits?',
          questionType: 'multiple_choice',
          options: [
            'Having a genuine desire to change for yourself',
            'Following a strict diet plan',
            'Having a support person',
            'Using medication'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q2',
          questionText: 'What are the main advantages of stopping binge eating?',
          questionType: 'multiple_choice',
          options: [
            'Improved self-respect, better relationships, and enhanced quality of life',
            'Guaranteed weight loss',
            'Elimination of all food cravings',
            'Perfect eating habits'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q3',
          questionText: 'What is the best time to start your recovery journey?',
          questionType: 'multiple_choice',
          options: [
            'Now, if you\'re committed to change',
            'When you have a perfect schedule',
            'After a major life event',
            'When you feel completely ready'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q4',
          questionText: 'When should you seek professional help instead of using self-help alone?',
          questionType: 'multiple_choice',
          options: [
            'If you are underweight, have serious health conditions, or are struggling with depression',
            'If you have tried self-help before',
            'If you are over 30 years old',
            'If you have a busy schedule'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q5',
          questionText: 'What typically happens to weight when people follow this program?',
          questionType: 'multiple_choice',
          options: [
            'Weight usually remains stable as binge calories are replaced with regular meals',
            'Everyone loses weight',
            'Everyone gains weight',
            'Weight changes are unpredictable'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q6',
          questionText: 'What is the recommended approach for using Nurtra?',
          questionType: 'multiple_choice',
          options: [
            'Follow the steps in order, work at your own pace, and be patient with the process',
            'Skip to the most relevant sections',
            'Complete everything in one week',
            'Only use the parts that seem easy'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q7',
          questionText: 'How long does it typically take to work through the Nurtra program?',
          questionType: 'multiple_choice',
          options: [
            '4 to 6 months',
            '1 month',
            '1 year',
            '2 weeks'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q8',
          questionText: 'What should you do if you\'re unsure whether a step applies to your situation?',
          questionType: 'multiple_choice',
          options: [
            'Give it a try and see how it works for you',
            'Skip it and move to the next step',
            'Ask someone else to do it for you',
            'Wait until you feel more confident'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q9',
          questionText: 'What is the purpose of weekly reviews in the program?',
          questionType: 'multiple_choice',
          options: [
            'To track your progress and stay on course',
            'To identify all your mistakes',
            'To compare yourself to others',
            'To plan your meals for the week'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_0_q10',
          questionText: 'True or False: It\'s normal to still feel urges to binge even after you stop binge eating.',
          questionType: 'multiple_choice',
          options: [
            'True - urges will get weaker and less frequent over time',
            'False - urges should disappear immediately',
            'True - but only if you\'re doing something wrong',
            'False - urges only happen if you\'re not following the program correctly'
          ],
        ),
      ],
    );
  }

  // Chapter 1 Quiz - Stage 2
  static Assessment getChapter1Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_1_stage_2',
      title: 'Chapter 1 Review Quiz',
      description: 'Test your understanding of self-monitoring, weighing, and progress tracking concepts.',
      lessonId: 'quiz_1_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_1_q1',
          questionText: 'What are the two main purposes of self-monitoring?',
          questionType: 'multiple_choice',
          options: [
            'To give you important information and to help you start changing',
            'To track calories and lose weight',
            'To identify all your mistakes',
            'To compare yourself to others'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q2',
          questionText: 'What three things will you learn through self-monitoring?',
          questionType: 'multiple_choice',
          options: [
            'WHAT you eat, WHEN you eat, and WHY you eat',
            'How many calories you consume, your weight, and your exercise',
            'What foods to avoid, when to eat, and how much to eat',
            'Your BMI, your body fat percentage, and your muscle mass'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q3',
          questionText: 'How often should you weigh yourself according to the program?',
          questionType: 'multiple_choice',
          options: [
            'Once a week',
            'Every day',
            'Twice a week',
            'Only when you feel like it'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q4',
          questionText: 'Why is once-a-week weighing better than daily weighing?',
          questionType: 'multiple_choice',
          options: [
            'Daily weigh-ins can be misleading due to normal fluctuations',
            'It saves time',
            'It\'s more accurate',
            'It prevents weight gain'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q5',
          questionText: 'What should you do if you feel resistant to monitoring?',
          questionType: 'multiple_choice',
          options: [
            'Give the structured approach a chance and remember it\'s a private record',
            'Skip monitoring and move to the next step',
            'Only monitor on good days',
            'Ask someone else to monitor for you'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q6',
          questionText: 'How often should you do review sessions with yourself?',
          questionType: 'multiple_choice',
          options: [
            'Twice a week',
            'Once a month',
            'Every day',
            'Only when you have problems'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q7',
          questionText: 'What is a "Change Day"?',
          questionType: 'multiple_choice',
          options: [
            'Any day where you did your best to monitor accurately and weigh in only once a week',
            'A day when you didn\'t binge eat',
            'A day when you lost weight',
            'A day when you followed a perfect diet'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q8',
          questionText: 'How many Change Days per week indicate you\'re ready for the next step?',
          questionType: 'multiple_choice',
          options: [
            '6-7 Change Days a week',
            '3-4 Change Days a week',
            'Every single day',
            'At least 5 days'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q9',
          questionText: 'What should you focus on when looking at your monitoring records?',
          questionType: 'multiple_choice',
          options: [
            'Patterns in timing, triggers, and types of food eaten',
            'Counting calories and tracking weight loss',
            'Comparing yourself to others',
            'Finding all your mistakes'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_1_q10',
          questionText: 'True or False: Self-monitoring might make you more obsessed with food at first, but this feeling fades quickly.',
          questionType: 'multiple_choice',
          options: [
            'True',
            'False'
          ],
        ),
      ],
    );
  }

  // Chapter 2 Quiz - Stage 2
  static Assessment getChapter2Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_2_stage_2',
      title: 'Chapter 2 Review Quiz',
      description: 'Test your understanding of regular eating patterns, purging behaviors, and meal planning strategies.',
      lessonId: 'quiz_2_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_2_q1',
          questionText: 'What is the most important first step in overcoming binge eating?',
          questionType: 'multiple_choice',
          options: [
            'Establishing a pattern of regular eating',
            'Avoiding all trigger foods',
            'Exercising more',
            'Taking medication'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q2',
          questionText: 'What are the four rules of regular eating?',
          questionType: 'multiple_choice',
          options: [
            'Plan ahead, don\'t skip, focus on when not what, mind the gaps',
            'Count calories, avoid carbs, eat protein, exercise daily',
            'Eat small portions, avoid snacks, drink water, sleep well',
            'Skip breakfast, eat lunch, have dinner, avoid late night eating'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q3',
          questionText: 'What is the 4-hour rule?',
          questionType: 'multiple_choice',
          options: [
            'Try not to go more than four hours without eating',
            'Eat four meals a day',
            'Wait four hours between snacks',
            'Exercise for four hours daily'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q4',
          questionText: 'If your eating is very chaotic, what should you do?',
          questionType: 'multiple_choice',
          options: [
            'Start small with just breakfast and lunch, then build gradually',
            'Skip all meals for a day',
            'Eat only one meal a day',
            'Follow a strict diet plan'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q5',
          questionText: 'What should you do if you have a binge?',
          questionType: 'multiple_choice',
          options: [
            'Get back to your planned schedule with the very next meal or snack',
            'Skip the next meal to compensate',
            'Start over the next day',
            'Eat less for the rest of the week'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q6',
          questionText: 'How are vomiting and binge eating connected?',
          questionType: 'multiple_choice',
          options: [
            'For most people, the urge to vomit is tied directly to binge eating',
            'They are completely unrelated',
            'Vomiting always comes before binge eating',
            'Only people with bulimia vomit after binges'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q7',
          questionText: 'How long do vomiting urges typically last after eating?',
          questionType: 'multiple_choice',
          options: [
            'About an hour, then they start to fade',
            'All day',
            'Just a few minutes',
            'Several hours'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q8',
          questionText: 'What should you do if you\'ve been taking laxatives daily?',
          questionType: 'multiple_choice',
          options: [
            'Phase them out gradually by cutting your daily amount in half each week',
            'Stop taking them immediately',
            'Increase the dosage',
            'Switch to a different type'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q9',
          questionText: 'What should you do with leftovers to avoid temptation?',
          questionType: 'multiple_choice',
          options: [
            'It\'s often best to discard leftovers, especially in the beginning',
            'Save them for the next meal',
            'Give them to someone else',
            'Freeze them for later'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_2_q10',
          questionText: 'How many change days per week indicate you\'re ready for Step 3?',
          questionType: 'multiple_choice',
          options: [
            'Six or seven change days each week',
            'Three or four change days each week',
            'Every single day',
            'At least five days'
          ],
        ),
      ],
    );
  }

  // Chapter 3 Quiz - Stage 2
  static Assessment getChapter3Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_3_stage_2',
      title: 'Chapter 3 Review Quiz',
      description: 'Test your understanding of alternative activities, urge surfing, and weight management during recovery.',
      lessonId: 'quiz_3_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_3_q1',
          questionText: 'How long do urges typically last?',
          questionType: 'multiple_choice',
          options: [
            'The most intense part usually lasts for an hour or so',
            'All day',
            'Just a few minutes',
            'Several hours'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q2',
          questionText: 'What are the three keys to a great alternative activity?',
          questionType: 'multiple_choice',
          options: [
            'It\'s active, enjoyable, and realistic',
            'It\'s quick, easy, and cheap',
            'It\'s social, fun, and healthy',
            'It\'s quiet, relaxing, and private'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q3',
          questionText: 'What should you do when you feel an urge to binge?',
          questionType: 'multiple_choice',
          options: [
            'Acknowledge the urge, let time pass, and engage in a distracting activity',
            'Ignore the urge and try to forget about it',
            'Eat a small snack to satisfy the urge',
            'Go to bed and sleep it off'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q4',
          questionText: 'What is "urge surfing"?',
          questionType: 'multiple_choice',
          options: [
            'The process of riding out an urge until it passes',
            'A type of exercise to burn calories',
            'A meditation technique',
            'A way to track your weight'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q5',
          questionText: 'What should you do if you notice other difficult emotions as you stop bingeing?',
          questionType: 'multiple_choice',
          options: [
            'This is a good sign - it means you can now address them directly',
            'Try to ignore them and focus only on eating',
            'Go back to bingeing to avoid these feelings',
            'Take medication to suppress the emotions'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q6',
          questionText: 'What should you do with your list of alternative activities?',
          questionType: 'multiple_choice',
          options: [
            'Write it down and keep it accessible',
            'Memorize it and throw it away',
            'Share it with everyone you know',
            'Only use it when you\'re alone'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q7',
          questionText: 'What is the most important thing to remember about weight fluctuations?',
          questionType: 'multiple_choice',
          options: [
            'Short-term changes of 1-3 pounds are usually due to hydration shifts, not body fat',
            'Weight should never change',
            'All weight changes are permanent',
            'Weight changes only happen when you binge'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q8',
          questionText: 'How long should you look at weight trends to understand what\'s really happening?',
          questionType: 'multiple_choice',
          options: [
            'At least four weeks of data',
            'Just one week',
            'Two days',
            'One month'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q9',
          questionText: 'What should you do if your weight has consistently changed?',
          questionType: 'multiple_choice',
          options: [
            'Approach the information calmly and thoughtfully without making drastic changes',
            'Start a strict diet immediately',
            'Stop weighing yourself',
            'Double your exercise routine'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_3_q10',
          questionText: 'What is the most important rule about weight changes?',
          questionType: 'multiple_choice',
          options: [
            'Do not react by starting a strict diet',
            'Weigh yourself daily to track changes',
            'Avoid all high-calorie foods',
            'Exercise more to compensate'
          ],
        ),
      ],
    );
  }

  // Chapter 4 Quiz - Stage 2
  static Assessment getChapter4Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_4_stage_2',
      title: 'Chapter 4 Review Quiz',
      description: 'Test your understanding of problem-solving skills and their application in recovery.',
      lessonId: 'quiz_4_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_4_q1',
          questionText: 'What is the goal of problem-solving in recovery?',
          questionType: 'multiple_choice',
          options: [
            'To get better at the process of fixing problems, not just fix individual problems',
            'To avoid all problems in life',
            'To only solve eating-related problems',
            'To eliminate the need for help from others'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q2',
          questionText: 'How often should you practice problem-solving?',
          questionType: 'multiple_choice',
          options: [
            'Every day, looking for opportunities to practice whenever problems arise',
            'Only when you have major problems',
            'Once a week',
            'Only when you feel like it'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q3',
          questionText: 'What are the six steps of problem-solving?',
          questionType: 'multiple_choice',
          options: [
            'Define the problem, generate solutions, evaluate options, choose best solution, implement, review',
            'Ignore the problem, wait for it to go away, ask for help, give up, try again, succeed',
            'Think about it, talk to friends, make a decision, act, hope for the best, move on',
            'Identify the issue, brainstorm ideas, pick one, do it, check results, celebrate'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q4',
          questionText: 'What is the most important part of problem-solving practice?',
          questionType: 'multiple_choice',
          options: [
            'Reviewing your work the next day to see how you problem-solved',
            'Solving the problem quickly',
            'Getting the right answer',
            'Avoiding mistakes'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q5',
          questionText: 'What should you do if problem-solving feels "obsessive" at first?',
          questionType: 'multiple_choice',
          options: [
            'Remind yourself that you are actively learning a new skill and it won\'t feel this intense forever',
            'Stop practicing immediately',
            'Only practice when you have big problems',
            'Ask someone else to solve your problems'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q6',
          questionText: 'What is a "change day" in Step 4?',
          questionType: 'multiple_choice',
          options: [
            'A day where you monitored, weighed weekly, did regular eating, used alternative activities, AND practiced problem-solving',
            'A day when you didn\'t binge eat',
            'A day when you solved all your problems',
            'A day when you felt happy'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q7',
          questionText: 'When is it time to move on to Step 5?',
          questionType: 'multiple_choice',
          options: [
            'When binge eating has become infrequent or you\'ve been practicing skills for 6-8 weeks',
            'When you\'ve solved all your problems',
            'When you feel completely recovered',
            'When you\'ve been in the program for one month'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q8',
          questionText: 'What is the benefit of writing down your problem-solving steps?',
          questionType: 'multiple_choice',
          options: [
            'It\'s much more effective than just thinking them through in your head',
            'It makes the problem go away faster',
            'It impresses other people',
            'It prevents you from making mistakes'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q9',
          questionText: 'What should you do when you face a problem?',
          questionType: 'multiple_choice',
          options: [
            'Consciously go through the six steps of problem-solving',
            'Ask someone else to solve it for you',
            'Ignore it and hope it goes away',
            'Make a quick decision without thinking'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_4_q10',
          questionText: 'What is the key to making problem-solving effective and automatic?',
          questionType: 'multiple_choice',
          options: [
            'Following the steps consistently and practicing regularly',
            'Only solving easy problems',
            'Getting help from others',
            'Avoiding difficult problems'
          ],
        ),
      ],
    );
  }

  // Chapter 5 Quiz - Stage 2
  static Assessment getChapter5Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_5_stage_2',
      title: 'Chapter 5 Review Quiz',
      description: 'Test your understanding of taking stock and planning your recovery journey.',
      lessonId: 'quiz_5_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_5_q1',
          questionText: 'What is the purpose of taking stock in Step 5?',
          questionType: 'multiple_choice',
          options: [
            'To honestly see where you are so you can choose the best next step',
            'To judge your progress harshly',
            'To compare yourself to others',
            'To decide if you should give up'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q2',
          questionText: 'What are the signs that things are going well in your recovery?',
          questionType: 'multiple_choice',
          options: [
            'Binges have become less frequent and you\'ve reduced or stopped purging behaviors',
            'You never think about food anymore',
            'You\'ve lost a lot of weight',
            'You feel completely recovered'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q3',
          questionText: 'What should you do if you haven\'t been able to follow the program closely?',
          questionType: 'multiple_choice',
          options: [
            'Be honest with yourself and reconnect with your motivation',
            'Give up and try a different program',
            'Blame yourself for not trying hard enough',
            'Ignore the problem and continue anyway'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q4',
          questionText: 'What should you do if you\'ve been trying your best but binge eating hasn\'t improved much?',
          questionType: 'multiple_choice',
          options: [
            'Consider seeking professional help as this may indicate the program isn\'t enough on its own',
            'Try harder and work longer hours',
            'Give up completely',
            'Blame yourself for not trying hard enough'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q5',
          questionText: 'What are the two key areas to explore for your next steps?',
          questionType: 'multiple_choice',
          options: [
            'The dieting connection and the body image connection',
            'Exercise and nutrition',
            'Medication and therapy',
            'Social support and family relationships'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q6',
          questionText: 'How can you tell if dieting contributes to your binge eating?',
          questionType: 'multiple_choice',
          options: [
            'Your binges often happen after you\'ve broken a diet rule or tried to restrict',
            'You never diet',
            'You only binge when you\'re not dieting',
            'Dieting always prevents binges'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q7',
          questionText: 'How can you tell if body image concerns contribute to your binge eating?',
          questionType: 'multiple_choice',
          options: [
            'You find yourself dieting because you\'re unhappy with your body, which then leads to a binge',
            'You never think about your body',
            'You only binge when you feel good about your body',
            'Body image has no connection to eating'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q8',
          questionText: 'What should you do if both dieting and body image feel like important issues?',
          questionType: 'multiple_choice',
          options: [
            'Start with the one that feels like the biggest trigger and focus on it for 3-4 weeks',
            'Try to work on both at the same time immediately',
            'Choose randomly which one to work on first',
            'Avoid both issues entirely'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q9',
          questionText: 'What should you remember to keep practicing while working on new areas?',
          questionType: 'multiple_choice',
          options: [
            'All the skills you learned in Steps 1 through 4',
            'Only the most recent skills',
            'Only the skills that feel easy',
            'Only the skills that others recommend'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_5_q10',
          questionText: 'What is the most important thing to remember when taking stock?',
          questionType: 'multiple_choice',
          options: [
            'Be proud of yourself for taking the brave step of starting this program',
            'Compare your progress to others',
            'Focus only on your failures',
            'Expect perfection from yourself'
          ],
        ),
      ],
    );
  }

  // Chapter 6 Quiz - Stage 2
  static Assessment getChapter6Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_6_stage_2',
      title: 'Chapter 6 Review Quiz',
      description: 'Test your understanding of making peace with food and addressing strict dieting patterns.',
      lessonId: 'quiz_6_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_6_q1',
          questionText: 'What are the three main forms of strict dieting that can trigger binges?',
          questionType: 'multiple_choice',
          options: [
            'Delaying eating, restricting calories, and avoiding forbidden foods',
            'Eating too much, eating too little, and eating at wrong times',
            'Counting calories, weighing food, and measuring portions',
            'Avoiding carbs, avoiding fat, and avoiding sugar'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q2',
          questionText: 'What is the problem with delaying eating?',
          questionType: 'multiple_choice',
          options: [
            'It creates intense physical and mental pressure to eat',
            'It helps you lose weight faster',
            'It makes you more disciplined',
            'It prevents overeating'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q3',
          questionText: 'What calorie limit makes you more likely to binge?',
          questionType: 'multiple_choice',
          options: [
            'Under 1,500 calories per day',
            'Over 2,000 calories per day',
            'Exactly 1,200 calories per day',
            'Any calorie limit'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q4',
          questionText: 'What is the first step in facing forbidden foods?',
          questionType: 'multiple_choice',
          options: [
            'Make a list of all the foods you\'re afraid to eat',
            'Avoid all forbidden foods completely',
            'Eat only forbidden foods',
            'Ask someone else to choose for you'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q5',
          questionText: 'How should you reintroduce forbidden foods?',
          questionType: 'multiple_choice',
          options: [
            'Start with the least scary foods and include small portions in planned meals',
            'Eat large amounts of forbidden foods immediately',
            'Only eat forbidden foods when you\'re alone',
            'Never eat forbidden foods again'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q6',
          questionText: 'What is a "change day" in the dieting module?',
          questionType: 'multiple_choice',
          options: [
            'A day where you actively tackled strict dieting along with other skills',
            'A day when you didn\'t eat any forbidden foods',
            'A day when you lost weight',
            'A day when you felt happy'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q7',
          questionText: 'How long should you practice the dieting module?',
          questionType: 'multiple_choice',
          options: [
            'At least a month or two to feel comfortable and confident',
            'Just one week',
            'Until you lose weight',
            'Only when you feel like it'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q8',
          questionText: 'Why is it important to persevere with the dieting module?',
          questionType: 'multiple_choice',
          options: [
            'Strict dieting is often what makes you most vulnerable to binge eating',
            'It helps you lose weight faster',
            'It makes you more disciplined',
            'It prevents you from eating too much'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q9',
          questionText: 'What should you do if you\'re working on both dieting and body image modules?',
          questionType: 'multiple_choice',
          options: [
            'Continue to practice both as they are often connected',
            'Choose only one to work on',
            'Stop working on both',
            'Work on them at different times of day'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_6_q10',
          questionText: 'What is the surprising truth about stopping restriction?',
          questionType: 'multiple_choice',
          options: [
            'When you stop restricting so much, you\'ll likely binge less and may eat less overall',
            'You will definitely gain weight',
            'You will binge more often',
            'You will lose control completely'
          ],
        ),
      ],
    );
  }

  // Chapter 7 Quiz - Stage 2
  static Assessment getChapter7Stage2Quiz() {
    return Assessment(
      id: 'quiz_chapter_7_stage_2',
      title: 'Chapter 7 Review Quiz',
      description: 'Test your understanding of body image concerns and developing a healthier relationship with your body.',
      lessonId: 'quiz_7_stage_2',
      questions: [
        AssessmentQuestion(
          id: 'quiz_s2_7_q1',
          questionText: 'What is a sign of overconcern with shape and weight?',
          questionType: 'multiple_choice',
          options: [
            'If the slice for shape and weight takes up a third of your pie chart or more',
            'If you think about your body once a day',
            'If you weigh yourself once a week',
            'If you exercise regularly'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q2',
          questionText: 'What are the two strategies for rebalancing your pie chart?',
          questionType: 'multiple_choice',
          options: [
            'Grow the other slices and shrink the shape and weight slice',
            'Only focus on shape and weight',
            'Ignore all other areas of life',
            'Compare yourself to others more often'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q3',
          questionText: 'What is shape checking?',
          questionType: 'multiple_choice',
          options: [
            'The habit of repeatedly checking parts of your body',
            'Avoiding looking at your body',
            'Weighing yourself once a week',
            'Exercising regularly'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q4',
          questionText: 'What should you do with unusual checking behaviors?',
          questionType: 'multiple_choice',
          options: [
            'Stop them completely',
            'Do them more often',
            'Only do them when alone',
            'Ask others to do them for you'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q5',
          questionText: 'What is a good reason to use a mirror?',
          questionType: 'multiple_choice',
          options: [
            'Checking your hair, applying makeup, or shaving',
            'Studying your body for flaws',
            'Comparing yourself to others',
            'Avoiding your reflection'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q6',
          questionText: 'What is shape avoidance?',
          questionType: 'multiple_choice',
          options: [
            'Trying not to see or be aware of your body because you dislike how it looks',
            'Exercising regularly',
            'Eating healthy foods',
            'Avoiding mirrors completely'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q7',
          questionText: 'What is the most effective way to address shape avoidance?',
          questionType: 'multiple_choice',
          options: [
            'Gentle, progressive exposure to your body',
            'Avoiding your body completely',
            'Only looking at your body when you feel good',
            'Asking others to describe your body'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q8',
          questionText: 'What does "feeling fat" really mean?',
          questionType: 'multiple_choice',
          options: [
            'It\'s a feeling, not a fact about your body, and often represents other emotions',
            'It means you are actually fat',
            'It only happens when you gain weight',
            'It\'s always accurate'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q9',
          questionText: 'What should you do when you "feel fat"?',
          questionType: 'multiple_choice',
          options: [
            'Ask yourself what might be the real cause and address the underlying issue',
            'Immediately try to lose weight',
            'Avoid eating anything',
            'Ignore the feeling completely'
          ],
        ),
        AssessmentQuestion(
          id: 'quiz_s2_7_q10',
          questionText: 'How long does it take to change your body image?',
          questionType: 'multiple_choice',
          options: [
            'Many months of practice',
            'Just a few days',
            'One week',
            'Only when you lose weight'
          ],
        ),
      ],
    );
  }

  // Get assessment by lesson ID
  static Assessment? getAssessmentByLessonId(String lessonId) {
    switch (lessonId) {
      case 'lesson_2_1':
        return getEDEQAssessment();
      case 'lesson_2_2':
        return getCIAAssessment();
      case 'lesson_2_3':
        return getGeneralPsychiatricAssessment();
      case 'lesson_s3_0_3':
        return getEDEQAssessment();
      case 'lesson_s3_0_4':
        return getCIAAssessment();
      case 'quiz_1_chapter_1':
        return getChapter1Quiz();
      case 'quiz_3_chapter_3':
        return getChapter3Quiz();
      case 'quiz_0_chapter_0':
        return getChapter0Quiz();
      case 'quiz_1_stage_2':
        return getChapter1Stage2Quiz();
      case 'quiz_2_stage_2':
        return getChapter2Stage2Quiz();
      case 'quiz_3_stage_2':
        return getChapter3Stage2Quiz();
      case 'quiz_4_stage_2':
        return getChapter4Stage2Quiz();
      case 'quiz_5_stage_2':
        return getChapter5Stage2Quiz();
      case 'quiz_6_stage_2':
        return getChapter6Stage2Quiz();
      case 'quiz_7_stage_2':
        return getChapter7Stage2Quiz();
      default:
        return null;
    }
  }
}
