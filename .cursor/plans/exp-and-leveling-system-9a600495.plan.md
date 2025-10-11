<!-- 9a600495-ea12-4b86-8116-14a710198a77 0829b1ca-0a03-45b6-942c-cb3d76eb3bb9 -->
# EXP and Leveling System Implementation (Cloud Functions)

## Overview

Implement a secure EXP system where Cloud Functions validate quiz answers and award EXP based on accuracy. Users advance through 5 levels with exponential progression. Level/EXP displayed in app bar and profile, with celebration dialog on level-up.

## Architecture Flow

```
User completes quiz → Client submits to Firestore (pending) → Cloud Function triggered
→ Validates answers → Calculates score/EXP → Updates user atomically
→ Creates audit ledger → Client listens to changes → Shows level-up UI
```

## 1. Data Model Updates

### Update UserModel (`lib/models/user_model.dart`)

- Add `level` (int, default 1)
- Add `exp` (int, default 0)
- Update `toFirestore()`, `fromFirestore()`, and `copyWith()` methods

### Create QuizSubmission Model (`lib/models/quiz_submission.dart`)

- Fields: `userId`, `quizId`, `answers` (Map<questionId, selectedIndex>), `submittedAt`, `status` (pending/validated/failed)
- Store in Firestore for Cloud Function processing

### Create ExpLedger Model (`lib/models/exp_ledger.dart`)

- Fields: `userId`, `quizId`, `expAwarded`, `score`, `totalQuestions`, `oldLevel`, `newLevel`, `timestamp`
- Audit trail for all EXP transactions

## 2. Quiz Answer Key Configuration

### Create Quiz Answer Keys (`functions/src/config/quiz-answers.ts`)

- Store correct answers (index 0 in options array per multiple choice)
- Map quizId → array of correct answer indices
- Include all 10 quizzes with correct answers

### Create EXP Configuration (`functions/src/config/exp-config.ts`)

- Define base EXP per quiz difficulty:
  - Stage 1 quizzes: 50 base EXP (quiz_1_chapter_1, quiz_3_chapter_3)
  - Stage 2 Chapter 0: 75 base EXP (quiz_0_chapter_0)
  - Stage 2 Chapters 1-4: 100 base EXP each
  - Stage 2 Chapters 5-7: 150 base EXP each
- Award EXP based on score percentage: `baseEXP * (score / totalQuestions)`
- Level thresholds: Level 2: 500, Level 3: 1000, Level 4: 2000, Level 5: 4000
- Helper functions: `getExpForQuiz()`, `getExpRequiredForLevel()`, `calculateLevel()`

## 3. Cloud Functions

### Quiz Validation Function (`functions/src/validateQuiz.ts`)

**Trigger**: Firestore onCreate at `quiz_submissions/{submissionId}`

**Process**:

1. Read submission document (userId, quizId, answers)
2. Load correct answers from quiz-answers config
3. Calculate score (correct answers / total questions)
4. Calculate EXP awarded based on score
5. Check if user leveled up
6. Use Firestore transaction to:

   - Update user document (exp, level)
   - Create exp_ledger entry
   - Update submission status to 'validated'

7. Log to analytics

**Security**:

- Verify submission hasn't been processed (idempotent)
- Prevent duplicate quiz completion (check exp_ledger)
- Validate quiz exists and user is authenticated

### Helper Functions (`functions/src/utils/exp-utils.ts`)

- `validateAnswers(quizId, userAnswers)`: Compare against correct answers
- `calculateScore(correctCount, totalQuestions)`: Return percentage
- `calculateExpAwarded(quizId, score)`: Base EXP × score percentage
- `checkLevelUp(currentExp, currentLevel)`: Return new level if leveled up
- `isQuizAlreadyCompleted(userId, quizId)`: Check ledger for duplicates

## 4. Client-Side Integration

### Update AssessmentService (`lib/core/services/assessment_service.dart`)

- Remove direct EXP awarding logic
- After saving responses, create `quiz_submission` document
- Return submission document reference for monitoring

