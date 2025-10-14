# Onboarding Flow Testing Guide

## Prerequisites
- Flutter development environment set up
- Firebase project configured
- Test user accounts created

## Test Scenarios

### Scenario 1: New User - Complete Flow
**Objective:** Verify new users see intro and onboarding

**Steps:**
1. Create a new user account (or use a fresh test account)
2. After signup, verify you're redirected to `/intro`
3. Navigate through all 5 intro pages
4. Click "Get Started" on the final page
5. Verify redirection to `/onboarding`
6. Complete the onboarding questionnaire
7. Verify access to main app

**Expected Results:**
- ✅ User sees intro screen first
- ✅ All 5 pages display correctly with images
- ✅ "Get Started" button works
- ✅ User is redirected to onboarding
- ✅ After onboarding, user has access to main app

**Database State After:**
```json
{
  "hasSeenIntro": true,
  "onboardingCompleted": true,
  "onboardingPartiallyCompleted": false
}
```

---

### Scenario 2: New User - Skip Intro
**Objective:** Verify skip functionality works

**Steps:**
1. Create a new user account
2. After signup, verify you're on `/intro`
3. Click "Skip" button on any intro page
4. Verify immediate redirection to `/onboarding`

**Expected Results:**
- ✅ Skip button is visible on all pages
- ✅ Skip immediately redirects to onboarding
- ✅ `hasSeenIntro` is set to `true`

**Database State After:**
```json
{
  "hasSeenIntro": true,
  "onboardingCompleted": false,
  "onboardingPartiallyCompleted": false
}
```

---

### Scenario 3: New User - Partial Onboarding
**Objective:** Verify partial onboarding flow

**Steps:**
1. Complete intro (or skip it)
2. On onboarding screen, answer first 4 questions
3. Click "Skip to App" button
4. Verify access to main app

**Expected Results:**
- ✅ Can skip after first 4 required questions
- ✅ User gains access to main app
- ✅ Partial onboarding flag is set

**Database State After:**
```json
{
  "hasSeenIntro": true,
  "onboardingCompleted": false,
  "onboardingPartiallyCompleted": true
}
```

---

### Scenario 4: Returning User
**Objective:** Verify returning users don't see intro/onboarding

**Steps:**
1. Use an existing user account with:
   - `hasSeenIntro: true`
   - `onboardingCompleted: true` OR `onboardingPartiallyCompleted: true`
2. Sign in to the app
3. Verify direct access to main app

**Expected Results:**
- ✅ No intro screen shown
- ✅ No onboarding screen shown
- ✅ Direct access to home screen

---

### Scenario 5: Back Navigation
**Objective:** Verify navigation controls work correctly

**Steps:**
1. Start intro flow
2. Navigate to page 3 using next button
3. Click back button to return to page 2
4. Click back button to return to page 1
5. Verify no back button on page 1

**Expected Results:**
- ✅ Back button works correctly
- ✅ Page 1 has no back button
- ✅ Progress dots update correctly

---

### Scenario 6: Asset Loading
**Objective:** Verify images load correctly or fallback works

**Steps:**
1. Start intro flow with good network connection
2. Verify all images load on pages 1-3
3. Verify icons display on pages 4-5

**Expected Results:**
- ✅ Page 1: Nurtra logo displays
- ✅ Page 2: Stage 1 lesson image displays
- ✅ Page 3: Food diary image displays
- ✅ Page 4: Heart icon displays
- ✅ Page 5: Rocket icon displays
- ✅ Fallback icons work if images fail to load

---

### Scenario 7: Network Error Handling
**Objective:** Verify error handling when network fails

**Steps:**
1. Complete intro pages
2. Disable network connection
3. Click "Get Started"
4. Observe error handling

**Expected Results:**
- ✅ Loading indicator shows during save
- ✅ Error snackbar appears with message
- ✅ Loading state resets
- ✅ User can retry when network is restored

---

### Scenario 8: Sign Out and Sign In
**Objective:** Verify state persists after sign out

**Steps:**
1. New user completes intro and onboarding
2. Sign out
3. Sign back in with same account
4. Verify no intro/onboarding screens shown

**Expected Results:**
- ✅ User goes directly to main app
- ✅ No intro shown on subsequent logins
- ✅ State properly saved in Firestore

---

## Manual Testing Checklist

