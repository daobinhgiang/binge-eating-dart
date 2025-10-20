# Quest System - Visual Design Guide

## 🎨 Design Overview

The new quest system features a modern, clean interface inspired by popular productivity apps with card-based layouts, progress bars, and color-coded categories.

---

## 📱 Screen Layout

### Header Section
```
┌─────────────────────────────────────────────┐
│  [←]  Your Quests               [↻]         │
│       Track your recovery journey           │
└─────────────────────────────────────────────┘
```
- Clean gradient background (light gray to blue-gray)
- Large, bold title with descriptive subtitle
- White card-style icon buttons with shadows
- Refresh button triggers manual quest regeneration

---

### Filter Chips (Horizontal Scroll)
```
┌──────────────────────────────────────────────────────────┐
│  [📊 All Quests] [☀️ Daily Seeds] [📈 Growth] [🏆 Mastery] │
└──────────────────────────────────────────────────────────┘
```
- Horizontally scrollable
- Active filter highlighted with color and shadow
- Smooth animations on selection
- Each tier has unique icon and color

**Colors:**
- All Quests: Purple (#6C5CE7)
- Daily Seeds: Orange (#FFB951)
- Growth Tasks: Green (#00B894)
- Mastery Quests: Purple (#6C5CE7)

---

### Statistics Overview Card
```
┌─────────────────────────────────────────────┐
│  Overall Progress                    75%    │
│  ■■■■■■■■■■■■■■■■■■■■□□□□□          │
│                                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │  ☀️      │  │  📈      │  │  🏆      │  │
│  │  2/3     │  │  1/2     │  │  0/5     │  │
│  │  Seeds   │  │  Growth  │  │  Mastery │  │
│  └─────────┘  └─────────┘  └─────────┘  │
└─────────────────────────────────────────────┘
```
- Purple gradient background with shadow
- Overall progress percentage and bar
- Breakdown by tier type
- Shows completed/total for each category
- Semi-transparent white backgrounds for stats

---

### Quest Card Design
```
┌────────────────────────────────────────────────┐
│  ○  [☀️ Daily Seed] [📚 Lesson]               │
│                                            ⋮   │
│     Complete Today's Food Diary                │
│     Record your meals and reflections for...   │
│                                                │
│     [⭐ +50 EXP]                               │
│────────────────────────────────────────────────│
│  ████████░░░░░░░░░░ (Progress bar - 50%)       │
└────────────────────────────────────────────────┘
```

**Card Features:**
- White background with subtle shadow
- Rounded corners (16px radius)
- Checkbox on left (animated on completion)
- Two badge pills at top (tier + type)
- Quest title in bold
- Description text (max 2 lines, truncated)
- EXP reward badge with star icon
- Three-dot menu for actions
- Progress bar at bottom (color matches tier)

**Badge Colors:**
- Seeds: Orange background with orange text
- Growth: Green background with green text
- Mastery: Purple background with purple text
- Lesson: Blue background with blue text
- Tool: Red background with red text
- Journal: Light purple background with purple text

---

### Empty State
```
        ┌─────────────────┐
        │                 │
        │    🎯 Icon      │
        │                 │
        └─────────────────┘
        
        No Quests Found
        
    Start your recovery journey by
    adding quests or wait for daily
    quests to be generated.
    
    [+ Add Your First Quest]
```

---

## 🎨 Color Palette

### Primary Colors
- **Purple (#6C5CE7)**: Primary brand color, buttons, mastery quests
- **Orange (#FFB951)**: Daily seeds, EXP rewards
- **Green (#00B894)**: Growth tasks, success states
- **Blue (#0984E3)**: Lessons
- **Red (#D63031)**: Tools/exercises
- **Light Purple (#A29BFE)**: Journals

### Neutral Colors
- **Dark Gray (#2D3436)**: Primary text
- **Medium Gray (#636E72)**: Secondary text
- **Light Gray (#DFE6E9)**: Borders, inactive elements
- **Off White (#F5F7FA)**: Background gradient start
- **Light Blue Gray (#E8EDF2)**: Background gradient end

### Shadows
- Subtle shadows: `rgba(0,0,0,0.05)` with 10px blur
- Card shadows: `rgba(0,0,0,0.04)` with 8px blur
- Button shadows: Color-specific with 0.3 opacity

---

## 📊 Quest Tiers Explained

### 🌱 Daily Seeds
**Purpose**: Build daily recovery habits  
**Regeneration**: Every 24 hours at midnight  
**Auto-delete**: End of day (11:59 PM)  
**EXP Range**: 30-60 points  
**Examples**:
- Complete today's food diary
- Practice coping strategy
- Mindfulness exercise

**Visual Indicators**:
- Orange color theme
- Sun icon (☀️)
- Progress bar: Orange
- Badge: "Daily Seed"

---

### 📈 Growth Tasks
**Purpose**: Weekly learning and skill development  
**Regeneration**: Every Monday at midnight  
**Auto-delete**: End of week (Sunday 11:59 PM)  
**EXP Range**: 150-250 points  
**Examples**:
- Complete this week's lesson
- Assessment quiz
- Problem-solving exercise

**Visual Indicators**:
- Green color theme
- Trending up icon (📈)
- Progress bar: Green
- Badge: "Growth Task"

---

### 🏆 Mastery Quests
**Purpose**: Long-term milestones and achievements  
**Regeneration**: Never (persistent)  
**Auto-delete**: Never  
**EXP Range**: 500-2000 points  
**Examples**:
- Complete all Stage 1 lessons
- Maintain 30-day journal streak
- Earn 10,000 EXP

**Visual Indicators**:
- Purple color theme
- Trophy icon (🏆)
- Progress bar: Purple
- Badge: "Mastery Quest"

---

## 🔄 Quest Lifecycle

### Generation Flow
```
App Launch
    ↓
Check Last Regeneration
    ↓
    ├─→ New Day? → Generate Seeds (3 random)
    ├─→ New Week? → Generate Growth Tasks (2 random)
    └─→ Progress Milestone? → Create Mastery Quest
    ↓
Display in UI
```

### Completion Flow
```
User Action
    ↓
    ├─→ Tap Checkbox
    ├─→ Complete Activity
    └─→ Navigate to Activity
    ↓
Mark as Complete
    ↓
Award EXP
    ↓
Update Progress Bar
    ↓
Refresh Statistics
```

### Cleanup Flow
```
Daily Check (Seeds)
    ↓
Current Time > autoDeleteDate?
    ↓
    ├─→ Yes + Incomplete → Delete Quest
    ├─→ Yes + Complete → Keep in History
    └─→ No → Keep Quest

Weekly Check (Growth)
    ↓
Current Week > Generation Week?
    ↓
    ├─→ Yes + Incomplete → Delete Quest
    ├─→ Yes + Complete → Keep in History
    └─→ No → Keep Quest
```

---

## 🎯 User Interactions

### Quest Card Actions
1. **Tap Checkbox**: Toggle completion status
2. **Tap Card**: Start linked activity (if available)
3. **Three-dot Menu**:
   - "Start Quest" - Navigate to activity
   - "Edit" - Modify quest details
   - "Delete" - Remove quest

### Filter Actions
- **Tap Filter Chip**: Show only that tier type
- **Smooth Animation**: Fade in/out filtered quests
- **Count Update**: Badge shows filtered count

### Refresh Action
- **Pull Down**: Standard pull-to-refresh
- **Tap Refresh Button**: Manual regeneration check
- **Auto-check**: On screen mount

---

## 📱 Responsive Design

### Layout Adaptations
- **Phone Portrait**: Single column, full width cards
- **Phone Landscape**: Single column, reduced padding
- **Tablet**: Single column with max-width constraint
- **Large Tablet**: Potentially two columns (future)

### Text Scaling
- Titles: 16-28px based on importance
- Body: 13-14px for descriptions
- Labels: 11-12px for badges and chips
- Scales with system font size settings

---

## 🎨 Animation Details

### Checkbox Animation
- Duration: 200ms
- Easing: Ease-in-out
- Transforms: Scale, opacity, border color
- Checkmark: Fade in with slight scale

### Progress Bar
- Duration: 300ms
- Easing: Ease-out
- Width transition: Smooth linear
- Color: Matches tier color

### Filter Chip Selection
- Duration: 200ms
- Transforms: Background color, shadow, text color
- Shadow animates in/out
- Scale: Slight scale up on tap

### Card Entry
- Staggered fade-in
- Slight slide up from bottom
- Duration: 400ms per card
- Delay: 50ms between cards

---

## 🔧 Technical Implementation

### Component Structure
```
TodosScreen
  ├─ Header
  │   ├─ Back Button
  │   ├─ Title & Subtitle
  │   └─ Refresh Button
  ├─ Filter Chips Bar
  │   ├─ All Quests Chip
  │   ├─ Seeds Chip
  │   ├─ Growth Chip
  │   └─ Mastery Chip
  ├─ Stats Overview Card
  │   ├─ Progress Header
  │   ├─ Progress Bar
  │   └─ Tier Stats Grid
  └─ Quest List
      ├─ Section Header (Active)
      ├─ Quest Cards
      ├─ Section Header (Completed)
      └─ Quest Cards
```

### State Management
- **Provider**: Riverpod StateNotifier
- **Auto-refresh**: On mount and manual trigger
- **Optimistic Updates**: Immediate UI update
- **Error Handling**: Graceful fallback to cached data

---

## 📐 Spacing & Layout

### Padding & Margins
- Screen padding: 20px horizontal
- Card margin: 12px vertical
- Card padding: 16px
- Section spacing: 24px
- Chip spacing: 12px

### Border Radius
- Cards: 16px
- Buttons: 12px
- Badges: 6-8px
- Stats card: 20px

### Shadows
- Elevation 1: `offset(0,2) blur(4) opacity(0.05)`
- Elevation 2: `offset(0,4) blur(8) opacity(0.08)`
- Elevation 3: `offset(0,10) blur(20) opacity(0.1)`

---

## 🚀 Performance Optimizations

### Caching Strategy
- Todo data cached for 5 minutes
- Regeneration log cached
- Template data bundled (no network fetch)
- Firestore queries minimized

### Render Optimization
- Stateless widgets where possible
- Const constructors for static widgets
- ListView for efficient scrolling
- Lazy loading for large lists

### Network Efficiency
- Batch writes for regeneration
- Single query for all todos
- Local filtering instead of queries
- Offline support with cached data

---

## ✅ Accessibility Features

### Screen Reader Support
- Semantic labels for all interactive elements
- Progress announcements
- Action button descriptions
- Navigation hints

### Visual Accessibility
- High contrast text
- Clear focus indicators
- Minimum touch target: 44x44px
- Color not sole indicator (icons + text)

### Motion Preferences
- Respects reduced motion settings
- Alternative static states
- No auto-playing animations
- User-triggered animations only

---

## 🎯 Success Metrics

### User Engagement
- Daily active quest completion rate
- Time to first quest completion
- Quest regeneration utilization
- Filter usage patterns

### Quest Performance
- Most completed quest types
- Average completion time
- Abandonment rate per tier
- EXP earned per tier

### UI Performance
- Screen load time < 500ms
- Animation smoothness 60fps
- No dropped frames on scroll
- Memory usage stable

---

This visual guide complements the technical implementation documentation and provides a comprehensive overview of the design decisions, user experience flow, and visual styling of the quest system.

