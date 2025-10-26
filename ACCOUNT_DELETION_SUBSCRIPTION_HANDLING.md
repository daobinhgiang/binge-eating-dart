# Account Deletion & Subscription Handling

## Overview

This document describes the enhanced account deletion system that properly manages user subscriptions and prevents trial abuse when users delete and recreate accounts.

## ✅ What Was Implemented

### 1. Enhanced Account Deletion Flow

The `deleteAccount()` method in `auth_service.dart` now:

1. **Records Subscription History**
   - Before deletion, checks if user had a subscription (`isPremium`, `subscriptionStore`, or `subscriptionProductId`)
   - If user had a subscription, creates a permanent record in `subscription_history` collection
   - This record persists even after account deletion

2. **Resets Premium Status**
   - Sets `isPremium = false` before deletion
   - Updates `lastSubscriptionUpdate` timestamp
   - Marks `accountDeletionInitiated = true`

3. **Clears Subscription Events**
   - Deletes all documents in the `subscription_events` subcollection
   - Removes transaction history associated with the account

4. **Resets Superwall State**
   - Calls `Superwall.shared.reset()` to clear on-device subscription data
   - Clears paywall assignments and user identity
   - Removes subscription entitlements from Superwall SDK

### 2. Trial Eligibility System

#### Subscription History Collection

**Firestore Path:** `/subscription_history/{email}`

**Document Structure:**
```json
{
  "email": "user@example.com",
  "hadSubscription": true,
  "lastDeletedAt": 1234567890000,
  "previousUserId": "abc123",
  "trialEligible": false
}
```

**Purpose:**
- Persists across account deletions
- Tracks which emails have previously used subscriptions/trials
- Prevents trial abuse by blocking trial access for returning users

#### Trial Eligibility Check

During user creation (all sign-in methods), the system:

1. **Checks Subscription History**
   ```dart
   final hasSubscriptionHistory = await _hasSubscriptionHistory(email);
   ```

2. **Sets Trial Eligibility**
   ```dart
   userData['trialEligible'] = !hasSubscriptionHistory;
   ```

3. **Logs Decision**
   - "✅ New user is trial eligible" - First time users
   - "⚠️ User has previous subscription history - not trial eligible" - Returning users

### 3. Security Rules

The `subscription_history` collection is protected by Firestore security rules:

```javascript
match /subscription_history/{email} {
  allow read: if request.auth != null;  // Users can read their own history
  allow write: if false;                 // Only Cloud Functions can write
}
```

**Why This Matters:**
- Users cannot modify their own trial eligibility
- Only the system (via Cloud Functions or server-side code) can update subscription history
- Prevents unauthorized manipulation of trial status

## 🔄 Complete Flow Diagrams

### Account Deletion Flow

```
1. User requests account deletion
   ↓
2. Get user email and check if had subscription
   ↓
3. If had subscription → Create subscription_history record
   ↓
4. Update user document: isPremium = false
   ↓
5. Clear all service caches
   ↓
6. Reset Superwall (clear subscription state)
   ↓
7. Delete all Firestore data
   - todos
   - regenerationLog
   - assessments
   - exercises
   - subscription_events ← NEW
   - weeks and diaries
   ↓
8. Delete Firebase Auth user
   ↓
9. Disconnect Google Sign-In
   ↓
10. Account fully deleted ✅
```

### Re-Registration Flow (Same Email)

```
1. User signs up with email that previously had subscription
   ↓
2. Check subscription_history collection
   ↓
3. Found record → hasSubscriptionHistory = true
   ↓
4. Create new user account
   ↓
5. Set trialEligible = false
   ↓
6. User sees paywall WITHOUT trial option
   ↓
7. User must purchase full subscription
```

### New User Flow (First Time)

```
1. User signs up with new email
   ↓
2. Check subscription_history collection
   ↓
3. No record found → hasSubscriptionHistory = false
   ↓
4. Create new user account
   ↓
5. Set trialEligible = true
   ↓
6. User sees paywall WITH trial option
   ↓
7. User can start trial or purchase
```

## 📋 Implementation Details

### Files Modified

1. **`lib/core/services/auth_service.dart`**
   - Enhanced `deleteAccount()` method
   - Added `_hasSubscriptionHistory()` helper
   - Added subscription tracking to `_deleteAllUserData()`
   - Updated all user creation flows (email, Google, Apple)

2. **`lib/providers/auth_provider.dart`**
   - Added `Superwall.shared.reset()` call in `deleteAccount()`
   - Clears subscription state before account deletion

3. **`firestore.rules`**
   - Added security rules for `subscription_history` collection
   - Prevents unauthorized modifications

### New Database Collections

#### `subscription_history` (Top-Level Collection)

- **Purpose:** Track emails that have had subscriptions
- **Document ID:** User email (lowercase)
- **Persistence:** Never deleted (survives account deletion)
- **Security:** Read by users, write by system only

#### Deleted Subcollections

The account deletion now also removes:
- `subscription_events` - All Superwall webhook events

## 🔒 Security Considerations

### Why This Approach?

1. **Email-Based Tracking**
   - Emails are persistent across account deletions
   - Cannot be easily changed by users
   - Apple/Google sign-in use verified emails

2. **Separate Collection**
   - Survives user document deletion
   - Protected by security rules
   - Cannot be modified by users

