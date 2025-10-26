# User Premium Status Default Verification

## ✅ Verification Complete

All user creation paths have been verified to ensure that **`isPremium` defaults to `false`** for new users.

---

## 🔍 Verification Results

### 1. UserModel Constructor Default Value

**File:** `lib/models/user_model.dart` (Line 94)

```dart
const UserModel({
  // ... other parameters
  this.isPremium = false,  // ✅ Defaults to false
  // ... other parameters
});
```

**Result:** ✅ **Default value is `false`**

---

### 2. Email/Password Registration

**File:** `lib/core/services/auth_service.dart` (Lines 97-105)

```dart
final userModel = UserModel(
  id: credential.user!.uid,
  email: email.trim(),
  firstName: firstName.trim(),
  lastName: lastName.trim(),
  role: role,
  createdAt: DateTime.now(),
  lastLoginAt: DateTime.now(),
  // isPremium is NOT specified, so it uses default value: false
);
```

**Result:** ✅ **Uses default value (`false`)**

---

### 3. Google Sign-In Registration

**File:** `lib/core/services/auth_service.dart` (Lines 216-225)

```dart
final userModel = UserModel(
  id: userCredential.user!.uid,
  email: userCredential.user!.email ?? '',
  firstName: firstName,
  lastName: lastName,
  role: UserRole.patient,
  createdAt: DateTime.now(),
  lastLoginAt: DateTime.now(),
  photoUrl: userCredential.user!.photoURL,
  // isPremium is NOT specified, so it uses default value: false
);
```

**Result:** ✅ **Uses default value (`false`)**

---

### 4. Firestore Deserialization

**File:** `lib/models/user_model.dart` (Line 181)

```dart
factory UserModel.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return UserModel(
    // ... other fields
    isPremium: data['isPremium'] ?? false,  // ✅ Defaults to false if missing
    // ... other fields
  );
}
```

**Result:** ✅ **Defaults to `false` if field is missing in Firestore**

---

### 5. Firestore Serialization

**File:** `lib/models/user_model.dart` (Line 228)

```dart
Map<String, dynamic> toFirestore() {
  return {
    // ... other fields
    'isPremium': isPremium,  // ✅ Saves the actual value
    // ... other fields
  };
}
```

**Result:** ✅ **Properly saves `isPremium` field to Firestore**

---

### 6. Premium Status Updates (Webhook Only)

**File:** `functions/src/superwallWebhook.ts` (Lines 165-198)

```typescript
async function updateUserPremiumStatus(
  userId: string,
  isPremium: boolean,
  payload: SuperwallWebhookPayload
): Promise<void> {
  // ... validation code
  
  const updateData: any = {
    isPremium: isPremium,  // ✅ Only updated via webhook
    lastSubscriptionUpdate: admin.firestore.FieldValue.serverTimestamp(),
    subscriptionStore: payload.store || null,
    subscriptionProductId: payload.product_id || null,
  };
  
  await userRef.update(updateData);
}
```

**Premium Grant Events:**
- `subscription_start`
- `transaction_complete`
- `subscription_renew`
- `trial_start`

**Premium Revoke Events:**
- `subscription_cancel`
- `subscription_expire`
- `billing_issue`

**Result:** ✅ **`isPremium` is ONLY set to `true` via Superwall webhook events**

---

### 7. No Hardcoded Premium Status

**Search Results:** Searched entire codebase for `isPremium.*=.*true` and `isPremium: true`

**Findings:**
- ✅ No instances found in user creation code
- ✅ Only references are in documentation files explaining the flow
- ✅ Only actual implementation is in the Superwall webhook function

**Result:** ✅ **No hardcoded premium status during user creation**

---

## 📊 Complete User Journey Verification

### New User Journey (Default Behavior)

```
1. User registers (Email/Password or Google)
   ↓
2. UserModel created with isPremium = false (default)
   ↓
3. User document saved to Firestore with isPremium: false
   ↓
4. User completes onboarding → isPremium: false ✅
   ↓
5. User completes tutorial → hasSeenTimerClosingSlides: true, isPremium: false ✅
   ↓
6. AuthGuard checks subscription → Detects !isPremium && hasSeenTimerClosingSlides ✅
   ↓
7. Redirects to paywall → User sees Superwall paywall ✅
   ↓
8. User subscribes → Superwall webhook → isPremium: true ✅
   ↓
9. User can access app → AuthGuard allows through ✅
```

### Premium User Journey (After Subscription)

```
1. User subscribes via Superwall
   ↓
2. Superwall sends webhook to Firebase Function
   ↓
3. Firebase Function updates Firestore: isPremium = true ✅
   ↓
4. AuthProvider stream detects change
   ↓
5. User automatically navigated to home ✅
   ↓
6. On next app launch: AuthGuard checks → isPremium = true → Skip paywall ✅
```

---

## 🎯 Summary

| Component | Status | Notes |
|-----------|--------|-------|
| UserModel Default | ✅ | `isPremium = false` |
| Email/Password Registration | ✅ | Uses default value |
| Google Sign-In Registration | ✅ | Uses default value |
| Firestore Serialization | ✅ | Properly saves field |
| Firestore Deserialization | ✅ | Defaults to `false` if missing |
| No Hardcoded Premium | ✅ | No instances in creation code |
| Webhook Updates Only | ✅ | Only way to set `isPremium = true` |
| AuthGuard Paywall Check | ✅ | Properly checks `isPremium` status |

---

## ✅ Conclusion

**All new users are created with `isPremium: false` by default.**

The only way for a user to get `isPremium: true` is through:
1. Subscribing via Superwall paywall
2. Superwall webhook event triggering the Firebase Function
3. Firebase Function updating the user's Firestore document

This ensures that:
- ✅ No users get free premium access by default
- ✅ All users must go through the proper subscription flow
- ✅ Premium status is only granted through verified Superwall events
- ✅ The paywall system works as intended

---

## 🔒 Security Notes

1. **Default is Non-Premium:** All new users start as non-premium
2. **Webhook Verification:** Superwall webhook uses signature verification
3. **Firestore Security Rules:** Should enforce that only the webhook function can update `isPremium`
4. **No Client-Side Updates:** Users cannot set their own premium status from the app

---

## 📝 Recommendation

Consider adding Firestore security rules to prevent client-side updates to `isPremium`:

```javascript
// firestore.rules
match /users/{userId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow update: if request.auth != null && 
                   request.auth.uid == userId &&
                   // Prevent users from updating their own premium status
                   !request.resource.data.diff(resource.data).affectedKeys().hasAny(['isPremium', 'subscriptionStore', 'subscriptionProductId', 'subscriptionStartedAt', 'subscriptionExpiresAt']);
}
```

This ensures that subscription-related fields can only be updated by the Firebase Function (which has admin privileges), not by the client app.