### Create ExpService (`lib/core/services/exp_service.dart`)

- `submitQuizForValidation(quizId, answers)`: Create submission doc
- `listenToSubmissionResult(submissionId)`: Stream for validation result
- `getExpHistory()`: Fetch user's exp_ledger entries
- `getCurrentLevelProgress()`: Calculate progress to next level
- `getExpForQuiz(quizId)`: Get base EXP amount (for UI display)

## 5. State Management

### Create ExpProvider (`lib/providers/exp_provider.dart`)

- Stream user's level and exp from UserModel
- Provide methods to submit quiz and listen to results
- Expose level-up events for UI
- Cache exp_ledger entries for history display

### Update AuthProvider (`lib/providers/auth_provider.dart`)

- Ensure level and exp fields are loaded with user data
- Stream updates when Cloud Function modifies user doc

## 6. UI Components

### Create Level-Up Dialog (`lib/widgets/level_up_dialog.dart`)

- Animated celebration modal with confetti effect
- Display: "Level X → Level Y!"
- Show EXP earned and total EXP
- Encouraging message based on level reached
- Use Flutter animations (AnimatedContainer, Hero)

### Create EXP Progress Widget (`lib/widgets/exp_progress_widget.dart`)

- Compact badge showing "Level X"
- Animated progress bar to next level
- Tooltip/long-press shows: current EXP / required EXP
- Pulsing animation on level-up

### Create Quiz Result Widget (`lib/widgets/quiz_result_widget.dart`)

- Display after quiz submission
- Shows: Score (X/10), EXP earned, Level progress
- Loading state while Cloud Function validates
- Celebration animation if leveled up

### Update MainNavigation (`lib/screens/main_navigation.dart`)

- Add AppBar to Scaffold (currently none)
- Include ExpProgressWidget in top-right corner
- Consistent across all main screens

### Update ProfileScreen (`lib/screens/profile/profile_screen.dart`)

- Add "Progress" section with:
  - Large level badge with animation
  - EXP progress bar with current/required
  - Quizzes completed: X/10
  - History list: Show last 5 quiz completions with scores
  - "View All History" button → full ledger screen

### Create EXP History Screen (`lib/screens/profile/exp_history_screen.dart`)

- Full list of all quiz completions
- Display: Quiz name, Date, Score, EXP earned, Level at time
- Sort by most recent first

## 7. Update AssessmentWidget

### Modify AssessmentWidget (`lib/widgets/assessment_widget.dart`)

**Changes**:

1. After quiz submission, create quiz_submission document
2. Show loading dialog: "Validating your answers..."
3. Listen to submission result stream
4. Once validated:

   - Show QuizResultWidget with score and EXP
   - If leveled up, show LevelUpDialog on top

5. Handle errors gracefully (timeout, validation failure)

### Update Quiz Screens

- All quiz screens in `lib/screens/assessments/`
- Pass quiz result callback to AssessmentWidget
- Handle navigation after seeing results

## 8. Firestore Structure

### Collections

**users/{userId}**

```
- level: number (1-5)
- exp: number
- ... existing fields
```

**quiz_submissions/{submissionId}**

```
- userId: string
- quizId: string
- answers: map<questionId, selectedIndex>
- submittedAt: timestamp
- status: string (pending/validated/failed)
- validatedAt?: timestamp
- score?: number
- expAwarded?: number
```

**exp_ledger/{ledgerId}**

```
- userId: string (indexed)
- quizId: string
- expAwarded: number
- score: number
- totalQuestions: number
- oldLevel: number
- newLevel: number
- createdAt: timestamp (indexed)
```

### Indexes Required

- `exp_ledger`: `userId` ASC, `createdAt` DESC
- `quiz_submissions`: `userId` ASC, `status` ASC

## 9. Security Rules

### Update Firestore Rules (`firestore.rules`)

