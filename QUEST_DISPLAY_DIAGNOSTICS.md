# Quest Display Diagnostics

## Issue: Quests/Todos Not Visible on Home Screen

### Possible Causes

1. **No Quests for Today**
   - The `_buildDailyQuestsWidget()` method only shows quests if there are todos due today
   - Check: Do you have any todos with `dueDate` set to today?
   - If not: Create a todo via the `/todos` screen or `/todos/add` route

2. **User Not Authenticated**
   - Quests only show for authenticated users
   - The `_buildTodoSection()` checks `authState.when(data: (user) {...})`
   - Check: Are you logged in? (Should see your profile icon)

3. **Data Loading Issue**
   - Todos might be loading but not displaying
   - The UI shows `_buildTodoLoadingCard()` while loading
   - Check: Do you see "Loading your quests..." message?

4. **Route Not Accessible**
   - The `/todos` route is defined and should work
   - It's wrapped in `AuthGuard` so you must be authenticated
   - Check: Can you navigate directly to `/todos` from the app?

### Debugging Steps

#### Step 1: Check if Todos Exist
- Go to `/todos` directly (press the "See All" button or navigate to `/todos`)
- Are any todos showing there?

#### Step 2: Check User Authentication
- Look for profile icon/level badge on the home screen
- If not visible, you're not authenticated

#### Step 3: Check for Today's Quests
- Manually create a todo from the `/todos/add` screen
- Set the due date to TODAY
- Return to home screen
- The quest should now appear

#### Step 4: Check Browser Console/Logs
- Open Developer Tools
- Check JavaScript Console for errors
- Check Dart VM service logs for errors

### Code Flow

The Daily Quests section renders through this sequence:

```
HomeScreen
  ↓
_buildAuthenticatedContent()
  ↓
_buildTodoSection()  <- Consumer widget that watches todoProvider
  ↓
ref.watch(userTodosProvider(user.id))  <- Fetches todos from Firestore
  ↓
_buildDailyQuestsWidget()
  ↓
_buildDailyQuestItem() for each todo due today
  ↓
_buildQuestProgressBar()  <- NEW: Displays progress bar
```

### Data Requirements

For quests to display:
1. User must be authenticated
2. User must have todos in Firestore
3. At least one todo must have `dueDate` = today
4. TodoItem must parse correctly from Firestore

### Testing Checklist

- [ ] Logged in as a user
- [ ] User has at least one todo
- [ ] That todo has `dueDate` set to today
- [ ] Can see "Daily Quests" header on home screen
- [ ] Can see at least one quest item below the header
- [ ] Progress bar displays below the quest title
- [ ] Can see percentage or counter in the progress bar
- [ ] Can click the quest to navigate
- [ ] Can toggle checkbox to mark complete

### Common Issues

**Issue: "Daily Quests" header visible but no quests below**
- Solution: Create a quest for today via `/todos/add`

**Issue: No "Daily Quests" section at all**
- Solution: Make sure you're authenticated (check for profile icon)
- Or: Create a quest for today

**Issue: Progress bar not showing**
- Solution: Check browser console for errors
- Ensure `ActivityData` is populated in the TodoItem
- Verify no runtime exceptions

**Issue: Progress bar showing but no text**
- Solution: May be a rendering issue, try hot reload
- Check that ProgressType enum is properly defined

### Manual Testing

```dart
// Create a test quest manually in Firebase Console
{
  "title": "Test Quest",
  "type": "lesson",
  "dueDate": Timestamp.now(),  // Today
  "activityData": {
    "duration": 5  // 5 minutes of 15 minute lesson
  },
  "isCompleted": false
}
```

This should display as: `5/15 min` on the progress bar
