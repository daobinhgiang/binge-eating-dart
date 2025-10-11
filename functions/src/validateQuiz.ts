import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import {
  validateAnswers,
  calculateScore,
  calculateExp,
  isQuizAlreadyCompleted,
  isSubmissionProcessed,
  determineNewLevel,
  validateSubmissionData,
} from './utils/exp-utils';

/**
 * Cloud Function: Validate Quiz Submission and Award EXP
 * 
 * Triggered when a new quiz_submission document is created.
 * Validates answers, calculates score and EXP, updates user level atomically.
 */
export const validateQuiz = functions.firestore
  .document('quiz_submissions/{submissionId}')
  .onCreate(async (snapshot, context) => {
    const submissionId = context.params.submissionId;
    const submissionData = snapshot.data();

    console.log(`Processing quiz submission: ${submissionId}`);

    try {
      // Validate submission data structure
      const validation = validateSubmissionData(submissionData);
      if (!validation.valid) {
        console.error(`Invalid submission data: ${validation.error}`);
        await snapshot.ref.update({
          status: 'failed',
          validatedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: validation.error,
        });
        return;
      }

      const { userId, quizId, answers } = submissionData;

      // Check if submission was already processed (idempotency)
      const alreadyProcessed = await isSubmissionProcessed(submissionId);
      if (alreadyProcessed) {
        console.log(`Submission ${submissionId} already processed, skipping...`);
        return;
      }

      // Check if user has already completed this quiz
      const alreadyCompleted = await isQuizAlreadyCompleted(userId, quizId);
      if (alreadyCompleted) {
        console.log(`User ${userId} has already completed quiz ${quizId}`);
        await snapshot.ref.update({
          status: 'failed',
          validatedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: 'Quiz already completed',
        });
        return;
      }

      // Validate answers
      const validationResult = validateAnswers(quizId, answers);
      if (!validationResult.isValid) {
        console.error(`Invalid quiz ID or answer key not found: ${quizId}`);
        await snapshot.ref.update({
          status: 'failed',
          validatedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: 'Invalid quiz ID',
        });
        return;
      }

      const { correctCount, totalQuestions } = validationResult;
      const scorePercentage = calculateScore(correctCount, totalQuestions);
      const expAwarded = calculateExp(quizId, correctCount, totalQuestions);

      console.log(`Quiz ${quizId} - Score: ${correctCount}/${totalQuestions} (${scorePercentage}%), EXP: ${expAwarded}`);

      // Use transaction to atomically update user and create ledger entry
      await admin.firestore().runTransaction(async (transaction) => {
        const userRef = admin.firestore().collection('users').doc(userId);
        const userDoc = await transaction.get(userRef);

        if (!userDoc.exists) {
          throw new Error(`User ${userId} not found`);
        }

        const userData = userDoc.data();
        const currentLevel = userData?.level || 1;
        const currentExp = userData?.exp || 0;

        // Calculate new EXP and level
        const newTotalExp = currentExp + expAwarded;
        const levelResult = determineNewLevel(newTotalExp, currentLevel);

        console.log(`User ${userId}: Level ${currentLevel} → ${levelResult.newLevel}, EXP ${currentExp} → ${newTotalExp}`);

        // Update user document
        transaction.update(userRef, {
          exp: newTotalExp,
          level: levelResult.newLevel,
        });

        // Create ledger entry
        const ledgerRef = admin.firestore().collection('exp_ledger').doc();
        transaction.set(ledgerRef, {
          userId,
          quizId,
          expAwarded,
          score: correctCount,
          totalQuestions,
          oldLevel: currentLevel,
          newLevel: levelResult.newLevel,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Update submission status
        transaction.update(snapshot.ref, {
          status: 'validated',
          validatedAt: admin.firestore.FieldValue.serverTimestamp(),
          score: correctCount,
          expAwarded,
        });

        // Log analytics
        console.log(`✓ Quiz validated for user ${userId}: +${expAwarded} EXP, ${levelResult.leveledUp ? `LEVEL UP to ${levelResult.newLevel}!` : `Level ${currentLevel}`}`);
      });

      console.log(`Successfully processed submission ${submissionId}`);
    } catch (error) {
      console.error(`Error processing submission ${submissionId}:`, error);
      
      // Update submission with error status
      try {
        await snapshot.ref.update({
          status: 'failed',
          validatedAt: admin.firestore.FieldValue.serverTimestamp(),
          error: error instanceof Error ? error.message : 'Unknown error',
        });
      } catch (updateError) {
        console.error(`Failed to update submission status:`, updateError);
      }
    }
  });