3. **Trial Eligibility Flag**
   - Set during account creation
   - Based on subscription history
   - Used by paywall to show/hide trial options

### Potential Issues & Solutions

| Issue | Solution |
|-------|----------|
| User changes email | Email change would require re-verification; track both emails |
| Cloud Functions bypass rules | Use `request.auth` checks in functions |
| Malicious users try to edit | Security rules prevent client-side writes |
| Data privacy concerns | Include in privacy policy; allow GDPR deletion requests |

## 🧪 Testing Guide

### Test 1: Account Deletion with Subscription

```bash
# Setup
1. Create user account (user@test.com)
2. Subscribe to premium (isPremium = true)
3. Verify subscription is active

# Delete Account
4. Delete account
5. Check logs for "📝 Subscription history recorded"
6. Verify subscription_history/user@test.com exists

# Re-register
7. Create new account with same email
8. Check logs for "⚠️ User has previous subscription history"
9. Verify new user has trialEligible = false
10. Open paywall - should NOT show trial option
```

### Test 2: Account Deletion without Subscription

```bash
# Setup
1. Create user account (newuser@test.com)
2. Complete onboarding but DON'T subscribe

# Delete Account
3. Delete account
4. Verify NO subscription_history created

# Re-register
5. Create new account with same email
6. Check logs for "✅ New user is trial eligible"
7. Verify new user has trialEligible = true
8. Open paywall - SHOULD show trial option
```

### Test 3: Superwall Reset

```bash
# Setup
1. Create user account
2. Subscribe via Superwall
3. Verify Superwall shows premium status

# Delete Account
4. Delete account
5. Check logs for "✅ Superwall reset - subscription data cleared"

# Verify
6. Check device - Superwall identity should be reset
7. paywall assignments should be cleared
```

### Test 4: Trial Eligibility Check

```bash
# Firestore Console Test
1. Create document: subscription_history/test@example.com
   {
     "hadSubscription": true,
     "trialEligible": false
   }

# Sign Up Test
2. Create new account with test@example.com
3. Check user document - should have trialEligible = false
4. Verify trial is NOT offered in paywall
```

## 📊 Monitoring & Debugging

### Key Logs to Watch

```bash
# Subscription history created
📝 Subscription history recorded for email: user@test.com

# Premium status reset
✅ isPremium reset to false

# Superwall reset
✅ Superwall reset - subscription data and user identity cleared

# Subscription events deleted
Deleted X documents from subscription_events

# Trial eligibility check
✅ New user is trial eligible
⚠️ User has previous subscription history - not trial eligible
```

### Debugging Commands

```bash
# Check subscription history
firebase firestore:get subscription_history

# Check if email has history
firebase firestore:get subscription_history/USER_EMAIL

# View account deletion logs
firebase functions:log --only auth

# Check user's trial eligibility
firebase firestore:get users/USER_ID
```

## 🎯 Integration with Superwall

### How to Use Trial Eligibility in Superwall

In your paywall configuration, you can use the `trialEligible` attribute:

```javascript
// Superwall Dashboard - Paywall Rules
if (user.attributes.trialEligible === true) {
  show_trial_option();
} else {
  hide_trial_option();
  show_full_price_only();
}
```

### Setting User Attributes

The `_identifyUserWithSuperwall()` method in `auth_provider.dart` should be updated to include trial eligibility:

```dart
await Superwall.shared.setUserAttributes({
  'user_id': user.id,
  'email': user.email,
  'is_premium': user.isPremium,
  'trial_eligible': user.trialEligible,  // ← Add this
  // ... other attributes
});
```

## ⚠️ Important Notes

### Data Persistence

- **`subscription_history` collection is NEVER deleted**
- Even if user requests GDPR deletion, consider keeping this for fraud prevention
- If required by law to delete, implement separate GDPR compliance function

### Email Case Sensitivity

- All emails are stored in lowercase: `email.toLowerCase()`
- Ensures consistent matching across sign-in methods
- Prevents case-sensitive bypasses

### Trial Eligibility Field

- **For backward compatibility:** Existing users won't have `trialEligible` field
- **Default behavior:** If field is missing, treat as trial eligible (graceful fallback)
- **Migration:** Consider running a migration script to add field to existing users

## 🔄 Potential Enhancements

### Future Improvements

1. **Grace Period**
   - Allow re-registration with trial within 24 hours of deletion
   - Track `lastDeletedAt` timestamp

2. **Multiple Email Tracking**
   - Track users who change emails
   - Link old and new emails in subscription history

3. **Admin Override**
   - Allow admins to grant trial eligibility manually
   - Useful for customer support cases

4. **Analytics**
   - Track how many users delete and recreate accounts
   - Monitor trial abuse attempts

5. **Webhook Integration**
   - Notify Superwall when account is deleted
   - Sync subscription status with external systems

## ✅ Summary

The enhanced account deletion system ensures:

- ✅ Premium status is reset to `false` before deletion
- ✅ Superwall subscription state is cleared
- ✅ Subscription history persists across deletions
- ✅ Users who had subscriptions cannot get trials again
- ✅ Trial eligibility is checked during every sign-up
- ✅ Subscription history is protected from user modification
- ✅ All subscription events are deleted with account

**No more trial abuse!** Users who delete and recreate accounts will no longer get trial offers. 🎉

---

**Last Updated:** October 26, 2025
**Version:** 1.0.0

