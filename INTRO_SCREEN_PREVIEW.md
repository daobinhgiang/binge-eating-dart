# Introduction Screen - Visual Preview

## Screenshots Preview (Mockup)

### Page 1 - Welcome to Nurtra
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║                    [Nurtra Logo]                          ║
║                      (Green icon)                         ║
║                                                           ║
║                                                           ║
║              Welcome to Nurtra                            ║
║                                                           ║
║     Your compassionate companion in                       ║
║     understanding and overcoming binge                    ║
║     eating. We're here to support you                     ║
║     every step of the way on your journey                 ║
║     to a healthier relationship with food.                ║
║                                                           ║
║                                                           ║
║                                                           ║
║                                                           ║
║                   ● ○ ○ ○ ○                              ║
║                                                           ║
║                                                           ║
║         [Skip]                          [→]               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

### Page 2 - Learn and Understand
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║              [Education Stage Image]                      ║
║                 (Book/Learning icon)                      ║
║                                                           ║
║                                                           ║
║            Learn and Understand                           ║
║                                                           ║
║     Our comprehensive education modules                   ║
║     help you understand binge eating                      ║
║     disorder. Discover evidence-based                     ║
║     insights, expert guidance, and learn                  ║
║     proven methods to manage your eating                  ║
║     patterns.                                             ║
║                                                           ║
║                                                           ║
║                   ○ ● ○ ○ ○                              ║
║                                                           ║
║                                                           ║
║         [Skip]                          [→]               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

### Page 3 - Your Personal Journey Partner
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║              [Food Diary Image]                           ║
║               (Journal/Notebook icon)                     ║
║                                                           ║
║                                                           ║
║         Your Personal Journey Partner                     ║
║                                                           ║
║     Nurtra isn't just an app—it's a friend,              ║
║     a partner that stands by you                          ║
║     throughout your journey. Track your                   ║
║     progress with our journal, and use                    ║
║     our practical tools to support you in                 ║
║     real-time whenever you need it.                       ║
║                                                           ║
║                                                           ║
║                   ○ ○ ● ○ ○                              ║
║                                                           ║
║                                                           ║
║         [Skip]                          [→]               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

### Page 4 - You're Not Alone
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║                                                           ║
║                     💚                                    ║
║                  (Heart Icon)                             ║
║                  Green color                              ║
║                                                           ║
║                                                           ║
║              You're Not Alone                             ║
║                                                           ║
║     We want you to know that we're always                ║
║     by your side in this journey. Every                   ║
║     step forward, no matter how small, is                 ║
║     a victory worth celebrating. You have                 ║
║     the strength within you, and we're                    ║
║     here to help you find it.                             ║
║                                                           ║
║                   ○ ○ ○ ● ○                              ║
║                                                           ║
║                                                           ║
║         [Skip]                          [→]               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

### Page 5 - Ready to Start Your Journey?
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║                                                           ║
║                                                           ║
║                     🚀                                    ║
║                 (Rocket Icon)                             ║
║                  Green color                              ║
║                                                           ║
║                                                           ║
║         Ready to Start Your Journey?                      ║
║                                                           ║
║     Let's get to know you better so we can               ║
║     personalize your experience. This quick               ║
║     assessment will help us understand                    ║
║     your needs and provide the best                       ║
║     support for you.                                      ║
║                                                           ║
║          Estimated time: 5 minutes                        ║
║                                                           ║
║                   ○ ○ ○ ○ ●                              ║
║                                                           ║
║                                                           ║
║         [Skip]                    [Get Started]           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

---

## Design Specifications

### Colors
- **Primary Color:** `#4CAF50` (Nurtra Green)
- **Text Color (Titles):** `#1C1C1E` (Near Black)
- **Text Color (Body):** `#3C3C3E` (Dark Gray)
- **Background:** `#FFFFFF` (White)
- **Dots (Active):** `#4CAF50` (Green)
- **Dots (Inactive):** `#E0E0E0` (Light Gray)

### Typography
- **Title Font Size:** 28.0
- **Title Font Weight:** Bold (700)
- **Body Font Size:** 18.0
- **Body Line Height:** 1.5
- **Button Font Weight:** Semi-bold (600)

### Spacing
- **Page Padding:** 16px horizontal
- **Body Padding:** 16px vertical
- **Image Top Padding:** 40px
- **Image Bottom Padding:** 20px
- **Button Margin:** 16px all sides

### Components
- **Progress Dots:**
  - Inactive: 10x10 circle
  - Active: 22x10 rounded rectangle
  - Spacing: Auto
  
- **Buttons:**
  - Skip: Text button, gray
  - Next: Icon button with arrow
  - Get Started: Text button, emphasized

### Images
- **Page 1:** `assets/logo.png` (200px height)
- **Page 2:** `assets/lessons/stages/stage_1.png` (175px height)
- **Page 3:** `assets/journal/food_diary.png` (175px height)
- **Page 4:** Heart icon (175px, Material Icons)
- **Page 5:** Rocket icon (175px, Material Icons)

