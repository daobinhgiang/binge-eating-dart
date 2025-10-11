/**
 * EXP Configuration
 * 
 * Defines base EXP rewards for quizzes and level thresholds.
 */

export interface ExpConfig {
  baseExp: number;
  difficulty: 'easy' | 'medium' | 'hard';
}

/**
 * Base EXP per quiz (before score multiplier)
 */
export const QUIZ_BASE_EXP: Record<string, ExpConfig> = {
  // Stage 1 quizzes - 50 base EXP (easier content)
  'quiz_1_chapter_1': { baseExp: 50, difficulty: 'easy' },
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
export const LEVEL_THRESHOLDS: Record<number, number> = {
  1: 0,       // Level 1 starts at 0 EXP
  2: 500,     // Level 2 requires 500 EXP
  3: 1000,    // Level 3 requires 1000 more (1500 total)
  4: 2000,    // Level 4 requires 2000 more (3500 total)
  5: 4000,    // Level 5 requires 4000 more (7500 total) - max level
};

/**
 * Maximum level in the system
 */
export const MAX_LEVEL = 5;

/**
 * Get the base EXP for a quiz
 */
export function getBaseExpForQuiz(quizId: string): number {
  return QUIZ_BASE_EXP[quizId]?.baseExp || 0;
}

/**
 * Calculate EXP awarded based on quiz score
 * Formula: baseEXP * (correctAnswers / totalQuestions)
 */
export function calculateExpAwarded(quizId: string, correctAnswers: number, totalQuestions: number): number {
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
export function getTotalExpForLevel(level: number): number {
  if (level <= 1) return 0;
  if (level > MAX_LEVEL) return getTotalExpForLevel(MAX_LEVEL);

  let totalExp = 0;
  for (let i = 2; i <= level; i++) {
    totalExp += LEVEL_THRESHOLDS[i];
  }
  
  return totalExp;
}

/**
 * Calculate what level a user should be at given their total EXP
 */
export function calculateLevel(totalExp: number): number {
  if (totalExp < LEVEL_THRESHOLDS[2]) return 1;
  if (totalExp < getTotalExpForLevel(3)) return 2;
  if (totalExp < getTotalExpForLevel(4)) return 3;
  if (totalExp < getTotalExpForLevel(5)) return 4;
  return 5; // Max level
}

/**
 * Get EXP required for next level
 */
export function getExpRequiredForLevel(currentLevel: number): number {
  if (currentLevel >= MAX_LEVEL) {
    return 0; // Already at max level
  }
  
  return LEVEL_THRESHOLDS[currentLevel + 1] || 0;
}

/**
 * Get total EXP available from all quizzes (perfect score)
 */
export function getTotalAvailableExp(): number {
  return Object.values(QUIZ_BASE_EXP).reduce((sum, config) => sum + config.baseExp, 0);
}

/**
 * Check if EXP is sufficient to level up
 */
export function checkLevelUp(currentExp: number, currentLevel: number): { leveledUp: boolean; newLevel: number } {
  const calculatedLevel = calculateLevel(currentExp);
  return {
    leveledUp: calculatedLevel > currentLevel,
    newLevel: calculatedLevel,
  };
}


