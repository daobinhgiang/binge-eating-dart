# Journal Entry EXP - Deployment Guide

## Overview
This guide walks you through deploying the new `awardJournalEntryExp` Cloud Function to Firebase.

## Prerequisites
Before deploying, ensure you have:
- ✅ Firebase CLI installed (`npm install -g firebase-tools`)
- ✅ Node.js installed (v14 or higher)
- ✅ Logged into Firebase (`firebase login`)
- ✅ The correct Firebase project selected (`firebase use [project-id]`)

## Step 1: Build the TypeScript Functions

The Cloud Functions are written in TypeScript and need to be compiled to JavaScript before deployment.

### Option A: Using npm (Recommended)

```bash
cd functions
npm install
npm run build
```

This will:
1. Install dependencies (firebase-functions, firebase-admin, typescript)
2. Compile all TypeScript files in `src/` to JavaScript in `lib/`
3. Generate JavaScript source maps for debugging

### Option B: Manual TypeScript Compilation

```bash
cd functions
npx tsc
```

## Step 2: Verify Compilation

Check that the TypeScript compiled successfully:

```bash
ls -la lib/awardJournalEntryExp.js
```

You should see:
- `lib/awardJournalEntryExp.js` - Compiled function
- `lib/awardJournalEntryExp.js.map` - Source map for debugging
- `lib/index.js` - Main exports file

## Step 3: Deploy to Firebase

### Option A: Deploy Only Journal Entry Function

```bash
firebase deploy --only functions:awardJournalEntryExp
```

### Option B: Deploy All Functions

```bash
firebase deploy --only functions
```

This will also deploy the existing `validateQuiz` function and all notification functions.

## Step 4: Monitor Deployment

Watch the console output:

```
✔ functions[awardJournalEntryExp] Successful create operation.
Function URL: https://us-central1-[PROJECT].cloudfunctions.net/awardJournalEntryExp
```

The function is now live! ✅

## Step 5: Verify Deployment

Check in Firebase Console:
1. Go to https://console.firebase.google.com/
2. Select your project
3. Go to **Functions** section
4. You should see `awardJournalEntryExp` listed
5. Status should show as **Enabled** ✅

## Step 6: Monitor Logs

Watch the function logs in real-time:

```bash
firebase functions:log --follow
```

Or in Firebase Console:
1. Functions → Select `awardJournalEntryExp`
2. Go to **Logs** tab
3. Watch logs in real-time

## Testing

Once deployed, test by:

1. **Submit a Food Diary Entry**
   - App → Journal → Food Diary
   - Fill out form and submit
   - Check Firebase Logs for output like:
     ```
     🎯 JOURNAL ENTRY EXP AWARD FUNCTION TRIGGERED
     📍 Path: users/{userId}/weeks/week_1/foodDiaries/{entryId}
     👤 User ID: {userId}
     ...
     ✨ SUCCESS: Journal entry processed!
     ```

2. **Check User Document**
   - Go to Firebase Console → Firestore
   - Find your user document in `users` collection
   - Verify `exp` increased by 5
   - Verify level changed if applicable

3. **Check EXP Ledger**
   - Go to `exp_ledger` collection
   - Look for newest entry with:
     - `entryType`: "food_diary" (or other type)
     - `expAwarded`: 5
     - `userId`: Your user ID

## Troubleshooting

### Function not triggering?

**Check 1: Is the function deployed?**
```bash
firebase functions:list
```

Should show `awardJournalEntryExp` as "Enabled"

**Check 2: Are entries being created correctly?**
- In Firestore, navigate to: `users/{userId}/weeks/week_1/foodDiaries`
- You should see documents being created

**Check 3: Check the logs**
```bash
firebase functions:log
```

Look for:
- ✅ "🎯 JOURNAL ENTRY EXP AWARD FUNCTION TRIGGERED" - Function triggered
- ⚠️ "⚠️ SKIPPING: Invalid diary type" - Wrong collection path
- ❌ "❌ ERROR in journal entry processing" - Something went wrong

### Function triggered but no EXP awarded?

**Common Issues:**

1. **User document not found**
   ```
   ❌ User {userId} not found in users collection
   ```
   → Check that user document exists in `users` collection

2. **Diary type not recognized**
   ```
   ⚠️ SKIPPING: Invalid diary type "wrongType"
   ```
   → Entry was created in wrong location
   → Check the collection name matches exactly: `foodDiaries`, `weightDiaries`, `bodyImageDiaries`, `moneyDiaries`

3. **Firestore security rules blocking writes**
   ```
   ❌ ERROR: Missing or insufficient permissions
   ```
   → Update Firestore rules to allow Cloud Functions to write to `exp_ledger`
   → See Security Rules section below

### Firestore Security Rules

Make sure your rules allow the Cloud Function to write to `exp_ledger`:

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Allow Cloud Functions (no auth) to write to exp_ledger
    match /exp_ledger/{document=**} {
      allow write: if request.auth == null;
    }
  }
}
```

Then deploy rules:
```bash
firebase deploy --only firestore:rules
```

## Monitoring Production

### Real-time Logs
```bash
firebase functions:log --follow
```

### Check EXP Distribution
Query in Firebase Console:
```javascript
// Query: Show top 10 users with most EXP this week
db.collection("exp_ledger")
  .where("createdAt", ">=", lastWeekDate)
  .orderBy("createdAt", "desc")
  .limit(10)
```

### Common Log Patterns

**Successful Journal Entry:**
```
═══════════════════════════════════════════════════════════
🎯 JOURNAL ENTRY EXP AWARD FUNCTION TRIGGERED
═══════════════════════════════════════════════════════════
📍 Path: users/abc123/weeks/week_1/foodDiaries/entry456
👤 User ID: abc123
📅 Week: week_1
📔 Diary Type: foodDiaries
📝 Entry ID: entry456
⏰ Trigger Time: 2024-10-19T10:30:00.000Z

🔍 VALIDATION STEP
✅ Diary type is valid, proceeding...

💳 STARTING FIRESTORE TRANSACTION
📖 Step 1: Reading user document...
✅ User found!
   Current Level: 1
   Current EXP: 0

🔢 Step 2: Calculating new level...
   Old EXP: 0
   + Award: 5
   = New EXP: 5
   Old Level: 1
   New Level: 1
   Level Up: No

📝 Step 3: Updating user document...
✅ User document queued for update

📋 Step 4: Creating EXP ledger entry...
✅ Ledger entry queued for creation

✓ Journal entry EXP awarded: User abc123: +5 EXP, Level 1 → 1

⏱️ Transaction completed successfully in 234ms

✨ SUCCESS: Journal entry entry456 processed!
═══════════════════════════════════════════════════════════
```

## Rollback

If you need to disable the function:

```bash
# Option 1: Delete from index.ts and redeploy
# Remove: export { awardJournalEntryExp } from './awardJournalEntryExp';
# Then run:
firebase deploy --only functions

# Option 2: Delete function directly
firebase functions:delete awardJournalEntryExp
```

## Common Commands Reference

```bash
# Install dependencies
cd functions && npm install

# Build TypeScript
npm run build

# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:awardJournalEntryExp

# View logs live
firebase functions:log --follow

# View specific function logs
firebase functions:log --only awardJournalEntryExp

# List all deployed functions
firebase functions:list

# Delete a function
firebase functions:delete awardJournalEntryExp
```

## Next Steps

After successful deployment:
1. ✅ Test with one entry submission
2. ✅ Verify logs show success
3. ✅ Check Firebase Console for updated EXP/Level
4. ✅ Have users test submitting various diary entries
5. ✅ Monitor logs for errors or patterns

Done! 🎉
