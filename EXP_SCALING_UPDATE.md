# EXP Scaling System Update

## Summary
Updated the exp scaling system to make leveling 10x faster while keeping quiz exp rewards unchanged.

## Changes Made

### Level Thresholds (Cumulative EXP Required)

**Before:**
- Level 1: 0 EXP
- Level 2: 500 EXP (need 500 to advance)
- Level 3: 1,500 EXP (need 1,000 more)
- Level 4: 3,500 EXP (need 2,000 more)
- Level 5: 7,500 EXP (need 4,000 more)

**After:**
- Level 1: 0 EXP
- Level 2: 50 EXP (need 50 to advance) ✨
- Level 3: 150 EXP (need 100 more)
- Level 4: 350 EXP (need 200 more)
- Level 5: 750 EXP (need 400 more)

### Quiz EXP Rewards (Unchanged)
- Stage 1 quizzes: 50 base EXP
- Stage 2 Chapter 0: 75 base EXP
- Stage 2 Chapters 1-4: 100 base EXP
- Stage 2 Chapters 5-7: 150 base EXP

*Note: Actual EXP awarded is base EXP × (correct answers / total questions)*

## Example Progression

### Before Update
- Complete 1 Stage 1 quiz (50 EXP): Still Level 1 (need 450 more)
- Complete 10 Stage 1 quizzes (500 EXP): Reach Level 2 🎉
- Complete 20 more quizzes: Still Level 2...

### After Update
- Complete 1 Stage 1 quiz (50 EXP): **Reach Level 2** 🎉
- Complete 2 more Stage 1 quizzes (150 EXP total): **Reach Level 3** 🎉
- Complete 4 Stage 2 quizzes (100 EXP each, 550 EXP total): **Reach Level 4** 🎉
- Complete 2 Stage 2 advanced quizzes (150 EXP each, 850 EXP total): **Reach Level 5** 🎉

## Files Updated

1. **functions/src/config/exp-config.ts** - Server-side TypeScript source (authoritative)
2. **functions/lib/config/exp-config.js** - Compiled JavaScript (executed by Firebase Functions)
3. **lib/core/services/exp_service.dart** - Client-side Dart reference

## Impact

- **User Experience**: Users will level up much faster, providing more frequent positive reinforcement
- **Progression**: Maintains exponential scaling (50 → 100 → 200 → 400) but at a more achievable pace
- **Quiz Rewards**: No changes to exp awarded per quiz
- **UI**: All existing UI components automatically work with new thresholds
- **Database**: Existing user exp values remain valid; users at intermediate exp levels will see instant level-ups when logging in

## Deployment Notes

When deploying to Firebase:
```bash
cd functions
firebase deploy --only functions
```

This will deploy the updated `validateQuiz` function with the new level thresholds.