```javascript
// Users can read own level/exp but cannot write directly
match /users/{userId} {
  allow read: if request.auth.uid == userId;
  allow update: if request.auth.uid == userId 
    && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['level', 'exp']);
}

// Users can create quiz submissions but only read their own
match /quiz_submissions/{submissionId} {
  allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Only Cloud Functions can update
}

// Users can only read their own exp ledger entries
match /exp_ledger/{ledgerId} {
  allow read: if request.auth.uid == resource.data.userId;
  allow write: if false; // Only Cloud Functions can write
}
```

## 10. Analytics Integration

### Track Events

- `quiz_submitted`: When user submits quiz
- `quiz_validated`: When Cloud Function validates (score, exp)
- `level_up`: When user advances a level
- `exp_awarded`: Each EXP transaction

## Implementation Files

### New Cloud Functions (5)

1. `functions/src/config/quiz-answers.ts` - Correct answer keys
2. `functions/src/config/exp-config.ts` - EXP rewards and levels
3. `functions/src/utils/exp-utils.ts` - Validation helper functions
4. `functions/src/validateQuiz.ts` - Main Cloud Function
5. `functions/src/index.ts` - Export new function

### New Client Files (8)

1. `lib/models/quiz_submission.dart` - Submission model
2. `lib/models/exp_ledger.dart` - Ledger entry model
3. `lib/core/services/exp_service.dart` - EXP operations
4. `lib/providers/exp_provider.dart` - State management
5. `lib/widgets/level_up_dialog.dart` - Celebration dialog
6. `lib/widgets/exp_progress_widget.dart` - Progress bar
7. `lib/widgets/quiz_result_widget.dart` - Score display
8. `lib/screens/profile/exp_history_screen.dart` - Full history

### Modified Client Files (6)

1. `lib/models/user_model.dart` - Add level/exp
2. `lib/core/services/assessment_service.dart` - Submit for validation
3. `lib/widgets/assessment_widget.dart` - Handle validation flow
4. `lib/screens/main_navigation.dart` - Add app bar
5. `lib/screens/profile/profile_screen.dart` - Add progress section
6. `firestore.rules` - Security rules

## Testing Plan

### Cloud Functions Testing

- Test validation with correct answers (100% score)
- Test validation with partial answers (50% score)
- Test idempotency (submit same quiz twice)
- Test level-up calculation
- Test atomic transaction rollback on failure

### Client Testing

- Submit quiz and verify validation flow
- Test loading states during validation
- Verify level-up dialog appears correctly
- Test EXP display in app bar
- Test history screen pagination
- Verify offline behavior (submission queues)

### Edge Cases

- Max level reached (level 5)
- Completing quiz twice (should show already completed)
- Invalid quiz submission (malformed data)
- Network timeout during validation
- Multiple quizzes completed rapidly

## Deployment Steps

1. Deploy Cloud Functions: `npm run deploy` in functions/
2. Create Firestore indexes (auto-prompted or manual)
3. Update client code and test in dev
4. Gradual rollout: Test with beta users
5. Monitor Cloud Function logs for errors
6. Track analytics for EXP/level engagement

## Cost Considerations

- Cloud Function invocations: ~10 per user (10 quizzes)
- Firestore reads/writes: ~4 per quiz submission
- Estimated cost: < $0.01 per user for full completion

### To-dos

- [ ] Update UserModel with level and exp fields
- [ ] Create exp_config.dart with quiz rewards and level requirements
- [ ] Create ExpService with EXP logic methods
- [ ] Create ExpProvider for state management
- [ ] Update AssessmentService to award EXP on quiz completion
- [ ] Create level_up_dialog.dart with celebration animation
- [ ] Create exp_progress_widget.dart for displaying level/progress
- [ ] Add app bar to MainNavigation with EXP progress widget
- [ ] Add detailed stats section to ProfileScreen
- [ ] Update AssessmentWidget to show EXP earned and trigger level-up dialog
- [ ] Update Firestore rules to allow level/exp fields
- [ ] Test EXP system with all quizzes and level progression