### Visual Design
- [ ] All pages display correctly on mobile
- [ ] All pages display correctly on tablet
- [ ] All pages display correctly on web
- [ ] Text is readable and properly sized
- [ ] Images are properly centered and scaled
- [ ] Progress dots update correctly
- [ ] Buttons are easily tappable

### Functionality
- [ ] Next button advances to next page
- [ ] Back button returns to previous page
- [ ] Skip button redirects to onboarding
- [ ] Get Started button redirects to onboarding
- [ ] Loading states display correctly
- [ ] Error messages are clear and helpful

### Data Persistence
- [ ] `hasSeenIntro` flag is saved correctly
- [ ] Flag persists after app restart
- [ ] Flag persists after sign out/in
- [ ] Onboarding flags are independent

### Edge Cases
- [ ] Rapid button clicking is handled
- [ ] Back navigation from page 1 is disabled
- [ ] Network errors display properly
- [ ] App doesn't crash on errors
- [ ] BuildContext warnings are resolved

---

## Automated Testing (Future)

### Unit Tests
```dart
// Test updateIntroStatus method
test('updateIntroStatus sets hasSeenIntro to true', () async {
  // Setup
  final authService = MockAuthService();
  
  // Execute
  await authService.updateIntroStatus(hasSeenIntro: true);
  
  // Verify
  expect(user.hasSeenIntro, true);
});
```

### Widget Tests
```dart
// Test IntroScreen renders correctly
testWidgets('IntroScreen displays all 5 pages', (tester) async {
  await tester.pumpWidget(IntroScreen());
  
  // Verify page 1
  expect(find.text('Welcome to Nurtra'), findsOneWidget);
  
  // Navigate to page 2
  await tester.tap(find.byIcon(Icons.arrow_forward));
  await tester.pumpAndSettle();
  
  expect(find.text('Learn and Understand'), findsOneWidget);
});
```

### Integration Tests
```dart
// Test complete onboarding flow
testWidgets('Complete onboarding flow works', (tester) async {
  // Sign up new user
  await signUpNewUser();
  
  // Verify intro screen
  expect(find.byType(IntroScreen), findsOneWidget);
  
  // Complete intro
  await completeIntroPages(tester);
  
  // Verify onboarding screen
  expect(find.byType(OnboardingScreen), findsOneWidget);
  
  // Complete onboarding
  await completeOnboarding(tester);
  
  // Verify main app
  expect(find.byType(MainNavigation), findsOneWidget);
});
```

---

## Database Verification

### Check User Document in Firestore
```javascript
// In Firebase Console or using Firebase CLI
db.collection('users').doc(USER_ID).get().then(doc => {
  console.log('hasSeenIntro:', doc.data().hasSeenIntro);
  console.log('onboardingCompleted:', doc.data().onboardingCompleted);
  console.log('onboardingPartiallyCompleted:', doc.data().onboardingPartiallyCompleted);
});
```

### Reset User State for Testing
```javascript
// To re-test intro flow for existing user
db.collection('users').doc(USER_ID).update({
  hasSeenIntro: false,
  onboardingCompleted: false,
  onboardingPartiallyCompleted: false
});
```

---

## Common Issues and Solutions

### Issue 1: Infinite Redirect Loop
**Symptom:** App keeps redirecting to intro screen
**Solution:** Check that `hasSeenIntro` is being saved to Firestore correctly

### Issue 2: Images Not Loading
**Symptom:** Blank spaces where images should be
**Solution:** Verify assets are in pubspec.yaml and files exist in assets folder

### Issue 3: Skip Button Not Working
**Symptom:** Skip button doesn't navigate
**Solution:** Check network connection and Firestore permissions

### Issue 4: Build Context Errors
**Symptom:** Console warnings about BuildContext across async gaps
**Solution:** Already fixed - verify mounted checks are in place

---

## Performance Metrics to Monitor

- **Intro Completion Rate:** % of users who complete all 5 pages vs skip
- **Time on Intro:** Average time users spend on intro
- **Skip Page Distribution:** Which pages do users skip from most
- **Intro → Onboarding Conversion:** % who proceed to onboarding
- **Full Flow Completion:** % who complete intro + full onboarding

---

## Success Criteria

The onboarding flow implementation is successful if:
- ✅ 100% of new users see the intro screen
- ✅ All navigation works smoothly without errors
- ✅ State persists correctly across sessions
- ✅ Images load properly or fallback gracefully
- ✅ Error handling provides clear feedback
- ✅ No linter warnings or errors
- ✅ App compiles successfully for all platforms
- ✅ User experience is smooth and welcoming

