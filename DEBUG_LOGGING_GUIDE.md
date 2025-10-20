# Quest System - Comprehensive Debug Logging Guide

## Overview

Extensive logging has been added to the regeneration process. You'll now see detailed console output showing every decision the system makes.

---

## Console Output Examples

### Example 1: First App Open (Generate Quests)

```
═══════════════════════════════════════════════════════════
🔍 REGENERATION CHECK STARTED for userId: VnMAWhzxFuce5EMU1RsavxbLMGI2
═══════════════════════════════════════════════════════════
⏰ Current time: 2025-10-20 10:30:45.123456
💾 Last check time: null
✅ Session cache updated - proceeding with regeneration check

📖 Querying Firestore for last regeneration log...
   Querying regenerationLog collection...
   Query returned 0 document(s)
   ❌ No documents found in regenerationLog
❌ No previous regeneration log found!

🌱 CHECKING SEEDS...
   Checking if seeds need regeneration...
   ❌ No regeneration log exists - REGENERATE SEEDS
Seeds need regeneration? true
🔄 Generating seeds...
      🌱 Starting seed generation...
      Today: 2025-10-20
      Due time (7 PM): 2025-10-20T19:00:00.000000
      🧹 Deleting old incomplete seeds...
      ℹ️  No old seeds to delete
      📋 Selected 3 seed templates
      🏷️  Batch ID: seeds_2025-10-20_1729427445123
      ✏️  Creating task: Complete Today's Food Diary
      ✅ Saved to Firestore: user123_seeds_1729427445456
      ✏️  Creating task: Reflect on Body Image
      ✅ Saved to Firestore: user123_seeds_1729427445789
      ✏️  Creating task: Log Your Weight
      ✅ Saved to Firestore: user123_seeds_1729427446012
      📝 Logging regeneration...
      Log data:
         - seedsDate: 2025-10-20
         - growthWeek: null
         - growthYear: null
         - taskIds: 3 tasks
      ✅ Regeneration log saved to Firestore
✅ Generated 3 seeds
✅ Generated 3 seeds for VnMAWhzxFuce5EMU1RsavxbLMGI2

📈 CHECKING GROWTH TASKS...
   Checking if growth tasks need regeneration...
   ❌ No regeneration log exists - REGENERATE GROWTH TASKS
Growth tasks need regeneration? true
🔄 Generating growth tasks...
      📈 Starting growth task generation...
      Week number: 43, Year: 2025
      🧹 Deleting old incomplete growth tasks...
      ℹ️  No old growth tasks to delete
      📅 Week starts Monday: 2025-10-20T00:00:00.000000
      Due dates: [2025-10-20T19:00:00.000000, 2025-10-22T19:00:00.000000, 2025-10-24T19:00:00.000000]
      📋 Selected 2 growth task templates
      🏷️  Batch ID: growth_w43_2025_1729427447123
      ✏️  Creating task: Complete This Week's Lesson (due: 2025-10-20T19:00:00.000000)
      ✅ Saved to Firestore: user123_growth_1729427447234
      ✏️  Creating task: Problem-Solving Exercise (due: 2025-10-22T19:00:00.000000)
      ✅ Saved to Firestore: user123_growth_1729427447567
      📝 Logging regeneration...
      Log data:
         - seedsDate: null
         - growthWeek: 43
         - growthYear: 2025
         - taskIds: 2 tasks
      ✅ Regeneration log saved to Firestore
✅ Generated 2 growth tasks
✅ Generated 2 growth tasks for VnMAWhzxFuce5EMU1RsavxbLMGI2

🧹 CLEANING UP EXPIRED TASKS...
   ℹ️  No expired tasks to delete

📊 REGENERATION COMPLETE:
   - Total new tasks generated: 5
═══════════════════════════════════════════════════════════
```

### Example 2: Second Open (Same Day - Session Cache Hit)

```
═══════════════════════════════════════════════════════════
🔍 REGENERATION CHECK STARTED for userId: VnMAWhzxFuce5EMU1RsavxbLMGI2
═══════════════════════════════════════════════════════════
⏰ Current time: 2025-10-20 10:35:12.654321
💾 Last check time: 2025-10-20 10:30:45.123456
⏭️  SKIPPING - Already checked 4 minutes ago (< 5 min cooldown)
═══════════════════════════════════════════════════════════
```

### Example 3: Next Day (New Seeds Generated)

