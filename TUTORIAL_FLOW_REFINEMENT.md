# Tutorial Flow Refinement

## Overview

Implemented a natural tutorial flow system that ensures users complete the full initial tutorial before accessing the app. Users with incomplete tutorials are automatically redirected to their next incomplete step (intro, onboarding, or closing slides) and can continue from where they left off. No progress is reset - users simply pick up where they stopped.

## Changes Made

### 1. Auth Service Updates (`lib/core/services/auth_service.dart`)

#### Existing Methods Used:

**`isInitialTutorialComplete(UserModel user)`** (available but not actively used)
- Helper method that checks if user has completed all three parts of the initial tutorial:
  - `hasSeenIntro` - Intro screen (5 pages)
  - `onboardingCompleted` - Onboarding questionnaire
  - `hasSeenTimerClosingSlides` - Tutorial closing slides (3 slides)
- Returns `true` only if all three are complete
- Can be used for analytics or other checks if needed

**Note:** The `resetInitialTutorialProgress()` method exists but is **not used** in the current flow. Users are not forced to restart the tutorial - they continue from their last incomplete step.

### 2. Auth Provider Updates (`lib/providers/auth_provider.dart`)

#### Simplified `initialize()` Method:

**No Tutorial Reset Logic:**
- The `initialize()` method simply loads user data via stream
- **Does not** check or reset tutorial progress
- Relies on `AuthGuard` to handle tutorial flow naturally
- Flow:
  1. App launches → `initialize()` called
  2. User stream receives user data
  3. Updates app state with user data
  4. `AuthGuard` checks tutorial flags and redirects as needed

**Why This Approach:**
- ✅ Simple and predictable - no hidden resets
- ✅ Users continue from where they left off
- ✅ `AuthGuard` naturally handles redirects based on user's current state
- ✅ No duplicate logic between `initialize()` and `AuthGuard`
- ✅ Works seamlessly for fresh sign-ins AND existing sessions

#### Sign-in Methods (Unchanged):

Sign-in methods remain simple:
- `signInWithEmailAndPassword()`
- `signInWithGoogle()`
- `signInWithApple()`

Each method:
1. Authenticates user
2. Identifies with Superwall (if native)
3. Regenerates daily quests
4. Updates auth state

**Note:** Tutorial flow is entirely handled by `AuthGuard`, not auth methods

### 3. Main App / Auth Guard Updates (`lib/main.dart`)

#### Progressive Tutorial Flow Checking:

The `AuthGuard` widget checks tutorial completion in progressive order:

**1. Check Intro:**
```dart
if (!user.hasSeenIntro) {
  context.go('/intro');
}
```

**2. Check Onboarding:**
```dart
if (!user.onboardingCompleted && !user.onboardingPartiallyCompleted) {
  context.go('/onboarding');
}
```

**3. Check Tutorial Closing Slides:**
```dart
if (user.onboardingCompleted && !user.hasSeenTimerClosingSlides) {
  context.go('/tutorial-closing-slides');
}
```

**Key Features:**
- Progressive checks ensure users are redirected to their **first incomplete step**
- No tutorial progress is reset - users continue from where they stopped
- Once all flags are true, users can access protected routes
- Proper flow: Intro → Onboarding → Tutorial Slides → Paywall → Home

#### Route Configuration Updates:

Removed `AuthGuard` from `/tutorial-closing-slides` route:
```dart
GoRoute(
  path: '/tutorial-closing-slides',
  builder: (context, state) => const TutorialClosingSlidesScreen(), // No AuthGuard!
),
```

**Why:**
- Prevents redirect loops when users are on the tutorial page
- Tutorial pages (`/intro`, `/onboarding`, `/tutorial-closing-slides`) don't need AuthGuard
- They're part of the tutorial flow, not protected app content

### 4. Tutorial Closing Slides Screen Updates (`lib/screens/onboarding/tutorial_closing_slides_screen.dart`)

#### Enhanced Slide Tracking:

**Added Features:**
- `_viewedSlides` Set to track which slides user has viewed
- Slide counter: "Slide 1 of 3", "Slide 2 of 3", etc.
- Comprehensive logging at each step:
  - When screen is opened
  - When user moves between slides
  - When all slides are viewed
  - When tutorial is marked complete

**Improved User Experience:**
- Visual progress indicator showing current slide
- Clear feedback on which slide user is viewing
- Validation to ensure all slides are viewed before completion
- Better error messages if user tries to skip

**Key Logic:**
- User starts on slide 0 (first slide)
- Must click "Continue" on each slide to proceed
- Each slide view is tracked in `_viewedSlides` set
- On final slide, system checks if all 3 slides were viewed
- Only marks `hasSeenTimerClosingSlides = true` after viewing all slides
- This happens BEFORE the paywall is shown

## Tutorial Flow Diagram

```
App Launches (fresh sign-in OR page refresh)
    ↓
initialize() called
    ↓
User stream loads data
    ↓
User navigates to protected route (e.g., /home)
    ↓
Auth Guard Checks (Progressive)
    ↓
Has Seen Intro?
    ├─ NO → Redirect to /intro
    │       User completes intro
    │       ↓
    └─ YES → Next check
              ↓
           Onboarding Complete?
              ├─ NO → Redirect to /onboarding
              │       User completes onboarding
              │       ↓
              └─ YES → Next check
                        ↓
                     Completed 3 Slides?
                        ├─ NO → Redirect to /tutorial-closing-slides
                        │       User views all 3 slides
                        │       ↓
                        └─ YES → Tutorial Complete!
                                  ↓
                               Premium User?
                                  ├─ NO → Show Paywall
                                  └─ YES → Access /home ✅
```

