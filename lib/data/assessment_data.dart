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
      default:
        return null;
    }
  }
}
