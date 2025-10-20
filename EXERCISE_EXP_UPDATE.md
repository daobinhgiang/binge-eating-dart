# Exercise EXP System - Updated Implementation ✅

## Overview
Users now earn **variable EXP** based on which exercise they complete. Each exercise type has its own EXP reward amount, and meal planning has special handling for updates.

## EXP Rewards by Exercise Type

| Exercise Type | First Completion | Updates | Notes |
|---------------|-----------------|---------|-------|
| **Problem Solving** | 12 EXP | 12 EXP each | Full EXP each time |
| **Meal Planning** | 15 EXP | 3 EXP each | First time: 15 EXP, Updates: 3 EXP |
| **Urge Surfing** | 5 EXP | 5 EXP each | Full EXP each time |
| **Addressing Overconcern** | 12 EXP | 12 EXP each | Full EXP each time |
| **Addressing Setbacks** | 12 EXP | 12 EXP each | Full EXP each time |

## How It Works

### For All Exercises (Except Meal Planning Updates)
When a user completes an exercise:

```
User completes exercise
    ↓
Document created at: users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}
    ↓
Cloud Function: awardExerciseExp triggers
    ↓
Awards EXP based on exercise type:
  - Problem Solving: 12 EXP
  - Urge Surfing: 5 EXP
  - Addressing Overconcern: 12 EXP
  - Addressing Setbacks: 12 EXP
  - Meal Planning (new): 15 EXP
    ↓
User EXP & Level updated
```

### For Meal Planning Updates
When a user updates their meal plan:

```
User updates existing meal plan
    ↓
Document updated at: users/{userId}/exercises/mealPlan/exercises/{planId}
    ↓
Cloud Function: awardMealPlanUpdateExp triggers
    ↓
Awards 3 EXP for the update
    ↓
User EXP & Level updated
```

## Cloud Functions

### 1. awardExerciseExp
**Trigger**: `onCreate` (when exercise is first created)
**Path**: `users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}`
**Valid Exercise Types**:
- `problemSolving` → 12 EXP
- `urgeSurfing` → 5 EXP
- `addressingOverconcern` → 12 EXP
- `addressingSetbacks` → 12 EXP
- `mealPlan` → 15 EXP (first time only)

### 2. awardMealPlanUpdateExp (NEW!)
**Trigger**: `onUpdate` (when meal plan is updated)
**Path**: `users/{userId}/exercises/mealPlan/exercises/{planId}`
**Reward**: 3 EXP per update

## Collection Paths

```
users/
├── {userId}/
    ├── exercises/
    │   ├── problemSolving/
    │   │   └── exercises/
    │   │       └── {exerciseId} → onCreate: +12 EXP
    │   ├── urgeSurfing/
    │   │   └── exercises/
    │   │       └── {exerciseId} → onCreate: +5 EXP
    │   ├── addressingOverconcern/
    │   │   └── exercises/
    │   │       └── {exerciseId} → onCreate: +12 EXP
    │   ├── addressingSetbacks/
    │   │   └── exercises/
    │   │       └── {exerciseId} → onCreate: +12 EXP
    │   └── mealPlan/
    │       └── exercises/
    │           └── {planId} → onCreate: +15 EXP
    │                        → onUpdate: +3 EXP
```

## EXP Ledger Entries

### For Exercise Completion
```javascript
{
  userId: "user123",
  entryType: "problem_solving", // or urge_surfing, etc.
  expAwarded: 12,
  score: 1,
  oldLevel: 1,
  newLevel: 1,
  createdAt: Timestamp
}
```

### For Meal Plan Update
```javascript
{
  userId: "user123",
  entryType: "meal_planning_update",
  expAwarded: 3,
  score: 1,
  oldLevel: 1,
  newLevel: 1,
  createdAt: Timestamp
}
```

## Deployment Status

```
Function:              awardExerciseExp
Status:                🟢 ACTIVE
Type:                  onCreate trigger
EXP Amounts:           Variable (5-15 EXP)

Function:              awardMealPlanUpdateExp
Status:                🟢 ACTIVE (NEW!)
Type:                  onUpdate trigger
EXP Amount:            3 EXP
```

## Testing Instructions

### Test Problem Solving (12 EXP)
1. Go to Tools → Problem Solving
2. Complete the exercise and submit
3. Check logs for: `💰 EXP to award: 12`
4. Verify user EXP increased by 12

### Test Urge Surfing (5 EXP)
1. Go to Tools → Urge Surfing Activities
2. Complete the exercise and submit
3. Check logs for: `💰 EXP to award: 5`
4. Verify user EXP increased by 5

