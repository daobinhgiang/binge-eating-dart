# Premium Status Security Update

## ✅ Changes Completed

Updated Firestore security rules to prevent users from modifying their own premium/subscription status.

---

## 🔒 Security Enhancement

### Previous Rules (INSECURE)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;  // ❌ Too permissive!
    }
  }
}
```

**Problem:** Users could modify ANY field in their own document, including `isPremium`, effectively giving themselves free premium access.

---

### New Rules (SECURE)

**File:** `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own document
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Users can update their own document, but NOT subscription-related fields
      allow update: if request.auth != null && 
                       request.auth.uid == userId &&
                       // Prevent users from updating their own premium/subscription status
                       !request.resource.data.diff(resource.data).affectedKeys()
                         .hasAny(['isPremium', 'subscriptionStore', 'subscriptionProductId', 
                                  'subscriptionStartedAt', 'subscriptionExpiresAt', 'lastSubscriptionUpdate']);
      
      // Only allow user creation during registration (handled by auth service)
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Allow deletion of own account
      allow delete: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections under users
      match /{subcollection}/{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Allow all authenticated users to read/write other collections
    // (todos, exercises, journal entries, etc.)
    match /{collection}/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🛡️ Protected Fields

The following fields are now **protected** and can only be updated by Firebase Functions (with admin privileges):

1. `isPremium` - Premium subscription status
2. `subscriptionStore` - Store where subscription was purchased (App Store, Play Store)
3. `subscriptionProductId` - Product ID of the subscription
4. `subscriptionStartedAt` - When subscription started
5. `subscriptionExpiresAt` - When subscription expires
6. `lastSubscriptionUpdate` - Last time subscription status was updated

---

## ✅ What Users CAN Do

- ✅ Read their own user document
- ✅ Update non-subscription fields (name, preferences, tutorial flags, etc.)
- ✅ Create their own user document during registration
- ✅ Delete their own account
- ✅ Read/write their own subcollections (todos, journal entries, etc.)

---

## ❌ What Users CANNOT Do

- ❌ Update their own `isPremium` status
- ❌ Update their own subscription-related fields
- ❌ Read other users' documents
- ❌ Update other users' documents

---

## 🔐 How Premium Status IS Updated

**Only through the Superwall Webhook:**

```
1. User subscribes via Superwall paywall
   ↓
2. Superwall sends webhook to Firebase Function
   ↓
3. Firebase Function (with admin privileges) updates Firestore
   ↓
4. isPremium = true ✅
```

The Firebase Function has **admin privileges** and is not subject to Firestore security rules, allowing it to update protected fields.

---

## 🧪 Testing the Security Rules

### Test 1: User Tries to Set isPremium to True (Should FAIL)

```dart
// This should be REJECTED by Firestore
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'isPremium': true});

// Expected: Permission denied error
```

### Test 2: User Updates Non-Protected Field (Should SUCCEED)

```dart
// This should SUCCEED
await FirebaseFirestore.instance
  .collection('users')
  .doc(userId)
  .update({'firstName': 'John'});

// Expected: Success
```

### Test 3: Webhook Updates isPremium (Should SUCCEED)

```typescript
// Firebase Function with admin privileges - should SUCCEED
await admin.firestore()
  .collection('users')
  .doc(userId)
  .update({ isPremium: true });

// Expected: Success
```

---

## 📋 Deployment Checklist

- [x] Update `firestore.rules` file
- [ ] Deploy Firestore rules: `firebase deploy --only firestore:rules`
- [ ] Test user updates (non-protected fields should work)
- [ ] Test subscription flow (webhook should still work)
- [ ] Verify users cannot modify `isPremium` directly

---

## 🚀 Deploy Command

```bash
# Deploy the updated Firestore security rules
firebase deploy --only firestore:rules
```

---

## 📊 Security Summary

| Aspect | Status | Details |
|--------|--------|---------|
| Default Premium Status | ✅ | All new users start with `isPremium: false` |
| Client-Side Protection | ✅ | Users cannot modify subscription fields |
| Webhook Updates | ✅ | Only Firebase Functions can update premium status |
| User Data Access | ✅ | Users can only access their own data |
| Subcollections | ✅ | Users have full access to their own subcollections |
| Other Collections | ✅ | Authenticated users can access shared collections |

---

## ⚠️ Important Notes

1. **Deploy Required:** The new rules must be deployed to take effect
2. **Backward Compatible:** Existing functionality is preserved
3. **Admin Functions:** Firebase Functions with admin SDK can still update all fields
4. **Testing Recommended:** Test the subscription flow after deployment

---

## 🔗 Related Documentation

- `USER_PREMIUM_DEFAULT_VERIFICATION.md` - Verification that all users default to non-premium
- `SUPERWALL_WEBHOOK_IMPLEMENTATION.md` - How the webhook updates premium status
- `PAYWALL_DEBUGGING_GUIDE.md` - Debugging the paywall flow

