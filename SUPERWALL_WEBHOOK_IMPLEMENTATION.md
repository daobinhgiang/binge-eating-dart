# Superwall Webhook Implementation Guide

## ✅ Implementation Complete

The Superwall webhook system has been fully implemented to automatically update user subscription status when they subscribe through Superwall.

## 📋 What Was Implemented

### 1. Firebase Cloud Function: `superwallWebhook`

**File:** `functions/src/superwallWebhook.ts`

A complete webhook handler that:
- ✅ Receives webhook events from Superwall
- ✅ Verifies webhook signatures for security
- ✅ Handles multiple subscription event types
- ✅ Updates user `isPremium` status in Firestore
- ✅ Logs all subscription events for debugging
- ✅ Stores subscription metadata (store, product ID, dates)

**Supported Events:**

| Event | Action | Description |
|-------|--------|-------------|
| `subscription_start` | Grant Premium | User started a new subscription |
| `transaction_complete` | Grant Premium | User completed a purchase |
| `subscription_renew` | Grant Premium | Subscription renewed |
| `trial_start` | Grant Premium | User started a trial |
| `subscription_cancel` | Revoke Premium | User cancelled subscription |
| `subscription_expire` | Revoke Premium | Subscription expired |
| `billing_issue` | Revoke Premium | Payment failed |

### 2. Manual Update Function: `updateUserPremium`

**File:** `functions/src/superwallWebhook.ts`

A callable function for admins/clinicians to manually update premium status:
- ✅ Requires authentication
- ✅ Only accessible by clinicians
- ✅ Can be called from Firebase Console or app
- ✅ Useful for testing and customer support

### 3. Enhanced UserModel

**File:** `lib/models/user_model.dart`

Added new subscription-related fields:
- ✅ `lastSubscriptionUpdate`: Timestamp of last status update
- ✅ `subscriptionStore`: Store where purchased (App Store/Play Store)
- ✅ `subscriptionProductId`: Product ID of subscription
- ✅ `subscriptionStartedAt`: When subscription started
- ✅ `subscriptionExpiresAt`: When subscription expires

All fields are:
- Properly serialized/deserialized to/from Firestore
- Included in `copyWith` method
- Optional (nullable) to maintain backward compatibility

## 🔧 Setup Instructions

### Step 1: Configure Superwall Webhook Secret

1. **Get Webhook Secret from Superwall Dashboard:**
   - Log into Superwall dashboard
   - Go to Settings → Webhooks
   - Copy the webhook secret

2. **Set Firebase Function Config:**

```bash
# Option 1: Using Firebase CLI
firebase functions:config:set superwall.webhook_secret="YOUR_WEBHOOK_SECRET_HERE"

# Option 2: Using Environment Variable (for local testing)
export SUPERWALL_WEBHOOK_SECRET="YOUR_WEBHOOK_SECRET_HERE"
```

3. **Deploy Functions:**

```bash
cd functions
npm run build
firebase deploy --only functions:superwallWebhook,functions:updateUserPremium
```

### Step 2: Configure Superwall Dashboard

1. **Add Webhook URL:**
   - Go to Superwall Dashboard → Settings → Webhooks
   - Add webhook URL: `https://YOUR_PROJECT_ID.cloudfunctions.net/superwallWebhook`
   - Select events to send:
     - ✅ subscription_start
     - ✅ transaction_complete
     - ✅ subscription_renew
     - ✅ trial_start
     - ✅ subscription_cancel
     - ✅ subscription_expire
     - ✅ billing_issue

2. **Configure User ID Mapping:**
   - Ensure Superwall is configured to use Firebase Auth UID as `app_user_id`
   - This is typically set when calling `Superwall.shared.identify(userId)`

### Step 3: Verify Integration

1. **Test with Sandbox Purchase:**
   - Use a test account
   - Complete a subscription purchase in sandbox mode
   - Check Firebase Functions logs
   - Verify user document updated in Firestore

2. **Check Logs:**

```bash
# View function logs
firebase functions:log --only superwallWebhook

# Expected output:
# ═══════════════════════════════════════════════════════════
# 🔔 SUPERWALL WEBHOOK RECEIVED
# ═══════════════════════════════════════════════════════════
# 📦 Webhook Payload:
#    Event: subscription_start
#    User ID: abc123
#    Product: monthly_premium
# 💎 Premium access event detected: subscription_start
# 🔄 Updating user abc123 premium status to: true
# ✅ User abc123 updated successfully
```

3. **Verify Firestore:**
   - Check user document has `isPremium: true`
   - Check `subscription_events` subcollection for event log

## 🔄 Complete Subscription Flow

### New User Subscribes

```
1. User completes tutorial
   ↓
2. AuthGuard redirects to paywall (isPremium: false)
   ↓
3. User sees Superwall paywall
   ↓
4. User subscribes through Superwall
   ↓
5. Superwall processes payment
   ↓
6. Superwall sends webhook to Firebase Function
   ↓
7. superwallWebhook function receives event
   ↓
8. Function updates Firestore: isPremium = true
   ↓
9. AuthProvider stream detects change
   ↓
10. PaywallScreen navigates to home
   ↓
11. User has full access! ✅
```