### Fallback Behavior
If images fail to load:
- Display Material Icon equivalent
- Maintain same size and color
- No error shown to user

---

## User Interactions

### Navigation Flow
```
Page 1 → Page 2 → Page 3 → Page 4 → Page 5
  ↓        ↓        ↓        ↓        ↓
Skip → Skip → Skip → Skip → Skip/Get Started
  ↓        ↓        ↓        ↓        ↓
            Onboarding Screen
```

### Button Actions
- **Next Arrow (→):** Advances to next page
- **Back Arrow (←):** Returns to previous page (not on page 1)
- **Skip:** Immediately goes to onboarding
- **Get Started:** Completes intro, goes to onboarding

### Loading States
- **During Save:**
  - Get Started button shows spinner
  - Skip button disabled
  - No other interactions possible

### Error States
- **If Save Fails:**
  - Red snackbar appears at bottom
  - Shows error message
  - Buttons re-enabled
  - User can retry

---

## Animations & Transitions

### Page Transitions
- Smooth slide animation between pages
- Duration: ~300ms
- Easing: Standard curve

### Progress Dots
- Active dot expands horizontally
- Smooth transition animation
- Updates immediately on page change

### Button States
- Hover effect (web)
- Ripple effect on tap
- Loading spinner animation

---

## Accessibility Features

### Screen Reader Support
- Page titles announced
- Button labels clear
- Progress indicator accessible

### Touch Targets
- All buttons ≥ 48x48 logical pixels
- Skip and Next buttons well-spaced
- No overlapping touch areas

### Visual Hierarchy
- Clear title/body distinction
- High contrast ratios
- Large, readable text

### Navigation
- Can navigate with keyboard (web)
- Swipe gestures work (mobile)
- Back button available

---

## Platform Adaptations

### Mobile (iOS/Android)
- Full-screen layout
- Touch-optimized buttons
- Swipe gestures enabled

### Web
- Centered on wide screens
- Keyboard navigation support
- Hover states on buttons

### Tablet
- Responsive layout
- Larger touch targets
- Optimized spacing

---

## Code Structure

### Widget Hierarchy
```
IntroductionScreen
├── PageViewModel (Page 1)
│   ├── Image (Nurtra Logo)
│   ├── Title Text
│   └── Body Text
├── PageViewModel (Page 2)
│   ├── Image (Education)
│   ├── Title Text
│   └── Body Text
├── PageViewModel (Page 3)
│   ├── Image (Journal)
│   ├── Title Text
│   └── Body Text
├── PageViewModel (Page 4)
│   ├── Icon (Heart)
│   ├── Title Text
│   └── Body Text
├── PageViewModel (Page 5)
│   ├── Icon (Rocket)
│   ├── Title Text
│   └── Body Text
├── DotsDecorator
└── Control Buttons
    ├── Skip Button
    └── Done/Next Button
```

---

## State Management

### Loading State
```dart
bool _isLoading = false;
```

### Page Index
```dart
int currentPageIndex = 0; // Managed by introduction_screen
```

### User Progress
```dart
// In Firestore
{
  hasSeenIntro: false → true
}
```

---

## Performance

### Metrics
- **Initial Load:** < 1s
- **Page Transitions:** ~300ms
- **Save Operation:** 500ms - 2s (network dependent)
- **Image Loading:** Cached after first load

### Optimizations
- Images preloaded
- Lazy initialization of icons
- Minimal rebuild on state changes
- Efficient Riverpod integration

---

## Testing Checklist

### Visual
- [ ] All pages display correctly
- [ ] Images load or fallback works
- [ ] Text is readable and sized correctly
- [ ] Buttons are properly positioned
- [ ] Progress dots work correctly

### Functional
- [ ] Next button advances pages
- [ ] Back button returns (not on page 1)
- [ ] Skip button works on all pages
- [ ] Get Started completes flow
- [ ] Loading state displays
- [ ] Error handling works

### Data
- [ ] hasSeenIntro flag updates
- [ ] Navigation to onboarding works
- [ ] State persists across sessions
- [ ] No data loss on errors

---

## Known Limitations

1. **Images:** Require assets to exist in specified paths
2. **Network:** Requires connection to save state
3. **Browser:** Back button may interfere (web)

---

## Future Enhancements

### Visual
- [ ] Custom animations
- [ ] Video backgrounds
- [ ] Animated icons
- [ ] Particle effects

### Functional
- [ ] Progress save/resume
- [ ] A/B tested messaging
- [ ] Personalized content
- [ ] Multi-language support

### Analytics
- [ ] Page view tracking
- [ ] Time on page metrics
- [ ] Skip pattern analysis
- [ ] Conversion funnel

---

## Summary

The introduction screen provides a warm, professional welcome to Nurtra. It sets the right tone, explains the app's value, and prepares users for their journey—all in a beautiful, user-friendly interface that takes just 1-2 minutes to complete (or can be skipped instantly).

