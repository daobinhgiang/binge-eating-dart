# Exercise EXP Reward System

## Overview
Users now earn **10 EXP** for completing any exercise from the Tools/Exercises section. This complements the existing quiz and journal entry rewards.

## Supported Exercises
The following exercise completions award EXP:
1. **Problem Solving** - Structured approach to challenges (+10 EXP)
2. **Meal Planning** - Plan and organize meals (+10 EXP)
3. **Urge Surfing Activities** - Learn to ride out urges (+10 EXP)
4. **Addressing Overconcern** - Work through weight/shape concerns (+10 EXP)
5. **Addressing Setbacks** - Navigate recovery setbacks (+10 EXP)

## Complete EXP System

### All EXP Sources
```
Quizzes:              50-150 EXP (score-based)
Journal Entries:         5 EXP (flat rate)
Exercises:              10 EXP (flat rate)
```

### Example Progression
```
Initial: Level 1 (0 EXP)

Action                           Result
─────────────────────────────────────────────
Food diary entry                 Level 1 (5 EXP)
Weight diary entry               Level 1 (10 EXP)
Problem solving exercise         Level 1 (20 EXP)
Urge surfing exercise            Level 1 (30 EXP)
Quiz: 50 EXP                     Level 2 (80 EXP)
```

## How It Works

### Client-Side (Dart/Flutter)
1. User completes an exercise through the Tools screen
2. Exercise saved to Firestore at: `users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}`
3. Exercise types:
   - `problemSolving` → Stored as `problem_solving` in EXP ledger
   - `urgeSurfing` → Stored as `urge_surfing` in EXP ledger
   - `addressingSetbacks` → Stored as `addressing_setbacks` in EXP ledger
   - `addressingOverconcern` → Stored as `addressing_overconcern` in EXP ledger
   - `mealPlanning` → Stored as `meal_planning` in EXP ledger

### Cloud Function (Server-Side)
1. **Trigger**: `awardExerciseExp` Cloud Function triggers on document creation
2. **Pattern**: `users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}`
3. **Validation**: Only processes valid exercise types
4. **Reward**: Awards 10 EXP to the user
5. **Ledger**: Creates an entry in `exp_ledger` collection with:
   - `userId`: User who completed the exercise
   - `entryType`: Type of exercise (problem_solving, urge_surfing, etc.)
   - `expAwarded`: 10 EXP
   - `oldLevel` / `newLevel`: Level before and after the reward
   - `createdAt`: Timestamp of the reward

### Collection Path Structure
```
users/
├── {userId}/
    ├── exercises/
    │   ├── problemSolving/
    │   │   └── exercises/
    │   │       └── {exerciseId} → Triggers EXP reward
    │   ├── urgeSurfing/
    │   │   └── exercises/
    │   │       └── {exerciseId} → Triggers EXP reward
    │   ├── addressingSetbacks/
    │   │   └── exercises/
    │   │       └── {exerciseId} → Triggers EXP reward
    │   ├── addressingOverconcern/
    │   │   └── exercises/
    │   │       └── {exerciseId} → Triggers EXP reward
    │   └── mealPlanning/
    │       └── exercises/
    │           └── {exerciseId} → Triggers EXP reward
```

## Implementation Details

### Files Created
1. **functions/src/awardExerciseExp.ts** - Cloud Function for exercise EXP rewards
2. **EXERCISE_EXP_SYSTEM.md** - This documentation

### Files Modified
1. **functions/src/index.ts** - Exported the new function

## Testing

### How to Test
1. Open the app
2. Go to **Tools/Exercises** screen
3. Select any exercise (e.g., "Problem Solving")
4. Complete the exercise and submit
5. Check Firebase logs for confirmation

### Expected Log Output
```
═══════════════════════════════════════════════════════════
🏋️ EXERCISE EXP AWARD FUNCTION TRIGGERED
═══════════════════════════════════════════════════════════
📍 Path: users/{userId}/exercises/problemSolving/exercises/{exerciseId}
👤 User ID: {userId}
🎯 Exercise Type: problemSolving
📝 Exercise ID: {exerciseId}

🔍 VALIDATION STEP
✅ Exercise type is valid, proceeding...

💳 STARTING FIRESTORE TRANSACTION

📖 Step 1: Reading user document...
✅ User found! Level: 1, EXP: 30

🔢 Step 2: Calculating new level...
   Old EXP: 30 + Award: 10 = New EXP: 40

📝 Step 3: Updating user document...
✅ User document queued for update

📋 Step 4: Creating EXP ledger entry...
✅ Ledger entry queued for creation

⏱️ Transaction completed in 234ms
✨ SUCCESS: Exercise {exerciseId} processed!
═══════════════════════════════════════════════════════════
```

## Verification Checklist

After completing an exercise:
- [ ] Firebase logs show "✨ SUCCESS: Exercise processed!"
- [ ] User document `exp` increased by 10
- [ ] `exp_ledger` contains new entry with correct exercise type
- [ ] Level progression works correctly with combined sources
- [ ] All 5 exercise types award EXP

## EXP Ledger Model

### Exercise Entry Fields
- `userId`: User who completed the exercise
- `entryType`: Type of exercise (problem_solving, urge_surfing, etc.)
- `expAwarded`: 10 EXP
- `score`: 1 (placeholder for consistency)
- `oldLevel`: Level before reward
- `newLevel`: Level after reward
- `createdAt`: Timestamp

### Example Entry
```javascript
{
  userId: "abc123",
  entryType: "problem_solving",
  expAwarded: 10,
  score: 1,
  oldLevel: 1,
  newLevel: 2,  // If threshold reached
  createdAt: Timestamp
}
```

## Monitoring

### Watch Logs in Real-Time
```bash
firebase functions:log --follow
```

### Filter for Exercise Function
```bash
firebase functions:log --only awardExerciseExp
```

### In Firebase Console
1. Go to Functions section
2. Select `awardExerciseExp`
3. View Logs tab

## Features

- **Automatic**: No UI changes needed
- **Real-time**: Instant EXP reward
- **Tracked**: All exercises logged in exp_ledger
- **Logged**: Comprehensive debugging logs
- **Atomic**: Transaction ensures data consistency
- **Backward Compatible**: Existing rewards still work
- **Fair**: Higher reward (10 EXP) for more substantial exercises

## Deployment

The function is already deployed! You can verify with:
```bash
firebase functions:list | grep awardExerciseExp
```

Should show:
```
awardExerciseExp    v1    document.create    us-central1    256    nodejs18
```

## Summary

### EXP Reward Hierarchy
```
Exercises (10 EXP)    >    Journal Entries (5 EXP)    >    Quizzes (50-150 EXP)
└─ More involved       └─ Quick logging               └─ Most comprehensive
```

### Why 10 EXP?
- Exercises require more effort than journal entries (5 EXP)
- Exercises are less comprehensive than quizzes (50-150 EXP)
- 10 EXP is a fair middle ground for structured activities

### Complete EXP Ecosystem
```
Quizzes          → Education & Knowledge Assessment
Journal Entries  → Daily Tracking & Awareness
Exercises        → Active Skill Building & Practice
```

All three work together to encourage comprehensive recovery engagement!
