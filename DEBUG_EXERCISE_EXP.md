# Debugging Exercise EXP Not Working

## Issue
User completed exercises but EXP is not increasing.

## Deployed Functions Status
✅ `awardExerciseExp` - DEPLOYED and ACTIVE
✅ `awardMealPlanUpdateExp` - DEPLOYED and ACTIVE

## Possible Causes

### 1. Function Not Triggering
**Symptom**: No logs appearing in Firebase Console
**Possible reasons**:
- Firestore trigger path mismatch
- Document not actually being created
- Function deployment issue

**How to verify**:
```bash
# Watch logs in real-time
firebase functions:log --follow

# Then complete an exercise and watch for logs
```

### 2. Firestore Path Mismatch
**Expected path**: `users/{userId}/exercises/{exerciseType}/exercises/{exerciseId}`

**Valid exercise types in code**:
- `problemSolving`
- `urgeSurfing`
- `addressingSetbacks`
- `addressingOverconcern`
- `mealPlan`

**How to verify**:
1. Open Firebase Console → Firestore Database
2. Navigate to `users/{your-user-id}/exercises`
3. Check the actual collection names
4. They should match exactly (case-sensitive!)

### 3. Document Creation vs Update
**Important**: The function only triggers on `.onCreate()` (new documents)
- If you're updating an existing exercise, it won't trigger
- Exception: Meal plan updates trigger a separate function

**How to verify**:
- Create a NEW exercise (don't update existing)
- Check if logs appear

### 4. Security Rules Blocking
**Possible issue**: Firestore security rules might block Cloud Functions

**How to verify**:
Check `firestore.rules` for:
```javascript
// Allow Cloud Functions to write to exp_ledger
match /exp_ledger/{document=**} {
  allow write: if request.auth == null;
}

// Allow Cloud Functions to read user documents
match /users/{userId} {
  allow read: if true; // Or allow read by Cloud Functions
  allow write: if request.auth.uid == userId;
}
```

## Debugging Steps

### Step 1: Verify Functions Are Deployed
```bash
firebase functions:list | grep award
```

Expected output:
```
awardExerciseExp        ... ENABLED
awardMealPlanUpdateExp  ... ENABLED
awardJournalEntryExp    ... ENABLED
```

### Step 2: Check Firestore Console
1. Go to Firebase Console → Firestore Database
2. Navigate to: `users/{your-user-id}/exercises`
3. Look for subdocuments like:
   - `problemSolving/exercises/{id}` ✅
   - `urgeSurfing/exercises/{id}` ✅
   - `mealPlan/exercises/{id}` ✅
   - etc.

4. Verify the collection names match EXACTLY (case-sensitive)

### Step 3: Watch Logs Live
```bash
# Terminal 1: Start log watcher
firebase functions:log --follow

# Terminal 2: Complete a NEW exercise (not update)
# App → Tools → Problem Solving → Complete → Submit
# Watch Terminal 1 for logs
```

### Step 4: Check for Errors in Logs
Look for:
- ✅ `🏋️ EXERCISE EXP AWARD FUNCTION TRIGGERED` - Function triggered
- ⚠️ `⚠️ SKIPPING: Invalid exercise type` - Wrong type name
- ❌ `❌ ERROR` - Something went wrong

### Step 5: Verify Document Creation
After completing an exercise:
1. Check Firestore Console
2. Go to the exercises collection
3. Verify a new document was created
4. Check the timestamp - should be recent

### Step 6: Manual Trigger Test
Create a test document manually in Firestore:
1. Go to Firestore Console
2. Navigate to: `users/{your-user-id}/exercises/problemSolving/exercises`
3. Add a new document manually with any data
4. Check if function triggers (watch logs)

## Common Issues & Solutions

### Issue 1: "No logs appearing"
**Solution**: 
- Make sure you're creating a NEW exercise (not updating)
- Check that the collection path matches exactly
- Verify function is deployed: `firebase functions:list`

### Issue 2: "Logs show 'SKIPPING: Invalid exercise type'"
**Solution**:
- Check the Firestore path in console
- The collection name must match exactly (case-sensitive)
- Valid names: `problemSolving`, `urgeSurfing`, `addressingSetbacks`, `addressingOverconcern`, `mealPlan`

### Issue 3: "Function triggers but EXP doesn't increase"
**Solution**:
- Check user document in Firestore
- Look for errors in logs
- Verify Firestore rules allow writes to exp_ledger

### Issue 4: "TypeError or undefined errors"
**Solution**:
- Rebuild functions: `cd functions && npm run build`
- Redeploy: `firebase deploy --only functions`

## Quick Fix Checklist

- [ ] Functions are deployed (`firebase functions:list`)
- [ ] Firestore paths match exactly
- [ ] Creating NEW exercises (not updating old ones)
- [ ] Logs show function triggered
- [ ] User document exists in Firestore
- [ ] Firestore rules allow Cloud Functions to write
- [ ] No errors in Firebase logs

## Next Steps

1. **Start log watcher**: `firebase functions:log --follow`
2. **Complete a NEW exercise** in the app
3. **Watch for logs** - should see detailed output
4. **Check Firestore** - verify exp_ledger entry created
5. **Verify user EXP** - check users collection

If still not working, share:
- Screenshot of Firestore collection structure
- Any error messages from logs
- Which exercise you're trying to complete