```
═══════════════════════════════════════════════════════════
🔍 REGENERATION CHECK STARTED for userId: VnMAWhzxFuce5EMU1RsavxbLMGI2
═══════════════════════════════════════════════════════════
⏰ Current time: 2025-10-21 09:15:30.123456
💾 Last check time: null
✅ Session cache updated - proceeding with regeneration check

📖 Querying Firestore for last regeneration log...
   Querying regenerationLog collection...
   Query returned 1 document(s)
   ✅ Found regeneration log
✅ Found regeneration log:
   - regeneratedAt: 2025-10-20 10:32:15.654321
   - seedsDate: 2025-10-20
   - growthWeek: 43
   - growthYear: 2025

🌱 CHECKING SEEDS...
   Checking if seeds need regeneration...
   📅 Comparing dates:
      Last seeds generated: 2025-10-20 (2025-10-20T00:00:00.000000)
      Today: 2025-10-21
      Last date only: 2025-10-20 00:00:00.000000
      Today only: 2025-10-21 00:00:00.000000
      Same day? false
   ❌ Needs regeneration: true
Seeds need regeneration? true
🔄 Generating seeds...
      🌱 Starting seed generation...
      Today: 2025-10-21
      Due time (7 PM): 2025-10-21T19:00:00.000000
      🧹 Deleting old incomplete seeds...
         🗑️  Deleted old seed: "Complete Today's Food Diary" (ID: user123_seeds_1729427445456)
         🗑️  Deleted old seed: "Reflect on Body Image" (ID: user123_seeds_1729427445789)
         🗑️  Deleted old seed: "Log Your Weight" (ID: user123_seeds_1729427446012)
         ✅ Deleted 3 old seeds
      📋 Selected 3 seed templates
      🏷️  Batch ID: seeds_2025-10-21_1729513730123
      ✏️  Creating task: Practice a Coping Strategy
      ✅ Saved to Firestore: user123_seeds_1729513730456
      ✏️  Creating task: Mindfulness Exercise
      ✅ Saved to Firestore: user123_seeds_1729513730789
      ✏️  Creating task: Complete Today's Food Diary
      ✅ Saved to Firestore: user123_seeds_1729513731012
      📝 Logging regeneration...
      Log data:
         - seedsDate: 2025-10-21
         - growthWeek: null
         - growthYear: null
         - taskIds: 3 tasks
      ✅ Regeneration log saved to Firestore
✅ Generated 3 seeds
✅ Generated 3 seeds for VnMAWhzxFuce5EMU1RsavxbLMGI2

📈 CHECKING GROWTH TASKS...
   Checking if growth tasks need regeneration...
   📅 Comparing weeks:
      Last growth week: 43 (year: 2025)
      Current week: 43 (year: 2025)
      Week match? true
      Year match? true
   ✅ Needs regeneration: false
Growth tasks need regeneration? false
⏭️  Skipping growth tasks - already generated this week

🧹 CLEANING UP EXPIRED TASKS...
   ℹ️  No expired tasks to delete

📊 REGENERATION COMPLETE:
   - Total new tasks generated: 3
═══════════════════════════════════════════════════════════
```

### Example 4: Error Case - Date Parsing Issue

```
═══════════════════════════════════════════════════════════
🔍 REGENERATION CHECK STARTED for userId: VnMAWhzxFuce5EMU1RsavxbLMGI2
═══════════════════════════════════════════════════════════
⏰ Current time: 2025-10-21 09:15:30.123456
💾 Last check time: null

📖 Querying Firestore for last regeneration log...
   Querying regenerationLog collection...
   Query returned 1 document(s)
   ✅ Found regeneration log
✅ Found regeneration log:
   - regeneratedAt: 2025-10-20 10:32:15.654321
   - seedsDate: CORRUPTED_DATE_STRING
   - growthWeek: 43
   - growthYear: 2025

🌱 CHECKING SEEDS...
   Checking if seeds need regeneration...
   📅 Comparing dates:
      Last seeds generated: CORRUPTED_DATE_STRING
   ❌ Error parsing date: Invalid date format - REGENERATE SEEDS
   ❌ Needs regeneration: true
Seeds need regeneration? true
🔄 Generating seeds...
      [... seeds generated as fallback ...]
```

---

## What Each Symbol Means