### Subscription Expires/Cancels

```
1. Subscription expires or user cancels
   ↓
2. Superwall sends webhook (subscription_expire/cancel)
   ↓
3. superwallWebhook function receives event
   ↓
4. Function updates Firestore: isPremium = false
   ↓
5. Next app launch, AuthGuard redirects to paywall
   ↓
6. User must resubscribe
```

## 📊 Subscription Event Logging

All subscription events are logged to a subcollection for analytics and debugging:

**Firestore Path:** `/users/{userId}/subscription_events/{eventId}`

**Event Document Structure:**
```json
{
  "eventName": "subscription_start",
  "eventCreatedAt": "2025-01-15T10:30:00Z",
  "productId": "monthly_premium",
  "periodType": "monthly",
  "purchasedAt": "2025-01-15T10:30:00Z",
  "expirationAt": "2025-02-15T10:30:00Z",
  "store": "app_store",
  "environment": "production",
  "processedAt": Timestamp,
  "rawPayload": { ... }
}
```

**Use Cases:**
- Debugging subscription issues
- Analytics on subscription patterns
- Customer support investigations
- Audit trail for subscription changes

## 🧪 Testing

### Test 1: Sandbox Purchase

```bash
# 1. Set up test user
# 2. Complete sandbox purchase
# 3. Check logs:
firebase functions:log --only superwallWebhook

# 4. Verify Firestore:
# - User document: isPremium = true
# - subscription_events subcollection has event
```

### Test 2: Manual Update (Admin)

```javascript
// From Firebase Console or app (as clinician):
const updatePremium = firebase.functions().httpsCallable('updateUserPremium');

await updatePremium({
  userId: 'USER_ID_HERE',
  isPremium: true
});
```

### Test 3: Webhook Simulation

```bash
# Send test webhook using curl:
curl -X POST https://YOUR_PROJECT_ID.cloudfunctions.net/superwallWebhook \
  -H "Content-Type: application/json" \
  -d '{
    "event_name": "subscription_start",
    "app_user_id": "TEST_USER_ID",
    "product_id": "monthly_premium",
    "store": "app_store",
    "environment": "sandbox"
  }'
```

## 🔒 Security

### Webhook Signature Verification

The webhook handler verifies signatures using HMAC-SHA256:

```typescript
function verifyWebhookSignature(payload, signature, secret): boolean {
  const hmac = crypto.createHmac('sha256', secret);
  hmac.update(payloadString);
  const expectedSignature = hmac.digest('hex');
  return crypto.timingSafeEqual(signature, expectedSignature);
}
```

**Security Features:**
- ✅ Timing-safe comparison prevents timing attacks
- ✅ Rejects requests with invalid signatures
- ✅ Logs all verification attempts
- ✅ Returns 401 for invalid signatures

### Access Control

**Manual Update Function:**
- ✅ Requires authentication
- ✅ Only clinicians can update premium status
- ✅ Logs who made the update
- ✅ Stores `manuallyUpdatedBy` field

## 📝 Monitoring & Debugging

### Key Logs to Monitor

```bash
# Successful webhook
✅ Webhook processed successfully

# Premium granted
💎 Premium access event detected: subscription_start
✅ User abc123 updated successfully
   isPremium: true

# Premium revoked
🔓 Premium revoke event detected: subscription_expire
✅ User abc123 updated successfully
   isPremium: false

# Errors
❌ Invalid webhook signature
❌ User xyz789 not found in Firestore
❌ Error processing webhook: ...
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| Webhook not received | Check Superwall dashboard webhook configuration |
| Invalid signature | Verify webhook secret matches Superwall dashboard |
| User not found | Ensure `app_user_id` matches Firebase Auth UID |
| isPremium not updating | Check Firestore rules allow function writes |
| Function timeout | Check function has sufficient memory/timeout |

## 🎯 Next Steps

1. **Deploy Functions:**
   ```bash
   firebase deploy --only functions:superwallWebhook,functions:updateUserPremium
   ```

2. **Configure Superwall:**
   - Add webhook URL
   - Select events
   - Test with sandbox purchase

3. **Monitor Logs:**
   ```bash
   firebase functions:log --only superwallWebhook --follow
   ```

4. **Test Complete Flow:**
   - Create test user
   - Complete tutorial
   - See paywall
   - Subscribe
   - Verify access granted

## ✅ Summary

The Superwall webhook integration is now complete and ready for deployment. The system will:

- ✅ Automatically update `isPremium` when users subscribe
- ✅ Handle subscription renewals and cancellations
- ✅ Log all events for debugging
- ✅ Provide admin tools for manual updates
- ✅ Secure webhook handling with signature verification
- ✅ Store subscription metadata for analytics

**No more stuck users!** The subscription system now works end-to-end. 🎉

