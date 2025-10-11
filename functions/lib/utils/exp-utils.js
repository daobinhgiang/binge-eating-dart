"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateAnswers = validateAnswers;
exports.calculateScore = calculateScore;
exports.calculateExp = calculateExp;
exports.isQuizAlreadyCompleted = isQuizAlreadyCompleted;
exports.isSubmissionProcessed = isSubmissionProcessed;
exports.determineNewLevel = determineNewLevel;
exports.validateSubmissionData = validateSubmissionData;
const admin = require("firebase-admin");
const quiz_answers_1 = require("../config/quiz-answers");
const exp_config_1 = require("../config/exp-config");
/**
 * Validate user's answers against the correct answer key
 */
function validateAnswers(quizId, userAnswers) {
    const answerKey = (0, quiz_answers_1.getQuizAnswerKey)(quizId);
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
function calculateScore(correctCount, totalQuestions) {
    if (totalQuestions === 0)
        return 0;
    return Math.round((correctCount / totalQuestions) * 100);
}
/**
 * Calculate EXP to be awarded based on quiz and score
 */
function calculateExp(quizId, correctCount, totalQuestions) {
    return (0, exp_config_1.calculateExpAwarded)(quizId, correctCount, totalQuestions);
}
/**
 * Check if user has already completed this quiz
 */
async function isQuizAlreadyCompleted(userId, quizId) {
    try {
        const ledgerQuery = await admin.firestore()
            .collection('exp_ledger')
            .where('userId', '==', userId)
            .where('quizId', '==', quizId)
            .limit(1)
            .get();
        return !ledgerQuery.empty;
    }
    catch (error) {
        console.error(`Error checking quiz completion for user ${userId}, quiz ${quizId}:`, error);
        return false;
    }
}
/**
 * Check if submission has already been processed (idempotency check)
 */
async function isSubmissionProcessed(submissionId) {
    try {
        const submissionDoc = await admin.firestore()
            .collection('quiz_submissions')
            .doc(submissionId)
            .get();
        if (!submissionDoc.exists) {
            return false;
        }
        const data = submissionDoc.data();
        return (data === null || data === void 0 ? void 0 : data.status) === 'validated' || (data === null || data === void 0 ? void 0 : data.status) === 'failed';
    }
    catch (error) {
        console.error(`Error checking submission ${submissionId}:`, error);
        return false;
    }
}
/**
 * Determine new level based on total EXP
 */
function determineNewLevel(currentExp, currentLevel) {
    const result = (0, exp_config_1.checkLevelUp)(currentExp, currentLevel);
    return {
        newLevel: result.newLevel,
        leveledUp: result.leveledUp,
    };
}
/**
 * Validate submission data
 */
function validateSubmissionData(data) {
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
//# sourceMappingURL=exp-utils.js.map