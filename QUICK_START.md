# Journal Entry EXP System - Quick Start

## TL;DR - Get it deployed in 5 minutes

### Step 1: Build (2 minutes)
```bash
cd functions
npm install
npm run build
```

### Step 2: Deploy (2 minutes)
```bash
firebase deploy --only functions:awardJournalEntryExp
```

### Step 3: Test (1 minute)
```bash
# Watch logs in real-time
firebase functions:log --follow

# In another terminal, submit a diary entry in your app
# Watch the logs show: ✨ SUCCESS: Journal entry processed!
```

Done! 🎉

---

## What was implemented?

✅ Users now get **5 EXP** for each journal entry submitted
- Food Diary: +5 EXP
- Weight Diary: +5 EXP
- Body Image Diary: +5 EXP
- Money/Spending Diary: +5 EXP

## Deployment Status

| Component | Status | Action |
|-----------|--------|--------|
| Code (TypeScript) | ✅ Complete | In `functions/src/awardJournalEntryExp.ts` |
| Model (Dart) | ✅ Complete | Updated `lib/models/exp_ledger.dart` |
| Logging | ✅ Complete | Full tracking with emojis 📊 |
| **Compilation** | ⏳ Pending | Run `npm run build` in functions/ |
| **Deployment** | ⏳ Pending | Run `firebase deploy --only functions` |
| Testing | ⏳ Pending | Submit entries and check logs |

## What happens when deployed?

When a user submits a diary entry:

```
1. Entry created in Firestore
   ↓
2. Cloud Function triggers automatically
   ↓
3. Logs show detailed progress (see all 4 steps)
   ↓
4. User EXP increases by 5
   ↓
5. Level updates if threshold reached
   ↓
6. Entry logged in exp_ledger collection
```

## Real-time Logs Preview

When you run the function, you'll see logs like:

```
═══════════════════════════════════════════════════════════
🎯 JOURNAL ENTRY EXP AWARD FUNCTION TRIGGERED
═══════════════════════════════════════════════════════════
📍 Path: users/abc123/weeks/week_1/foodDiaries/xyz789
👤 User ID: abc123
📔 Diary Type: foodDiaries

📖 Step 1: Reading user document...
✅ User found!
   Current Level: 2
   Current EXP: 55

🔢 Step 2: Calculating new level...
   Old EXP: 55 + Award: 5 = New EXP: 60
   Level: 2 → 2

📝 Step 3: Updating user document...
✅ User document queued for update

📋 Step 4: Creating EXP ledger entry...
✅ Ledger entry queued for creation

⏱️ Transaction completed successfully in 234ms
✨ SUCCESS: Journal entry xyz789 processed!
═══════════════════════════════════════════════════════════
```

## Files Modified/Created

```
Modified:
  • lib/models/exp_ledger.dart (supports both quizzes and journal entries)
  • functions/src/index.ts (exported new function)

Created:
  • functions/src/awardJournalEntryExp.ts (new Cloud Function with logging)
  • DEPLOYMENT_GUIDE.md (detailed deployment steps)
  • JOURNAL_EXP_SYSTEM.md (complete system documentation)
  • IMPLEMENTATION_SUMMARY.md (technical summary)
  • QUICK_START.md (this file)
```

## Troubleshooting

### "Function not found after deploying"
→ Make sure you ran `npm run build` before deploying
→ Check that `lib/awardJournalEntryExp.js` was created

### "Logs show 'SKIPPING: Invalid diary type'"
→ The diary type name doesn't match exactly
→ Must be: `foodDiaries`, `weightDiaries`, `bodyImageDiaries`, or `moneyDiaries`

### "User not found error"
→ Make sure the user document exists in the `users` collection
→ Check the user ID is correct

### "No logs appearing"
→ Run `firebase functions:log --follow` in a separate terminal
→ Make sure you're submitting diary entries (they should appear as logs)
→ Check that the function is deployed: `firebase functions:list`

## What's Next?

- [ ] Compile: `cd functions && npm run build`
- [ ] Deploy: `firebase deploy --only functions:awardJournalEntryExp`
- [ ] Watch logs: `firebase functions:log --follow`
- [ ] Test: Submit a diary entry in the app
- [ ] Verify: Check logs for success message and check Firestore for updated EXP

Questions? See `DEPLOYMENT_GUIDE.md` for detailed instructions.
