# Journal Entry EXP System - Implementation Summary

## Overview
Implemented a system to award users 5 EXP for each journal entry submission, complementing the existing quiz-based EXP rewards. Users can now gain experience through multiple pathways:
- **Quizzes**: 50-150 EXP (score-based)
- **Journal Entries**: 5 EXP (flat rate per entry)

## Changes Made

### 1. Updated Models
**File**: `lib/models/exp_ledger.dart`

**Changes**:
- Made `quizId` optional (was required)
- Added `entryType` field (optional) for journal entry type tracking
- Made `totalQuestions` optional (was required)
- Updated `fromFirestore()` to handle optional fields
- Updated `toFirestore()` to conditionally include fields
- Updated `scorePercentage` getter to handle null `totalQuestions`
- Updated `toString()` method to display appropriate info based on entry type

**Rationale**: The model now flexibly supports both quiz submissions and journal entries without requiring null coalescing throughout the codebase.

### 2. Created Cloud Function
**File**: `functions/src/awardJournalEntryExp.ts`

**Features**:
- Triggers on document creation in any diary collection
- Matches pattern: `users/{userId}/weeks/{weekId}/{diaryType}/{entryId}`
- Validates diary type (foodDiaries, weightDiaries, bodyImageDiaries, moneyDiaries)
- Awards 5 EXP consistently
- Uses Firestore transactions for atomic updates
- Updates user level progression
- Creates ledger entry for tracking
- Includes comprehensive logging

**Diary Type Mapping**:
- `foodDiaries` → `food_diary`
- `weightDiaries` → `weight_diary`
- `bodyImageDiaries` → `body_image_diary`
- `moneyDiaries` → `money_diary`

### 3. Updated Cloud Functions Export
**File**: `functions/src/index.ts`

**Changes**:
- Added export for `awardJournalEntryExp` function
- Function is now available for deployment

### 4. Documentation
**Files Created**:
- `JOURNAL_EXP_SYSTEM.md` - Comprehensive guide on how the system works
- `IMPLEMENTATION_SUMMARY.md` - This file

## How It Works

### Collection Path Structure
```
users/{userId}/weeks/week_{N}/
├── foodDiaries/{entryId}        → +5 EXP
├── weightDiaries/{entryId}      → +5 EXP  
├── bodyImageDiaries/{entryId}   → +5 EXP
└── moneyDiaries/{entryId}       → +5 EXP
```

### Reward Flow
1. **User submits entry** → Entry saved to Firestore
2. **Cloud Function triggers** → Validates diary type
3. **Transaction begins** → Atomically:
   - Reads current user EXP/Level
   - Adds 5 EXP
   - Calculates new level
   - Updates user document
   - Creates ledger entry
4. **Immediate reward** → User sees updated EXP/Level

### Example Progression
```
Initial State: Level 1 (0 EXP)

Action                           Result
─────────────────────────────────────────────
Food diary entry                 Level 1 (5 EXP)
Weight diary entry               Level 1 (10 EXP)
Quiz: 50 EXP                     Level 2 (60 EXP)
Body image diary entry           Level 2 (65 EXP)
Money diary entry                Level 2 (70 EXP)
```

## Implementation Quality

### Backward Compatibility
✅ Existing quiz-based EXP system unchanged
✅ All quiz submissions continue to work as before
✅ New fields are optional in ExpLedger model

### Consistency
✅ Uses same transaction pattern as quiz validation
✅ Uses same level progression logic
✅ Creates ledger entries in same format
✅ Follows existing code patterns

### Error Handling
✅ Transaction ensures atomicity
✅ Validates diary types before processing
✅ Gracefully skips invalid collections
✅ Comprehensive error logging

### Performance
✅ Efficient Cloud Function (no loops)
✅ Single transaction per entry
✅ Minimal reads/writes per operation
✅ Scales linearly with entries

## Affected User Screens
The following screens now contribute to EXP progression:
1. **Food Diary** (`lib/screens/journal/food_diary_survey_screen.dart`)
2. **Weight Diary** (`lib/screens/journal/weight_diary_survey_screen.dart`)
3. **Body Image Diary** (`lib/screens/journal/body_image_diary_survey_screen.dart`)
4. **Money/Spending Diary** (money_diary_survey_screen.dart)

*Note*: No UI changes needed - EXP rewards happen automatically via Cloud Function

## Testing Recommendations

### Functional Tests
- [ ] Submit food diary entry → Verify +5 EXP awarded
- [ ] Submit weight diary entry → Verify +5 EXP awarded
- [ ] Submit body image diary entry → Verify +5 EXP awarded
- [ ] Submit money diary entry → Verify +5 EXP awarded

### Integration Tests
- [ ] Combine journal entries with quiz completion
- [ ] Verify level progression works with both sources
- [ ] Verify EXP ledger shows correct entry types

### Edge Cases
- [ ] Rapidly submit multiple entries → All should award EXP
- [ ] Submit after hitting level threshold → Should trigger level up
- [ ] Max level (5) reached → No more EXP awarded

## Deployment Steps
1. Deploy Cloud Function: `firebase deploy --only functions:awardJournalEntryExp`
2. Or deploy all functions: `firebase deploy --only functions`
3. Verify function appears in Firebase Console
4. Monitor logs for any errors during early usage

## Rollback Plan
If needed to disable:
1. Delete `awardJournalEntryExp` from `functions/src/index.ts`
2. Redeploy Cloud Functions
3. Manual EXP adjustments may be needed via admin panel if desired

## Future Enhancement Opportunities
1. **Variable Rewards**: Different EXP per diary type
2. **Bonus Multipliers**: Streak bonuses for consecutive entries
3. **Quest System**: Combined challenges across diary types
4. **Achievements**: Unlock badges for journal consistency
5. **Social Sharing**: EXP for sharing progress
