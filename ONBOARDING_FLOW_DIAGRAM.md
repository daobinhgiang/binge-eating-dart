# Onboarding Flow Diagram

## User Journey Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         NEW USER SIGNUP                          │
│                    (Email/Google/Apple Auth)                     │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  hasSeenIntro?  │
                    └────────┬────────┘
                             │
                   ┌─────────┴─────────┐
                   │                   │
                  NO                  YES
                   │                   │
                   ▼                   │
          ┌─────────────────┐          │
          │  INTRO SCREEN   │          │
          │   (5 Pages)     │          │
          └────────┬────────┘          │
                   │                   │
           [Complete/Skip]             │
                   │                   │
                   ▼                   │
          ┌─────────────────┐          │
          │ hasSeenIntro =  │          │
          │      true       │          │
          └────────┬────────┘          │
                   │                   │
                   └─────────┬─────────┘
                             │
                             ▼
              ┌──────────────────────────┐
              │  onboardingCompleted OR  │
              │ onboardingPartially...?  │
              └────────┬─────────────────┘
                       │
              ┌────────┴────────┐
              │                 │
             NO                YES
              │                 │
              ▼                 │
     ┌─────────────────┐        │
     │  ONBOARDING     │        │
     │  QUESTIONNAIRE  │        │
     │   (16 Qs)       │        │
     └────────┬────────┘        │
              │                 │
    ┌─────────┴─────────┐       │
    │                   │       │
First 4 Qs          All 16 Qs   │
Complete            Complete    │
    │                   │       │
    ▼                   ▼       │
┌────────┐         ┌────────┐   │
│Partial │         │ Full   │   │
│  flag  │         │  flag  │   │
└───┬────┘         └───┬────┘   │
    │                  │        │
    └──────────┬───────┘        │
               │                │
               └────────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │   MAIN APP    │
                │  (Full Access)│
                └───────────────┘
```

## Introduction Screen Pages

### Page 1: Welcome to Nurtra
```
╔════════════════════════════════════╗
║                                    ║
║         [Nurtra Logo Image]        ║
║                                    ║
║      Welcome to Nurtra             ║
║                                    ║
║  Your compassionate companion in   ║
║  understanding and overcoming      ║
║  binge eating. We're here to       ║
║  support you every step of the     ║
║  way on your journey to a          ║
║  healthier relationship with food. ║
║                                    ║
║         ● ○ ○ ○ ○                 ║
║                                    ║
║    [Skip]           [→]            ║
╚════════════════════════════════════╝
```

### Page 2: Education Feature
```
╔════════════════════════════════════╗
║                                    ║
║      [Education Stage Image]       ║
║                                    ║
║      Learn and Understand          ║
║                                    ║
║  Our comprehensive education       ║
║  modules help you understand       ║
║  binge eating disorder. Discover   ║
║  evidence-based insights, expert   ║
║  guidance, and learn proven        ║
║  methods to manage your eating     ║
║  patterns.                         ║
║                                    ║
║         ○ ● ○ ○ ○                 ║
║                                    ║
║    [Skip]           [→]            ║
╚════════════════════════════════════╝
```

### Page 3: Journal & Tools
```
╔════════════════════════════════════╗
║                                    ║
║      [Food Diary Image]            ║
║                                    ║
║  Your Personal Journey Partner     ║
║                                    ║
║  Nurtra isn't just an app—it's a   ║
║  friend, a partner that stands by  ║
║  you throughout your journey.      ║
║  Track your progress with our      ║
║  journal, and use our practical    ║
║  tools to support you in real-time ║
║  whenever you need it.             ║
║                                    ║
║         ○ ○ ● ○ ○                 ║
║                                    ║
║    [Skip]           [→]            ║
╚════════════════════════════════════╝
```

### Page 4: Supportive Message
```
╔════════════════════════════════════╗
║                                    ║
║           [Heart Icon]             ║
║                                    ║
║       You're Not Alone             ║
║                                    ║
║  We want you to know that we're    ║
║  always by your side in this       ║
║  journey. Every step forward, no   ║
║  matter how small, is a victory    ║
║  worth celebrating. You have the   ║
║  strength within you, and we're    ║
║  here to help you find it.         ║
║                                    ║
║         ○ ○ ○ ● ○                 ║
║                                    ║
║    [Skip]           [→]            ║
╚════════════════════════════════════╝
```

### Page 5: Ready to Begin
```
╔════════════════════════════════════╗
║                                    ║
║         [Rocket Icon]              ║
║                                    ║
║    Ready to Start Your Journey?    ║
║                                    ║
║  Let's get to know you better so   ║
║  we can personalize your           ║
║  experience. This quick            ║
║  assessment will help us           ║
║  understand your needs and         ║
║  provide the best support for you. ║
║                                    ║
║  Estimated time: 5 minutes         ║
║                                    ║
║         ○ ○ ○ ○ ●                 ║
║                                    ║
║    [Skip]      [Get Started]       ║
╚════════════════════════════════════╝
```

## Database Fields

### User Model
```typescript
{
  id: string,
  email: string,
  firstName: string,
  lastName: string,
  role: UserRole,
  createdAt: DateTime,
  lastLoginAt: DateTime?,
  photoUrl: string?,
  fcmToken: string?,
  preferences: Map<String, dynamic>,
  
  // Onboarding tracking fields
  hasSeenIntro: bool,                    // ← NEW: Tracks intro completion
  onboardingCompleted: bool,             // ← EXISTING: Full onboarding
  onboardingPartiallyCompleted: bool,    // ← EXISTING: Partial (4 Qs)
  
  level: int,
  exp: int
}
```

## Navigation Routes

```
/login              → Login Screen
/register           → Registration Screen
/intro              → Introduction Screen (NEW)
/onboarding         → Onboarding Questionnaire
/onboarding/review  → Review/Update Answers
/                   → Main App (Home)
```

## Key Interactions

### Skip Button Behavior
- Available on all 5 intro pages
- Immediately marks `hasSeenIntro = true`
- Navigates directly to `/onboarding`

### Get Started Button Behavior
- Only on Page 5 (final page)
- Marks `hasSeenIntro = true`
- Navigates to `/onboarding`

### Back Navigation
- Standard back button on pages 2-5
- Returns to previous intro page
- Page 1 has no back button

## Error Handling

### Network Errors
- Shows error snackbar
- Resets loading state
- Allows user to retry

### Asset Loading Errors
- Falls back to Material icons
- Maintains layout integrity
- No user-facing errors

## Analytics Opportunities

Track the following events for insights:
1. Intro started
2. Page viewed (1-5)
3. Skip button clicked (which page)
4. Intro completed (Get Started clicked)
5. Time spent on each page
6. Intro → Onboarding conversion rate

## Accessibility Features

- ✅ Semantic page titles and descriptions
- ✅ High contrast text and backgrounds
- ✅ Large touch targets for buttons
- ✅ Clear visual hierarchy
- ✅ Progress indicators (dots)
- ✅ Skip option available on every page

## Performance Considerations

- Images are lazy-loaded
- Fallback icons prevent loading delays
- Async operations don't block UI
- Proper mounted checks prevent memory leaks
- Loading states provide feedback

