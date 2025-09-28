import '../models/stage.dart';
import '../models/chapter.dart';
import '../models/lesson.dart';
import '../models/lesson_slide.dart';

class Stage2Data {
  static Stage getStage2() {
    final now = DateTime.now();
    
    return Stage(
      stageNumber: 2,
      title: 'Maintaining Mechanisms',
      chapters: [
        // Chapter 0: Starting Well
        Chapter(
          chapterNumber: 0,
          title: 'Starting Well',
          lessons: List.generate(6, (index) {
            final titles = [
              '0.1 Why Change',
              '0.2 How To Change: Various Options', 
              '0.3 When to Start',
              '0.4 When Self-Help May Not Be Appropriate',
              '0.5 What Will Happen To My Weight?',
              '0.6 How To Use The Program'
            ];
            
            final descriptions = [
              'Understanding the reasons and motivation for making positive changes in your eating patterns',
              'Exploring different approaches and treatment options available for eating disorder recovery',
              'Understanding the right timing and conditions for beginning your recovery journey',
              'Recognizing situations where professional treatment is necessary instead of or alongside self-help',
              'Understanding weight changes during recovery and developing a healthy relationship with your body',
              'Guidelines for effectively using this recovery program to achieve the best outcomes'
            ];
            
            return Lesson(
              id: 'lesson_s2_0_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 0,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_0_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 1: Step 1 - Starting Well
        Chapter(
          chapterNumber: 1,
          title: 'Step 1 - Starting Well',
          lessons: List.generate(3, (index) {
            final titles = [
              '1.1 Start Self-Monitoring',
              '1.2 Establishing Weekly Weighing',
              '1.3 Step 1 Review Sessions'
            ];
            
            final descriptions = [
              'Learning to track your eating patterns, thoughts, and feelings to gain insight into your behaviors',
              'Learning to weigh yourself appropriately as part of recovery without becoming obsessed',
              'Reviewing your progress with self-monitoring and weekly weighing before moving to the next step'
            ];
            
            return Lesson(
              id: 'lesson_s2_1_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 1,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_1_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 2: Step 2 - Regular Eating
        Chapter(
          chapterNumber: 2,
          title: 'Step 2 - Regular Eating',
          lessons: List.generate(7, (index) {
            final titles = [
              '2.1 Establishing a Pattern of Regular Eating',
              '2.2 What to Do About Self-Induced Vomiting',
              '2.3 What to Do About Laxative and Diuretic Misuse',
              '2.4 Some Advice on Eating In and Eating Out',
              '2.5 Some Advice on Shopping and Cooking',
              '2.6 Step 2 Review Sessions',
              '2.7 Practice Meal Planning Exercise'
            ];
            
            final descriptions = [
              'Learning to eat at regular intervals to prevent extreme hunger and reduce binge episodes',
              'Strategies for stopping purging behaviors and managing the urges to vomit after eating',
              'Understanding and stopping the misuse of laxatives and diuretics for weight control',
              'Strategies for maintaining regular eating patterns both at home and in social situations',
              'Practical strategies for grocery shopping and meal preparation to support regular eating',
              'Reviewing your progress with establishing regular eating patterns and addressing challenges',
              'Complete an interactive meal planning exercise to practice structuring your daily eating'
            ];
            
            return Lesson(
              id: 'lesson_s2_2_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 2,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_2_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 3: Step 3 - Alternatives to Binge Eating
        Chapter(
          chapterNumber: 3,
          title: 'Step 3 - Alternatives to Binge Eating',
          lessons: List.generate(5, (index) {
            final titles = [
              '3.1 Preparing to Use Alternative Activities',
              '3.2 Substituting Alternative Activities',
              '3.3 Step 3 Review Sessions',
              '3.4 What is Happening to My Weight?',
              '3.5 Practice Urge Surfing Exercise'
            ];
            
            final descriptions = [
              'Learning to identify triggers and prepare alternative activities to prevent binge episodes',
              'Learning to effectively use alternative activities when experiencing urges to binge eat',
              'Reviewing your progress with using alternative activities and preparing for the next step',
              'Understanding and managing weight concerns during the recovery process',
              'Complete an interactive urge surfing exercise to practice managing urges without acting on them'
            ];
            
            return Lesson(
              id: 'lesson_s2_3_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 3,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_3_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 4: Step 4 - Problem Solving
        Chapter(
          chapterNumber: 4,
          title: 'Step 4 - Problem Solving',
          lessons: List.generate(3, (index) {
            final titles = [
              '4.1 Developing Your Problem-Solving Skills',
              '4.2 Step 4 Review Sessions',
              '4.3 Practice Problem-Solving Exercise'
            ];
            
            final descriptions = [
              'Learning systematic problem-solving techniques to address life challenges that contribute to binge eating',
              'Reviewing your progress with problem-solving skills and preparing for the next phase',
              'Complete an interactive problem-solving exercise to practice the techniques you\'ve learned'
            ];
            
            return Lesson(
              id: 'lesson_s2_4_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 4,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_4_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 5: Step 5 - Taking Stock
        Chapter(
          chapterNumber: 5,
          title: 'Step 5 - Taking Stock',
          lessons: List.generate(2, (index) {
            final titles = [
              '5.1 Should I Continue with the Program?',
              '5.2 What Next?'
            ];
            
            final descriptions = [
              'Evaluating your progress and deciding whether to continue with additional program modules',
              'Planning your next steps whether you continue with the program or focus on maintenance'
            ];
            
            return Lesson(
              id: 'lesson_s2_5_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 5,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_5_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 6: Dieting Module
        Chapter(
          chapterNumber: 6,
          title: 'Dieting Module',
          lessons: List.generate(3, (index) {
            final titles = [
              '6.1 Addressing Strict Dieting',
              '6.2 Dieting Module Review Sessions',
              '6.3 When to Move On'
            ];
            
            final descriptions = [
              'Learning to identify and eliminate strict dietary rules that contribute to binge eating',
              'Reviewing your progress in addressing strict dieting patterns and food rules',
              'Determining when you\'re ready to move on from the dieting module to other areas of focus'
            ];
            
            return Lesson(
              id: 'lesson_s2_6_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 6,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_6_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
        
        // Chapter 7: Body Image Module
        Chapter(
          chapterNumber: 7,
          title: 'Body Image Module',
          lessons: List.generate(9, (index) {
            final titles = [
              '7.1 Identifying Overconcern About Shape and Weight',
              '7.2 Addressing Overconcern About Shape and Weight',
              '7.2.1 Practice Addressing Overconcern Exercise',
              '7.3 Addressing Shape Checking',
              '7.4 Addressing Comparison Making',
              '7.5 Addressing Shape Avoidance',
              '7.6 Addressing Feeling Fat',
              '7.7 Body Image Review Sessions',
              '7.8 When to Move On'
            ];
            
            final descriptions = [
              'Recognizing when concerns about body shape and weight become excessive and problematic',
              'Learning strategies to reduce excessive focus on body shape and weight',
              'Complete an interactive exercise to practice techniques for addressing overconcern about body image',
              'Learning to reduce compulsive body checking behaviors that increase body dissatisfaction',
              'Learning to stop comparing your appearance to others and develop self-acceptance',
              'Learning to stop avoiding situations due to body shape concerns and reclaim your life',
              'Understanding and managing the experience of "feeling fat" and its emotional meanings',
              'Reviewing your progress in addressing body image concerns and planning continued work',
              'Determining when you\'ve made sufficient progress with body image work to move forward'
            ];
            
            return Lesson(
              id: 'lesson_s2_7_${index + 1}',
              title: titles[index],
              description: descriptions[index],
              chapterNumber: 7,
              lessonNumber: index + 1,
              slides: List.generate(4, (slideIndex) => LessonSlide(
                id: 'slide_s2_7_${index + 1}_${slideIndex + 1}',
                title: 'Slide ${slideIndex + 1}',
                content: 'Content for ${titles[index]} - Slide ${slideIndex + 1}',
                slideNumber: slideIndex + 1,
                bulletPoints: [
                  'Key point 1 for this lesson topic',
                  'Key point 2 for this lesson topic',
                  'Key point 3 for this lesson topic',
                  'Key point 4 for this lesson topic'
                ],
              )),
              createdAt: now,
              updatedAt: now,
            );
          }),
        ),
      ],
    );
  }
}
