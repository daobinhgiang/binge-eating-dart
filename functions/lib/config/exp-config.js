"use strict";
/**
 * EXP Configuration
 *
 * Defines base EXP rewards for quizzes and level thresholds.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MAX_LEVEL = exports.LEVEL_THRESHOLDS = exports.QUIZ_BASE_EXP = void 0;
exports.getBaseExpForQuiz = getBaseExpForQuiz;
exports.calculateExpAwarded = calculateExpAwarded;
exports.getTotalExpForLevel = getTotalExpForLevel;
exports.calculateLevel = calculateLevel;
exports.getExpRequiredForLevel = getExpRequiredForLevel;
exports.getTotalAvailableExp = getTotalAvailableExp;
exports.checkLevelUp = checkLevelUp;
/**
 * Base EXP per quiz (before score multiplier)
 */
exports.QUIZ_BASE_EXP = {
    // Stage 1 quizzes - 150 base EXP (easier content)
    'quiz_1_chapter_1': { baseExp: 150, difficulty: 'easy' },
    'quiz_3_chapter_3': { baseExp: 50, difficulty: 'easy' },
    // Stage 2 Chapter 0 - 75 base EXP (foundational)
    'quiz_0_chapter_0': { baseExp: 75, difficulty: 'easy' },
    // Stage 2 Chapters 1-4 - 100 base EXP (intermediate)
    'quiz_1_stage_2': { baseExp: 100, difficulty: 'medium' },
    'quiz_2_stage_2': { baseExp: 100, difficulty: 'medium' },
    'quiz_3_stage_2': { baseExp: 100, difficulty: 'medium' },
    'quiz_4_stage_2': { baseExp: 100, difficulty: 'medium' },
    // Stage 2 Chapters 5-7 - 150 base EXP (advanced)
    'quiz_5_stage_2': { baseExp: 150, difficulty: 'hard' },
    'quiz_6_stage_2': { baseExp: 150, difficulty: 'hard' },
    'quiz_7_stage_2': { baseExp: 150, difficulty: 'hard' },
};
/**
 * Level thresholds (exponential progression)
 */
exports.LEVEL_THRESHOLDS = {
    1: 0, // Level 1 starts at 0 EXP
    2: 50, // Level 2 requires 50 EXP
    3: 100, // Level 3 requires 100 more (150 total)
    4: 200, // Level 4 requires 200 more (350 total)
    5: 400, // Level 5 requires 400 more (750 total) - max level
};
/**
 * Maximum level in the system
 */
exports.MAX_LEVEL = 5;
/**
 * Get the base EXP for a quiz
 */
function getBaseExpForQuiz(quizId) {
    var _a;
    return ((_a = exports.QUIZ_BASE_EXP[quizId]) === null || _a === void 0 ? void 0 : _a.baseExp) || 0;
}
/**
 * Calculate EXP awarded based on quiz score
 * Formula: baseEXP * (correctAnswers / totalQuestions)
 */
function calculateExpAwarded(quizId, correctAnswers, totalQuestions) {
    const baseExp = getBaseExpForQuiz(quizId);
    if (baseExp === 0 || totalQuestions === 0) {
        return 0;
    }
    const scorePercentage = correctAnswers / totalQuestions;
    const expAwarded = Math.floor(baseExp * scorePercentage);
    return expAwarded;
}
/**
 * Get total EXP required for a specific level
 */
function getTotalExpForLevel(level) {
    if (level <= 1)
        return 0;
    if (level > exports.MAX_LEVEL)
        return getTotalExpForLevel(exports.MAX_LEVEL);
    let totalExp = 0;
    for (let i = 2; i <= level; i++) {
        totalExp += exports.LEVEL_THRESHOLDS[i];
    }
    return totalExp;
}
/**
 * Calculate what level a user should be at given their total EXP
 */
function calculateLevel(totalExp) {
    if (totalExp < exports.LEVEL_THRESHOLDS[2])
        return 1;
    if (totalExp < getTotalExpForLevel(3))
        return 2;
    if (totalExp < getTotalExpForLevel(4))
        return 3;
    if (totalExp < getTotalExpForLevel(5))
        return 4;
    return 5; // Max level
}
/**
 * Get EXP required for next level
 */
function getExpRequiredForLevel(currentLevel) {
    if (currentLevel >= exports.MAX_LEVEL) {
        return 0; // Already at max level
    }
    return exports.LEVEL_THRESHOLDS[currentLevel + 1] || 0;
}
/**
 * Get total EXP available from all quizzes (perfect score)
 */
function getTotalAvailableExp() {
    return Object.values(exports.QUIZ_BASE_EXP).reduce((sum, config) => sum + config.baseExp, 0);
}
/**
 * Check if EXP is sufficient to level up
 */
function checkLevelUp(currentExp, currentLevel) {
    const calculatedLevel = calculateLevel(currentExp);
    return {
        leveledUp: calculatedLevel > currentLevel,
        newLevel: calculatedLevel,
    };
}
//# sourceMappingURL=exp-config.js.map