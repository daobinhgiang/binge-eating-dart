# Gated Paywall Configuration

## Overview

The app is now configured with a **gated paywall** that ensures users on native platforms (iOS/Android) must subscribe before accessing the home screen after completing the tutorial flow. Web users bypass the paywall entirely.

## How It Works

### Tutorial Flow → Paywall

1. **User completes tutorial** → The closing slides screen shows 3 informational slides
2. **User clicks final button** → The `_completeTutorial()` method is called
3. **Platform check:**
   - **Web**: Skip paywall, go directly to `/home`
   - **iOS/Android**: Show gated paywall

### Gated Paywall Logic

The `_showGatedPaywall()` method implements a recursive loop that enforces subscription:

```dart
1. Check if user already has subscription in Firestore
   ├─ Yes → Navigate to /home ✓
   └─ No → Show Superwall paywall
        ↓
2. User interacts with paywall
        ↓
3. Paywall dismissed (via feature callback)
        ↓
4. Sync subscription status from Superwall to Firestore
        ↓
5. Check subscription status again
   ├─ Subscribed → Navigate to /home ✓
   └─ Not subscribed → Recursively call _showGatedPaywall() (go back to step 1)
```

### Key Implementation Details

#### 1. Subscription Status Syncing

**File**: `lib/core/services/subscription_service.dart`

The `syncSubscriptionStatus()` method now properly queries Superwall's subscription status:

```dart
// Get subscription status from Superwall
final subscriptionStatus = await Superwall.shared.subscriptionStatus;

// Check if it's an active subscription (SubscriptionStatus is a sealed class)
bool isPremium = subscriptionStatus is SubscriptionStatusActive;

// Update Firestore
await updateSubscriptionStatus(isPremium);
```

**Important**: `SubscriptionStatus` is a **sealed class** with three subclasses:
- `SubscriptionStatusActive` - User has active subscription
- `SubscriptionStatusInactive` - User doesn't have subscription
- `SubscriptionStatusUnknown` - Subscription status is unknown

#### 2. Gated Paywall Display

**File**: `lib/screens/onboarding/tutorial_closing_slides_screen.dart`

The `_showGatedPaywall()` method:

1. **Pre-check**: Verifies if user already has `isPremium = true` in Firestore
2. **Show paywall**: Uses `Superwall.shared.registerPlacement('campaign_trigger', ...)`
3. **Post-paywall check**: Syncs Superwall status to Firestore, then rechecks
4. **Recursive enforcement**: If user still not subscribed, recursively calls itself

#### 3. Platform-Specific Behavior

```dart
if (kIsWeb) {
  // Web: No paywall
  context.go('/home');
} else {
  // Native: Show gated paywall
  await _showGatedPaywall();
}
```

## User Experience

### Non-Subscribed User (iOS/Android)

1. Completes tutorial
2. Sees Superwall paywall
3. **Option A**: Subscribes → Paywall dismisses → Navigates to home ✓
4. **Option B**: Dismisses without subscribing → Paywall shows again → Loop continues

**Result**: User **cannot** access the home screen without subscribing.

### Already Subscribed User (iOS/Android)

1. Completes tutorial
2. App checks Firestore: `isPremium = true`
3. Skips paywall entirely
4. Navigates directly to home ✓

### Web User

1. Completes tutorial
2. Skips paywall entirely (Superwall not available on web)
3. Navigates directly to home ✓

## Technical Flow Diagram

```
Tutorial Complete
      ↓
  Platform?
      ↓
   ┌──┴──┐
   │     │
  Web  Native
   │     │
   ↓     ↓
 /home  Check isPremium
         ↓
      ┌──┴──┐
      │     │
    Yes    No
      │     │
      ↓     ↓
    /home  Show Paywall
              ↓
         User Interacts
              ↓
         Sync Status
              ↓
         Check Again
              ↓
           ┌──┴──┐
           │     │
         Yes    No
           │     │
           ↓     ↓
         /home  Loop Back
                  ↑
                  │
                  └──┘
```

## Database Schema

**Firestore**: `users/{userId}`

```javascript
{
  isPremium: boolean,  // Synced from Superwall subscription status
  hasSeenTimerClosingSlides: boolean,  // Tutorial completion flag
  // ... other fields
}
```

## Files Modified

### 1. `lib/core/services/subscription_service.dart`

**Changes**:
- Added import: `import 'package:superwallkit_flutter/superwallkit_flutter.dart';`
- Implemented `syncSubscriptionStatus()` method to query Superwall and update Firestore
- Uses `subscriptionStatus is SubscriptionStatusActive` to check subscription

### 2. `lib/screens/onboarding/tutorial_closing_slides_screen.dart`

**Already Configured** (no changes needed):
- `_completeTutorial()` method already calls `_showGatedPaywall()` for native platforms
- `_showGatedPaywall()` already implements recursive loop to enforce subscription
- Web platform already bypasses paywall

## Testing Scenarios

### Test Case 1: New User on iOS (Not Subscribed)
1. Complete tutorial
2. Verify paywall appears
3. Dismiss paywall without subscribing
4. **Expected**: Paywall appears again
5. Subscribe
6. **Expected**: Navigate to home screen

### Test Case 2: Returning User on iOS (Already Subscribed)
1. Complete tutorial
2. **Expected**: Skip paywall, navigate directly to home

### Test Case 3: User on Web
1. Complete tutorial
2. **Expected**: Skip paywall, navigate directly to home

### Test Case 4: Subscription Sync
1. User subscribes through paywall
2. **Expected**: `isPremium` field in Firestore is updated to `true`
3. User navigates to home screen

## Configuration Required

### Superwall Dashboard

To ensure the paywall is properly gated, configure in Superwall dashboard:

1. Navigate to your paywall settings
2. Under **"Feature Gating"**, select **"Gated"**
3. This ensures the `feature` closure only executes when user subscribes

**Placement ID**: `campaign_trigger`

## Error Handling

### Scenario 1: Superwall API Error
- Error is logged but doesn't crash the app
- User sees error message: "Unable to load subscription. Please try again."
- Loading state is reset so user can retry

### Scenario 2: Firestore Update Error
- Error is logged
- Subscription sync fails gracefully
- User experience is not disrupted

## Security Considerations

1. **Client-Side Check**: The current implementation relies on Firestore for subscription status
2. **Recommendation**: For production, implement server-side verification:
   - Use Cloud Functions to verify subscription with Apple/Google
   - Update `isPremium` field server-side only
   - Prevent client from directly modifying `isPremium`

## Code Quality

✅ Zero linter errors  
✅ Proper error handling  
✅ Platform-specific logic (web vs native)  
✅ Recursive enforcement loop  
✅ Async safety with mounted checks  
✅ Detailed logging for debugging  
✅ Graceful error degradation

## Summary

The app now has a **fully functional gated paywall** that:
- ✅ **Enforces subscription** on iOS/Android after tutorial
- ✅ **Bypasses paywall** on web platforms
- ✅ **Loops until subscribed** using recursive calls
- ✅ **Syncs subscription status** from Superwall to Firestore
- ✅ **Handles errors gracefully** without crashing
- ✅ **Provides clear user feedback** during the process

Users on native platforms **cannot** access the home screen without subscribing, while web users proceed normally.

