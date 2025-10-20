r# Journal Entry EXP Reward System

## Overview
Users can now earn experience points (EXP) not only from completing quizzes but also by submitting entries to any of the journal diaries. Each journal entry submission rewards the user with **5 EXP**.

## Supported Journal Types
The following diary entry submissions award EXP:
1. **Food Diary** - Track meals and eating behaviors (+5 EXP per entry)
2. **Weight Diary** - Track weight progress (+5 EXP per entry)
3. **Body Image Diary** - Track body checking behaviors (+5 EXP per entry)
4. **Spending/Money Diary** - Track spending on binge eating (+5 EXP per entry)

## How It Works

### Client-Side (Dart/Flutter)
1. User submits an entry through any of the journal screens
2. The entry is saved to Firestore at the path: `users/{userId}/weeks/week_{weekNumber}/{diaryType}/{entryId}`
3. Common diary types:
   - `foodDiaries` → Stored as `food_diary` in EXP ledger
   - `weightDiaries` → Stored as `weight_diary` in EXP ledger
   - `bodyImageDiaries` → Stored as `body_image_diary` in EXP ledger
   - `moneyDiaries` → Stored as `money_diary` in EXP ledger

### Cloud Function (Server-Side)
1. **Trigger**: `awardJournalEntryExp` Cloud Function triggers on document creation in any diary collection
2. **Pattern**: `users/{userId}/weeks/{weekId}/{diaryType}/{entryId}`
3. **Validation**: Only processes valid diary types (foodDiaries, weightDiaries, bodyImageDiaries, moneyDiaries)
4. **Reward**: Awards 5 EXP to the user
5. **Ledger**: Creates an entry in `exp_ledger` collection with:
   - `userId`: User who submitted the entry
   - `entryType`: Type of diary entry (food_diary, weight_diary, etc.)
   - `expAwarded`: 5 EXP
   - `oldLevel` / `newLevel`: Level before and after the reward
   - `createdAt`: Timestamp of the reward

### Level Progression
The level progression system remains unchanged:
- Level 1: 0 EXP
- Level 2: 50 EXP (50 total)
- Level 3: 150 EXP (100 more)
- Level 4: 350 EXP (200 more)
- Level 5: 750 EXP (400 more) - Maximum level

### EXP Ledger Model Updates
The `ExpLedger` model has been updated to support both quiz submissions and journal entries:

**Quiz Submission Fields:**
- `quizId`: ID of the quiz
- `entryType`: null (omitted for quizzes)
- `score`: Number of correct answers
- `totalQuestions`: Total questions in the quiz

**Journal Entry Fields:**
- `quizId`: null (omitted for journal entries)
- `entryType`: Type of diary (food_diary, weight_diary, etc.)
- `score`: Always 1 (placeholder for consistency)
- `totalQuestions`: null (omitted for journal entries)

## Implementation Details

### Files Changed
1. **lib/models/exp_ledger.dart** - Made quizId and entryType optional, added support for journal entries
2. **functions/src/awardJournalEntryExp.ts** - New Cloud Function for journal entry EXP rewards
3. **functions/src/index.ts** - Exported the new function

### Collection Path Structure
```
users/
├── {userId}/
    ├── weeks/
    │   └── week_{weekNumber}/
    │       ├── foodDiaries/
    │       │   └── {entryId} → Triggers EXP reward
    │       ├── weightDiaries/
    │       │   └── {entryId} → Triggers EXP reward
    │       ├── bodyImageDiaries/
    │       │   └── {entryId} → Triggers EXP reward
    │       └── moneyDiaries/
    │           └── {entryId} → Triggers EXP reward
```

## Usage Examples

### From Food Diary Screen
When user submits a food diary entry, the function automatically awards 5 EXP:
```
User Level: 1 (0 EXP)
→ Submits food diary entry
→ Receives 5 EXP
→ New total: 5 EXP (Still Level 1, needs 50 for Level 2)
```

### Multiple Entries
```
Initial: Level 1 (0 EXP)
→ Food diary entry: +5 EXP (5 total)
→ Weight diary entry: +5 EXP (10 total)
→ Body image diary entry: +5 EXP (15 total)
→ Money diary entry: +5 EXP (20 total)
→ Quiz submission: +50 EXP (70 total) → LEVEL UP to Level 2!
```

## Testing Checklist
- [ ] Food diary entry rewards 5 EXP
- [ ] Weight diary entry rewards 5 EXP
- [ ] Body image diary entry rewards 5 EXP
- [ ] Money diary entry rewards 5 EXP
- [ ] Level progression works correctly with combined sources
- [ ] EXP ledger contains correct entry type for each submission
- [ ] Multiple entries from same user accumulate EXP
- [ ] Level up notifications appear when threshold is reached

## Limitations & Notes
1. **One reward per entry**: Each diary entry only awards EXP once (on creation)
2. **No duplicate rewards**: Editing an entry does not award additional EXP
3. **All diary types equal**: Each diary entry is worth 5 EXP regardless of type
4. **Real-time**: EXP is awarded immediately upon entry submission (via Cloud Function)
5. **Backward compatible**: Existing quiz EXP calculations remain unchanged

## Future Enhancements
- Could add variable EXP rewards based on diary type
- Could add streak bonuses (e.g., +1 EXP for submitting entries daily)
- Could implement achievement milestones based on journal entries