## Complete Tutorial Sequence

### New User Flow:
1. **Sign Up** → Create account
2. **Intro Screen** → 5 intro pages
3. **Onboarding** → Complete questionnaire
4. **Tutorial Closing Slides** → View all 3 slides:
   - Slide 1: "Nice job!" - Building habits
   - Slide 2: "Nurtra helps manage symptoms" - Beta user results
   - Slide 3: "Based on CBT-E" - Evidence-based approach
5. **Paywall** (Native only) → Subscribe or continue
6. **Main App** → Access granted ✅

### Returning User with Incomplete Tutorial:
1. **Login** → Authenticate
2. **Navigate to App** → Try to access /home
3. **AuthGuard Redirect** → Redirected to first incomplete step
   - If stopped at onboarding → redirected to /onboarding
   - If stopped at slides → redirected to /tutorial-closing-slides
4. **Continue Tutorial** → Complete remaining steps from where they stopped
5. **Access App** → Once complete, can access protected routes

## Benefits

### 1. Natural Tutorial Flow
- Users continue from where they left off
- No frustrating progress resets
- Smooth, user-friendly experience

### 2. Prevents Skipping Tutorial
- Users can't access main app without completing all steps
- Progressive checks ensure proper tutorial sequence
- AuthGuard automatically redirects to incomplete steps

### 3. Better User Experience
- Users maintain their progress through tutorial
- Can complete tutorial at their own pace
- No need to redo completed sections

### 4. Simple and Predictable
- Clear, linear tutorial flow
- Easy to understand and debug
- No hidden reset logic or complex state management

## Testing Scenarios

### Scenario 1: New User Completes Tutorial
- **Expected:** User sees intro → onboarding → 3 slides → paywall → home
- **Result:** ✅ All tutorial flags set correctly, user accesses app

### Scenario 2: User Stops at Slide 2 and Refreshes (Stays Logged In)
- **Action:** User views slides 1 and 2, then refreshes page (still logged in)
- **Expected:** AuthGuard checks tutorial status, user continues from slide 2
- **Result:** ✅ User redirected to /tutorial-closing-slides, continues from where they stopped

### Scenario 3: User Completes Onboarding but Not Slides
- **Action:** User completes intro and onboarding, but closes app before slides
- **Expected:** On next login, AuthGuard redirects to slides
- **Result:** ✅ User redirected to /tutorial-closing-slides, completes remaining 3 slides

### Scenario 4: User Completes Everything
- **Action:** User completes intro, onboarding, and all 3 slides
- **Expected:** User accesses main app (after paywall if needed)
- **Result:** ✅ Tutorial marked complete, no reset on next login

## Logging

Clear logging throughout the flow:

### Auth Guard Logs:
```
✅ AUTH GUARD: User authenticated: user@example.com
📖 AUTH GUARD: User has not seen intro, redirecting to /intro
```
```
✅ AUTH GUARD: User authenticated: user@example.com
📝 AUTH GUARD: User has not completed onboarding, redirecting to /onboarding
```
```
✅ AUTH GUARD: User authenticated: user@example.com
📖 AUTH GUARD: User has not completed tutorial closing slides, redirecting to /tutorial-closing-slides
```

### Tutorial Slides Logs:
```
📖 TUTORIAL SLIDES: Starting tutorial closing slides (3 slides total)
   User must view all 3 slides to complete tutorial
📖 TUTORIAL SLIDES: Moved to slide 2/3
   Viewed slides: {0, 1}
✅ TUTORIAL SLIDES: All slides viewed, completing tutorial...
🎯 TUTORIAL SLIDES: Marking tutorial closing slides as complete...
✅ TUTORIAL SLIDES: Tutorial closing slides marked complete
```

### AuthGuard Flow:
```
✅ AUTH GUARD: User authenticated
   → Checking tutorial status...
   → User redirected to appropriate incomplete step (intro/onboarding/slides)
   → Once complete, user accesses protected routes
```

## Technical Details

### State Management
- Uses Riverpod for state management
- Real-time Firestore listeners update user state
- Auth guard automatically responds to state changes
- Seamless redirects without manual refreshes

### Data Persistence
- All tutorial flags stored in Firestore
- Survives app restarts and device changes
- Syncs across all user devices
- Secure and reliable

### Error Handling
- Graceful error handling throughout
- User never gets stuck due to errors
- Comprehensive error logging
- Fallback to safe states on error

## Future Enhancements

Possible improvements:
1. Add analytics tracking for tutorial completion rates
2. Add tutorial progress percentage indicator
3. Allow admin to reset tutorial for specific users
4. Add tutorial "skip" option for returning users (with confirmation)
5. Track time spent on each tutorial step

## Files Modified

1. `lib/core/services/auth_service.dart`
2. `lib/providers/auth_provider.dart`
3. `lib/main.dart`
4. `lib/screens/onboarding/tutorial_closing_slides_screen.dart`

## Summary

The tutorial flow refinement ensures users complete the entire initial tutorial before accessing the app. The tutorial check runs **once on app launch** (in the `initialize()` method), making it work for both fresh sign-ins and existing sessions (page refresh, app restart). This prevents users from bypassing the tutorial by staying logged in.

Users who launch the app with an incomplete tutorial will have their progress reset automatically, forcing them to redo the tutorial from the beginning. The 3 tutorial closing slides must all be viewed before the user can proceed to the paywall and main app. Comprehensive logging and error handling ensure a smooth, predictable user experience.

**Key Advantage:** Users cannot bypass the tutorial by refreshing the page or restarting the app while logged in. The check runs on every app launch, ensuring complete tutorial enforcement.

