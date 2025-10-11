import * as admin from 'firebase-admin';
import { getQuizAnswerKey } from '../config/quiz-answers';
import { calculateExpAwarded, checkLevelUp } from '../config/exp-config';

/**
 * Validate user's answers against the correct answer key
 */
export function validateAnswers(
  quizId: string,
  userAnswers: Record<string, number>
): { correctCount: number; totalQuestions: number; isValid: boolean } {
  const answerKey = getQuizAnswerKey(quizId);
  
  if (!answerKey) {
    console.error(`No answer key found for quiz: ${quizId}`);
    return { correctCount: 0, totalQuestions: 0, isValid: false };
  }

  let correctCount = 0;
  const totalQuestions = answerKey.totalQuestions;

  // Check each answer
  for (const [questionId, userAnswer] of Object.entries(userAnswers)) {
    const correctAnswer = answerKey.correctAnswers[questionId];
    if (correctAnswer !== undefined && userAnswer === correctAnswer) {
      correctCount++;
    }
  }

  return {
    correctCount,
    totalQuestions,
    isValid: true,
  };
}

/**
 * Calculate score percentage
 */
export function calculateScore(correctCount: number, totalQuestions: number): number {
  if (totalQuestions === 0) return 0;
  return Math.round((correctCount / totalQuestions) * 100);
}

/**
 * Calculate EXP to be awarded based on quiz and score
 */
export function calculateExp(quizId: string, correctCount: number, totalQuestions: number): number {
  return calculateExpAwarded(quizId, correctCount, totalQuestions);
}

/**
 * Check if user has already completed this quiz
 */
export async function isQuizAlreadyCompleted(userId: string, quizId: string): Promise<boolean> {
  try {
    const ledgerQuery = await admin.firestore()
      .collection('exp_ledger')
      .where('userId', '==', userId)
      .where('quizId', '==', quizId)
      .limit(1)
      .get();

    return !ledgerQuery.empty;
  } catch (error) {
    console.error(`Error checking quiz completion for user ${userId}, quiz ${quizId}:`, error);
    return false;
  }
}

/**
 * Check if submission has already been processed (idempotency check)
 */
export async function isSubmissionProcessed(submissionId: string): Promise<boolean> {
  try {
    const submissionDoc = await admin.firestore()
      .collection('quiz_submissions')
      .doc(submissionId)
      .get();

    if (!submissionDoc.exists) {
      return false;
    }

    const data = submissionDoc.data();
    return data?.status === 'validated' || data?.status === 'failed';
  } catch (error) {
    console.error(`Error checking submission ${submissionId}:`, error);
    return false;
  }
}

/**
 * Determine new level based on total EXP
 */
export function determineNewLevel(currentExp: number, currentLevel: number): { newLevel: number; leveledUp: boolean } {
  const result = checkLevelUp(currentExp, currentLevel);
  return {
    newLevel: result.newLevel,
    leveledUp: result.leveledUp,
  };
}

/**
 * Validate submission data
 */
export function validateSubmissionData(data: any): { valid: boolean; error?: string } {
  if (!data.userId || typeof data.userId !== 'string') {
    return { valid: false, error: 'Missing or invalid userId' };
  }

  if (!data.quizId || typeof data.quizId !== 'string') {
    return { valid: false, error: 'Missing or invalid quizId' };
  }

  if (!data.answers || typeof data.answers !== 'object') {
    return { valid: false, error: 'Missing or invalid answers' };
  }

  if (!data.submittedAt) {
    return { valid: false, error: 'Missing submittedAt timestamp' };
  }

  return { valid: true };
}