| Symbol | Meaning |
|--------|---------|
| 🔍 | Starting a check or query |
| ⏰ | Time-related information |
| 💾 | Cache or stored data |
| ✅ | Action successful or condition met |
| ❌ | Problem found or condition not met |
| ⏭️ | Skipping an action |
| 🔄 | Generating or processing |
| 📖 | Reading from database |
| 🌱 | Seed-related operation |
| 📈 | Growth task-related operation |
| 📅 | Date comparison |
| 🧹 | Cleanup operation |
| 🗑️ | Deleting something |
| ℹ️ | Informational message |
| 📋 | Template/list information |
| 🏷️ | ID or batch ID |
| ✏️ | Creating something |
| 📝 | Logging |
| 📊 | Summary/statistics |
| 🔴 | Error |

---

## How to Debug Issues

### Issue: Quests generating when they shouldn't

**Check the date comparison lines:**
```
📅 Comparing dates:
   Last seeds generated: 2025-10-20 (2025-10-20T00:00:00.000000)
   Today: 2025-10-21
   Last date only: 2025-10-20 00:00:00.000000
   Today only: 2025-10-21 00:00:00.000000
   Same day? false  ← Should be true if same day!
   ❌ Needs regeneration: true
```

**Things to check:**
- Are the dates being parsed correctly?
- Is "Last date only" matching "Today only"?
- Is the same-day check returning the right value?

### Issue: Old quests not being deleted

**Check the cleanup lines:**
```
🧹 Deleting old incomplete seeds...
   🗑️  Deleted old seed: "Complete Today's Food Diary" (ID: ...)
   ✅ Deleted 3 old seeds
```

**Things to check:**
- Are old seeds being found and deleted?
- Count: Is it deleting the right number?
- Are completed quests being preserved (not in delete list)?

### Issue: Session cache not working

**Check the first lines:**
```
💾 Last check time: 2025-10-20 10:30:45.123456
⏭️  SKIPPING - Already checked 4 minutes ago (< 5 min cooldown)
```

**Should see:**
- Last check time should be recent
- Should say "SKIPPING" if checked within 5 minutes
- Minutes ago should be < 5

### Issue: Firestore not returning data

**Check these lines:**
```
📖 Querying Firestore for last regeneration log...
   Querying regenerationLog collection...
   Query returned 0 document(s)
   ❌ No documents found in regenerationLog
```

**Check:**
- Is query returning documents?
- Do you have write permissions to `regenerationLog` collection?
- Is data actually being saved?

---

## Test Cases & Expected Output

### Test 1: First Open
**Expected Output:**
```
❌ No previous regeneration log found!
❌ No regeneration log exists - REGENERATE SEEDS
❌ No regeneration log exists - REGENERATE GROWTH TASKS
Generated 3 seeds
Generated 2 growth tasks
Total new tasks generated: 5
```

### Test 2: Second Open (Same Day, Within 5 Min)
**Expected Output:**
```
⏭️  SKIPPING - Already checked X minutes ago
```
No regeneration should happen.

### Test 3: New Day
**Expected Output:**
```
📅 Comparing dates:
   Last seeds generated: YESTERDAY
   Today: TODAY
   Same day? false
❌ Needs regeneration: true
🗑️  Deleted old seed: ...
Generated 3 seeds
```

### Test 4: Same Week (Growth Tasks)
**Expected Output:**
```
📅 Comparing weeks:
   Last growth week: 43 (year: 2025)
   Current week: 43 (year: 2025)
   Week match? true
   Year match? true
✅ Needs regeneration: false
⏭️  Skipping growth tasks
```

---

## Tips for Debugging

1. **Copy/paste console output** to see full trace
2. **Look for the date comparisons** - they tell you what's happening
3. **Check deleted count** - should show how many old quests were removed
4. **Verify IDs** - check if Firebase is actually saving/deleting
5. **Check for errors** - Red ❌ symbols indicate problems

---

## Common Issues & Solutions

### "No documents found in regenerationLog"
- **Cause**: First run, no logs yet
- **Expected**: System regenerates automatically
- **Solution**: None needed, this is normal on first run

### "Query returned 0 documents"
- **Cause**: Firestore query failed or has permission issue
- **Check**: 
  - Firestore rules allow read from `regenerationLog`
  - Collection path is correct: `users/{userId}/regenerationLog`
  - User is authenticated

### "Deleted 0 old seeds" but still has stacking
- **Cause**: Quests might not have `isSeed` property set correctly
- **Check**: Verify `tier` field is being set correctly
- **Debug**: Check if `todo.isSeed` is returning true

### "Same day? true" but still regenerating
- **Cause**: Error occurred, falling back to regenerate
- **Check**: Look for error messages above the date comparison
- **Solution**: Check console for specific error

---

**All logging added and ready for debugging!** 🚀
