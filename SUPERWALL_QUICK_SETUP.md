# Superwall Webhook - Quick Setup Guide

## 🚀 Quick Start (5 Minutes)

### Step 1: Set Webhook Secret

```bash
# Get secret from Superwall Dashboard → Settings → Webhooks
firebase functions:config:set superwall.webhook_secret="YOUR_SECRET_HERE"
```

### Step 2: Deploy Functions

```bash
cd functions
npm run build
firebase deploy --only functions:superwallWebhook,functions:updateUserPremium
```

### Step 3: Configure Superwall Dashboard

1. Go to Superwall Dashboard → Settings → Webhooks
2. Add webhook URL: `https://YOUR_PROJECT_ID.cloudfunctions.net/superwallWebhook`
3. Select events:
   - subscription_start
   - transaction_complete
   - subscription_renew
   - subscription_cancel
   - subscription_expire

### Step 4: Test

```bash
# Make a sandbox purchase and check logs:
firebase functions:log --only superwallWebhook --follow
```

## ✅ That's It!

Your subscription system is now fully functional. Users who subscribe through Superwall will automatically get `isPremium: true` in Firestore.

## 📊 What Happens Now

```
User Subscribes → Superwall Webhook → Firebase Function → isPremium = true → User Gets Access
```

## 🔍 Verify It's Working

1. **Check Firestore:** User document should have `isPremium: true`
2. **Check Logs:** Should see "✅ User updated successfully"
3. **Check App:** User should bypass paywall on next launch

## 🆘 Need Help?

See `SUPERWALL_WEBHOOK_IMPLEMENTATION.md` for complete documentation.

## 🧪 Manual Testing

```javascript
// Call from Firebase Console (as clinician):
const updatePremium = firebase.functions().httpsCallable('updateUserPremium');
await updatePremium({ userId: 'USER_ID', isPremium: true });
```

