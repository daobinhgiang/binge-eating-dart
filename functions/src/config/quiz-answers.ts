/**
 * Quiz Answer Keys
 * 
 * Maps quiz IDs to their correct answers. 
 * For multiple choice questions, the correct answer is the index (0-based) 
 * of the correct option in the options array.
 */

export interface QuizAnswerKey {
  quizId: string;
  correctAnswers: Record<string, number>; // questionId -> correct option index
  totalQuestions: number;
}

export const QUIZ_ANSWERS: Record<string, QuizAnswerKey> = {
  // Stage 1 - Chapter 1 Quiz
  'quiz_1_chapter_1': {
    quizId: 'quiz_1_chapter_1',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_1_q1': 0, // Starting Well, Taking Stock, The Core Work, Ending Well
      'quiz_1_q2': 0, // Real-time monitoring in your Food Diary
      'quiz_1_q3': 0, // To become aware of your patterns and gain control
      'quiz_1_q4': 0, // Once a week at the same time
      'quiz_1_q5': 0, // To reduce binge eating and regain control
      'quiz_1_q6': 0, // 4 hours
      'quiz_1_q7': 0, // Eat anyway, as your hunger signals may be unreliable
      'quiz_1_q8': 0, // The things that are keeping the problem going right now
      'quiz_1_q9': 0, // As soon as possible after eating (in real-time)
      'quiz_1_q10': 0, // True
    },
  },

  // Stage 1 - Chapter 3 Quiz
  'quiz_3_chapter_3': {
    quizId: 'quiz_3_chapter_3',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_3_q1': 0, // Strict dieting and food restriction
      'quiz_3_q2': 0, // Delaying eating, drastic restriction, and avoiding forbidden foods
      'quiz_3_q3': 3, // All of the above
      'quiz_3_q4': 0, // Judging self-worth largely based on body shape and weight
      'quiz_3_q5': 0, // Excessive amount of food AND a sense of loss of control
      'quiz_3_q6': 0, // Foods that the person is trying to avoid (forbidden foods)
      'quiz_3_q7': 0, // Only about 50% of calories are removed
      'quiz_3_q8': 0, // It's often a disguised emotion, not actually about body size
      'quiz_3_q9': 3, // All of the above
      'quiz_3_q10': 0, // Breaking current cycles that maintain the problem
    },
  },

  // Stage 2 - Chapter 0 Quiz
  'quiz_0_chapter_0': {
    quizId: 'quiz_0_chapter_0',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_0_q1': 0, // Having a genuine desire to change for yourself
      'quiz_0_q2': 0, // Improved self-respect, better relationships, and enhanced quality of life
      'quiz_0_q3': 0, // Now, if you're committed to change
      'quiz_0_q4': 0, // If you are underweight, have serious health conditions, or are struggling with depression
      'quiz_0_q5': 0, // Weight usually remains stable as binge calories are replaced with regular meals
      'quiz_0_q6': 0, // Follow the steps in order, work at your own pace, and be patient with the process
      'quiz_0_q7': 0, // 4 to 6 months
      'quiz_0_q8': 0, // Give it a try and see how it works for you
      'quiz_0_q9': 0, // To track your progress and stay on course
      'quiz_0_q10': 0, // True - urges will get weaker and less frequent over time
    },
  },

  // Stage 2 - Chapter 1 Quiz
  'quiz_1_stage_2': {
    quizId: 'quiz_1_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_1_q1': 0, // To give you important information and to help you start changing
      'quiz_s2_1_q2': 0, // WHAT you eat, WHEN you eat, and WHY you eat
      'quiz_s2_1_q3': 0, // Once a week
      'quiz_s2_1_q4': 0, // Daily weigh-ins can be misleading due to normal fluctuations
      'quiz_s2_1_q5': 0, // Give the structured approach a chance and remember it's a private record
      'quiz_s2_1_q6': 0, // Twice a week
      'quiz_s2_1_q7': 0, // Any day where you did your best to monitor accurately and weigh in only once a week
      'quiz_s2_1_q8': 0, // 6-7 Change Days a week
      'quiz_s2_1_q9': 0, // Patterns in timing, triggers, and types of food eaten
      'quiz_s2_1_q10': 0, // True
    },
  },

  // Stage 2 - Chapter 2 Quiz
  'quiz_2_stage_2': {
    quizId: 'quiz_2_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_2_q1': 0, // Establishing a pattern of regular eating
      'quiz_s2_2_q2': 0, // Plan ahead, don't skip, focus on when not what, mind the gaps
      'quiz_s2_2_q3': 0, // Try not to go more than four hours without eating
      'quiz_s2_2_q4': 0, // Start small with just breakfast and lunch, then build gradually
      'quiz_s2_2_q5': 0, // Get back to your planned schedule with the very next meal or snack
      'quiz_s2_2_q6': 0, // For most people, the urge to vomit is tied directly to binge eating
      'quiz_s2_2_q7': 0, // About an hour, then they start to fade
      'quiz_s2_2_q8': 0, // Phase them out gradually by cutting your daily amount in half each week
      'quiz_s2_2_q9': 0, // It's often best to discard leftovers, especially in the beginning
      'quiz_s2_2_q10': 0, // Six or seven change days each week
    },
  },

  // Stage 2 - Chapter 3 Quiz
  'quiz_3_stage_2': {
    quizId: 'quiz_3_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_3_q1': 0, // The most intense part usually lasts for an hour or so
      'quiz_s2_3_q2': 0, // It's active, enjoyable, and realistic
      'quiz_s2_3_q3': 0, // Acknowledge the urge, let time pass, and engage in a distracting activity
      'quiz_s2_3_q4': 0, // The process of riding out an urge until it passes
      'quiz_s2_3_q5': 0, // This is a good sign - it means you can now address them directly
      'quiz_s2_3_q6': 0, // Write it down and keep it accessible
      'quiz_s2_3_q7': 0, // Short-term changes of 1-3 pounds are usually due to hydration shifts, not body fat
      'quiz_s2_3_q8': 0, // At least four weeks of data
      'quiz_s2_3_q9': 0, // Approach the information calmly and thoughtfully without making drastic changes
      'quiz_s2_3_q10': 0, // Do not react by starting a strict diet
    },
  },

  // Stage 2 - Chapter 4 Quiz
  'quiz_4_stage_2': {
    quizId: 'quiz_4_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_4_q1': 0, // To get better at the process of fixing problems, not just fix individual problems
      'quiz_s2_4_q2': 0, // Every day, looking for opportunities to practice whenever problems arise
      'quiz_s2_4_q3': 0, // Define the problem, generate solutions, evaluate options, choose best solution, implement, review
      'quiz_s2_4_q4': 0, // Reviewing your work the next day to see how you problem-solved
      'quiz_s2_4_q5': 0, // Remind yourself that you are actively learning a new skill and it won't feel this intense forever
      'quiz_s2_4_q6': 0, // A day where you monitored, weighed weekly, did regular eating, used alternative activities, AND practiced problem-solving
      'quiz_s2_4_q7': 0, // When binge eating has become infrequent or you've been practicing skills for 6-8 weeks
      'quiz_s2_4_q8': 0, // It's much more effective than just thinking them through in your head
      'quiz_s2_4_q9': 0, // Consciously go through the six steps of problem-solving
      'quiz_s2_4_q10': 0, // Following the steps consistently and practicing regularly
    },
  },

  // Stage 2 - Chapter 5 Quiz
  'quiz_5_stage_2': {
    quizId: 'quiz_5_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_5_q1': 0, // To honestly see where you are so you can choose the best next step
      'quiz_s2_5_q2': 0, // Binges have become less frequent and you've reduced or stopped purging behaviors
      'quiz_s2_5_q3': 0, // Be honest with yourself and reconnect with your motivation
      'quiz_s2_5_q4': 0, // Consider seeking professional help as this may indicate the program isn't enough on its own
      'quiz_s2_5_q5': 0, // The dieting connection and the body image connection
      'quiz_s2_5_q6': 0, // Your binges often happen after you've broken a diet rule or tried to restrict
      'quiz_s2_5_q7': 0, // You find yourself dieting because you're unhappy with your body, which then leads to a binge
      'quiz_s2_5_q8': 0, // Start with the one that feels like the biggest trigger and focus on it for 3-4 weeks
      'quiz_s2_5_q9': 0, // All the skills you learned in Steps 1 through 4
      'quiz_s2_5_q10': 0, // Be proud of yourself for taking the brave step of starting this program
    },
  },

  // Stage 2 - Chapter 6 Quiz
  'quiz_6_stage_2': {
    quizId: 'quiz_6_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_6_q1': 0, // Delaying eating, restricting calories, and avoiding forbidden foods
      'quiz_s2_6_q2': 0, // It creates intense physical and mental pressure to eat
      'quiz_s2_6_q3': 0, // Under 1,500 calories per day
      'quiz_s2_6_q4': 0, // Make a list of all the foods you're afraid to eat
      'quiz_s2_6_q5': 0, // Start with the least scary foods and include small portions in planned meals
      'quiz_s2_6_q6': 0, // A day where you actively tackled strict dieting along with other skills
      'quiz_s2_6_q7': 0, // At least a month or two to feel comfortable and confident
      'quiz_s2_6_q8': 0, // Strict dieting is often what makes you most vulnerable to binge eating
      'quiz_s2_6_q9': 0, // Continue to practice both as they are often connected
      'quiz_s2_6_q10': 0, // When you stop restricting so much, you'll likely binge less and may eat less overall
    },
  },

  // Stage 2 - Chapter 7 Quiz
  'quiz_7_stage_2': {
    quizId: 'quiz_7_stage_2',
    totalQuestions: 10,
    correctAnswers: {
      'quiz_s2_7_q1': 0, // If the slice for shape and weight takes up a third of your pie chart or more
      'quiz_s2_7_q2': 0, // Grow the other slices and shrink the shape and weight slice
      'quiz_s2_7_q3': 0, // The habit of repeatedly checking parts of your body
      'quiz_s2_7_q4': 0, // Stop them completely
      'quiz_s2_7_q5': 0, // Checking your hair, applying makeup, or shaving
      'quiz_s2_7_q6': 0, // Trying not to see or be aware of your body because you dislike how it looks
      'quiz_s2_7_q7': 0, // Gentle, progressive exposure to your body
      'quiz_s2_7_q8': 0, // It's a feeling, not a fact about your body, and often represents other emotions
      'quiz_s2_7_q9': 0, // Ask yourself what might be the real cause and address the underlying issue
      'quiz_s2_7_q10': 0, // Many months of practice
    },
  },
};

/**
 * Get the answer key for a specific quiz
 */
export function getQuizAnswerKey(quizId: string): QuizAnswerKey | null {
  return QUIZ_ANSWERS[quizId] || null;
}

/**
 * Validate if a quiz ID exists in the answer key
 */
export function isValidQuizId(quizId: string): boolean {
  return quizId in QUIZ_ANSWERS;
}