### Test Meal Planning (15 EXP + 3 EXP for updates)
1. **First Time**: Go to Tools → Meal Planning
   - Complete and submit
   - Check logs for: `💰 EXP to award: 15`
   - Verify user EXP increased by 15

2. **Update**: Edit the same meal plan
   - Update and save
   - Check logs for: `🍽️ MEAL PLAN UPDATE EXP AWARD`
   - Check logs for: `💰 EXP to award for update: 3`
   - Verify user EXP increased by 3

### Test Addressing Overconcern (12 EXP)
1. Go to Tools → Addressing Overconcern
2. Complete the exercise and submit
3. Check logs for: `💰 EXP to award: 12`
4. Verify user EXP increased by 12

### Test Addressing Setbacks (12 EXP)
1. Go to Tools → Addressing Setbacks
2. Complete the exercise and submit
3. Check logs for: `💰 EXP to award: 12`
4. Verify user EXP increased by 12

## Log Examples

### Exercise Completion (Variable EXP)
```
═══════════════════════════════════════════════════════════
🏋️ EXERCISE EXP AWARD FUNCTION TRIGGERED
═══════════════════════════════════════════════════════════
📍 Path: users/user123/exercises/problemSolving/exercises/ex456
👤 User ID: user123
🎯 Exercise Type: problemSolving

🔍 VALIDATION STEP
✅ Exercise type is valid, proceeding...

📌 Mapped exercise type: problemSolving → problem_solving
💰 EXP to award: 12

💳 STARTING FIRESTORE TRANSACTION
📖 Step 1: Reading user document...
✅ User found! Level: 1, EXP: 0

🔢 Step 2: Calculating new level...
   Old EXP: 0 + Award: 12 = New EXP: 12

📝 Step 3: Updating user document...
✅ User document queued for update

📋 Step 4: Creating EXP ledger entry...
✅ Ledger entry queued for creation

⏱️ Transaction completed successfully in 234ms
✨ SUCCESS: Exercise ex456 processed!
═══════════════════════════════════════════════════════════
```

### Meal Plan Update (3 EXP)
```
═══════════════════════════════════════════════════════════
🍽️ MEAL PLAN UPDATE EXP AWARD FUNCTION TRIGGERED
═══════════════════════════════════════════════════════════
📍 Path: users/user123/exercises/mealPlan/exercises/plan789
👤 User ID: user123
📝 Plan ID: plan789

💰 EXP to award for update: 3

💳 STARTING FIRESTORE TRANSACTION
📖 Step 1: Reading user document...
✅ User found! Level: 1, EXP: 15

🔢 Step 2: Calculating new level...
   Old EXP: 15 + Award: 3 = New EXP: 18

📝 Step 3: Updating user document...
✅ User document queued for update

📋 Step 4: Creating EXP ledger entry...
✅ Ledger entry queued for creation

⏱️ Transaction completed successfully in 189ms
✨ SUCCESS: Meal plan update plan789 processed!
═══════════════════════════════════════════════════════════
```

## What Changed

### Files Modified
1. **functions/src/awardExerciseExp.ts**
   - Updated to use variable EXP amounts
   - Added `awardMealPlanUpdateExp` function for meal plan updates
   - Fixed exercise type to use `mealPlan` (not `mealPlanning`)

2. **functions/src/index.ts**
   - Exported `awardMealPlanUpdateExp` function

### Previous Behavior
- ❌ All exercises awarded flat 15 EXP
- ❌ Meal plan updates didn't award any EXP

### New Behavior
- ✅ Problem Solving: 12 EXP
- ✅ Urge Surfing: 5 EXP
- ✅ Addressing Overconcern: 12 EXP
- ✅ Addressing Setbacks: 12 EXP
- ✅ Meal Planning (new): 15 EXP
- ✅ Meal Planning (update): 3 EXP

## Monitoring

Watch real-time logs:
```bash
firebase functions:log --follow
```

Filter for exercise EXP:
```bash
firebase functions:log --only awardExerciseExp
```

Filter for meal plan updates:
```bash
firebase functions:log --only awardMealPlanUpdateExp
```

## Summary

✅ **Status**: DEPLOYED AND ACTIVE
✅ **Exercise EXP**: Variable amounts (5-15 EXP)
✅ **Meal Plan Updates**: 3 EXP per update
✅ **Logging**: Full step-by-step tracking
✅ **Ready**: For user testing!

---

**All exercise types now award appropriate EXP amounts! 🎉**
