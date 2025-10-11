import '../models/stage.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_slide.dart';

class Stage1Data {
  static Stage getStage1() {
    final now = DateTime.now();
    
    return Stage(
      stageNumber: 1,
      title: 'Starting Well',
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
                    'Becoming an Expert: Together, we\'ll work to make you an expert on your own eating patterns and what helps you move forward.',
                    'A Team Effort: You and your therapist (or this app guide) will work as a team. You are an active participant in your recovery.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_2',
                  title: 'What to Expect',
                  content: 'Your recovery journey is organized into four main stages to give you a clear roadmap. Having a structure helps us focus our efforts and ensures we cover all the important steps for a lasting recovery.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Stage 1 (Starting Well): We\'ll begin by getting a clear picture of your current habits. The key goals are to introduce regular eating and start using your Journal for self-monitoring.',
                    'Stage 2 (Taking Stock): After the first few weeks, we\'ll pause to review your progress, identify what\'s working, and plan the main body of your treatment.',
                    'Stage 3 (The Core Work): This is where we will work together to address the key mechanisms that maintain the eating problem, such as concerns about shape and weight, dieting, and how events and moods affect your eating.',
                    'Stage 4 (Ending Well): The final stage focuses on the future. We\'ll create a plan to help you maintain your progress and minimize the risk of setbacks long-term.',
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_3',
                  title: 'Using Nurtra for Success',
                  content: 'Nurtra is designed to support you through every stage of your treatment. The three main sections—Lessons, Tools, and your Journal—are the core components of your therapy.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Lessons (You are here!): These will provide you with crucial information and psychoeducation, guiding you through the treatment process one step at a time.',
                    'Tools (Exercises): In the "Tools" tab, you\'ll find practical exercises and strategies. These are your "homework" tasks—what you do between sessions is essential for making progress.',
                    'Journal (Monitoring): Your Journal is one of the most powerful tools for change. Recording your food, drinks, context, and feelings as they happen helps you become more aware of your patterns and gives you back a sense of control.',
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_1_4',
                  title: 'The Real Prospect of Change',
                  content: 'It\'s completely normal to feel a mix of hope and apprehension when starting treatment. Overcoming an eating problem is hard work, but it is absolutely worth it. Lasting change is not just a vague hope; it\'s a very real possibility.',
                  slideNumber: 4,
                  bulletPoints: [
                    'You Can Make a Full Recovery: Research and clinical experience show that the great majority of people can be helped, and many make a full and lasting recovery. There is no reason why you shouldn\'t be one of them.',
                    'Progress Continues: Many people find that they continue to improve even after the formal treatment program ends. As long as we disrupt the main things keeping the problem going, your mind will have time to "catch up" with your new, healthier behaviors.',
                    'It\'s Your Commitment: This is your opportunity to change. Since you\'ve likely had the eating problem for a while, it\'s important to make the most of this treatment. The more you put in, the more you\'ll get out.',
                    'A Fresh Start: This treatment is an opportunity to make a "fresh start" and build a life that isn\'t dominated by the eating disorder.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.2: Monitoring, Your Path to Awareness
            Lesson(
              id: 'lesson_1_2',
              title: 'Monitoring, Your Path to Awareness',
              description: 'Learning to track your eating patterns, emotions, and triggers in real-time',
              chapterNumber: 1,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_1_2_1',
                  title: 'Module 1: Why Monitoring is Your Superpower',
                  content: 'Welcome to one of the most important parts of your treatment! Self-monitoring is central to your recovery—it\'s your personal tool for becoming an expert on your eating problem and, ultimately, overcoming it. At first, it might feel a bit strange, but it will soon become an incredibly valuable habit.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It Reveals Your Patterns: Monitoring helps you see exactly what\'s happening on a day-to-day basis. We need to know the details of what you\'re doing, thinking, and feeling at the moment these things happen. This clarity is the first step to making changes.',
                    'It Empowers You to Change: By becoming aware of your behaviors and thoughts in real-time, you\'ll start to see that you have choices. Things that felt automatic or out of your control can be changed with attention and practice.',
                    'A Quick Note: You might find that monitoring makes you more aware of your eating at first. This is normal and actually a good thing! This heightened awareness is constructive, and the feeling of preoccupation usually fades within a week or so.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_2',
                  title: 'Module 2: Your Food Diary - How It Works',
                  content: 'Your Food Diary is more than just a list of what you eat. It\'s a space to observe the connections between food, situations, thoughts, and feelings. The most important rule is to fill it out in real-time—that means recording things as soon as possible after they happen.',
                  slideNumber: 2,
                  bulletPoints: [
                    'What to Record: For everything you eat or drink, log the following:',
                    'Time: When you ate or drank.',
                    'Food & Drink: A simple description of what you had. No need for calorie counting!',
                    'Place: Where you were (e.g., kitchen, car, work desk).',
                    'Context & Comments: This is key! Note down any thoughts, feelings, or events that happened. Were you arguing with someone? Feeling lonely? Feeling out of control?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_3',
                  title: 'Module 3: Your Weight & Body Image Diaries',
                  content: 'These diaries help us address two other important areas: your relationship with your weight and how you feel about your body shape. Like the food diary, the goal is awareness, not judgment.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The Weight Diary: The goal is to weigh yourself just once a week. Weighing yourself too often makes you focus on normal daily fluctuations, which can be misleading and upsetting.',
                    'Choose one day and time of the week to weigh yourself.',
                    'Record the number in your Weight Diary.',
                    'Most importantly, use the "comments" section to note your thoughts and feelings about the number. This helps us work on reinterpreting your weight in a healthier way.',
                    'The Body Image Diary: This is a space to track moments when thoughts about your shape and weight are particularly strong.',
                    'Log "Feeling Fat" Moments: Note down when you have an intense feeling of "feeling fat." What was happening at that moment? What were you really feeling (e.g., sad, angry, bored)?',
                    'Log Body Checking: Record any instances of body checking (e.g., repeatedly looking in the mirror, pinching parts of your body, comparing yourself to others). What triggered it? How did it make you feel?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_4',
                  title: 'Module 4: Your First Assignment: Let\'s Begin!',
                  content: 'You\'re all set! Your first task is to start using the Journal tab today. Don\'t worry about getting it perfect right away. The simple act of starting is a huge step forward.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Your Goal: Start monitoring everything in your Food, Weight, and Body Image diaries as it happens.',
                    'Carry it With You: Keep your phone handy so you can record things in real-time.',
                    'Be Curious: Approach this task with a sense of curiosity. You are a detective learning about yourself. Every entry, good or bad, is just a clue that will help you solve the puzzle. You\'ve got this!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.2.1: Journal Practice Exercise
            Lesson(
              id: 'lesson_1_2_1',
              title: 'Journal Practice Exercise',
              description: 'Practice your monitoring and journaling skills with structured exercises and real-world scenarios',
              chapterNumber: 1,
              lessonNumber: 21, // Using 21 to represent 2.1
              slides: [
                LessonSlide(
                  id: 'slide_1_2_1_1',
                  title: 'Ready to Practice Journaling?',
                  content: 'This lesson will take you directly to the Journal section where you can practice your monitoring and journaling skills with structured exercises and real-world scenarios.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Journal provides hands-on practice with real monitoring scenarios',
                    'You can work through journaling step-by-step using the structured approach',
                    'Practice makes the journaling process more natural and automatic',
                    'You can return to this exercise anytime to continue building your skills'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_1_2',
                  title: 'What You\'ll Practice',
                  content: 'In the Journal section, you\'ll work through various scenarios that help you practice monitoring your eating patterns, emotions, and triggers in real-time.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Learn to track your eating patterns and behaviors',
                    'Practice recording your emotions and triggers',
                    'Develop your food diary skills',
                    'Build confidence in your monitoring abilities'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_1_3',
                  title: 'Getting Started',
                  content: 'When you\'re ready, tap "Start Exercise" to go directly to the Journal section. You can work through as many scenarios as you like and return anytime.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The Journal will guide you through each step of the monitoring process',
                    'Take your time with each entry - there\'s no rush',
                    'The more you practice, the more natural this approach will become',
                    'Remember: monitoring is your superpower for understanding your eating patterns'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_2_1_4',
                  title: 'Ready to Begin?',
                  content: 'You\'re about to access the Journal section. This hands-on practice will help you master the monitoring and journaling skills you\'ve learned.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tap "Start Exercise" to go to the Journal section',
                    'Work through the scenarios at your own pace',
                    'Return to this lesson anytime to access the Journal again',
                    'Remember: practice makes perfect!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.3: The Foundation of Change - Regular Eating
            Lesson(
              id: 'lesson_1_3',
              title: 'The Foundation of Change - Regular Eating',
              description: 'Creating a structured eating schedule to support recovery and prevent binge episodes',
              chapterNumber: 1,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_1_3_1',
                  title: 'Module 1: Why Regular Eating is a Game-Changer',
                  content: 'It\'s time to begin making the first major change to your eating, and it\'s a powerful one. This lesson is about when you eat, not what you eat. Establishing a pattern of regular eating is the foundation upon which all other changes will be built. It\'s one of the most effective ways to reduce binge eating and regain a sense of control.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It Breaks the Binge Cycle: For most people, eating at regular intervals rapidly decreases the frequency of binge eating. This happens because it prevents you from getting overly hungry and helps stabilize your body\'s signals.',
                    'It Provides Structure and Control: When eating feels chaotic, a regular pattern provides predictability and puts you back in the driver\'s seat.',
                    'It Boosts Your Mood: Regaining control over your eating pattern often leads to a significant improvement in your mood and overall sense of well-being.',
                    'It\'s the First Step to Freedom: This simple change helps reduce the constant preoccupation with food and frees up mental space for other things in your life.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_2',
                  title: 'Module 2: Your Regular Eating Plan',
                  content: 'The goal is to create a simple, consistent, and predictable pattern of eating throughout your day. This pattern will become your new normal and will help you feel more stable and in control.\n\nHere is the plan:',
                  slideNumber: 2,
                  bulletPoints: [
                    'Three Meals + Two or Three Snacks: Aim to eat breakfast, lunch, and an evening meal, plus a mid-morning snack, a mid-afternoon snack, and an optional evening snack.',
                    'No More Than 4 Hours Apart: Don\'t let more than four hours go by without eating. This prevents the intense hunger that can trigger a binge.',
                    'Plan Ahead: This is crucial! Each morning (or the night before), plan what and when you will eat for the day. Knowing your plan removes uncertainty and makes it easier to stick to your goals.',
                    'Don\'t Skip: Adhere to your plan even if you don\'t feel hungry. Your body\'s hunger and fullness signals are likely unreliable right now. We are retraining them by eating based on the clock, not on confusing internal feelings.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_3',
                  title: 'Module 3: Tackling Common Worries',
                  content: 'It\'s completely normal to have concerns when changing your eating habits. Let\'s address the most common ones head-on so you can feel confident moving forward.',
                  slideNumber: 3,
                  bulletPoints: [
                    '"Will I gain weight?" This is a very common fear. Because regular eating drastically reduces binge eating, most people find that their overall calorie intake actually goes down. We are not asking you to eat more, just to distribute your eating differently throughout the day.',
                    '"I don\'t like eating breakfast." Many people feel this way, often fearing it will "open the floodgates" for the rest of the day. This is an opportunity to test that belief. You will likely find that starting your day with food actually gives you more control, not less.',
                    '"What if I feel uncomfortably full?" Feeling full can be a trigger. It\'s important to remember that this sensation is temporary and usually passes within an hour. As your body adjusts to regular eating, this feeling will lessen.',
                    '"I don\'t like planning so much." Spontaneity is great, but for the next few weeks, structure is your best friend. Think of this planning as a temporary tool that is essential for overcoming the eating problem and achieving long-term freedom.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_1_3_4',
                  title: 'Module 4: Get Started with Your Plan!',
                  content: 'Now it\'s time to put your plan into action. You can use the regular eating settings in your profile to help track your meal times.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Set Up Your Regular Eating Schedule: Go to your profile and set up your regular eating times. This will help you track your meal schedule and maintain consistency.',
                    'Your Goal For This Week: Your assignment is to follow your regular eating plan every day. Plan your meals and snacks, and do your best not to eat in between them.',
                    'Be Patient with Yourself: It can take a few weeks to master this new pattern. If you have a slip-up, don\'t see it as a failure. Just get back on track with your next planned meal or snack. You can do this!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Quiz: Chapter 1 Review
            Lesson(
              id: 'quiz_1_chapter_1',
              title: 'Chapter 1 Review Quiz',
              description: 'Test your understanding of the key concepts from Chapter 1',
              chapterNumber: 1,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_quiz_1_1',
                  title: 'Chapter 1 Review Quiz',
                  content: 'Congratulations on completing Chapter 1! Before moving on, let\'s review what you\'ve learned about starting your treatment journey, monitoring, and regular eating.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This quiz will help reinforce the key concepts',
                    'Take your time with each question',
                    'Your responses are saved automatically',
                    'You can always return to review the lessons if needed'
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
                  title: 'Module 1: The Diet-Binge Trap Cycle',
                  content: 'Hey there! It\'s super common to think that dieting is the answer to binge eating, but it often works the other way around. For many people, strict dieting is the very thing that triggers and fuels the binge eating cycle. It\'s a tough trap to be in, but understanding how it works is the first step to getting out.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Pressure Builds: You start a strict diet, which creates intense physical and psychological pressure to eat.',
                    'A Rule Is Broken: You eat something "off-limits," go over a calorie goal, or eat at the "wrong" time.',
                    'The Binge Happens: That small slip makes you feel like you\'ve failed completely, so you give up and binge.',
                    'Guilt and More Dieting: After the binge, you feel incredibly guilty and scared of gaining weight, so you decide to start an even stricter diet tomorrow, which just starts the cycle all over again.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_2',
                  title: 'Module 2: The Three Faces of Problematic Dieting',
                  content: 'When we talk about "dieting" that causes binges, it\'s usually not a casual, flexible plan. It\'s often a combination of extreme strategies that set you up for a fall. See if you recognize any of these common patterns.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Delaying Eating: You might skip meals or try to go as long as possible without eating, often not having your first real food until the evening. This leads to intense hunger, making it very hard to control your eating once you start.',
                    'Drastic Restriction: You might try to stick to a very low and rigid calorie limit, like 1,000 or even 600 calories a day, which is far below what your body actually needs to function well.',
                    'Avoiding "Forbidden" Foods: You create a mental list of "bad," "dangerous," or "fattening" foods that you\'re not allowed to eat. Ironically, these are often the exact foods that show up during a binge.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_3',
                  title: 'Module 3: The "All-or-Nothing" Mindset',
                  content: 'The way you think about dieting is just as important as the rules you follow. Many people who binge have an "all-or-nothing" (or "black-and-white") thinking style that turns a tiny slip-up into a total catastrophe.',
                  slideNumber: 3,
                  bulletPoints: [
                    'No Middle Ground: With this mindset, you\'re either following your diet perfectly or you\'ve failed completely. Foods are either "good" or "bad".',
                    'One Small Slip Feels Like Total Failure: Breaking a minor rule, like eating one cookie you planned to avoid, can trigger the thought, "Well, I\'ve blown it now, I might as well eat everything".',
                    'It Feeds the Cycle: This way of thinking is what creates the direct link between dieting and bingeing. A small, normal deviation from your plan is viewed as a total failure, which gives you "permission" to abandon all control.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_1_4',
                  title: 'Module 4: Your Body\'s Natural Rebellion',
                  content: 'It\'s so important to remember this: your body is not your enemy! When you restrict food severely, your body has no idea you\'re trying to lose weight; it just thinks it\'s starving and kicks into survival mode. The urge to binge is often your body\'s powerful, predictable rebellion against what it perceives as a famine.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Psychological Obsession: Dieting makes your brain become preoccupied with thoughts of food and eating. It can become almost impossible to concentrate on anything else, because your brain is trying to get you to find food.',
                    'Physical Pressure: Extreme restriction creates a mounting physiological pressure to eat. When you finally allow yourself to eat, that pent-up pressure can feel like a "dam bursting," making a binge feel inevitable.',
                    'It\'s a Response, Not a Weakness: These powerful urges are not a sign that you have no willpower. They are a normal and predictable biological response to being deprived of food.'
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
                  title: 'Module 1: What Does "Overevaluation" Mean? (The Pie Chart Test)',
                  content: 'For most people, self-worth is a mix of many things—like being a good friend, excelling at work, or pursuing hobbies. But for someone with a binge eating problem, the "pie chart" of self-worth often gets taken over by one giant slice: shape and weight. This is called the "overevaluation of shape and weight," and it\'s seen as the core engine of the disorder.',
                  slideNumber: 1,
                  bulletPoints: [
                    'People with this core belief judge their self-worth largely, or even exclusively, in terms of their shape, weight, and their ability to control them.',
                    'In a healthy self-esteem pie chart, life is balanced with slices for family, friends, work, values, and hobbies.',
                    'In an eating disorder pie chart, the slice for "Shape, Weight, and Eating" can dominate everything else, leaving little room for other sources of confidence and happiness.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_2',
                  title: 'Module 2: How It Shows Up: Constant Body Checking',
                  content: 'When your value as a person feels tied to your body, you\'re driven to constantly monitor it for changes or "flaws." This is called body checking. It\'s a direct expression of the core fear, and it\'s a habit that almost always makes you feel worse.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Weight Checking: This involves weighing yourself frequently, sometimes up to 15 times a day. This makes you react to normal daily water weight fluctuations, which in turn fuels more dieting.',
                    'Shape Checking: This can include pinching areas to check for fat, repeatedly measuring your body, obsessing over how clothes fit, or spending excessive time studying yourself in mirrors.',
                    'The Magnifying Glass Effect: Scrutinizing your body is prone to magnify any apparent defects. Remember, if you go looking for fatness, you will find it.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_3',
                  title: 'Module 3: How It Shows Up: Body Avoidance',
                  content: 'The flip side of constant checking is complete avoidance. This happens when you dislike your body so much that you can\'t bear to look at it or even acknowledge it. This is just as harmful as checking because it allows negative beliefs to grow stronger without ever being challenged.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Body avoidance is any behavior designed to prevent you from seeing or being aware of your body.',
                    'This can look like avoiding mirrors completely, only wearing baggy clothes, or avoiding situations that involve body exposure, like swimming or intimacy.',
                    'The problem is that this avoidance allows your fears and negative assumptions about your body to persist and feel even more real because you never give yourself a chance to question them.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_4',
                  title: 'Module 4: The Rigged Game of Comparison',
                  content: 'Another way this core problem shows up is through constant comparison making. You might find yourself always measuring your body against others, but it\'s a game you can never win because the rules are rigged to make you feel inadequate every time.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The comparison is biased because you critically scrutinize your own body while making a much more superficial assessment of others.',
                    'You also tend to selectively compare yourself with a very specific group of people who are thin and good-looking, while failing to notice everyone else.',
                    'Many people also compare themselves to manipulated images in magazines and on the internet, which sets an unrealistic and unattainable standard.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_2_5',
                  title: 'Module 5: The Engine That Drives the Entire Cycle',
                  content: 'This core belief isn\'t just a passive thought—it\'s the active engine that powers the entire eating disorder. It directly causes the other behaviors that keep you stuck in the cycle.',
                  slideNumber: 5,
                  bulletPoints: [
                    'This "overevaluation of shape and weight" is the primary driver behind the strict dieting that so often leads to binges.',
                    'It also accounts for extreme weight-control behaviors like self-induced vomiting and laxative misuse.',
                    'The binge eating itself then reinforces your negative beliefs about your body, creating a powerful vicious circle where the core belief drives the behavior, and the behavior strengthens the core belief.'
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
                  title: 'Module 1: The Two Key Ingredients of a Binge',
                  content: 'Hey there! Many people say they "binged" after having a big meal, but a true binge is more specific. It isn\'t just about overindulging; it has two essential ingredients that must both be present to separate it from simple overeating.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Amount is Excessive: The amount of food eaten is viewed by the person as being too much.',
                    'The Feeling of Lost Control: Crucially, there is a distinct sense of being out of control while eating.',
                    'Both Are Required: This feeling of lost control is what truly distinguishes a binge from everyday overeating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_2',
                  title: 'Module 2: What "Loss of Control" Actually Feels Like',
                  content: 'That feeling of being "out of control" is the heart of a binge, but it can feel a bit different for everyone. It\'s often more than just a passing thought; it can be an intense and almost automatic experience.',
                  slideNumber: 2,
                  bulletPoints: [
                    'A Trance-Like State: People often describe feeling as if they are in a trance during a binge, with their behavior seeming almost automatic, "as if it is not really you who is eating".',
                    'A Powerful Urge: The craving for food can feel like a powerful force that drives you to eat, which is why the term "compulsive eating" is sometimes used.',
                    'It Can Sneak Up on You: The feeling might emerge long before you eat, or it might come on suddenly as you realize you\'ve broken a diet rule or eaten too much.',
                    'It\'s Persistent: Even if a binge is interrupted by something like a phone call, it\'s very common for the binge to restart as soon as the interruption ends, showing just how persistent that loss of control is.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_3',
                  title: 'Module 3: It\'s Not Always About the Amount (Objective vs. Subjective)',
                  content: 'It\'s a huge myth that a binge has to involve a massive, Hollywood-movie amount of food. The feeling of being completely out of control is what truly matters, and that can happen with any quantity of food. The book makes a very helpful distinction between two types of binges.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Objective Binge: This is what most people picture. It\'s an episode where you eat a definitively large amount of food—more than what most people would eat under similar circumstances.',
                    'Subjective Binge: This is an episode where you eat a normal or even small amount of food (like a few cookies) but experience the exact same distressing sense of complete loss of control.',
                    'Both Are Valid: Subjective binges can cause considerable distress and are just as real and important as objective ones. They are especially common in people who are trying to stick to a very strict diet.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_3_4',
                  title: 'Module 4: The Sneaky Side of Losing Control',
                  content: 'This might sound like a contradiction, but sometimes a "loss of control" can actually look like a plan. For people who have been bingeing for a long time, the episodes can start to feel so unavoidable that they actually prepare for them.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Fading Resistance: Over many years, the sense of being out of control can fade because experience teaches the person that binges are inevitable, so they stop trying to resist them.',
                    '"Planned" Binges: Some people even plan for what they see as unavoidable binges by buying special foods ahead of time.',
                    'Still a Loss of Control: This is still considered a loss of control because while they might manage the when and where of a binge, they feel unable to prevent the episode from happening in the first place.',
                    'Unable to Stop: Furthermore, even within a so-called "planned" binge, many people report that they are unable to stop eating once they have started.'
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
                  title: 'Module 1: Debunking the "Carb Craving" Myth',
                  content: 'You\'ve probably heard the term "carb craving" a lot, but it\'s time to set the record straight. The idea that binges are driven by a biological need for carbohydrates is a widespread myth that isn\'t supported by the facts. It\'s a catchy phrase, but it\'s not what\'s actually happening.',
                  slideNumber: 1,
                  bulletPoints: [
                    '"Carbohydrate craving" is a myth, despite being a popular belief.',
                    'Research shows that the proportion of carbohydrates in binges is not particularly high and is no higher than what\'s found in ordinary meals.',
                    'What really defines a binge is the overall amount of food eaten, not its specific nutritional makeup in terms of carbs, fats, or proteins.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_2',
                  title: 'Module 2: The Real Driver: Your List of "Forbidden" Foods',
                  content: 'So, if it\'s not a carb craving, what is it? The answer lies in your own personal food rules. Binges are almost always composed of the very foods you are trying your hardest to avoid—the ones you\'ve labeled as "off-limits."',
                  slideNumber: 2,
                  bulletPoints: [
                    'When asked what they eat during a binge, people often use terms that reflect their attitude toward the food, like "forbidden food," "dangerous food," or "fattening food".',
                    'This is a crucial point: most binges are composed of foods that the person is trying to avoid.',
                    'This connection between avoidance and bingeing is central to understanding why many binges happen and is key to learning how to overcome them.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_3',
                  title: 'Module 3: The Psychology of the Forbidden Fruit',
                  content: 'Why does forbidding a food make you want it more? It\'s a classic case of the "forbidden fruit" effect. By creating strict rules, you give those foods immense psychological power, which sets you up for a fall.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Avoiding foods you see as "bad" is a form of extreme dieting.',
                    'When you have these strict rules, breaking one of them is a common trigger for a binge.',
                    'This happens because of an "all-or-nothing" thinking style. Eating one "bad" cookie makes you feel like you\'ve completely failed, which can lead you to give up and binge on all the other "forbidden" foods.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_4_4',
                  title: 'Module 4: What Binge Foods Are Really Made Of',
                  content: 'We tend to think of classic binge foods like ice cream, cookies, and chocolate as being packed with carbs, but that\'s not the whole story. A closer look at their nutritional content reveals a different picture.',
                  slideNumber: 4,
                  bulletPoints: [
                    'While it\'s commonly believed that these foods are high in carbohydrates, they are more accurately described as sweet foods with a high fat content.',
                    'Interestingly, the composition of binges often reflects current dietary fads. What society labels as "bad" at the moment—whether it\'s fat or carbs—is what tends to show up most often in binges.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.5: "Fixes" Like Purging Are Ineffective and Make Things Worse"
            Lesson(
              id: 'lesson_3_5',
              title: '3.5 "Fixes" Like Purging Are Ineffective and Make Things Worse"',
              description: 'Understanding why compensatory behaviors don\'t work and actually perpetuate the cycle',
              chapterNumber: 3,
              lessonNumber: 5,
              slides: [
                LessonSlide(
                  id: 'slide_3_5_1',
                  title: 'Module 1: The Illusion of a Quick Fix',
                  content: 'Hello! People often turn to purging behaviors like vomiting or using laxatives because they seem like a brilliant, logical solution to a binge. It feels like a way to "undo the damage" and regain control. However, this sense of control is a dangerous illusion that makes the underlying problem much worse over time.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Many people start purging because they believe they can eat whatever they want and then simply get rid of it without gaining weight.',
                    'Initially, this can bring a sense of relief or of feeling "cleansed".',
                    'However, this mistaken belief in a "fix" is what allows the binge eating cycle to become more powerful and entrenched.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_2',
                  title: 'Module 2: The Hard Numbers: Vomiting\'s 50% Failure Rate',
                  content: 'It might feel like vomiting gets rid of everything you\'ve eaten, but the science tells a very different story. Laboratory studies have measured exactly how many calories are actually removed, and the results are pretty shocking.',
                  slideNumber: 2,
                  bulletPoints: [
                    'The belief that vomiting is an effective way to get rid of food is a mistaken one.',
                    'On average, vomiting only retrieves about half of the calories consumed during a binge.',
                    'One study found that while patients\' binges averaged 2,131 calories, their vomit only contained 979 calories.',
                    'This is why most people with bulimia nervosa maintain a normal body weight—they are unknowingly living off the 50% of calories they cannot retrieve.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_3',
                  title: 'Module 3: The Laxative and Diuretic Lie',
                  content: 'Laxatives and diuretics can be especially deceptive because they make the number on the scale go down, which feels like proof that they\'re working. In reality, this is just a temporary trick involving water weight, and they have almost no impact on the calories you\'ve consumed.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Laxatives have little to no effect on calorie absorption. They work in the lower intestine, which is after most calories have already been absorbed by your body.',
                    'Diuretics (water pills) have zero effect on calorie absorption. They only cause fluid loss through urine.',
                    'The weight you lose is just water, and your body quickly regains it as it rehydrates, often with extra bloating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_4',
                  title: 'Module 4: How the "Fix" Becomes a Trap',
                  content: 'Here\'s the cruelest part of the cycle: the very behaviors you use to "undo" a binge actually make you more likely to binge again. The "fix" is a trap that strengthens the problem instead of solving it.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Knowing you can vomit or use laxatives later makes a binge feel "safer" and undermines your attempts to resist eating in the first place.',
                    'Because the binge feels less consequential, you become more prone to binge, and the binges themselves often become larger in size.',
                    'This creates a powerful vicious circle where purging is both a response to bingeing and a behavior that actively encourages more bingeing.',
                    'For many, these behaviors become one of the main processes that maintains the entire eating problem.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_5_5',
                  title: 'Module 5: The Serious Physical Price',
                  content: 'Beyond being ineffective, these behaviors can cause significant and sometimes irreversible damage to your physical health. The temporary feeling of relief comes at a very high long-term cost.',
                  slideNumber: 5,
                  bulletPoints: [
                    'Vomiting can cause irreversible erosion of tooth enamel, painful swelling of the salivary glands in your face, and dangerous electrolyte imbalances that can lead to irregular heartbeats.',
                    'Laxative Misuse can also cause serious electrolyte disturbances and, in high doses over long periods, may result in permanent damage to your intestines.',
                    'Diuretic Misuse is a fruitless exercise that carries the same risks of dangerous fluid and electrolyte disturbances.'
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
                  title: 'Module 1: Your Body\'s Survival Alarm',
                  content: 'Hello! It\'s easy to blame yourself when you feel an overwhelming urge to binge, but it\'s so important to understand what\'s happening behind the scenes. When you diet strictly, your body doesn\'t know you\'re trying to fit into a certain outfit; it thinks there\'s a famine. This sounds a powerful survival alarm that kicks off a chain of unavoidable biological responses.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Imposing strict limits on your eating creates a mounting physiological and psychological pressure to eat.',
                    'This creates a situation where, once you start eating, it can be incredibly difficult to stop; many people describe the feeling "like a dam bursting".',
                    'This isn\'t just in your head—undereating and being underweight physically affect your brain and its ability to function normally.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_2',
                  title: 'Module 2: How "Starvation" Changes Your Brain',
                  content: 'Undereating directly impacts your most important organ: your brain. The food obsession, the inability to focus, and the rigid thinking that often accompany dieting aren\'t signs of weakness; they are neurological symptoms of a brain that is being deprived of the fuel it needs to work properly.',
                  slideNumber: 2,
                  bulletPoints: [
                    'A major psychological effect of dieting is becoming preoccupied with thoughts about food and eating.',
                    'This preoccupation can make it hard to concentrate on everyday tasks, as thoughts about food constantly intrude into your mind and even your dreams.',
                    'Your thinking can become inflexible, making it hard to switch between topics, and your decision-making can be impaired, often leading to procrastination.',
                    'In one famous study, healthy men put on a restricted diet became irritable, lost interest in socializing, and focused their lives around food, much like what is seen in anorexia nervosa.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_3',
                  title: 'Module 3: Your Body\'s Smart Adaptations',
                  content: 'Your body is incredibly intelligent. When it senses a food shortage, it makes a series of smart adaptations to conserve energy and maximize its chances of survival. While these changes are helpful in a real famine, they can make binge eating feel almost inevitable.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Your gut slows down its processes to absorb as many nutrients as possible from the food you do eat. This can also make you feel uncomfortably full after eating even small amounts.',
                    'Non-essential processes, like the production of sex hormones, shut down to save energy, which can affect menstruation and fertility.',
                    'Your circulation is also affected; your heart rate slows down and your blood pressure drops as your body tries to conserve every bit of energy it can.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_6_4',
                  title: 'Module 4: A Biological Urge, Not a Moral Failing',
                  content: 'When you put all these pieces together, a clear picture emerges. That intense, desperate, and overwhelming urge to binge that follows a period of restriction is not a character flaw. It is a powerful, predictable, and completely understandable biological drive to survive.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The combination of intense psychological preoccupation with food and mounting physiological pressure to eat is a direct result of restriction.',
                    'This pressure can become so powerful that thoughts about food feel totally overwhelming, making a binge feel like the only option.',
                    'The binge itself is often a breakdown of the extreme attempts to restrict food, driven by your body\'s survival instincts.',
                    'Recognizing that these urges are biological responses—not moral failures—is a compassionate and crucial step toward breaking the cycle.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.7: "Feeling Fat" Is Often a Disguised Emotion"
            Lesson(
              id: 'lesson_3_7',
              title: '3.7 "Feeling Fat" Is Often a Disguised Emotion"',
              description: 'Learning to recognize when "feeling fat" represents other emotions or experiences',
              chapterNumber: 3,
              lessonNumber: 7,
              slides: [
                LessonSlide(
                  id: 'slide_3_7_1',
                  title: 'Module 1: What Is This "Feeling Fat"?',
                  content: 'Hello! "Feeling fat" is a strange, powerful, and often distressing experience. It\'s not the same as being concerned about your weight; it\'s a sensation that can wash over you and change dramatically from one hour to the next. This fluctuation is a big clue that the feeling isn\'t actually about your body\'s size.',
                  slideNumber: 1,
                  bulletPoints: [
                    '"Feeling fat" is an experience reported by many women, but its intensity and frequency are far greater among people with eating problems.',
                    'A key feature of this feeling is that it fluctuates markedly in intensity, even within a single day.',
                    'This is completely unlike your actual shape and weight, which are stable and don\'t change from moment to moment.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_2',
                  title: 'Module 2: The Real Feelings in Disguise',
                  content: 'Here\'s the big secret: the sensation of "feeling fat" is almost never truly about your body. The book explains that it\'s usually the result of mislabeling other, more complicated emotions or physical sensations that might be harder to face directly.',
                  slideNumber: 2,
                  bulletPoints: [
                    '"Feeling fat" is usually the result of mislabeling unpleasant emotions and bodily experiences.',
                    'Emotional Triggers: It can be a stand-in for feelings like being depressed, lonely, unloved, bored, or sleepy.',
                    'Physical Triggers: It can also be caused by bodily sensations like feeling bloated, premenstrual, hungover, hot, or sweaty.',
                    'Awareness Triggers: Sometimes it\'s sparked by simply becoming more aware of your body after checking it, seeing your reflection, or noticing your clothes feel tight.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_3',
                  title: 'Module 3: Why Does Our Brain Do This?',
                  content: 'So, why does your brain perform this tricky swap? While the exact reason isn\'t certain, it\'s likely a side effect of having been so deeply preoccupied with thoughts about your shape for a very long time. Your brain gets into a habit of interpreting everything through that filter.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The reason for this mislabeling isn\'t entirely clear.',
                    'It\'s thought to be a consequence of the long-standing and profound preoccupation with thoughts about shape and weight.',
                    'The danger is that people often equate feeling fat with actually being fat, which reinforces their body concerns and encourages more dieting.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_7_4',
                  title: 'Module 4: How to Decode the Feeling',
                  content: 'The great news is that you can learn to see "feeling fat" for what it really is and strip it of its power. By acting like a detective when the feeling hits, you can uncover the true cause and address it directly.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The first step is to start identifying the times when you have "peaks" of feeling fat and note them down.',
                    'When you feel it, ask yourself two key questions: "Was there a trigger in the hour beforehand?" and "What else am I feeling or doing right now?".',
                    'Once you identify the real cause (e.g., "I\'m not fat, I\'m just lonely" or "I\'m not fat, my clothes are just tight"), you can work on solving that actual problem.',
                    'As you practice this, the feeling will decline in frequency and intensity, and it will lose its significance as you realize it has nothing to do with being fat.'
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
                  title: 'Module 1: The Surface Similarities (and Why They\'re Misleading)',
                  content: 'Hey there! It\'s easy to see why terms like "food addict" have become so popular. On the surface, binge eating can look a lot like a classic addiction, with cravings, secrecy, and a feeling of lost control. But it\'s really important to know that just because two things look similar, it doesn\'t mean they have the same cause or need the same solution.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Binge eating can involve intense cravings and a sense of losing control, much like substance abuse.',
                    'People often keep the behavior secret and continue despite knowing it has negative effects.',
                    'However, focusing only on these similarities neglects the huge differences that are absolutely central to understanding the problem and treating it successfully.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_2',
                  title: 'Module 2: The Three Game-Changing Differences',
                  content: 'While they might look alike, binge eating and substance abuse are driven by completely different engines. The book highlights three fundamental differences that show why thinking of binge eating as an "addiction" is a mistake.',
                  slideNumber: 2,
                  bulletPoints: [
                    'What You "Crave": Binge eating is not about an addiction to a specific substance or class of foods. The main issue is the amount of food eaten, not what is eaten.',
                    'The Core Motivation: People with binge eating problems are constantly trying to avoid and restrict their food intake through dieting. This is the opposite of substance abuse, where the drive is toward the substance.',
                    'The Underlying Fear: Binge eating is fueled by an intense fear of weight gain and the belief that self-worth is based on body shape. There is no equivalent phenomenon in classic addictions.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_3',
                  title: 'Module 3: Two Opposite Paths to Treatment',
                  content: 'Because the root causes are so different, the most effective treatments are also polar opposites. The approach for addiction can be incredibly damaging for someone with a binge eating problem because it strengthens the exact issues that need to be fixed.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The Addiction Approach: This model says the problem can be "arrested but not cured" and that the solution is complete, lifelong abstinence from so-called "toxic" or "trigger" foods.',
                    'The Evidence-Based Approach: This model knows that full recovery is absolutely possible and that the solution involves systematically eliminating food avoidance by gradually reintroducing "forbidden" foods to prove they aren\'t dangerous.',
                    'These two approaches are at total odds with each other.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_8_4',
                  title: 'Module 4: Why "Abstinence" From Food Backfires',
                  content: 'Here\'s exactly why telling someone with a binge eating problem to "just abstain" from certain foods is so harmful. It accidentally reinforces the very beliefs and behaviors that keep the binge-restrict cycle going.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The idea that certain foods are "toxic" has no basis in fact.',
                    'In reality, it is the very attempt to avoid these foods that makes you vulnerable to bingeing on them.',
                    'An abstinence strategy strengthens the rigid, "all-or-nothing" thinking that is a core part of the problem.',
                    'Instead of making you fear food, effective treatment helps you learn to eat all foods in a moderate and normal way.'
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
                  title: 'Module 1: The Feeling of Being the "Only One"',
                  content: 'If you struggle with binge eating, it\'s incredibly common to feel like you are the only person in the world going through this. This intense feeling of isolation is a direct result of the shame and secrecy that are hallmarks of the behavior. But that feeling, as real as it is, isn\'t the truth.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Many people who binge have the sense that they are the only one with the problem.',
                    'A hallmark of the typical binge is that it occurs in secret. People are often so ashamed of their binge eating that they go to great lengths to hide it, sometimes successfully for many years.',
                    'In the early days of research, the majority of patients seen by doctors thought they were the only person with their specific type of eating problem.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_2',
                  title: 'Module 2: The Truth: A Hidden Epidemic Uncovered',
                  content: 'In the late 1970s, even researchers were in the dark about how common binge eating was. That changed when a small notice was placed in a popular magazine asking people who struggled with bingeing and purging to write in. The response was overwhelming and proved that this was a massive, hidden problem affecting thousands who all thought they were alone.',
                  slideNumber: 2,
                  bulletPoints: [
                    'To see if bulimia nervosa was a significant but undetected problem, a researcher placed a small notice in the April 1980 U.K. issue of Cosmopolitan magazine.',
                    'The result was dramatic. Within about a week, more than a thousand letters were received from women who seemed to have the disorder.',
                    'Most of the women who responded expressed surprise and relief at discovering that they were not the only one with the problem.',
                    'This study strongly suggested that bulimia nervosa was a significant and largely undetected issue.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_3',
                  title: 'Module 3: The Numbers Game: How Common Is It Really?',
                  content: 'It helps to know you\'re not alone, but seeing the actual numbers can be even more powerful. Modern community studies that interview people directly have found that millions of people from all walks of life struggle with binge eating.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Reliable interview-based studies have produced relatively consistent findings on how common these disorders are.',
                    'Bulimia Nervosa: Affects between 1 and 2% of young adult women.',
                    'Binge Eating Disorder: Affects about 2 to 3% of both men and women and is seen across a much broader age range.',
                    'These figures are noteworthy because binge eating problems impair both quality of life and physical health.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_9_4',
                  title: 'Module 4: It\'s a Global Issue, Not a "Western" Problem',
                  content: 'There\'s a persistent but outdated myth that eating disorders only happen in Western, developed countries. The reality is that binge eating problems are a global health concern, affecting people in many different cultures, countries, and ethnic groups.',
                  slideNumber: 4,
                  bulletPoints: [
                    'The view that eating disorders are "culture-bound syndromes" of the West is now outdated.',
                    'More and more evidence shows that these problems occur across the globe.',
                    'Eating disorders are found in both high- and low-income Asian countries, including Japan, China, India, and Malaysia.',
                    'In the Arab world, eating problems are also becoming a public health concern.',
                    'Studies have also suggested that Asian Americans and Hispanic Americans may be even more vulnerable to developing binge eating problems.'
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
                  title: 'Module 1: The Past vs. The Present',
                  content: 'Hello! It\'s natural to wonder "Why did this happen to me?" While understanding the past can give you context, the real key to getting better is tackling the habits and thought patterns that are keeping you stuck right now. Recovery is less about fixing the past and more about changing the present.',
                  slideNumber: 1,
                  bulletPoints: [
                    'When we think about a long-term problem, it\'s crucial to distinguish between the factors that caused it to start and the cycles that cause it to persist.',
                    'The research on what keeps binge eating going suggests that a limited number of interacting processes are involved.',
                    'Successful treatment focuses on identifying and breaking these cycles that are maintaining the problem today.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_2',
                  title: 'Module 2: Identifying Your "Now" Cycles',
                  content: 'Once a binge eating problem begins, new patterns often take over and become the real engine that keeps it running day after day. See if you recognize any of these common cycles that keep people trapped in the present.',
                  slideNumber: 2,
                  bulletPoints: [
                    'The Dieting Cycle: This is the powerful loop where strict dieting leads to a binge, which causes guilt and leads to even stricter dieting.',
                    'The Purging Cycle: The mistaken belief that vomiting or using laxatives "fixes" a binge actually encourages more binge eating because it removes the fear of weight gain.',
                    'The Mood Cycle: Binge eating can become a primary way to cope with difficult moods and thoughts because it serves as a distraction, creating a powerful reliance on it.',
                    'The Core Belief Cycle: The "overevaluation of shape and weight" is the engine that drives the strict dieting, which in turn drives the binge eating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_3',
                  title: 'Module 3: Why This Is Great News for Recovery!',
                  content: 'Shifting the focus from the unchangeable past to the changeable present is incredibly hopeful and empowering. You can\'t go back and erase the life events or risk factors that made you vulnerable, but you have complete power to start changing the patterns you\'re living out today.',
                  slideNumber: 3,
                  bulletPoints: [
                    'For successful treatment, the main task is to identify the processes that are keeping the problem going right now.',
                    'This means you don\'t have to be "stuck" because of your history; recovery is an active process of learning new skills to manage your life in the present.',
                    'The desire to change is a key factor; by deciding to make a fresh start, many people are able to overcome the problem.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_3_10_4',
                  title: 'Module 4: The Roadmap for Breaking the Cycles (CBT-E)',
                  content: 'The book\'s recommended treatment, Cognitive Behavior Therapy-Enhanced (CBT-E), is a practical and evidence-based approach designed specifically to target and dismantle these current cycles in a step-by-step way. It provides a clear roadmap for change.',
                  slideNumber: 4,
                  bulletPoints: [
                    'CBT is a great fit for binge eating because its behavioral parts tackle the eating habits, while its cognitive parts address the thoughts and beliefs that keep you stuck (like the overevaluation of shape and weight).',
                    'Stage 1 of the treatment immediately targets the behavioral cycle by helping you establish a pattern of regular eating, which displaces most binges.',
                    'Stage 2 then focuses on the underlying engines by tackling the tendency to diet and finding new ways to cope with difficult moods.',
                    'Stage 3 helps you create a plan to maintain your progress and handle future setbacks so you don\'t fall back into the old cycles.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Quiz: Chapter 3 Review
            Lesson(
              id: 'quiz_3_chapter_3',
              title: 'Chapter 3 Review Quiz',
              description: 'Test your understanding of the key psychoeducational concepts',
              chapterNumber: 3,
              lessonNumber: 11,
              slides: [
                LessonSlide(
                  id: 'slide_quiz_3_1',
                  title: 'Chapter 3 Review Quiz',
                  content: 'Congratulations on completing Chapter 3! Before moving on, let\'s review what you\'ve learned about the psychoeducational concepts that form the foundation of understanding eating disorders.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This quiz covers dieting, self-worth, binge eating, and recovery concepts',
                    'Focus on understanding the underlying mechanisms',
                    'Your responses are saved automatically',
                    'You can always return to review the lessons if needed'
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
