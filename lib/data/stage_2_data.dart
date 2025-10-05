import '../models/stage.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_slide.dart';

class Stage2Data {
  static Stage getStage2() {
    final now = DateTime.now();
    
    return Stage(
      stageNumber: 2,
      title: 'Building Strong Foundations',
      chapters: [
        // Chapter 0: Starting Well
        Chapter(
          chapterNumber: 0,
          title: 'Starting Well',
          lessons: [
            // Lesson 0.1: Why Change Your Eating Habits?
            Lesson(
              id: 'lesson_s2_0_1',
              title: '0.1: Why Change Your Eating Habits?',
              description: 'Understanding the reasons and motivation for making positive changes in your eating patterns',
              chapterNumber: 0,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_1_1',
                  title: 'Module 1: The \'Why\' Behind Change',
                  content: 'It\'s important to start by thinking about why you want to change your eating habits. Lasting change comes from a genuine desire to improve. Your motivation might go up and down, so it\'s helpful to have a clear list of reasons to look back on. You may have adjusted your life to fit around binge eating, and now is a good time to think about whether that\'s how you want to continue living.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Motivation is Key: Real change starts with truly wanting it for yourself.',
                    'Create Guidelines: Having a written list of reasons to change helps you stay on track when motivation fades.',
                    'Reflect on Your Life: Consider how much of your life has been arranged to accommodate binge eating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_1_2',
                  title: 'Module 2: The Advantages of Change',
                  content: 'Stopping binge eating can improve your life in many ways. You might be surprised by how much better you feel, even if you think your problem is minor. Regaining control over your eating can boost your self-respect and help you feel more like yourself again. It also gives you back time, money, and energy to focus on other things you enjoy.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Feel Better About Yourself: Improve your self-respect, self-worth, and overall mood.',
                    'Enhance Quality of Life: Reduce irritability, improve concentration, and feel more comfortable in social situations.',
                    'Improve Physical Health: Give your body a chance to heal and feel more energetic.',
                    'Benefit Others: Your relationships with friends and family can improve as you become happier and more present.',
                    'Better Weight Control: You\'ll be in a much better position to manage your weight in a healthy way.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_1_3',
                  title: 'Module 3: Considering the Disadvantages',
                  content: 'It\'s also fair to think about the possible downsides of trying to change. You might be worried about what will happen if you don\'t succeed. It\'s a valid concern, but trying to change is a brave step, no matter the outcome. If the program doesn\'t work for you, it\'s the program that has failed, not you. There are always other options to explore.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Fear of Failure: It\'s normal to worry about not succeeding, but don\'t let it stop you from trying.',
                    'It\'s a Learning Process: Discovering that it\'s not easy to change can show you how significant the problem is, which is an important realization.',
                    'No "Failure," Only Feedback: If one method doesn\'t work, it\'s a sign to try a different approach, not to give up on yourself.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.2: How to Change Your Eating Habits
            Lesson(
              id: 'lesson_s2_0_2',
              title: '0.2: How to Change Your Eating Habits',
              description: 'Exploring different approaches and treatment options available for eating disorder recovery',
              chapterNumber: 0,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_2_1',
                  title: 'Module 1: Exploring Your Paths to Change',
                  content: 'Once you\'ve decided you want to change, the next step is to figure out how. There are several paths you can take, and it\'s all about finding what feels right for you. You don\'t have to do this alone, and there are many resources available to support you on your journey.',
                  slideNumber: 1,
                  bulletPoints: [
                    'You have choices: There isn\'t just one "right" way to overcome binge eating.',
                    'Support is available: Many people and programs are ready to help.',
                    'Find your fit: The best approach is the one that you feel comfortable and confident with.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_2_2',
                  title: 'Module 2: Seeking Professional Help',
                  content: 'One of the most direct ways to tackle a binge eating problem is to work with a professional. There are many different types of specialists who can help, and they can provide expert guidance tailored to your specific needs.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Who can help: Professionals include psychologists, psychiatrists, dietitians, social workers, and nurses who specialize in eating problems.',
                    'Expert guidance: A specialist can offer personalized strategies and support.',
                    'Finding a professional: You can ask your doctor for a recommendation or look up organizations like the Academy for Eating Disorders online.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_2_3',
                  title: 'Module 3: Joining a Self-Help Group',
                  content: 'Connecting with others who have similar experiences can be incredibly powerful. Self-help groups offer a space to share, listen, and learn from peers who understand what you\'re going through. It\'s a great way to feel less alone.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Shared experience: Groups connect you with people who truly get it.',
                    'Do your research: Look for a group that is positive and focused on recovery.',
                    'Find the right vibe: If you join a group, make sure it feels like a good fit. It\'s okay to leave if it isn\'t right for you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_2_4',
                  title: 'Module 4: Using a Self-Help Program',
                  content: 'For many, a structured self-help program can provide the tools and steps needed to make a change. These programs are designed to be used on your own, allowing you to work at your own pace.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Work independently: A self-help program allows you to be in the driver\'s seat of your recovery.',
                    'Flexible and accessible: You can use the program whenever and wherever it\'s convenient for you.',
                    'Evidence-based: The program in "Overcoming Binge Eating" is based on proven therapeutic methods.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_2_5',
                  title: 'Module 5: Combining Your Options',
                  content: 'You don\'t have to choose just one path. Combining different approaches can be a very effective strategy. For example, you can work with a therapist while also using a self-help program on your own.',
                  slideNumber: 5,
                  bulletPoints: [
                    '"Guided self-help": This popular option involves following a self-help program with the support and guidance of a therapist or coach.',
                    'Therapy plus self-help: You can receive therapy for other issues (like self-esteem or relationships) while using this program for your eating habits.',
                    'Open communication: If you combine approaches, make sure to keep your therapist informed so they can best support you.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.3: When to Start Your Journey
            Lesson(
              id: 'lesson_s2_0_3',
              title: '0.3: When to Start Your Journey',
              description: 'Understanding the right timing and conditions for beginning your recovery journey',
              chapterNumber: 0,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_3_1',
                  title: 'Module 1: The Best Time to Start Is Now',
                  content: 'If you have decided you want to change, the best advice is to take the plunge and get started right away. It can be easy to put things off, waiting for the "perfect" moment, but often, the best moment is the one you create for yourself by simply beginning.',
                  slideNumber: 1,
                bulletPoints: [
                    'Take the plunge: If you\'re committed to changing, don\'t hesitate.',
                    'Embrace the present: Waiting for a perfect time can lead to endless delays.',
                    'Action creates momentum: Just starting the process can build your confidence and motivation.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_3_2',
                  title: 'Module 2: Timing Is Everything',
                  content: 'While starting now is great advice, it\'s also wise to be realistic about your schedule. If you know a major life event is just around the corner, it might be best to wait until things have settled down. Trying to start a new program during a very stressful or busy time can make it harder to succeed.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Look ahead: Are there any major distractions coming up in your life?',
                    'What counts as a major distraction?: Things like moving, starting a new job, getting married, having a baby, or going on a big vacation.',
                    'Set yourself up for success: It\'s okay to postpone starting until you have the clear headspace to focus on the program.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_3_3',
                  title: 'Module 3: Carving Out the Time for You',
                  content: 'To get the most out of this program, you\'ll need a solid block of time where you can really focus without major interruptions. Think of it as an investment in yourself and your well-being. A couple of months is a good timeframe to aim for.',
                  slideNumber: 3,
                bulletPoints: [
                    'Commit to the process: You\'ll need at least a couple of months free from big distractions.',
                    'It\'s a marathon, not a sprint: Lasting change takes time and consistent effort.',
                    'Protect your time: Treat this commitment as an important priority in your schedule.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.4: Is Self-Help Always the Best First Step?
            Lesson(
              id: 'lesson_s2_0_4',
              title: '0.4: Is Self-Help Always the Best First Step?',
              description: 'Recognizing situations where professional treatment is necessary instead of or alongside self-help',
              chapterNumber: 0,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_4_1',
                  title: 'Module 1: Knowing When to Seek More Support',
                  content: 'Self-help is a fantastic and empowering tool, but it\'s not always the right first step for everyone. Your health and safety are the top priorities. Let\'s go over a few situations where seeking professional guidance before starting a self-help program is the best and safest path forward.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Self-help is powerful: It can be a great way to take charge of your journey.',
                    'Safety first: In some cases, professional medical and psychological support is essential.',
                    'Be honest with yourself: Reviewing these points will help you decide the best course of action for your unique situation.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_4_2',
                  title: 'Module 2: If You Are Underweight',
                  content: 'This self-help program is designed for individuals whose weight is in a healthy range. If you are underweight (meaning your Body Mass Index or BMI is below 18.5), working with a knowledgeable therapist or doctor is crucial.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Why it matters: Being underweight comes with its own set of physical and psychological effects that need professional medical supervision.',
                    'This program isn\'t the right fit: On its own, this program is unlikely to be helpful and could be unsafe if you are underweight.',
                    'What to do: Please consult a doctor or a therapist who specializes in eating problems before you begin.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_4_3',
                  title: 'Module 3: If You Have Other Health Concerns',
                  content: 'Your overall physical health is a key factor. If you are managing other medical conditions, it\'s important to make sure any changes to your eating habits are safe for you.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Serious physical illness: If you have an ongoing illness, like diabetes, you should only use this program under a doctor\'s supervision.',
                    'If you\'re pregnant: It\'s best to discuss the program with your obstetrician first to ensure it\'s appropriate for you and your baby.',
                    'Health impacted by binge eating: If you think your physical health is already being affected by your eating habits, get a check-up from a physician before you start.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_4_4',
                  title: 'Module 4: If You\'re Struggling Emotionally',
                  content: 'Taking on a self-help program requires significant mental energy and optimism. If you\'re dealing with other serious challenges, it can be very difficult to make progress on your own.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Significant depression: If you\'re feeling very depressed or demoralized, you may not have the energy to use the program effectively. It\'s best to seek professional help for your mood first.',
                    'Alcohol or drug problems: If you have a significant issue with alcohol or drugs, this program on its own is unlikely to be enough.',
                    'Self-harm: If you are repeatedly self-harming, it is essential to seek professional help.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.5: What Will Happen To My Weight?
            Lesson(
              id: 'lesson_s2_0_5',
              title: '0.5: What Will Happen To My Weight?',
              description: 'Understanding weight changes during recovery and developing a healthy relationship with your body',
              chapterNumber: 0,
              lessonNumber: 5,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_5_1',
                  title: 'Module 1: The Big Question About Weight',
                  content: 'It\'s one of the first things people wonder: "If I change my eating habits, what will happen to my weight?" This is a completely valid question, especially when you\'ve been concerned about your weight for a long time. The main goal of this program is to help you heal your relationship with food, and it\'s helpful to know what to expect for your weight along the way.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It\'s normal and okay to be concerned about your weight.',
                    'This program\'s primary focus is on regaining control over your eating.',
                    'Let\'s look at what the journey typically looks like for most people.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_5_2',
                  title: 'Module 2: The Surprising Answer',
                  content: 'For most people who follow this program, there is very little or no change in their overall weight. This might seem surprising, but it makes sense when you think about it. As you stop binge eating, you also start eating more regularly. These two changes tend to balance each other out.',
                  slideNumber: 2,
                  bulletPoints: [
                    'The common result: Most people\'s weight remains stable.',
                    'Why this happens: You\'re replacing the calories from binges with planned, regular meals and snacks.',
                    'The goal: To create a stable and healthy eating pattern, which in turn helps stabilize your weight.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_5_3',
                  title: 'Module 3: Your Unique Journey',
                  content: 'While weight stability is the most common outcome, it\'s impossible to predict exactly what will happen in any individual case. Everyone\'s body and situation are different.',
                  slideNumber: 3,
                  bulletPoints: [
                    'If you are currently underweight: Because this program helps you stop restricting your food intake, you will likely need to gain some weight to reach a healthy level for your body.',
                    'If you are currently overweight: It\'s very unlikely that you will gain weight. The focus will be on stopping the binge eating cycle first.',
                    'Remember: This is not a weight-loss diet. It\'s a program to heal your relationship with food.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_5_4',
                  title: 'Module 4: A New Focus: Healing Over Numbers',
                  content: 'The best approach is to concentrate all your efforts on overcoming your binge eating problem first. Try to accept whatever changes in weight happen for the time being. This can be tough, but it\'s a crucial step in breaking free from the power the scale has over you.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Prioritize your goal: Focus on healing your eating habits, not on a number.',
                    'Try a one-month challenge: For the next month, put the question of your weight aside. Focus only on following the program\'s steps.',
                    'Re-evaluate later: After a month of focusing on your behaviors, you\'ll be in a much better position to assess your progress and think about your weight.',
                    'You\'ll still weigh in: We\'ll continue with weekly weighing to monitor things, but the goal is to observe without judgment.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 0.6: Using Nurtra
            Lesson(
              id: 'lesson_s2_0_6',
              title: '0.6: Using Nurtra',
              description: 'Guidelines for effectively using this recovery program to achieve the best outcomes',
              chapterNumber: 0,
              lessonNumber: 6,
              slides: [
                LessonSlide(
                  id: 'slide_s2_0_6_1',
                  title: 'Module 1: Your Step-by-Step Path',
                  content: 'Nurtra is designed like a path with several steps. Each step you take builds on the one before it, creating a strong foundation for change. For the best results, it\'s important to follow the steps in order.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Follow the sequence: The program is designed to be followed from beginning to end.',
                    'No skipping ahead: Each step prepares you for the next one.',
                    'Trust the process: Working through the program systematically will give you the best chance of success.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_6_2',
                  title: 'Module 2: Making It Your Own',
                  content: 'Nurtra is designed to help everyone who binges, but your personal journey is unique. You\'ll find that some parts of the program resonate more with you than others, and that\'s completely okay.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Not a one-size-fits-all: Some advice may not apply to your specific situation.',
                    'When in doubt, try it out: If you\'re unsure if a step is for you, the best policy is to give it a try.',
                    'Your experience is valid: Focus on the parts of Nurtra that help you the most.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_6_3',
                  title: 'Module 3: Tips for a Successful Journey (Part 1)',
                  content: 'Getting started is a big step, and here are a few things to keep in mind as you begin. Having a positive and realistic mindset can make all the difference.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Embrace the challenge: Often, the steps that feel the most difficult are the ones that will help you grow the most.',
                    'Be patient with yourself: Real change takes time. Don\'t rush through the program; give yourself the space to learn and adapt. Most people take about 4 to 6 months to work through it.',
                    'Progress isn\'t a straight line: Expect some ups and downs. There will be good weeks and some tougher ones. This is a normal part of any meaningful change.',
                    'Urges will fade: Even after you stop binge eating, you\'ll still feel the urge to binge from time to time. This is normal, and these urges will get weaker and less frequent over a few months.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_0_6_4',
                  title: 'Module 4: Tips for a Successful Journey (Part 2)',
                  content: 'Along with the right mindset, a few practical habits can help you stay on track and feel supported throughout the program.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Hold weekly reviews: Set aside 15-30 minutes each week to review your progress. Treat this as a non-negotiable appointment with yourself.',
                    'Consider getting support: You don\'t have to do this alone. Asking a trusted friend, family member, or therapist to act as a support person can be incredibly helpful.',
                    'This isn\'t forever: Remember, many of the tools in this program are for breaking the cycle. Over time, you\'ll discover which habits you want to carry with you for the long term.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 1: Step 1 - Starting Well
        Chapter(
          chapterNumber: 1,
          title: 'Step 1 - Starting Well',
          lessons: [
            // Lesson 1.1: The Power of Self-Monitoring
            Lesson(
              id: 'lesson_s2_1_1',
              title: '1.1: The Power of Self-Monitoring',
              description: 'Learning to track your eating patterns, thoughts, and feelings to gain insight into your behaviors',
              chapterNumber: 1,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_1_1_1',
                  title: 'Module 1: Your Most Powerful Tool',
                  content: 'Starting your journey begins with a simple but powerful tool: self-monitoring. Think of it as turning on the lights in a room you want to understand better. For a little while, you\'ll be a friendly observer of your own eating habits, which is the first and most essential step toward lasting change.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Self-monitoring is key: It\'s the foundation of this entire program.',
                    'It has two main purposes: To give you important information and to help you start changing.',
                    'You\'re in the driver\'s seat: This tool puts you in control by helping you understand your patterns.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_1_2',
                  title: 'Module 2: What You\'ll Discover',
                  content: 'Accurate monitoring helps you answer questions you may have never had clear answers to before. It helps you connect the dots and see the bigger picture of your eating patterns, moving you from confusion to clarity.',
                  slideNumber: 2,
                  bulletPoints: [
                    'You\'ll learn WHAT: What foods do you eat during binges? Are they foods you usually try to avoid?',
                    'You\'ll learn WHEN: Is there a pattern to when your binges happen? Evenings? Weekends?',
                    'You\'ll learn WHY: What triggers your binges? Are you feeling bored, lonely, or anxious? Does binge eating seem to serve a purpose, like relieving tension?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_1_3',
                  title: 'Module 3: But What If I Feel Resistant?',
                  content: 'It\'s completely normal to have some reservations about monitoring. Many people do! Let\'s talk through some common concerns.',
                  slideNumber: 3,
                  bulletPoints: [
                    '"I\'ve tried it before and it didn\'t work." This program uses monitoring in a very specific, structured way that you\'ve likely never tried before. Give this new approach a chance.',
                    '"It seems like too much work." It does take effort, but your willingness to try is a sign of your commitment to yourself and to changing your life.',
                    '"I\'m too embarrassed to write it all down." Feeling this way is understandable. But to overcome the problem, we have to be able to look at it honestly. It gets easier with time, and this is a private record just for you.',
                    '"Won\'t this make me more obsessed with food?" It might feel that way for the first few weeks, but it\'s a constructive focus that helps you find solutions. This feeling fades quickly.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_1_4',
                  title: 'Module 4: Your First Task: Just Observe',
                  content: 'For the next week, your only goal is to get into the habit of monitoring. Don\'t try to change your eating just yet. Simply practice recording what you eat and drink, and the thoughts and feelings that go along with it.',
                  slideNumber: 4,
                bulletPoints: [
                    'No pressure to change: The first step is just to build the habit of observing.',
                    'Be honest with yourself: It\'s very important not to leave anything out, including binges. This is a judgment-free zone.',
                    'Carry your record with you: Make it a habit to have your monitoring tool (a small notebook or our in-app tracker) with you at all times.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.2: A New Approach to Weighing
            Lesson(
              id: 'lesson_s2_1_2',
              title: '1.2: A New Approach to Weighing',
              description: 'Learning to weigh yourself appropriately as part of recovery without becoming obsessed',
              chapterNumber: 1,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_1_2_1',
                  title: 'Module 1: Your Weight and Your Journey',
                  content: 'As your eating habits begin to change, it\'s natural to wonder what\'s happening with your weight. Many people with binge eating concerns have a complicated relationship with the scale—either weighing themselves many times a day or avoiding it completely. We\'re going to find a balanced, less stressful middle path.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It\'s okay to be curious about your weight as you follow this program.',
                    'Avoiding the scale can often create more fear and anxiety.',
                    'The goal is to monitor your weight in a calm, informed way, without letting it control you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_2_2',
                  title: 'Module 2: The Once-a-Week Plan',
                  content: 'The best way to track your weight is to weigh yourself just once a week. This gives you helpful information without getting caught up in normal, day-to-day fluctuations. Think of it as checking in, not judging.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Why once a week? Daily weigh-ins can be misleading. Your body\'s weight can change by a few pounds in a single day due to things like water retention.',
                    'Look for the trend, not the dot: We\'re interested in the bigger picture over several weeks, not one single number on one day.',
                    'Information, not a grade: This is simply a way to gather information about your journey. The number on the scale does not define your success.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_2_3',
                  title: 'Module 3: How to Weigh Weekly',
                  content: 'Here\'s your simple plan for weighing in. The key is consistency and kindness to yourself.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Pick one day: Choose a specific morning of the week that will be your weigh-in day. A weekday is often best.',
                    'Weigh yourself once: Step on the scale, note the number, and then you\'re done for the week.',
                    'Resist weighing in between: If you\'re tempted to weigh yourself more often, try keeping the scale out of sight, perhaps in a closet or cabinet. This makes it easier to resist the urge.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_2_4',
                  title: 'Module 4: Making Sense of the Numbers',
                  content: 'It\'s helpful to plot your weekly weight on a simple graph. This makes it much easier to see the overall trend instead of getting fixated on one week\'s number. Over time, you\'ll see a clearer picture emerge from the natural ups and downs.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Your weight will fluctuate: This is completely normal and expected. Short-term changes are usually just about your body\'s hydration levels, not changes in body fat.',
                    'Track your progress: Use a simple graph (in a notebook or our in-app tracker) to plot your weight each week.',
                    'Patience is key: You\'ll need at least 3-4 weeks of data to start seeing a real trend.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 1.3: Checking In With Yourself
            Lesson(
              id: 'lesson_s2_1_3',
              title: '1.3: Checking In With Yourself',
              description: 'Reviewing your progress with self-monitoring and weekly weighing before moving to the next step',
              chapterNumber: 1,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_1_3_1',
                  title: 'Module 1: Your Personal Check-In',
                  content: 'Think of a review session as a friendly, 15-minute chat with yourself to see how things are going. Doing this twice a week is a key part of the program. It\'s your dedicated time to reflect, learn, and stay motivated on your journey.',
                  slideNumber: 1,
                bulletPoints: [
                    'Schedule it in: Plan two short review sessions for yourself each week.',
                    'It\'s simple: For each session, you\'ll reread the Step 1 lessons and then ask yourself a few gentle questions.',
                    'No judgment: This is a time for curiosity and support, not criticism.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_3_2',
                  title: 'Module 2: Are My Tools Working for Me?',
                  content: 'The first part of your check-in is about your two main tools: self-monitoring and weekly weighing. Let\'s see how you\'re doing with them.',
                  slideNumber: 2,
                  bulletPoints: [
                    '"Have I been monitoring my eating?" If yes, that\'s a fantastic start! If not, take a moment to think about what\'s holding you back. Remember, monitoring is your most powerful tool for understanding your patterns.',
                    '"Can I improve my monitoring?" Look over your records. Are you recording things as they happen? Are you including your thoughts and feelings? Small improvements can make a big difference.',
                    '"Am I weighing myself just once a week?" If so, great job sticking to the plan! If you\'re weighing yourself more, try putting the scale away. If you\'re avoiding it, remember that knowing is less scary than fearing the unknown.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_3_3',
                  title: 'Module 3: What Patterns Am I Noticing?',
                  content: 'This is the detective part of your check-in! Look over your monitoring records from the last few days and see what clues you can find. Understanding your patterns is the first step to changing them.',
                  slideNumber: 3,
                  bulletPoints: [
                    'About my binges: Do they happen at a certain time of day? Are there specific triggers, like a stressful event or feeling?',
                    'About the food: What do I eat during a binge? Are these foods that I\'m trying to avoid at other times?',
                    'About other meals: What am I eating outside of my binges? Am I skipping meals or restricting a lot?',
                    'About my days: Are some days different from others? For example, do I have "diet" days and "binge" days?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_1_3_4',
                  title: 'Module 4: Am I Ready for the Next Step?',
                  content: 'After you\'ve been practicing Step 1 for about a week, it\'s time to decide if you\'re ready to move on. The key is consistency, not perfection.',
                  slideNumber: 4,
                bulletPoints: [
                    'Track your "Change Days": A "Change Day" is any day where you did your best to monitor accurately and weigh in only once a week (if it was your weigh-in day). It doesn\'t matter if you binged or not.',
                    'Are you having 6-7 Change Days a week? If so, you\'ve built a solid foundation and you\'re ready to move on to Step 2!',
                    'Fewer than 6? No problem at all. Just spend another week practicing the habits from Step 1. Don\'t rush—it\'s more important to feel confident with each step.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 2: Step 2 - Regular Eating
        Chapter(
          chapterNumber: 2,
          title: 'Step 2 - Regular Eating',
          lessons: [
            // Lesson 2.1: The Power of Regular Eating
            Lesson(
              id: 'lesson_s2_2_1',
              title: '2.1: The Power of Regular Eating',
              description: 'Learning to eat at regular intervals to prevent extreme hunger and reduce binge episodes',
              chapterNumber: 2,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_1_1',
                  title: 'Module 1: The Most Important First Step',
                  content: 'Making one single change can have the biggest impact on overcoming binge eating: establishing a pattern of regular eating. Research has consistently shown that when you eat at regular intervals throughout the day, it naturally pushes aside most binges and helps you feel more in control.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This is a game-changer: It\'s the most significant step you can take.',
                    'The goal is consistency: We\'re aiming for three planned meals and two or three planned snacks each day.',
                    'An example schedule:',
                    '  ○ 8:00 AM: Breakfast',
                    '  ○ 10:30 AM: Snack',
                    '  ○ 12:30 PM: Lunch',
                    '  ○ 3:30 PM: Snack',
                    '  ○ 7:00 PM: Evening Meal'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_1_2',
                  title: 'Module 2: The Four Rules of Regular Eating',
                  content: 'To make this new pattern work for you, there are four simple but important guidelines to keep in mind. Following these will help you build a solid foundation for your new way of eating.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Plan Ahead: At the start of each day, decide when you\'ll eat and write it down.',
                    'Don\'t Skip: Make sure you eat each of your planned meals and snacks.',
                    'Focus on \'When,\' Not \'What\': For now, it doesn\'t matter exactly what you eat, as long as you\'re eating regularly and enough.',
                    'Mind the Gaps: Do your very best not to eat in the spaces between your planned meals and snacks.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_1_3',
                  title: 'Module 3: Tips for Making it Stick',
                  content: 'Adopting a new routine takes practice. Here are a few extra tips to help you navigate challenges and make this pattern feel more natural over time.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Be flexible, not rigid: Your plan should fit your life. It\'s okay to adjust the times to suit your schedule.',
                    'Let the clock be your guide (for now): Your body\'s hunger signals might be a bit off right now. For the time being, eat at your planned times, whether you feel hungry or not.',
                    'The 4-Hour Rule: Try not to go more than four hours without eating. This prevents you from getting overly hungry, which can be a trigger to binge.',
                    'Don\'t "compensate": Resist the urge to skip a planned meal or snack if you feel you\'ve eaten "too much." Sticking to the plan is what helps reduce binges overall.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_1_4',
                  title: 'Module 4: What if My Eating is Very Chaotic?',
                  content: 'If the idea of three meals and two snacks feels overwhelming right now, that\'s completely okay. You don\'t have to get there overnight. You can ease into it gently.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Start small: If your eating is very unpredictable, just start by planning and eating breakfast and lunch at regular times.',
                    'Build gradually: Once you feel comfortable with breakfast and lunch, add in an afternoon snack. Then, add in your evening meal, and so on.',
                    'Get back on track quickly: If you have a binge, don\'t write off the rest of the day. Just get back to your planned schedule with the very next meal or snack. Every time you do this, you\'re building strength.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.2: What About Vomiting?
            Lesson(
              id: 'lesson_s2_2_2',
              title: '2.2: What About Vomiting?',
              description: 'Strategies for stopping purging behaviors and managing the urges to vomit after eating',
              chapterNumber: 2,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_2_1',
                  title: 'Module 1: A Hopeful Connection',
                  content: 'If you make yourself vomit, it\'s important to understand how this is connected to your eating patterns. For most people, the urge to vomit is tied directly to binge eating. This is actually good news, because it means as you work on one, the other will naturally improve too.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Link: If you only vomit after a binge, the two behaviors are linked.',
                    'A Positive Ripple Effect: As you establish a pattern of regular eating (from Step 2), your binges will become less frequent.',
                    'Natural Improvement: As the binges reduce, the vomiting tied to them will also fade away. You\'re tackling the root, and the symptom will follow.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_2_2',
                  title: 'Module 2: Managing Urges After Meals',
                  content: 'In the first few weeks of eating regularly, you might feel a strong urge to vomit after your planned meals or snacks. This is normal, and it\'s a feeling you can learn to navigate. The key is to create a bit of space and time for the urge to pass.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Urges are temporary: The feeling is strongest for about an hour, and then it will start to fade.',
                    'Distraction is your friend: Plan a simple, engaging activity to do right after you eat. You could call a friend, go for a walk, or watch a favorite show.',
                    'Use your support system: If possible, try to be around other people after you eat. This can make it easier to resist the urge.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_2_3',
                  title: 'Module 3: When You Need More Support',
                  content: 'Sometimes, vomiting isn\'t only a response to binge eating. If you find yourself vomiting at times other than after a binge and feel unable to break the habit on your own, it\'s a sign that you could benefit from some extra support.',
                  slideNumber: 3,
                bulletPoints: [
                    'Listen to your experience: If vomiting feels separate from binge eating, that\'s important information.',
                    'It\'s okay to ask for help: Overcoming this type of habit can be very difficult to do alone.',
                    'Reach out: Seeking professional help is a strong and positive step towards taking care of yourself.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.3: What About Laxatives and Diuretics?
            Lesson(
              id: 'lesson_s2_2_3',
              title: '2.3: What About Laxatives and Diuretics?',
              description: 'Understanding and stopping the misuse of laxatives and diuretics for weight control',
              chapterNumber: 2,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_3_1',
                  title: 'Module 1: Two Different Patterns',
                  content: 'Just like with other behaviors, people tend to misuse laxatives or diuretics (water pills) in two main ways. Understanding your own pattern is the first step toward making a change.',
                  slideNumber: 1,
                bulletPoints: [
                    'Pattern 1: A Response to Binge Eating. Some people take laxatives or diuretics only after an episode of overeating, much like self-induced vomiting.',
                    'Pattern 2: A Daily Routine. Others take them more regularly, independent of any specific binge. This pattern is more like a form of dieting.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_3_2',
                  title: 'Module 2: A Clear Plan to Stop',
                  content: 'Once you understand that these methods are not effective for preventing calorie absorption, you can make a firm decision to stop. How you stop depends on your pattern of use.',
                  slideNumber: 2,
                  bulletPoints: [
                    'If you follow Pattern 1: This behavior is tied to binge eating. As you establish regular eating and your binges decrease, the misuse of laxatives or diuretics will fade away with them.',
                    'If you follow Pattern 2 (occasional use): You can make the decision to stop taking them all at once.',
                    'If you follow Pattern 2 (daily use): It\'s better to phase them out gradually. Try cutting your daily amount in half each week until you\'ve stopped completely.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_3_3',
                  title: 'Module 3: What to Expect Physically',
                  content: 'If you\'ve been taking laxatives or diuretics almost every day, your body might temporarily retain some fluid when you stop. This is a normal reaction, and it\'s important not to be discouraged by it.',
                  slideNumber: 3,
                bulletPoints: [
                    'Expect temporary weight gain: If this happens, remember it\'s just water weight, not fat.',
                    'It will pass: The fluid retention and any related weight gain will go away on its own within a week or two at the most.',
                    'When to see a doctor: In the unlikely event you notice swelling in your hands and feet, it\'s a good idea to see your physician.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.4: Tips on Eating In and Out
            Lesson(
              id: 'lesson_s2_2_4',
              title: '2.4: Tips on Eating In and Out',
              description: 'Strategies for maintaining regular eating patterns both at home and in social situations',
              chapterNumber: 2,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_4_1',
                  title: 'Module 1: Creating Mindful Spaces at Home',
                  content: 'Let\'s talk about creating a calm and intentional space for your meals at home. Where you eat can be just as important as what you eat. By making a few simple changes, you can help yourself focus on your food and enjoy it more.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Choose your spot: Designate one or two specific places in your home for eating, like the kitchen or dining table. Avoid eating in your bedroom or bathroom.',
                    'Focus on the food: Try not to eat while watching TV, working, or walking around. Sit down and give your meal your full attention. This helps reduce mindless "grazing."',
                    'Portion it out: Serve your planned meal on a plate, and keep extra food and serving dishes off the table. This helps you stick to your plan.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_4_2',
                  title: 'Module 2: Pacing Yourself at Mealtimes',
                  content: 'Sometimes, eating can feel automatic or rushed. Learning to slow down and be present with your food is a powerful skill. These simple practices can help you feel more in control and connected during your meals.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Take a pause: Try putting your fork or spoon down between bites. This gives your body time to register fullness.',
                    'It\'s okay to leave food: Practice leaving a little bit of food on your plate. This is a great way to remind yourself that you are in charge, not the food.',
                    'Handle leftovers thoughtfully: To avoid temptation, it\'s often best to discard leftovers, especially in the beginning. Your well-being is not a waste.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_4_3',
                  title: 'Module 3: Eating with Friends and Family',
                  content: 'Eating with others can sometimes feel tricky, especially when people encourage you to have more than you\'d planned. You always have the right to honor your own plan. Here\'s how to handle these situations with grace and confidence.',
                  slideNumber: 3,
                  bulletPoints: [
                    'You\'re in charge: Remember that you get to decide how much you eat.',
                    'Practice your "no, thank you": It\'s okay to politely and firmly decline second helpings. A simple, "No thank you, it was delicious but I\'ve had enough," works wonders.',
                    'Don\'t feel pressured: If someone puts more food on your plate than you want, you do not have to eat it.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_4_4',
                  title: 'Module 4: Strategies for Eating Out',
                  content: 'Eating in restaurants or at social events can feel challenging, but with a little planning, you can navigate them successfully. Having a strategy in place can help you stay on track and still enjoy the occasion.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Take a break: In a multi-course meal, it\'s okay to take a short break between courses. You can excuse yourself to use the restroom to collect your thoughts and review your plan.',
                    'Tackle the buffet: Buffets can be overwhelming. Take a moment to look at all the options first, then step away to decide what you\'d truly like to eat before getting your plate.',
                    'Be mindful of alcohol: Drinking alcohol can lower your inhibitions and make it harder to stick to your eating plan. It\'s a good idea to limit your intake when eating out.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.5: Tips on Eating In and Out (Review Sessions)
            Lesson(
              id: 'lesson_s2_2_5',
              title: '2.5: Tips on Eating In and Out',
              description: 'Reviewing your progress with establishing regular eating patterns and addressing challenges',
              chapterNumber: 2,
              lessonNumber: 5,
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_5_1',
                  title: 'Module 1: Your Twice-Weekly Check-In',
                  content: 'Now that you\'re working on establishing a pattern of regular eating, it\'s helpful to have a consistent time to check in with yourself. Think of this as a friendly meeting with yourself to see how things are going and what you\'re learning.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Schedule it in: Plan to have two review sessions each week.',
                    'A quick refresher: Start each session by rereading Step 2 ("Regular Eating"). This helps remind you of your goals.',
                    'The goal is learning, not perfection: These sessions are a chance to notice what\'s working and where you might need more support, without any judgment.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_2',
                  title: 'Module 2: The Four Foundation Questions',
                  content: 'In each review session, you\'ll start by asking yourself the same four foundational questions from your Step 1 review. These habits are the base for all the progress you\'ll make.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Have I been monitoring? Am I filling out my records in real-time?',
                    'Can I improve my monitoring? Is there anything I can do to make my records more accurate or detailed?',
                    'Am I weighing myself just once a week? How am I sticking to my weekly weighing plan?',
                    'Are any patterns becoming evident? What am I noticing about my eating habits, triggers, and feelings?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_3',
                  title: 'Module 3: Questions for Regular Eating',
                  content: 'After the foundation questions, it\'s time to reflect specifically on your new pattern of regular eating. These questions will help you see your progress and identify any challenges.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Planning: Am I planning my meals and snacks each day? Am I trying to stick to my plan?',
                    'Consistency: Am I skipping any meals or snacks? Are the gaps between them longer than 4 hours?',
                    'Getting Back on Track: When things go wrong, am I able to get back to my plan quickly, or do I write off the whole day?',
                    'Stopping Other Behaviors: Am I following the advice for stopping vomiting or the misuse of laxatives and diuretics?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_4',
                  title: 'Module 4: When to Move on to Step 3',
                  content: 'How do you know when you\'re ready to move to the next step? You don\'t need to be perfect, but you should see that you\'re making a consistent effort. This is where the idea of a "change day" comes in.',
                  slideNumber: 4,
                  bulletPoints: [
                    'What\'s a "change day"? At this stage, it\'s a day where you monitored accurately, weighed weekly, and did your best to stick to your plan for regular eating (whether you binged or not).',
                    'The 6 or 7 Day Goal: You\'re ready to move on to Step 3 when you\'re having six or seven "change days" each week.',
                    'What if I\'m not there yet? That\'s perfectly okay! It just means you need a little more time to practice. Reread the "Regular Eating" lessons and continue with this step for another week.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 2.5.1: Meal Planning Exercise
            Lesson(
              id: 'lesson_s2_2_5_1',
              title: '2.5.1: Meal Planning Exercise',
              description: 'Practice your meal planning skills with structured exercises and real-world scenarios',
              chapterNumber: 2,
              lessonNumber: 51, // Using 51 to represent 5.1
              slides: [
                LessonSlide(
                  id: 'slide_s2_2_5_1_1',
                  title: 'Ready to Practice Meal Planning?',
                  content: 'This lesson will take you directly to the Meal Planning Exercise in the Tools section. Here you can practice your meal planning skills with structured exercises and real-world scenarios.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Meal Planning Exercise provides hands-on practice with real meal scenarios',
                    'You can work through meal planning step-by-step using the structured approach',
                    'Practice makes the meal planning process more natural and automatic',
                    'You can return to this exercise anytime to continue building your skills'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_1_2',
                  title: 'What You\'ll Practice',
                  content: 'In the Meal Planning Exercise, you\'ll work through various meal planning scenarios that help establish regular eating patterns, learning to apply your new skills in real situations.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Plan balanced meals and snacks throughout the day',
                    'Create meal schedules that work with your lifestyle',
                    'Learn to prepare for different eating situations',
                    'Develop strategies for maintaining regular eating patterns'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_1_3',
                  title: 'Getting Started',
                  content: 'When you\'re ready, tap "Start Exercise" to go directly to the Meal Planning tool. You can work through as many scenarios as you like and return anytime.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The exercise will guide you through each step of the meal planning process',
                    'Take your time with each scenario - there\'s no rush',
                    'The more you practice, the more natural this approach will become',
                    'Remember: regular eating is the foundation for all your other progress'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_2_5_1_4',
                  title: 'Ready to Begin?',
                  content: 'You\'re about to access the Meal Planning Exercise. This hands-on practice will help you master the meal planning skills you\'ve learned.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tap "Start Exercise" to go to the Meal Planning tool',
                    'Work through the scenarios at your own pace',
                    'Return to this lesson anytime to access the exercise again',
                    'Remember: practice makes perfect!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 3: Step 3 - Alternatives to Binge Eating
        Chapter(
          chapterNumber: 3,
          title: 'Step 3 - Alternatives to Binge Eating',
          lessons: [
            // Lesson 3.1: Dealing with Urges: Alternative Activities
            Lesson(
              id: 'lesson_s2_3_1',
              title: '3.1: Dealing with Urges: Alternative Activities',
              description: 'Learning to identify triggers and prepare alternative activities to prevent binge episodes',
              chapterNumber: 3,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_3_1_1',
                  title: 'Module 1: Understanding Urges',
                  content: 'When you start changing your eating habits, it\'s completely normal to have urges to eat between your planned meals or snacks. The most important thing to remember is that these urges are temporary. You can learn to "ride the wave" until it passes.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Urges aren\'t permanent: They rise to a peak and then gradually fade away.',
                    'Time is on your side: The most intense part of an urge usually only lasts for an hour or so.',
                    'Your goal: The challenge is to find something to do to help yourself get through that peak without giving in.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_1_2',
                  title: 'Module 2: Create Your "Go-To" List',
                  content: 'The first step is to brainstorm your own personal list of activities that can help you resist an urge. Think of this as your "toolbox" for difficult moments. Don\'t censor yourself—just write down anything that comes to mind.',
                  slideNumber: 2,
                  bulletPoints: [
                    'What could you do? Think of activities like going for a brisk walk, calling or visiting a friend, exercising, or watching an engaging movie.',
                    'What do you enjoy? Consider hobbies or interests like playing a video game, browsing the internet, or taking a warm bath or shower.',
                    'The goal is to have options: Create a list of potential activities that feel like good possibilities for you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_1_3',
                  title: 'Module 3: The Three Keys to a Great Alternative',
                  content: 'As you look at your list, you\'ll find that the most helpful activities have three things in common. When you\'re choosing something to do in the moment, try to pick an activity that checks these boxes.',
                  slideNumber: 3,
                  bulletPoints: [
                    'It\'s active: It involves doing something rather than being passive (like channel surfing on TV).',
                    'It\'s enjoyable: It\'s something that doesn\'t feel like a chore.',
                    'It\'s realistic: It\'s something you can actually do right then and there.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_1_4',
                  title: 'Module 4: Your Mood-Booster Playlist',
                  content: 'Never underestimate the power of music! Creating a special playlist can be a fantastic way to change your frame of mind and help you deal with urges to eat or vomit.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Gather your favorites: Go through your music and find songs that are enjoyable and mood-enhancing.',
                    'Create a specific playlist: Keep these songs in one place that you can access easily.',
                    'Keep it handy: Have your music ready to go for those difficult moments when you need a quick mood shift.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_1_5',
                  title: 'Module 5: Putting Your Plan into Action',
                  content: 'Once you\'ve built your list, the final step is to make sure it\'s ready when you need it. Being prepared makes it much easier to use this skill successfully.',
                  slideNumber: 5,
                bulletPoints: [
                    'Write it down: Put your list on a card or in a note on your phone.',
                    'Keep it accessible: Make sure you can get to your list easily whenever an urge strikes.',
                    'Practice spotting urges early: The sooner you can identify an urge when it starts, the easier it will be to manage.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.2: Putting Your Plan into Action
            Lesson(
              id: 'lesson_s2_3_2',
              title: '3.2: Putting Your Plan into Action',
              description: 'Learning to effectively use alternative activities when experiencing urges to binge eat',
              chapterNumber: 3,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_3_2_1',
                  title: 'Module 1: The Moment of Choice',
                  content: 'You\'ve had your meal, and suddenly the urge to binge or vomit feels overwhelming. This is a critical moment, and it\'s one you can navigate successfully. The key is to see it as a signal to pause and use your new skills.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Acknowledge the urge: The first step is to notice the urge and write it down in your monitoring record. Something like, "Feeling tired and stressed, strong urge to binge."',
                    'Spot the two problems: Usually, there are two things going on: the urge itself, and the situation that\'s triggering it (like boredom or stress).',
                    'One step at a time: Right now, we\'re going to focus on getting through the urge. You\'ll learn how to handle the trigger situations in the next step of the program.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_2',
                  title: 'Module 2: Your Two-Part Action Plan',
                  content: 'When an urge feels powerful, it\'s easy to think it will last forever. But it won\'t. Your action plan is simple, and it\'s based on two facts: urges are temporary, and distraction is powerful.',
                  slideNumber: 2,
                  bulletPoints: [
                    '1. Let time pass: The most intense part of an urge will fade with time. Even giving yourself 30 minutes can be enough for the feeling to become much more manageable.',
                    '2. Engage in a distracting activity: Now is the time to get out your "Go-To" list of alternative activities. The goal is to do something active, enjoyable, and realistic to help you ride out the urge.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_3',
                  title: 'Module 3: An Example in Action',
                  content: 'Let\'s see how this works in a real-life scenario. Imagine it\'s evening, you\'ve had a stressful day, and after your meal, you feel a strong urge to binge. You have nothing planned for the rest of the night.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The Situation: You feel tired, stressed, and bored—a high-risk combination.',
                    'The Plan: You look at your list of activities and decide on a two-part plan: first, call a friend to catch up, and then go for a brisk walk to burn off some stress.',
                    'The Outcome: Talking to your friend is a welcome distraction, and the walk helps you feel better physically and mentally. By the time you get back, the urge has passed, and you\'ve made it through a difficult moment.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_4',
                  title: 'Module 4: "Urge Surfing" and What\'s Next',
                  content: 'This process of riding out an urge is sometimes called "urge surfing." It\'s a skill, and like any skill, it gets easier the more you practice it. Be patient and compassionate with yourself as you learn.',
                  slideNumber: 4,
                bulletPoints: [
                    'Practice makes progress: Over time, you\'ll find that the urges fade more and more quickly.',
                    'Uncovering other feelings: Sometimes, binge eating can cover up other difficult emotions. As you stop bingeing, you might become more aware of feelings like stress or loneliness.',
                    'This is a good sign: While it may be uncomfortable at first, noticing these feelings is a positive step. It means you can now start to address them directly, which is a core part of long-term recovery.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.2.1: Urge Surfing Exercise
            Lesson(
              id: 'lesson_s2_3_2_1',
              title: '3.2.1: Urge Surfing Exercise',
              description: 'Practice your urge surfing skills with structured exercises and real-world scenarios',
              chapterNumber: 3,
              lessonNumber: 21, // Using 21 to represent 2.1
              slides: [
                LessonSlide(
                  id: 'slide_s2_3_2_1_1',
                  title: 'Ready to Practice Urge Surfing?',
                  content: 'This lesson will take you directly to the Urge Surfing Exercise in the Tools section. Here you can practice your urge surfing skills with structured exercises and real-world scenarios.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Urge Surfing Exercise provides hands-on practice with real urge scenarios',
                    'You can work through urge surfing step-by-step using the structured approach',
                    'Practice makes the urge surfing process more natural and automatic',
                    'You can return to this exercise anytime to continue building your skills'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_1_2',
                  title: 'What You\'ll Practice',
                  content: 'In the Urge Surfing Exercise, you\'ll work through various scenarios that commonly trigger urges to binge, learning to apply your new skills in real situations.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Learn to recognize the early signs of urges',
                    'Practice riding the wave of urges without giving in',
                    'Develop your personal toolkit of alternative activities',
                    'Build confidence in your ability to handle difficult moments'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_1_3',
                  title: 'Getting Started',
                  content: 'When you\'re ready, tap "Start Exercise" to go directly to the Urge Surfing tool. You can work through as many scenarios as you like and return anytime.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The exercise will guide you through each step of the urge surfing process',
                    'Take your time with each scenario - there\'s no rush',
                    'The more you practice, the more natural this approach will become',
                    'Remember: urges are temporary and you have the power to ride them out'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_2_1_4',
                  title: 'Ready to Begin?',
                  content: 'You\'re about to access the Urge Surfing Exercise. This hands-on practice will help you master the urge surfing skills you\'ve learned.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tap "Start Exercise" to go to the Urge Surfing tool',
                    'Work through the scenarios at your own pace',
                    'Return to this lesson anytime to access the exercise again',
                    'Remember: practice makes perfect!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.3: Checking In on Your New Skills
            Lesson(
              id: 'lesson_s2_3_3',
              title: '3.3: Checking In on Your New Skills',
              description: 'Reviewing your progress with using alternative activities and preparing for the next step',
              chapterNumber: 3,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_3_3_1',
                  title: 'Module 1: Your Review Routine',
                  content: 'It\'s time for your check-in! As you practice using alternative activities to handle urges, reviewing your progress helps you learn and refine your approach. You\'ll want to have one or two of these review sessions each week.',
                  slideNumber: 1,
                bulletPoints: [
                    'Gather your tools: Have your monitoring records and your summary sheet ready.',
                    'Start with the basics: In each review, you\'ll still ask yourself the questions from your Step 1 and Step 2 reviews.',
                    'Focus on learning: The goal is to see what\'s working and what\'s not, so you can adjust your plan.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_3_2',
                  title: 'Module 2: Questions About Your Toolkit',
                  content: 'Now, let\'s focus specifically on your use of alternative activities. Answering these questions honestly will help you make your toolkit even more effective.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Is my list ready? Have I created my list of alternative activities? Do I have it with me so I can use it when I need it?',
                    'Am I spotting my urges? Am I noticing and recording my urges to eat or vomit in my monitoring records as they happen?',
                    'Am I using my list? When I have an urge, am I pulling out my list and trying one of the activities?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_3_3',
                  title: 'Module 3: Improving Your Approach',
                  content: 'Using these new skills is a learning process. The more you practice, the better you\'ll get. Think about how your recent attempts have gone and what you can learn from them.',
                  slideNumber: 3,
                  bulletPoints: [
                    'How did it go? When I tried an activity, did it help? Did I intervene early enough before the urge got too strong?',
                    'What works for me? Which activities on my list are most helpful? Which ones aren\'t as effective?',
                    'Am I updating my list? Based on my experience, have I made any changes to my "Go-To" list to make it stronger?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_3_4',
                  title: 'Module 4: When Are You Ready for Step 4?',
                  content: 'It takes time and practice to get comfortable using alternative activities. You don\'t need to be perfect, but you should feel like you are consistently trying to use this skill before moving on.',
                  slideNumber: 4,
                  bulletPoints: [
                    'It\'s about practice: If your review sessions show that you\'re having urges but are not successfully using your new strategies to address them, it\'s a sign that you need more practice at this step.',
                    'Don\'t rush the process: The more you practice "urge surfing," the more confident you will become.',
                    'Ready for the next challenge: Once you feel you are consistently applying this skill when urges arise, you\'ll be ready to move on to Step 4.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 3.4: What is Happening To My Weight?
            Lesson(
              id: 'lesson_s2_3_4',
              title: '3.4: What is Happening To My Weight?',
              description: 'Understanding and managing weight concerns during the recovery process',
              chapterNumber: 3,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_s2_3_4_1',
                  title: 'Module 1: Taking a Look at Your Weight',
                  content: 'By this point in the program, enough time has passed to start looking for a trend in your weight. It\'s a good moment to check in and see what\'s happening.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Look at your graph: The best way to see the big picture is to look at the weekly weights you\'ve been plotting on your weight graph.',
                    'What most people find: For most people, there has been little or no overall change in weight, although there will always be some week-to-week fluctuations.',
                    'The goal is understanding: This isn\'t about judging the number on the scale. It\'s about calmly observing the overall trend as you continue to heal your relationship with food.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_4_2',
                  title: 'Module 2: Why the Scale Can Be Tricky',
                  content: 'Interpreting your weight graph is a skill, and it\'s more complex than just looking at the latest number. Here are three key things to remember so you don\'t get discouraged by normal fluctuations.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Your body is mostly water: Short-term changes of 1 to 3 pounds are almost always due to shifts in your body\'s hydration level, not changes in body fat.',
                    'Trends take time: It\'s nearly impossible to see a real trend until you have at least a few weeks of data. One or two weigh-ins don\'t tell the whole story.',
                    'Focus on the last month: To understand what\'s really happening, you need to look at the pattern over the past four or more weeks, rather than focusing on a single number.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_4_3',
                  title: 'Module 3: If Your Weight Has Consistently Changed',
                  content: 'Sometimes, the trend on your graph might show a consistent change. It\'s important to approach this information calmly and thoughtfully, without jumping to conclusions or making drastic changes to your eating.',
                  slideNumber: 3,
                  bulletPoints: [
                    'If your weight has gone down: Has it fallen to a point where you are now in the underweight range? If so, it\'s a good idea to check in with your doctor. It may be a sign that you aren\'t eating enough in your planned meals and snacks.',
                    'If your weight has gone up: First, were you at a low weight when you started? Your body might be returning to a healthier place. Second, if you are in the overweight range, you\'ll be in a much better position to address that once you have a stable, healthy relationship with eating.',
                    'The most important rule: Do not react by starting a strict diet. This is the surest way to undo the wonderful progress you have made so far.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_3_4_4',
                  title: 'Module 4: The Path Forward',
                  content: 'No matter what your weight trend shows, the journey forward is the same: continue to focus on healing your relationship with food. This program is not a weight-loss plan; it\'s a plan to help you regain control and find peace with eating.',
                  slideNumber: 4,
                bulletPoints: [
                    'Stay the course: Continue to focus on regular eating and using your new skills to handle urges.',
                    'Trust the process: Building a healthy relationship with food is the foundation for long-term well-being, whatever your weight.',
                    'You\'re in control: Once you have control over your eating, you will be in a much stronger position to make any other health-related decisions in the future.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            // Additional lessons will be added here
          ],
        ),
        
        // Chapter 4: Step 4 - Problem Solving
        Chapter(
          chapterNumber: 4,
          title: 'Step 4 - Problem Solving',
          lessons: [
            // Lesson 4.1: Checking In on Problem-Solving
            Lesson(
              id: 'lesson_s2_4_1',
              title: '4.1: Checking In on Problem-Solving',
              description: 'Learning systematic problem-solving techniques to address life challenges that contribute to binge eating',
              chapterNumber: 4,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_4_1_1',
                  title: 'Module 1: Your Problem-Solving Review',
                  content: 'Welcome to your Step 4 check-in! This review is all about how you\'re using your new problem-solving skills. Remember, the goal isn\'t just to fix problems, but to get better at the process of fixing them.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Be consistent: Continue to hold your regular review sessions once or twice a week.',
                    'Keep the foundation: In addition to the new questions below, remember to keep asking yourself the review questions from Steps 1, 2, and 3.',
                    'Focus on the skill: This review helps you build a lifelong skill that will help you in all areas of your life, not just with eating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_1_2',
                  title: 'Module 2: Are You Practicing Enough?',
                  content: 'The first thing to ask yourself is whether you\'re giving yourself enough chances to practice your new superpower. The more you use it, the more natural it will become.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Look for opportunities: Are you practicing problem-solving whenever a problem comes up, even a small one? Any challenge is a chance to build your skill.',
                    'Is it frequent enough? You should be looking for opportunities to practice every day.',
                    'Reframe your thoughts: If it feels a bit "obsessive" at first, remind yourself that you are actively learning a new skill. It won\'t feel this intense forever.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_1_3',
                  title: 'Module 3: Are You Practicing Correctly?',
                  content: 'It\'s not just about how often you practice, but how you practice. Following the steps is key to making this skill effective and automatic over time.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Are you following the steps? When you face a problem, are you consciously going through the six steps of problem-solving?',
                    'Are you writing it down? It\'s much more effective to write the steps out (perhaps on the back of your monitoring record) than to just think them through in your head.',
                    'Are you reviewing your work? This is the most important part! Are you taking a moment the next day to review how you problem-solved, not just whether you fixed the problem? This is how you really learn and improve.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_1_4',
                  title: 'Module 4: Moving On to the Next Step',
                  content: 'By consistently practicing and reviewing your problem-solving skills, you are building a strong foundation for lasting change. Knowing when to move on is about feeling confident in your new approach.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Update your "change day": A "change day" now means you monitored, weighed weekly, did your best with regular eating, used alternative activities for urges, AND practiced problem-solving.',
                    'When is it time for Step 5? If your binge eating has become infrequent, or if you have been practicing the skills in Steps 2, 3, and 4 for about 6 to 8 weeks, it\'s a great time to move on and take stock of your amazing progress.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 4.2: Checking In on Problem-Solving (duplicate content from images)
            Lesson(
              id: 'lesson_s2_4_2',
              title: '4.2: Checking In on Problem-Solving',
              description: 'Reviewing your progress with problem-solving skills and preparing for the next phase',
              chapterNumber: 4,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_4_2_1',
                  title: 'Module 1: Your Problem-Solving Review',
                  content: 'Welcome to your Step 4 check-in! This review is all about how you\'re using your new problem-solving skills. Remember, the goal isn\'t just to fix problems, but to get better at the process of fixing them.',
                  slideNumber: 1,
                bulletPoints: [
                    'Be consistent: Continue to hold your regular review sessions once or twice a week.',
                    'Keep the foundation: In addition to the new questions below, remember to keep asking yourself the review questions from Steps 1, 2, and 3.',
                    'Focus on the skill: This review helps you build a lifelong skill that will help you in all areas of your life, not just with eating.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_2',
                  title: 'Module 2: Are You Practicing Enough?',
                  content: 'The first thing to ask yourself is whether you\'re giving yourself enough chances to practice your new superpower. The more you use it, the more natural it will become.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Look for opportunities: Are you practicing problem-solving whenever a problem comes up, even a small one? Any challenge is a chance to build your skill.',
                    'Is it frequent enough? You should be looking for opportunities to practice every day.',
                    'Reframe your thoughts: If it feels a bit "obsessive" at first, remind yourself that you are actively learning a new skill. It won\'t feel this intense forever.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_3',
                  title: 'Module 3: Are You Practicing Correctly?',
                  content: 'It\'s not just about how often you practice, but how you practice. Following the steps is key to making this skill effective and automatic over time.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Are you following the steps? When you face a problem, are you consciously going through the six steps of problem-solving?',
                    'Are you writing it down? It\'s much more effective to write the steps out (perhaps on the back of your monitoring record) than to just think them through in your head.',
                    'Are you reviewing your work? This is the most important part! Are you taking a moment the next day to review how you problem-solved, not just whether you fixed the problem? This is how you really learn and improve.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_4',
                  title: 'Module 4: Moving On to the Next Step',
                  content: 'By consistently practicing and reviewing your problem-solving skills, you are building a strong foundation for lasting change. Knowing when to move on is about feeling confident in your new approach.',
                  slideNumber: 4,
                bulletPoints: [
                    'Update your "change day": A "change day" now means you monitored, weighed weekly, did your best with regular eating, used alternative activities for urges, AND practiced problem-solving.',
                    'When is it time for Step 5? If your binge eating has become infrequent, or if you have been practicing the skills in Steps 2, 3, and 4 for about 6 to 8 weeks, it\'s a great time to move on and take stock of your amazing progress.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 4.2.1: Problem Solving Exercise
            Lesson(
              id: 'lesson_s2_4_2_1',
              title: '4.2.1: Problem Solving Exercise',
              description: 'Practice your problem-solving skills with structured exercises and real-world scenarios',
              chapterNumber: 4,
              lessonNumber: 21, // Using 21 to represent 2.1
              slides: [
                LessonSlide(
                  id: 'slide_s2_4_2_1_1',
                  title: 'Ready to Practice Problem Solving?',
                  content: 'This lesson will take you directly to the Problem Solving Exercise in the Tools section. Here you can practice your problem-solving skills with structured exercises and real-world scenarios.',
                  slideNumber: 1,
                bulletPoints: [
                    'The Problem Solving Exercise provides hands-on practice with real scenarios',
                    'You can work through problems step-by-step using the structured approach',
                    'Practice makes the problem-solving process more natural and automatic',
                    'You can return to this exercise anytime to continue building your skills'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_1_2',
                  title: 'What You\'ll Practice',
                  content: 'In the Problem Solving Exercise, you\'ll work through various scenarios that commonly trigger binge eating, learning to apply your new skills in real situations.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Identify the specific problem clearly and objectively',
                    'Generate multiple possible solutions without judgment',
                    'Evaluate the pros and cons of each solution',
                    'Choose the best solution and create a concrete action plan'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_1_3',
                  title: 'Getting Started',
                  content: 'When you\'re ready, tap "Start Exercise" to go directly to the Problem Solving tool. You can work through as many scenarios as you like and return anytime.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The exercise will guide you through each step of the problem-solving process',
                    'Take your time with each scenario - there\'s no rush',
                    'The more you practice, the more natural this approach will become',
                    'Remember: this is a skill that will help you in all areas of life, not just with eating'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_4_2_1_4',
                  title: 'Ready to Begin?',
                  content: 'You\'re about to access the Problem Solving Exercise. This hands-on practice will help you master the problem-solving skills you\'ve learned.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tap "Start Exercise" to go to the Problem Solving tool',
                    'Work through the scenarios at your own pace',
                    'Return to this lesson anytime to access the exercise again',
                    'Remember: practice makes perfect!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 5: Step 5 - Taking Stock
        Chapter(
          chapterNumber: 5,
          title: 'Step 5 - Taking Stock',
          lessons: [
            // Lesson 5.1: Taking Stock: Should You Continue?
            Lesson(
              id: 'lesson_s2_5_1',
              title: '5.1: Taking Stock: Should You Continue?',
              description: 'Evaluating your progress and deciding whether to continue with additional program modules',
              chapterNumber: 5,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_5_1_1',
                  title: 'Module 1: It\'s Time to Take Stock',
                  content: 'You\'ve been working hard for several weeks now, and it\'s a great time to pause and review your journey. Taking stock isn\'t about judgment; it\'s about honestly seeing where you are so you can choose the best next step for you.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Look at your summary sheet: The information you\'ve been tracking will give you a clear picture of your progress.',
                    'Progress looks different for everyone: There are a few common outcomes at this stage, and each one has a wise path forward.',
                    'Be proud of yourself: No matter what, you have taken a huge, brave step by starting this program. That\'s a win in itself.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_1_2',
                  title: 'Module 2: Scenario 1 - Things Are Going Well!',
                  content: 'This is a wonderful outcome! If you\'re seeing a real change in your eating patterns, it\'s a clear sign that the program is working for you. This is a moment to celebrate your progress and feel encouraged to keep going.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Look for the signs: Have your binges become less frequent? Have you reduced or stopped vomiting or misusing laxatives?',
                    'This is a green light: If your answer is yes, you are doing great! The best thing you can do now is continue with the program.',
                    'You\'re on the right track: These positive changes are a very promising sign, and you should feel confident in the path you\'re on.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_1_3',
                  title: 'Module 3: Scenario 2 - A Time for Gentle Honesty',
                  content: 'Sometimes, you might find there hasn\'t been much change, but if you\'re honest with yourself, you know you haven\'t been able to follow the program as closely as you\'d like. This is a common experience, and it\'s an opportunity to check in with your motivation.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Be honest, not critical: Have you been having a high number of "change days" each week? If not, it\'s a good time to ask why.',
                    'Reconnect with your "why": It might be helpful to go back and reread the "Why Change?" section. What inspired you to start?',
                    'You have a choice: You can either make a fresh commitment to the program now, or you can decide that now isn\'t the right time and plan to come back to it later. There is no right or wrong answer, only what\'s best for you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_1_4',
                  title: 'Module 4: Scenario 3 - When You\'ve Given It Your All',
                  content: 'What if you\'ve been trying your very best—you have lots of "change days" to show for it—but your binge eating hasn\'t improved much? First, be proud of your incredible effort. Second, know that this doesn\'t mean you\'ve failed; it means that this self-help program may not be enough on its own, and that\'s okay.',
                  slideNumber: 4,
                  bulletPoints: [
                    'It\'s not your fault: Sometimes, the eating problem is too severe or other life challenges are getting in the way.',
                    'Consider other challenges: Are major difficulties with depression, low self-esteem, perfectionism, or stressful relationships acting as a barrier to your progress?',
                    'A sign to seek more support: If this sounds like you, the bravest and most effective next step is to seek professional help. This isn\'t a failure—it\'s a smart and powerful move on your path to recovery.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 5.2: What's Next On Your Journey?
            Lesson(
              id: 'lesson_s2_5_2',
              title: '5.2: What\'s Next On Your Journey?',
              description: 'Planning your next steps whether you continue with the program or focus on maintenance',
              chapterNumber: 5,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_5_2_1',
                  title: 'Module 1: Planning Your Path Forward',
                  content: 'If you\'ve decided to continue with the program, congratulations! Now it\'s time to make the journey even more personal. The next step is to focus on the specific things that have been keeping your binge eating problem going.',
                  slideNumber: 1,
                bulletPoints: [
                    'You\'re ready to go deeper and tackle the root causes.',
                    'This is about understanding your unique patterns.',
                    'By focusing on what\'s most relevant to you, you\'ll make your progress even stronger and more lasting.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_2_2',
                  title: 'Module 2: The Dieting Connection',
                  content: 'Let\'s explore the first of two key areas. For many people, dieting and binge eating are locked in a powerful cycle. Take a moment to honestly reflect on whether this is true for you.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Ask yourself: Does my dieting contribute to my tendency to binge eat?',
                    'Do your binges often happen after you\'ve broken a diet rule or tried to restrict what you eat?',
                    'If this sounds familiar, then tackling your relationship with dieting is a very important next step for you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_2_3',
                  title: 'Module 3: The Body Image Connection',
                  content: 'Now let\'s look at the second key area. Concerns about shape and weight can be a major driving force behind the cycle of dieting and bingeing. Let\'s see if this is a factor for you.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Ask yourself: Do concerns about my shape or weight contribute to my binge eating problem?',
                    'Do you find yourself dieting because you\'re unhappy with your body, which then leads to a binge?',
                    'If this feels true for you, then working on body image will be a key part of your path forward.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_5_2_4',
                  title: 'Module 4: What If Both Are True?',
                  content: 'It\'s very common for both dieting and body image to feel like important issues. If you feel that both connections are true for you, don\'t worry! You don\'t have to tackle everything at once.',
                  slideNumber: 4,
                  bulletPoints: [
                    'If both are relevant, start with the one that feels like the biggest or most important trigger for you right now.',
                    'Focus your energy on that single area for the next 3 to 4 weeks.',
                    'After that, you can begin to work on the second area. Tackling them one by one is the most effective approach.',
                    'Most importantly, remember to keep practicing all the great skills you learned in Steps 1 through 4! They are your foundation for success.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 6: Dieting Module
        Chapter(
          chapterNumber: 6,
          title: 'Dieting Module',
          lessons: [
            // Lesson 6.1: Making Peace With Food
            Lesson(
              id: 'lesson_s2_6_1',
              title: '6.1: Making Peace With Food',
              description: 'Learning to identify and eliminate strict dietary rules that contribute to binge eating',
              chapterNumber: 6,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_6_1_1',
                  title: 'Module 1: Is Strict Dieting a Trigger for You?',
                  content: 'To keep moving forward, it\'s important to look at the things that might make you vulnerable to bingeing. For many people, strict dieting is a major trigger. Let\'s find out if this is part of your story.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Take a moment to reflect: Do you try not to eat for long periods of time?',
                    'Do you try to stay under a very specific calorie limit each day?',
                    'Do you have a list of "forbidden" or "bad" foods that you try to avoid?',
                    'Most importantly, do you find that if you break one of these "rules," you tend to give up and binge?',
                    'If you answered yes to any of these, then learning to address strict dieting will be a huge step forward for you.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_1_2',
                  title: 'Module 2: The Problem with Delaying and Restricting',
                  content: 'Two common forms of strict dieting are delaying eating and setting rigid calorie limits. While it might feel like you\'re in control when you do this, it often backfires by creating intense physical and mental pressure to eat.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Remember Step 2: Eating regularly is your best defense against delaying eating. It prevents you from getting overly hungry and keeps your body fueled.',
                    'Calorie limits can cause binges: Trying to eat very little (especially under 1,500 calories/day) makes you more likely to binge.',
                    'Let go of counting: For now, the goal is to stop counting calories. Focus on eating average-sized portions at your planned meals and snacks.',
                    'A surprising truth: When you stop restricting so much, you\'ll likely binge less, which often means you end up eating less overall.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_1_3',
                  title: 'Module 3: Facing "Forbidden" Foods - Step 1',
                  content: 'Avoiding certain foods is one of the most powerful triggers for binge eating. The very act of telling yourself you "can\'t" have something makes it all the more tempting. The good news is, you can change this, and it starts with a simple plan.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Your first mission: Make a list of all the foods you\'re afraid to eat or that you feel you "shouldn\'t" have. The best way to do this is to walk through a supermarket and write down everything that feels off-limits.',
                    'Organize your list: Once you have your list, group the foods into a few categories, from the "least scary" to introduce, to the "most challenging."',
                    'This is your roadmap: This list isn\'t for avoiding—it\'s your guide to gently and safely bringing these foods back into your life.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_1_4',
                  title: 'Module 4: Facing "Forbidden" Foods - Step 2',
                  content: 'Now it\'s time to put your plan into action. By slowly and intentionally reintroducing foods you\'ve avoided, you take away their power and reduce your urge to binge on them.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Start with the easiest group: Pick a food from your "least scary" list.',
                    'Plan it in: Include a small, normal-sized portion of this food as part of a planned meal or snack.',
                    'Choose a good day: Only do this on a day when you\'re feeling relatively calm and in control of your eating.',
                    'It\'s not about the amount: Even one bite is a huge success! The goal is to teach yourself that you can eat these foods without it leading to a binge.',
                    'Practice, practice, practice: Keep introducing these foods until they no longer feel scary. You are freeing yourself from the power of "forbidden" foods.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 6.2: Check In On Your Dieting Progress
            Lesson(
              id: 'lesson_s2_6_2',
              title: '6.2: Check In On Your Dieting Progress',
              description: 'Reviewing your progress in addressing strict dieting patterns and food rules',
              chapterNumber: 6,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_6_2_1',
                  title: 'Module 1: Time for a Dieting Check-In',
                  content: 'You\'ve been working on making peace with food by tackling strict dieting. Now it\'s time for your weekly review. This is a chance to look at your progress with curiosity and kindness, and to see what you\'ve learned.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This isn\'t about perfection: It\'s about noticing your efforts and identifying where you can keep growing.',
                    'Use your monitoring records: Your notes will give you a clear and honest picture of the past week.',
                    'Let\'s look at two key areas: We\'ll review how you\'re tackling the main forms of dieting and how you\'re handling eating with others.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_2_2',
                  title: 'Module 2: Reviewing the Three Forms of Dieting',
                  content: 'Let\'s take a closer look at your progress with the three main types of dieting that can trigger binges. Ask yourself how you\'ve done with each one over the past week.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Delaying eating: Have you been sticking to your pattern of regular eating from Step 2?',
                    'Restricting how much you eat: Have you been able to let go of strict calorie limits and focus on eating normal-sized portions?',
                    'Avoiding "forbidden" foods: Have you been practicing introducing some of your avoided foods back into your planned meals and snacks?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_2_3',
                  title: 'Module 3: Reflecting on Eating with Others',
                  content: 'Sometimes, our eating habits are different when we are with other people. This is a good time to reflect on whether this is an area you need to work on.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Ask yourself: Am I tackling eating in front of others?',
                    'Do you find it hard to eat normally or to eat your planned meals when you are not alone?',
                    'If this feels like a challenge, it\'s a great area to focus on. Practicing your new skills in social situations is a big step toward food freedom.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_2_4',
                  title: 'Module 4: What is a "Change Day" Now?',
                  content: 'As you review your week, remember to update your summary sheet. A "change day" now includes all your previous skills, plus your efforts in this module. It\'s a day where you did your best to...',
                  slideNumber: 4,
                  bulletPoints: [
                    'Monitor accurately and weigh in weekly.',
                    'Stick to your regular eating plan.',
                    'Use alternative activities and problem-solving skills when needed.',
                    'And, most importantly, a day where you actively tackled strict dieting.',
                    'Keep practicing for at least a month or two. This is a big change, and it\'s important to persevere to protect yourself from future binges.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 6.3: When to Move On from the Dieting Module
            Lesson(
              id: 'lesson_s2_6_3',
              title: '6.3: When to Move On from the Dieting Module',
              description: 'Determining when you\'re ready to move on from the dieting module to other areas of focus',
              chapterNumber: 6,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_6_3_1',
                  title: 'Module 1: This is a Marathon, Not a Sprint',
                  content: 'Breaking free from the habit of strict dieting is a big deal, and it\'s a process that takes time. Be patient and kind with yourself as you learn these new skills. This isn\'t about a quick fix; it\'s about creating lasting change.',
                  slideNumber: 1,
                bulletPoints: [
                    'Set a realistic timeline: It often takes at least a month or two to feel comfortable and confident with this new way of eating.',
                    'Progress over perfection: The goal is to keep practicing and moving in the right direction, not to be perfect every day.',
                    'You\'re building a new foundation: Every day you practice, you\'re making yourself stronger and more resilient.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_3_2',
                  title: 'Module 2: Why It\'s So Important to Persevere',
                  content: 'It can be tempting to move on quickly, but sticking with this module is one of the most important things you can do for your recovery. By truly making peace with food, you protect yourself from future binges.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Dieting is a major trigger: Remember, strict dieting is often what makes you most vulnerable to binge eating.',
                    'Don\'t leave yourself unprotected: By truly learning to let go of dieting, you are removing one of the biggest triggers.',
                    'Your future self will thank you: The effort you put in now will pay off for years to come in the form of food freedom.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_3_3',
                  title: 'Module 3: Juggling Different Goals',
                  content: 'It\'s very possible that you are also working on the Body Image module at the same time as this one. It\'s perfectly okay to work on both, as they are often very connected.',
                  slideNumber: 3,
                  bulletPoints: [
                    'It\'s normal to have multiple focuses: Your relationship with food and your relationship with your body are linked.',
                    'Keep practicing both: Continue to apply the skills you\'re learning about body image while you also work on letting go of strict dieting.',
                    'They support each other: As you make peace with food, it often becomes easier to make peace with your body, and vice versa.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_6_3_4',
                  title: 'Module 4: Looking Ahead to Lasting Change',
                  content: 'As you continue to practice and make progress, don\'t forget about the final step in the program. There is one last module that will help you make sure all your hard work sticks for the long term.',
                  slideNumber: 4,
                  bulletPoints: [
                    'You\'re almost there: You\'ve made incredible progress on your journey.',
                    'Don\'t forget the final step: The last module, "Ending Well," is designed to help you maintain your new skills.',
                    'This is for the long haul: This final step will help you feel confident in your ability to handle challenges and stay on track in the future.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
          ],
        ),
        
        // Chapter 7: Body Image Module
        Chapter(
          chapterNumber: 7,
          title: 'Body Image Module',
          lessons: [
            // Lesson 7.1: How Important is Shape and Weight to You?
            Lesson(
              id: 'lesson_s2_7_1',
              title: '7.1: How Important is Shape and Weight to You?',
              description: 'Recognizing when concerns about body shape and weight become excessive and problematic',
              chapterNumber: 7,
              lessonNumber: 1,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_1_1',
                  title: 'Module 1: How Do You Measure Your Self-Worth?',
                  content: 'Let\'s start with a big question: How do you decide if you\'re a "good" or "worthwhile" person? Most people use a mix of different things to measure their self-worth, like their friendships, their performance at work, their hobbies, or their family life. For people with eating challenges, however, shape and weight can often take over, becoming the main—or even the only—way they measure their value.',
                  slideNumber: 1,
                  bulletPoints: [
                    'A balanced view: A healthy sense of self-worth is usually based on performance in many different areas of life.',
                    'An unbalanced view: Sometimes, self-worth can become almost exclusively tied to shape, weight, and the ability to control them.',
                    'Our goal: Is to help you see where your self-worth comes from and to create a more balanced and fulfilling picture.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_2',
                  title: 'Module 2: Your Pie Chart of Self-Worth (Part 1)',
                  content: 'A great way to see how you evaluate yourself is to create a personal "pie chart." Each slice will represent an area of your life that you value. Let\'s start by gathering the ingredients for your chart.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Step 1: Make a list. Write down all the things that are important to how you judge yourself as a person. This might include family, friends, work, fitness, hobbies, and—if it\'s important to you—your shape and weight. Be honest with yourself.',
                    'Step 2: Rank your list. Now, arrange the items on your list in order of importance. A good way to do this is to ask yourself: "If this area of my life wasn\'t going well, how much would it bother me?"'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_3',
                  title: 'Module 3: Your Pie Chart of Self-Worth (Part 2)',
                  content: 'Now it\'s time to create your visual. This chart isn\'t about how you wish you saw yourself; it\'s an honest snapshot of how you evaluate yourself right now.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Step 3: Draw your chart. Draw a circle and divide it into slices. The size of each slice should represent how important that area is to your self-worth. A bigger slice means it has a bigger impact on how you feel about yourself.',
                    'Step 4: Review and adjust. Look at your pie chart over the next few days. Does it feel accurate? Does it truly reflect how you judge yourself day-to-day? Make any changes needed to make it feel right.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_4',
                  title: 'Module 4: What Your Pie Chart Reveals',
                  content: 'Your pie chart is a powerful tool. It can show you, at a glance, what\'s driving your sense of self-worth. Now, let\'s look at what it might be telling you.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Look at the "Shape and Weight" slice: Is there a slice for this? If so, how big is it?',
                    'A sign of overconcern: If the slice for shape and weight takes up a third of your pie chart or more, it\'s a sign that you are likely overconcerned with it.',
                    'Why this is risky: Relying too heavily on one area for your self-worth is like putting all your eggs in one basket. If that one thing isn\'t going "perfectly," it can make you feel bad about your entire self.',
                    'The path forward: Recognizing this is the first, most important step. In the next lessons, we\'ll learn how to shrink this slice and grow the others, creating a more balanced and resilient sense of who you are.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.1.1: Addressing Overconcern Exercise
            Lesson(
              id: 'lesson_s2_7_1_1',
              title: '7.1.1: Addressing Overconcern Exercise',
              description: 'Practice your skills for addressing overconcern about shape and weight with structured exercises',
              chapterNumber: 7,
              lessonNumber: 11, // Using 11 to represent 1.1
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_1_1_1',
                  title: 'Ready to Practice Addressing Overconcern?',
                  content: 'This lesson will take you directly to the Addressing Overconcern Exercise in the Tools section. Here you can practice your skills for addressing overconcern about shape and weight with structured exercises.',
                  slideNumber: 1,
                  bulletPoints: [
                    'The Addressing Overconcern Exercise provides hands-on practice with real scenarios',
                    'You can work through overconcern challenges step-by-step using the structured approach',
                    'Practice makes the addressing overconcern process more natural and automatic',
                    'You can return to this exercise anytime to continue building your skills'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_1_2',
                  title: 'What You\'ll Practice',
                  content: 'In the Addressing Overconcern Exercise, you\'ll work through various scenarios that commonly trigger overconcern about shape and weight, learning to apply your new skills in real situations.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Learn to recognize when overconcern is taking over your self-worth',
                    'Practice rebalancing your pie chart of self-worth',
                    'Develop strategies for reducing body checking and avoidance behaviors',
                    'Build confidence in your ability to address overconcern constructively'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_1_3',
                  title: 'Getting Started',
                  content: 'When you\'re ready, tap "Start Exercise" to go directly to the Addressing Overconcern tool. You can work through as many scenarios as you like and return anytime.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The exercise will guide you through each step of the addressing overconcern process',
                    'Take your time with each scenario - there\'s no rush',
                    'The more you practice, the more natural this approach will become',
                    'Remember: a balanced sense of self-worth comes from many areas of life'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_1_1_4',
                  title: 'Ready to Begin?',
                  content: 'You\'re about to access the Addressing Overconcern Exercise. This hands-on practice will help you master the skills for addressing overconcern about shape and weight.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tap "Start Exercise" to go to the Addressing Overconcern tool',
                    'Work through the scenarios at your own pace',
                    'Return to this lesson anytime to access the exercise again',
                    'Remember: practice makes perfect!'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.2: Rebalancing Your Pie Chart
            Lesson(
              id: 'lesson_s2_7_2',
              title: '7.2: Rebalancing Your Pie Chart',
              description: 'Learning strategies to reduce excessive focus on body shape and weight',
              chapterNumber: 7,
              lessonNumber: 2,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_2_1',
                  title: 'Module 1: Your Two-Part Strategy for Change',
                  content: 'If your pie chart showed that shape and weight have taken up too much space, don\'t worry. That\'s something you have the power to change. We\'re going to use a simple, two-part strategy to rebalance your chart and your life.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Strategy 1: Grow the other slices. We\'ll focus on adding more fulfilling activities and interests into your life, making the other parts of your pie chart bigger and more important.',
                    'Strategy 2: Shrink the "Shape and Weight" slice. We\'ll work on directly reducing the importance of shape and weight by tackling the habits that keep it in the spotlight.',
                    'Keep your foundation: As you work on this, it\'s essential to keep practicing all the skills you\'ve learned in Steps 1 through 4.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_2_2',
                  title: 'Module 2: Growing Your Life - The Brainstorming Phase',
                  content: 'The first step to building a richer, more balanced life is to explore the possibilities. Let\'s make a list of activities and interests that could bring you joy and a sense of accomplishment, helping you grow the other slices of your pie chart.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Look to the past: What did you used to enjoy doing? Make a list of old hobbies or interests you\'ve let go.',
                    'Get curious: What have you always wanted to try? Think about classes, clubs, or skills you\'ve been curious about.',
                    'Be inspired by others: What do your friends or family do for fun? Could any of their activities be a good fit for you? Don\'t censor yourself—just write down every idea that comes to mind.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_2_3',
                  title: 'Module 3: Growing Your Life - The Action Phase',
                  content: 'A list is a great start, but now it\'s time to turn those ideas into reality. The goal is to choose one or two things and commit to trying them out. This is how you begin to actively build new sources of self-worth.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Pick one (or two): From your list, choose one or two activities you\'re willing to try in the next week. It\'s best to pick something that happens regularly, not just a one-time event.',
                    'Give it a real chance: Commit to trying your chosen activity at least three times before deciding if it\'s right for you. If it\'s not a good fit, that\'s okay! Just go back to your list and pick something else.',
                    'Problem-solve any obstacles: Don\'t let little things get in your way. Use the problem-solving skills you learned in Step 4 to navigate any challenges that come up.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_2_4',
                  title: 'Module 4: Shrinking the Main Slice',
                  content: 'While you\'re busy growing the other areas of your life, we can also work on shrinking the "Shape and Weight" slice directly. We do this by addressing the specific behaviors and feelings that keep it so big and powerful.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Tackle the "Expressions": Overconcern is maintained by three key things: body checking, body avoidance, and "feeling fat."',
                    'A powerful ripple effect: When you start to change these behaviors and challenge these feelings, the overconcern itself naturally begins to fade.',
                    'What\'s next: In the upcoming lessons, we\'ll dive into each of these three areas and give you practical tools to address them one by one.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.3: A New Way of Seeing Yourself
            Lesson(
              id: 'lesson_s2_7_3',
              title: '7.3: A New Way of Seeing Yourself',
              description: 'Learning to reduce compulsive body checking behaviors that increase body dissatisfaction',
              chapterNumber: 7,
              lessonNumber: 3,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_3_1',
                  title: 'Module 1: What is Shape Checking?',
                  content: 'Shape checking is the habit of repeatedly checking parts of your body. It can take many forms, from studying your reflection to pinching your skin or seeing how clothes fit. While it might feel like you\'re "staying informed," this habit often magnifies flaws and keeps you stuck in a cycle of worry.',
                  slideNumber: 1,
                bulletPoints: [
                    'Common examples include: Studying your stomach in the mirror, pinching your arms or thighs, repeatedly measuring yourself, or checking how tight your watch feels.',
                    'The magnifying effect: When you scrutinize one part of your body, your brain can make it seem bigger or more flawed than it really is.',
                    'The goal: Is not to ignore your body, but to change this habit of constant, critical checking.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_3_2',
                  title: 'Module 2: A New Plan: Stop and Modify',
                  content: 'Let\'s create a new, healthier plan for how you interact with your body. The first step is to identify your specific checking habits. Then, we\'ll sort them into two simple categories: habits to "Stop" and habits to "Modify."',
                  slideNumber: 2,
                  bulletPoints: [
                    'Make your list: Take a moment to write down all the ways you check your shape throughout the day.',
                    'Create a "Stop" list: This list is for checking behaviors that are more unusual or that you would feel embarrassed about if others knew. The goal is to stop these completely. It will be hard at first, but it will get easier and feel very freeing.',
                    'Create a "Modify" list: This list is for more common behaviors, like using a mirror. We\'re not going to stop these, but we are going to learn a new, healthier way to do them.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_3_3',
                  title: 'Module 3: A Healthier Relationship with Mirrors',
                  content: 'Mirrors are a normal part of life, so our goal isn\'t to get rid of them completely. It\'s to change how we use them. The key is to start using mirrors with a clear and healthy purpose, rather than for automatic, critical checking.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Ask yourself "Why?": Before you look in a mirror, ask yourself, "What am I trying to find out?" If the answer is to check for flaws, it\'s not a helpful reason.',
                    'Good reasons to use a mirror: Checking your hair, applying makeup, or shaving are all great, purposeful reasons to use a mirror.',
                    'Less is more: It can be helpful to limit the number of mirrors in your home. Maybe one for your face and one full-length mirror is enough. Full-length mirrors in the bedroom can be especially tricky.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_3_4',
                  title: 'Module 4: Practical Tips for Using Mirrors',
                  content: 'Here are some simple, practical things you can do to change your mirror habits. Remember, the goal is to use them intentionally, not automatically.',
                  slideNumber: 4,
                  bulletPoints: [
                    'See the whole picture: When you look in the mirror, try to see your whole self rather than zooming in on one specific part you dislike.',
                    'Avoid naked checking: It\'s generally not helpful to study your body naked in the mirror. People with eating challenges rarely admire what they see, they only criticize.',
                    'Get dressed away from the mirror: Try not to dress or undress directly in front of a mirror.',
                    'Plan your outfit first: To avoid trying on multiple outfits (which often leads to more body dissatisfaction), try laying out your clothes on the bed before you put them on.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.4: Breaking the Comparison Trap
            Lesson(
              id: 'lesson_s2_7_4',
              title: '7.4: Breaking the Comparison Trap',
              description: 'Learning to stop comparing your appearance to others and develop self-acceptance',
              chapterNumber: 7,
              lessonNumber: 4,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_4_1',
                  title: 'Module 1: The Comparison Trap',
                  content: 'Do you find yourself constantly comparing your body to others? This is a very common habit, but it\'s often a trap that makes you feel worse about yourself. Let\'s look at why this happens and how you can start to break free.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It\'s not a fair fight: We often compare our "worst" features (the ones we scrutinize) with the "best" features of others, which we only see at a glance.',
                    'It\'s a biased view: We tend to compare ourselves to a very select group of people, like models or celebrities, instead of the wide variety of bodies that exist in the real world.',
                    'The goal: The first step is simply to become aware of this habit and understand that the conclusions you draw from it are probably not accurate or fair.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_4_2',
                  title: 'Module 2: Become a Comparison Detective',
                  content: 'To change a habit, you first have to understand it. For the next few days, your mission is to become a detective and simply notice when, and how, you make comparisons. Don\'t judge yourself, just observe.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Notice the moment: When you find yourself making a comparison, make a mental note or jot it down.',
                    'Ask yourself: Who did I just compare myself with? (A friend, a stranger, someone on social media?) What specifically did I focus on? How did it make me feel?',
                    'Look for patterns: You\'re just collecting information to see what your personal comparison patterns look like.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_4_3',
                  title: 'Module 3: A Real-World Experiment',
                  content: 'Are you ready to challenge the idea that everyone else looks "better"? Try this simple, eye-opening experiment the next time you\'re in a public place, like a mall or a busy street.',
                  slideNumber: 3,
                  bulletPoints: [
                    'The experiment: Decide to mindfully look at every third person who passes you (of your gender and approximate age).',
                    'The goal: The point isn\'t to judge them or yourself, but simply to notice the reality: bodies come in a huge variety of shapes and sizes.',
                    'The takeaway: You\'ll likely discover that your mind has been filtering out the "average" and focusing only on a narrow, often unrealistic, ideal.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_4_4',
                  title: 'Module 4: Challenging Media Myths',
                  content: 'It\'s almost impossible to avoid comparing ourselves to the images we see in magazines and online. But it\'s crucial to remember that what you\'re seeing often isn\'t real. Being smart about the media you consume is a powerful way to protect your self-esteem.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Most images are manipulated: Virtually all photos in ads and magazines are digitally altered (airbrushed or photoshopped) to create a flawless, unrealistic look.',
                    'Get curious: Go online and search for videos about "photo retouching" or "Dove Evolution." Seeing how it\'s done can be incredibly empowering.',
                    'Take it with a pinch of salt: From now on, when you see a "perfect" body in the media, remind yourself that you\'re likely looking at a fantasy, not a reality.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.5: Reconnecting With Your Body
            Lesson(
              id: 'lesson_s2_7_5',
              title: '7.5: Reconnecting With Your Body',
              description: 'Learning to stop avoiding situations due to body shape concerns and reclaim your life',
              chapterNumber: 7,
              lessonNumber: 5,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_5_1',
                  title: 'Module 1: What is Shape Avoidance?',
                  content: 'Shape avoidance is the opposite of shape checking. It\'s when you try not to see or be aware of your body because you dislike how it looks or feels. While this might feel like a way to protect yourself, it actually prevents you from challenging the negative feelings and fears you have about your body.',
                  slideNumber: 1,
                  bulletPoints: [
                    'Common examples include: Getting dressed in the dark, avoiding mirrors, wearing very baggy clothes, or avoiding activities like swimming.',
                    'The problem: When you avoid your body, any negative assumptions you have about it go unquestioned and can feel even more true.',
                    'The impact: At its most extreme, shape avoidance can interfere with your social life, your ability to be intimate, and your overall freedom.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_5_2',
                  title: 'Module 2: The Path Forward: Gentle Exposure',
                  content: 'The most effective way to address shape avoidance is through a process of gentle, progressive "exposure." This doesn\'t mean forcing yourself into uncomfortable situations. Instead, it means slowly and intentionally becoming accustomed to the sight and feel of your own body again, one small step at a time.',
                  slideNumber: 2,
                  bulletPoints: [
                    'It\'s a step-by-step journey: You\'ll move at a pace that feels right for you.',
                    'The goal is freedom: The aim is to free yourself from the rules and restrictions that avoidance has placed on your life.',
                    'Know your body, don\'t avoid it: It is far better and more liberating to know your own body than to live in fear of it.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_5_3',
                  title: 'Module 3: Practical Steps for Reconnecting',
                  content: 'Here are some gentle, practical steps you can take to begin the process of reconnecting with your body. Start with what feels most manageable and progress to the next step when you\'re ready.',
                  slideNumber: 3,
                  bulletPoints: [
                    'If you dress in the dark: Try lighting a candle in your room first. When you\'re comfortable with that, you can work your way toward dressing with the lights on.',
                    'If you avoid touching your body: Start by consciously washing yourself, perhaps focusing on neutral parts like your hands and feet. Gradually, you can work toward being able to wash your whole body with your hands.',
                    'If you avoid being aware of your body: Try activities that gently increase body awareness, like applying body lotion, getting a massage, or joining a gentle yoga or dance class.',
                    'If you wear baggy clothes: Try choosing one item of clothing that is a little more form-fitting and wear it at home for a short period to start.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_5_4',
                  title: 'Module 4: A Liberating Journey',
                  content: 'Remember, this is not a race. Changing your relationship with your body takes time and patience. Every small step you take to challenge avoidance is a step toward greater freedom and self-acceptance. Be kind to yourself as you go.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Take it slow: Move through the steps as quickly or as slowly as you need.',
                    'Be patient: You are unlearning a habit that may have been with you for a long time.',
                    'Celebrate your courage: It takes real strength to face these fears, and every effort is a victory.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.6: Understanding the Feeling of "Feeling Fat"
            Lesson(
              id: 'lesson_s2_7_6',
              title: '7.6: Understanding the Feeling of "Feeling Fat"',
              description: 'Understanding and managing the experience of "feeling fat" and its emotional meanings',
              chapterNumber: 7,
              lessonNumber: 6,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_6_1',
                  title: 'Module 1: What Does "Feeling Fat" Really Mean?',
                  content: '"Feeling fat" is a powerful and often distressing experience, but it\'s important to understand what it is—and what it isn\'t. It\'s a feeling, not a fact about your body. A key thing to notice is that this feeling can change dramatically throughout the day, even when your body hasn\'t changed at all.',
                  slideNumber: 1,
                  bulletPoints: [
                    'It\'s a Feeling, Not a Fact: Your body doesn\'t suddenly gain or lose fat in a matter of hours. "Feeling fat" is an emotional or physical sensation, not an accurate measurement.',
                    'It Fluctuates: Unlike your actual weight, which is relatively stable day-to-day, the intensity of "feeling fat" can go up and down quickly.',
                    'It\'s Often a Mislabeled Feeling: Most of the time, "feeling fat" is our brain\'s way of labeling other, less clear emotions or bodily sensations.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_6_2',
                  title: 'Module 2: Become a Detective of Your Feelings',
                  content: 'The first step to managing this feeling is to get curious about it. We\'re going to become detectives and look for clues about what\'s really going on when you start to "feel fat." For the next few days, try to notice when the feeling is strongest.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Identify the "Peaks": In your journal or notes, make a special mark whenever you have a peak of "feeling fat."',
                    'Look for Triggers: What was happening in the hour before you started to feel this way? Did you have a stressful conversation? Did you check your reflection?',
                    'Name the Other Feelings: At that moment, what else were you feeling? Common culprits include being bored, lonely, depressed, bloated, or tired.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_6_3',
                  title: 'Module 3: Connecting the Dots in the Moment',
                  content: 'As you get better at noticing the triggers, the next step is to practice identifying them in real-time. When the wave of "feeling fat" hits, pause and ask yourself what might be underneath it.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Ask "What\'s Really Going On?": When you feel fat, gently ask yourself, "What might be the real cause of this feeling right now?"',
                    'Unmask the Sensation: Are you feeling bloated after a meal? Are your clothes feeling tight? Are you feeling sad? Try to name the specific, underlying sensation.',
                    'Remind Yourself of the Truth: Gently remind yourself, "This is just a feeling. My body has not suddenly changed." This helps to break the connection between the feeling and the fear of being fat.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_6_4',
                  title: 'Module 4: Address the Real Cause',
                  content: 'Once you\'ve identified the likely cause behind the feeling, you can take action to address the real problem. This is how you take your power back from the feeling and respond to your true needs.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Simple Solutions: If the cause is physical (like tight clothes or feeling bloated), the solution can be simple. Change into something more comfortable, or do a gentle activity to help with digestion.',
                    'Emotional Needs: If the cause is emotional (like loneliness or sadness), what do you really need? Maybe you need to call a friend, journal your thoughts, or listen to comforting music.',
                    'Use Your Skills: You can use the problem-solving skills you learned in Step 4 to find the best way to address the underlying issue.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.7: Checking In on Your Body Image
            Lesson(
              id: 'lesson_s2_7_7',
              title: '7.7: Checking In on Your Body Image',
              description: 'Reviewing your progress in addressing body image concerns and planning continued work',
              chapterNumber: 7,
              lessonNumber: 7,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_7_1',
                  title: 'Module 1: Time to Check In on Your Progress',
                  content: 'It\'s time for your weekly body image check-in! This is a friendly, supportive moment to pause and look at the progress you\'re making. The goal isn\'t to judge yourself, but to get curious about what\'s working and what might need a little more attention as you build a healthier relationship with your body.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This is your time: Set aside 15-20 minutes for a weekly review.',
                    'Use your notes: Have your journal or monitoring records handy to help you reflect on the past week.',
                    'Be kind: Remember, this is a process of learning and growing. Every bit of effort is a success.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_7_2',
                  title: 'Module 2: Review Question 1: Are You Broadening Your Life?',
                  content: 'The first thing to reflect on is how you\'re rebalancing your "pie chart." A big part of reducing the overconcern with shape and weight is to grow the other important areas of your life. Take a moment to think about the new activities you\'ve been trying.',
                  slideNumber: 2,
                  bulletPoints: [
                    'Ask yourself: "Am I getting more into my life?" and "Am I doing new things?"',
                    'Think about the impact: How has engaging in new activities or hobbies made you feel?',
                    'Look at your pie chart: Is the slice for "shape and weight" starting to feel a little smaller as other slices get bigger?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_7_3',
                  title: 'Module 3: Review Question 2: Are You Challenging Old Habits?',
                  content: 'Next, let\'s look at how you\'re addressing the three main "expressions" of body image concerns. This is where you actively work to change the old habits that keep you stuck. Be honest and gentle with yourself as you review your progress.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Shape Checking: How have you done with reducing shape checking and comparisons? What\'s been easy? What\'s been hard?',
                    'Shape Avoidance: Have you taken any small steps to challenge shape avoidance?',
                    '"Feeling Fat": Are you getting better at identifying the real triggers behind the feeling of "feeling fat"?'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_7_4',
                  title: 'Module 4: When to Move On',
                  content: 'Changing your body image is a marathon, not a sprint. It takes many months of practice to change how you see and evaluate yourself as a person. Keep working through this module for as long as it feels helpful.',
                  slideNumber: 4,
                  bulletPoints: [
                    'Persevere: It\'s so important to stick with this work, as it will make you much less vulnerable to bingeing in the long run.',
                    'Keep practicing: Continue to use all the skills you\'ve learned in Steps 1 through 4.',
                    'Look ahead: When you feel you\'ve made good progress here, the final module, "Ending Well," will be waiting for you to help you maintain your progress for the long term.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            
            // Lesson 7.8: When to Move On from the Body Image Module
            Lesson(
              id: 'lesson_s2_7_8',
              title: '7.8: When to Move On from the Body Image Module',
              description: 'Determining when you\'ve made sufficient progress with body image work to move forward',
              chapterNumber: 7,
              lessonNumber: 8,
              slides: [
                LessonSlide(
                  id: 'slide_s2_7_8_1',
                  title: 'Module 1: A Journey, Not a Race',
                  content: 'Changing your body image is one of the deepest parts of this journey, and it\'s important to know that it takes time. You are unlearning old habits and building a new, kinder way of seeing yourself. Be patient and give yourself the grace to move at your own pace.',
                  slideNumber: 1,
                  bulletPoints: [
                    'This takes time: Changing how you see and evaluate yourself as a person can take many months.',
                    'It\'s a marathon, not a sprint: Don\'t expect overnight changes. This is about slow, steady progress.',
                    'Keep practicing: Continue to work through the exercises in this module for as long as they feel helpful.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_8_2',
                  title: 'Module 2: The Power of Perseverance',
                  content: 'Sticking with this work on body image is one of the most important things you can do for your long-term recovery. It might feel challenging at times, but building a more positive and realistic body image is what will make you strong and resilient against binge eating in the future.',
                  slideNumber: 2,
                  bulletPoints: [
                    'It\'s worth it: Your hard work here will pay off in a big way.',
                    'Reduce your vulnerability: A healthier body image makes you much less likely to fall back into old patterns with food.',
                    'Stay the course: Gently encourage yourself to keep going, even when it\'s tough.'
                  ],
                ),
                LessonSlide(
                  id: 'slide_s2_7_8_3',
                  title: 'Module 3: What\'s Next on the Path?',
                  content: 'As you continue your work on body image, remember that it\'s part of a larger program. Keep all your other new skills active. When you feel you\'ve made good, solid progress here, you\'ll be ready for the final step.',
                  slideNumber: 3,
                  bulletPoints: [
                    'Juggling modules: You may be working on this module at the same time as the "Dieting Module." That\'s perfectly fine.',
                    'Maintain your foundation: Don\'t forget to keep practicing regular eating, using alternative activities, and problem-solving.',
                    'Look ahead: The final module, "Ending Well," is designed to help you lock in your progress and maintain it for the long haul.'
                  ],
                ),
              ],
              createdAt: now,
              updatedAt: now,
            ),
            // Additional lessons will be added here
          ],
        ),
      ],
    );
  }
}
