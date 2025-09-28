import '../models/stage.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_slide.dart';

class Stage1Data {
  static Stage getStage1() {
    final now = DateTime.now();
    
    return Stage(
      stageNumber: 1,
      title: 'Introduction',
      chapters: [
        Chapter(
          chapterNumber: 1,
          title: 'Introduction',
          lessons: [
            // Lesson 1.1: Explaining what treatment will involve and the prospect of change
            Lesson(
              id: 'lesson_1_1',
              title: '1.1 Your Path to Change',
              description: 'Understanding the treatment process and building hope for recovery',
              chapterNumber: 1,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_1_1_1',
                  title: 'Welcome to Your Treatment Journey',
                  content: 'This program is designed to help you overcome your eating problem by understanding and changing the things that are keeping it going. Think of it as a collaborative journey that we\'ll take together. It\'s based on Cognitive Behavior Therapy (CBT-E), the leading evidence-based treatment for people with eating disorders. You can do this, and we are here to help.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Focus on the "Here and Now": We will concentrate on the things that are keeping the problem going right now, rather than dwelling on the past.',
                    'Tailored to You: This isn\'t a one-size-fits-all approach. The treatment will be personalized to your specific challenges and needs.',
                    'Focus on sustainable, long-term change',
                    'Personalized support throughout your journey'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_2',
                  title: 'What to Expect in Treatment',
                  content: 'Your treatment will involve learning new skills, understanding your eating patterns, and developing healthier coping strategies.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Self-monitoring and awareness building',
                    'Regular eating pattern establishment',
                    'Cognitive and behavioral skill development',
                    'Relapse prevention strategies'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_3',
                  title: 'The Prospect of Change',
                  content: 'Recovery from binge eating is absolutely possible. Many people have successfully overcome these challenges and built fulfilling lives.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Recovery is achievable with the right support',
                    'Small changes lead to significant improvements',
                    'You have the strength to overcome this challenge',
                    'Each step forward is progress worth celebrating'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_4',
                  title: 'Your Commitment to Change',
                  content: 'Success in this program requires your active participation and commitment to the process, even when it feels challenging.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Engage fully with all program components',
                    'Practice new skills consistently',
                    'Be patient and compassionate with yourself',
                    'Trust the process and stay committed to your goals'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.2: Establishing real-time self-monitoring and assign patient to start monitoring (for everything)
            Lesson(
              id: 'lesson_1_2',
              title: '1.2 Establishing real-time self-monitoring and assign patient to start monitoring (for everything)',
              description: 'Learning to track your eating patterns, emotions, and triggers in real-time',
              chapterNumber: 1,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_1_2_1',
                  title: 'The Power of Self-Monitoring',
                  content: 'Self-monitoring is one of the most effective tools for understanding and changing your eating patterns.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Increases awareness of eating behaviors',
                    'Helps identify triggers and patterns',
                    'Provides objective data about your progress',
                    'Empowers you to make informed decisions'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_2',
                  title: 'What to Monitor',
                  content: 'We\'ll track various aspects of your daily experience to get a complete picture of your relationship with food.',
                  slideNumber: 2,
                  bulletPoints: [
                    'All food and drink consumption',
                    'Emotions before, during, and after eating',
                    'Physical sensations and hunger levels',
                    'Environmental factors and triggers'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_3',
                  title: 'How to Monitor Effectively',
                  content: 'Real-time monitoring means recording information as close to the moment it happens as possible.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Record immediately after eating or drinking',
                    'Be honest and non-judgmental in your entries',
                    'Include details about context and circumstances',
                    'Use the app\'s monitoring tools consistently'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_4',
                  title: 'Starting Your Monitoring Journey',
                  content: 'Beginning today, you\'ll start monitoring all aspects of your eating and emotional experiences.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Start monitoring immediately after this lesson',
                    'Set reminders to help build the habit',
                    'Don\'t worry about being perfect - just be consistent',
                    'Review your entries regularly to identify patterns'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.3: Establishing "regular eating" and activate notification
            Lesson(
              id: 'lesson_1_3',
              title: '1.3 Establishing "regular eating" and activate notification',
              description: 'Creating a structured eating schedule to support recovery and prevent binge episodes',
              chapterNumber: 1,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_1_3_1',
                  title: 'Understanding Regular Eating',
                  content: 'Regular eating involves consuming meals and snacks at consistent times throughout the day to maintain stable blood sugar and reduce binge urges.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Prevents extreme hunger that triggers binges',
                    'Stabilizes blood sugar and energy levels',
                    'Reduces preoccupation with food',
                    'Creates structure and predictability'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_2',
                  title: 'The Regular Eating Pattern',
                  content: 'A typical regular eating pattern includes three meals and 2-3 snacks, spaced evenly throughout the day.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Breakfast within 1-2 hours of waking',
                    'Lunch 4-5 hours after breakfast',
                    'Dinner 4-5 hours after lunch',
                    'Planned snacks between meals as needed'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_3',
                  title: 'Setting Up Meal Notifications',
                  content: 'Notifications will help you remember to eat regularly, especially when you\'re not feeling hungry or are distracted.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Gentle reminders for meal and snack times',
                    'Customizable timing based on your schedule',
                    'Helps establish new eating rhythms',
                    'Reduces the mental load of meal planning'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_4',
                  title: 'Implementing Regular Eating',
                  content: 'Starting today, you\'ll begin following a regular eating schedule with the support of app notifications.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Set up your personalized meal schedule',
                    'Enable notifications for all meals and snacks',
                    'Eat according to the schedule, regardless of hunger',
                    'Trust that hunger cues will normalize over time'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 2: Assessments (optional)
        Chapter(
          chapterNumber: 2,
          title: 'Assessments (optional)',
          lessons: [
            // Lesson 2.1: Eating Disorder Examination Questionnaire (EDE-Q)
            Lesson(
              id: 'lesson_2_1',
              title: '2.1 Eating Disorder Examination Questionnaire (EDE-Q)',
              description: 'Complete the EDE-Q assessment to evaluate eating disorder symptoms',
              chapterNumber: 2,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_2_1_1',
                  title: 'Introduction to EDE-Q',
                  content: 'The Eating Disorder Examination Questionnaire (EDE-Q) is a widely used assessment tool that helps evaluate eating disorder symptoms and behaviors.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Comprehensive assessment of eating behaviors',
                    'Measures eating disorder psychopathology',
                    'Helps track progress over time',
                    'Provides baseline measurements for treatment'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_1_2',
                  title: 'What the EDE-Q Measures',
                  content: 'This assessment evaluates four key areas of eating disorder symptoms to provide a complete picture of your current state.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Restraint: Dietary restriction and food avoidance',
                    'Eating Concern: Preoccupation with food and eating',
                    'Shape Concern: Dissatisfaction with body shape',
                    'Weight Concern: Preoccupation with weight'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_1_3',
                  title: 'How to Complete the Assessment',
                  content: 'The EDE-Q asks about your experiences over the past 28 days. Answer honestly and consider your typical patterns during this period.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Reflect on the past 28 days of experiences',
                    'Answer all questions honestly and completely',
                    'Consider your typical patterns, not just recent days',
                    'Take your time to provide accurate responses'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_1_4',
                  title: 'Using Your Results',
                  content: 'Your EDE-Q results will help your treatment team understand your specific needs and track your progress throughout recovery.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Results inform personalized treatment planning',
                    'Provides baseline for measuring progress',
                    'Helps identify specific areas of focus',
                    'Can be repeated to track improvement over time'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.2: Clinical Impairment Assessment (CIA)
            Lesson(
              id: 'lesson_2_2',
              title: '2.2 Clinical Impairment Assessment (CIA)',
              description: 'Assess how eating behaviors impact your daily functioning and quality of life',
              chapterNumber: 2,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_2_2_1',
                  title: 'Understanding the CIA',
                  content: 'The Clinical Impairment Assessment (CIA) measures how eating disorder symptoms affect your daily life and overall functioning.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Measures functional impairment from eating issues',
                    'Assesses impact on daily activities',
                    'Evaluates quality of life effects',
                    'Helps prioritize treatment goals'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_2_2',
                  title: 'Areas of Life Assessment',
                  content: 'The CIA evaluates how eating concerns affect different aspects of your personal, social, and professional life.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Personal and emotional well-being',
                    'Social relationships and activities',
                    'Work or academic performance',
                    'Physical health and energy levels'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_2_3',
                  title: 'Completing the CIA',
                  content: 'Consider how your eating patterns and food-related thoughts have impacted various areas of your life over recent weeks.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Think about recent weeks, not just today',
                    'Consider both direct and indirect impacts',
                    'Include effects on relationships and activities',
                    'Be honest about functional limitations'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_2_4',
                  title: 'Treatment Planning Benefits',
                  content: 'CIA results help identify which areas of your life are most affected, allowing for targeted treatment approaches.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Identifies priority areas for improvement',
                    'Guides treatment goal setting',
                    'Measures functional recovery progress',
                    'Helps track quality of life improvements'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.3: A general psychiatric features measure
            Lesson(
              id: 'lesson_2_3',
              title: '2.3 A general psychiatric features measure',
              description: 'Complete a comprehensive assessment of general mental health symptoms',
              chapterNumber: 2,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_2_3_1',
                  title: 'General Psychiatric Assessment',
                  content: 'This assessment evaluates various mental health symptoms that commonly co-occur with eating disorders.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Comprehensive mental health screening',
                    'Identifies co-occurring conditions',
                    'Assesses mood and anxiety symptoms',
                    'Evaluates overall psychological well-being'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_3_2',
                  title: 'Common Co-occurring Conditions',
                  content: 'Many people with eating disorders also experience other mental health conditions that can impact treatment and recovery.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Depression and mood disorders',
                    'Anxiety disorders and panic symptoms',
                    'Obsessive-compulsive tendencies',
                    'Trauma-related symptoms'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_3_3',
                  title: 'Assessment Guidelines',
                  content: 'Answer questions based on your recent experiences, considering both frequency and intensity of symptoms.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Consider symptoms over the past few weeks',
                    'Rate both frequency and severity',
                    'Include symptoms even if mild',
                    'Be thorough and honest in responses'
                  ],
                ),
                LessonSlide(
                  id: 'slide_2_3_4',
                  title: 'Integrated Treatment Approach',
                  content: 'Understanding your complete mental health picture allows for comprehensive treatment that addresses all aspects of your well-being.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Enables comprehensive treatment planning',
                    'Addresses multiple conditions simultaneously',
                    'Improves overall treatment outcomes',
                    'Supports holistic recovery approach'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 3: Psychoeducation
        Chapter(
          chapterNumber: 3,
          title: 'Psychoeducation',
          lessons: [
            // Lesson 3.1: Dieting Is a Primary Cause, Not the Solution
            Lesson(
              id: 'lesson_3_1',
              title: '3.1 Dieting Is a Primary Cause, Not the Solution',
              description: 'Understanding how dieting contributes to binge eating rather than solving it',
              chapterNumber: 3,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_3_1_1',
                  title: 'The Dieting Paradox',
                  content: 'Contrary to popular belief, dieting often triggers and maintains binge eating behaviors rather than preventing them.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Dieting creates physical and psychological deprivation',
                    'Restriction leads to preoccupation with food',
                    'The body responds to dieting as a threat to survival',
                    'Binge eating is often a biological response to restriction'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_2',
                  title: 'The Restrict-Binge Cycle',
                  content: 'Dieting creates a vicious cycle where restriction leads to binge eating, which then leads to more restriction.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Restriction → Increased hunger and cravings',
                    'Deprivation → Loss of control around food',
                    'Binge eating → Guilt and shame',
                    'Guilt → More restrictive dieting'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_3',
                  title: 'Why Diets Fail',
                  content: 'Research shows that diets are not sustainable long-term and often lead to weight regain and disordered eating patterns.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Only 5% of diets result in long-term weight loss',
                    'Dieting slows metabolism and increases hunger hormones',
                    'Psychological effects include food obsession and guilt',
                    'Repeated dieting increases risk of eating disorders'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_4',
                  title: 'Breaking Free from Diet Culture',
                  content: 'Recovery involves rejecting diet mentality and learning to trust your body\'s natural hunger and fullness cues.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Recognize diet culture messages in media and society',
                    'Challenge thoughts about "good" and "bad" foods',
                    'Focus on nourishment rather than restriction',
                    'Trust your body\'s wisdom and natural regulation'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.2: The Core Problem Is Tying Self-Worth to Weight
            Lesson(
              id: 'lesson_3_2',
              title: '3.2 The Core Problem Is Tying Self-Worth to Weight',
              description: 'Exploring how linking self-worth to weight and appearance fuels eating disorders',
              chapterNumber: 3,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_3_2_1',
                  title: 'Weight-Based Self-Worth',
                  content: 'When we tie our value as a person to our weight or appearance, it creates an unstable foundation for self-esteem.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Self-worth becomes dependent on external factors',
                    'Weight fluctuations cause emotional distress',
                    'Creates pressure to control weight at any cost',
                    'Leads to shame and self-criticism'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_2',
                  title: 'The Thin Ideal Myth',
                  content: 'Society promotes the false belief that thinness equals happiness, success, and worth, but research shows this isn\'t true.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Media promotes unrealistic body standards',
                    'Thin people are not automatically happier or healthier',
                    'Body diversity is natural and normal',
                    'Health exists at many different sizes'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_3',
                  title: 'Identifying Weight-Based Thoughts',
                  content: 'Learning to recognize when your thoughts about yourself are influenced by weight or appearance concerns.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Notice "I feel fat" thoughts and emotions',
                    'Identify body-checking behaviors',
                    'Recognize appearance-based comparisons',
                    'Challenge weight-related self-criticism'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_4',
                  title: 'Building Unconditional Self-Worth',
                  content: 'Developing a sense of worth that isn\'t dependent on weight, appearance, or external validation.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Focus on personal values and character traits',
                    'Appreciate your body for what it does, not how it looks',
                    'Practice self-compassion and kindness',
                    'Cultivate interests and relationships beyond appearance'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.3: A Binge Is Defined by "Loss of Control"
            Lesson(
              id: 'lesson_3_3',
              title: '3.3 A Binge Is Defined by "Loss of Control"',
              description: 'Understanding that binge eating is characterized by loss of control, not just quantity of food',
              chapterNumber: 3,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_3_3_1',
                  title: 'Defining Binge Eating',
                  content: 'A binge episode is primarily defined by the feeling of loss of control, not necessarily by the amount of food consumed.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Loss of control is the key defining feature',
                    'Amount of food may vary between episodes',
                    'Feeling unable to stop or control eating',
                    'Eating continues despite feeling uncomfortably full'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_2',
                  title: 'Subjective vs. Objective Binges',
                  content: 'Both large amounts of food and smaller amounts can feel like binges if there\'s a loss of control present.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Objective binge: Large amount + loss of control',
                    'Subjective binge: Any amount + loss of control',
                    'Both types are valid and distressing experiences',
                    'Treatment addresses the loss of control, not food amount'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_3',
                  title: 'Recognizing Loss of Control',
                  content: 'Learning to identify the signs and feelings that indicate a loss of control around food.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Eating rapidly without tasting food',
                    'Feeling disconnected or "zoned out" while eating',
                    'Continuing to eat despite physical discomfort',
                    'Feeling unable to make conscious food choices'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_4',
                  title: 'Regaining Control',
                  content: 'Recovery focuses on developing skills to maintain a sense of control and choice around food.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Practice mindful eating techniques',
                    'Develop awareness of hunger and fullness cues',
                    'Create structured eating patterns',
                    'Build coping skills for emotional triggers'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.4: Binges Are Fueled by "Forbidden Foods," Not "Carb Cravings"
            Lesson(
              id: 'lesson_3_4',
              title: '3.4 Binges Are Fueled by "Forbidden Foods," Not "Carb Cravings"',
              description: 'Understanding how food rules and restrictions drive binge eating behaviors',
              chapterNumber: 3,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_3_4_1',
                  title: 'The Forbidden Fruit Effect',
                  content: 'When we label foods as "forbidden" or "bad," they become more appealing and trigger binge behaviors.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Restriction increases desire for forbidden foods',
                    'Mental deprivation creates psychological pressure',
                    'All-or-nothing thinking drives binge episodes',
                    'Food rules create anxiety and preoccupation'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_2',
                  title: 'Debunking Carb Cravings',
                  content: 'Binge episodes aren\'t caused by carbohydrate cravings, but by the restriction and rules around these foods.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Carbohydrates are not inherently addictive',
                    'Cravings increase when foods are restricted',
                    'Body needs carbohydrates for energy and brain function',
                    'Fear of carbs creates unhealthy relationship with food'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_3',
                  title: 'Food Rules and Mental Restrictions',
                  content: 'Even thinking about avoiding certain foods can trigger the same psychological effects as physical restriction.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Mental restriction is as powerful as physical restriction',
                    'Food rules create stress and preoccupation',
                    'Thoughts like "I shouldn\'t eat this" increase desire',
                    'Guilt after eating "forbidden" foods triggers binges'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_4',
                  title: 'Food Freedom and Neutrality',
                  content: 'Recovery involves removing moral judgments from food and allowing all foods to be part of a balanced approach.',
                  slideNumber: 4,
                  bulletPoints: [
                    'All foods can fit into a healthy relationship with food',
                    'Remove labels of "good" and "bad" foods',
                    'Practice unconditional permission to eat',
                    'Focus on how foods make you feel, not rules'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.5: "Fixes" Like Purging Are Ineffective and Make Things Worse
            Lesson(
              id: 'lesson_3_5',
              title: '3.5 "Fixes" Like Purging Are Ineffective and Make Things Worse',
              description: 'Understanding why compensatory behaviors don\'t work and actually perpetuate the cycle',
              chapterNumber: 3,
              lessonNumber: 5,
              slides: [
                LessonSlide(
                  id: 'slide_3_5_1',
                  title: 'Compensatory Behaviors Don\'t Work',
                  content: 'Purging, excessive exercise, and other compensatory behaviors are ineffective at "undoing" binge episodes.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Vomiting only removes about 50% of consumed calories',
                    'Laxatives don\'t prevent calorie absorption',
                    'Excessive exercise can\'t "burn off" binge episodes',
                    'These behaviors create physical and mental health risks'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_2',
                  title: 'The Binge-Purge Cycle',
                  content: 'Compensatory behaviors actually maintain and worsen binge eating by providing false reassurance.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Purging gives permission to binge more',
                    'Creates false sense of control over eating',
                    'Reinforces all-or-nothing thinking',
                    'Prevents learning natural hunger/fullness cues'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_3',
                  title: 'Physical and Mental Health Consequences',
                  content: 'Compensatory behaviors cause serious health problems and increase psychological distress.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Electrolyte imbalances and dehydration',
                    'Dental problems and throat damage',
                    'Increased anxiety and depression',
                    'Social isolation and shame'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_4',
                  title: 'Breaking the Compensatory Cycle',
                  content: 'Recovery requires stopping compensatory behaviors and learning healthier ways to cope with binge episodes.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Accept that binges happen during recovery',
                    'Practice self-compassion after difficult episodes',
                    'Return to regular eating patterns without compensation',
                    'Develop healthy coping strategies for distress'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.6: It's Biology, Not a Lack of Willpower
            Lesson(
              id: 'lesson_3_6',
              title: '3.6 It\'s Biology, Not a Lack of Willpower',
              description: 'Understanding the biological and genetic factors that contribute to eating disorders',
              chapterNumber: 3,
              lessonNumber: 6,
              slides: [
                LessonSlide(
                  id: 'slide_3_6_1',
                  title: 'The Biology of Eating Disorders',
                  content: 'Eating disorders have strong biological and genetic components that go far beyond willpower or personal choice.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Genetic factors account for 50-80% of eating disorder risk',
                    'Brain chemistry differences affect hunger and satiety',
                    'Hormonal imbalances influence eating behaviors',
                    'Neurological factors impact impulse control'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_2',
                  title: 'Starvation Response',
                  content: 'When the body experiences restriction, it activates biological survival mechanisms that drive binge eating.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Body interprets dieting as famine',
                    'Metabolism slows to conserve energy',
                    'Hunger hormones increase dramatically',
                    'Brain becomes hyper-focused on food'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_3',
                  title: 'Debunking the Willpower Myth',
                  content: 'Believing that eating disorders are about willpower creates shame and prevents effective treatment.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Willpower is not unlimited and depletes over time',
                    'Biological drives override conscious control',
                    'Shame about "lack of willpower" worsens symptoms',
                    'Self-blame interferes with recovery'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_4',
                  title: 'Compassionate Understanding',
                  content: 'Recognizing the biological nature of eating disorders allows for self-compassion and effective treatment.',
                  slideNumber: 4,
                  bulletPoints: [
                    'You didn\'t choose to have an eating disorder',
                    'Recovery requires medical and psychological support',
                    'Self-compassion is essential for healing',
                    'Focus on treatment, not self-blame'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.7: "Feeling Fat" Is Often a Disguised Emotion
            Lesson(
              id: 'lesson_3_7',
              title: '3.7 "Feeling Fat" Is Often a Disguised Emotion',
              description: 'Learning to recognize when "feeling fat" represents other emotions or experiences',
              chapterNumber: 3,
              lessonNumber: 7,
              slides: [
                LessonSlide(
                  id: 'slide_3_7_1',
                  title: 'Fat Is Not a Feeling',
                  content: '"Feeling fat" is not actually an emotion, but often represents other uncomfortable feelings or experiences.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Fat is a physical descriptor, not an emotion',
                    'Body size doesn\'t change from moment to moment',
                    '"Feeling fat" often masks other emotions',
                    'This feeling can occur regardless of actual body size'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_2',
                  title: 'What "Feeling Fat" Really Means',
                  content: 'When we say we "feel fat," we\'re often experiencing anxiety, sadness, shame, or other difficult emotions.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Anxiety about performance or social situations',
                    'Sadness or depression about life circumstances',
                    'Shame about behaviors or perceived failures',
                    'Feeling overwhelmed or out of control'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_3',
                  title: 'Body as Emotional Barometer',
                  content: 'Our relationship with our body often reflects our emotional state and overall life satisfaction.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Body dissatisfaction increases during stress',
                    'Negative emotions get projected onto body image',
                    'Body becomes a target for general life dissatisfaction',
                    'Physical sensations can trigger body-focused thoughts'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_4',
                  title: 'Emotional Awareness and Processing',
                  content: 'Learning to identify and address the real emotions behind "feeling fat" is crucial for recovery.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Ask "What am I really feeling right now?"',
                    'Practice naming specific emotions',
                    'Address underlying concerns directly',
                    'Develop healthy emotional coping strategies'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.8: The "Food Addiction" Model Is Harmful
            Lesson(
              id: 'lesson_3_8',
              title: '3.8 The "Food Addiction" Model Is Harmful',
              description: 'Understanding why the food addiction model is problematic and counterproductive',
              chapterNumber: 3,
              lessonNumber: 8,
              slides: [
                LessonSlide(
                  id: 'slide_3_8_1',
                  title: 'Problems with Food Addiction Model',
                  content: 'The food addiction model oversimplifies eating disorders and can actually make recovery more difficult.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Ignores complex psychological and social factors',
                    'Promotes fear and avoidance of certain foods',
                    'Reinforces all-or-nothing thinking',
                    'Creates shame and self-blame'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_2',
                  title: 'Food vs. Substance Addiction',
                  content: 'Unlike substances, food is necessary for survival, making the addiction model inappropriate and harmful.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Food is essential for life, drugs are not',
                    'Cannot achieve "sobriety" from food',
                    'Restriction increases "addictive-like" behaviors',
                    'Normal eating includes pleasure and satisfaction'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_3',
                  title: 'How the Model Perpetuates Problems',
                  content: 'Believing in food addiction often reinforces the very behaviors that maintain eating disorders.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Promotes avoidance of "trigger" foods',
                    'Increases fear and anxiety around eating',
                    'Justifies restrictive eating patterns',
                    'Prevents development of normal eating'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_4',
                  title: 'A Healthier Perspective',
                  content: 'Recovery involves developing a balanced, non-fearful relationship with all foods.',
                  slideNumber: 4,
                  bulletPoints: [
                    'All foods can be part of healthy eating',
                    'Focus on overall patterns, not individual foods',
                    'Develop internal cues for eating decisions',
                    'Practice food neutrality and flexibility'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.9: You Are Not Alone
            Lesson(
              id: 'lesson_3_9',
              title: '3.9 You Are Not Alone',
              description: 'Understanding the prevalence of eating disorders and the importance of community support',
              chapterNumber: 3,
              lessonNumber: 9,
              slides: [
                LessonSlide(
                  id: 'slide_3_9_1',
                  title: 'Eating Disorders Are Common',
                  content: 'Millions of people struggle with eating disorders, making them among the most common mental health conditions.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Affect people of all ages, genders, and backgrounds',
                    'Binge eating disorder is the most common eating disorder',
                    'Many people struggle in silence due to shame',
                    'You are not alone in this experience'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_2',
                  title: 'Breaking the Silence',
                  content: 'Shame and secrecy often keep people isolated, but sharing experiences can be healing and empowering.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Eating disorders thrive in secrecy and isolation',
                    'Sharing reduces shame and self-blame',
                    'Others\' stories can provide hope and validation',
                    'Community support accelerates recovery'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_3',
                  title: 'Finding Your Support System',
                  content: 'Recovery is easier with support from others who understand your experience.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Professional treatment teams provide expertise',
                    'Support groups offer peer understanding',
                    'Family and friends can learn to help',
                    'Online communities provide 24/7 connection'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_4',
                  title: 'Hope and Recovery',
                  content: 'Many people recover from eating disorders and go on to live full, healthy, and happy lives.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Recovery is possible for everyone',
                    'Treatment works when consistently applied',
                    'Many people achieve full recovery',
                    'Your story can inspire others in the future'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.10: Recovery Focuses on Breaking Current Cycles
            Lesson(
              id: 'lesson_3_10',
              title: '3.10 Recovery Focuses on Breaking Current Cycles',
              description: 'Understanding how recovery works by interrupting harmful patterns and building new ones',
              chapterNumber: 3,
              lessonNumber: 10,
              slides: [
                LessonSlide(
                  id: 'slide_3_10_1',
                  title: 'Understanding Cycles',
                  content: 'Eating disorders are maintained by repetitive cycles of thoughts, feelings, and behaviors that reinforce each other.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Restriction leads to binge eating',
                    'Binge eating leads to guilt and shame',
                    'Guilt leads to more restriction',
                    'Cycles become automatic and unconscious'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_2',
                  title: 'Breaking Points in the Cycle',
                  content: 'Recovery involves identifying where to interrupt harmful cycles and insert healthier responses.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Challenge restrictive thoughts and rules',
                    'Develop alternative responses to triggers',
                    'Practice self-compassion after setbacks',
                    'Build new, healthier behavioral patterns'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_3',
                  title: 'Building New Patterns',
                  content: 'Recovery creates new, healthier cycles that support well-being and a positive relationship with food.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Regular eating prevents extreme hunger',
                    'Self-compassion reduces shame and guilt',
                    'Mindful eating increases satisfaction',
                    'Healthy coping skills manage emotions'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_4',
                  title: 'The Recovery Process',
                  content: 'Recovery is a gradual process of replacing old, harmful patterns with new, supportive ones.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Change happens gradually, not overnight',
                    'Setbacks are normal and expected',
                    'Each small change builds on the last',
                    'Focus on progress, not perfection'
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
