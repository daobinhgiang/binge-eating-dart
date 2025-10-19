<!-- ca5f3ecc-0976-4905-af96-9cfab490dc3c b1729d55-be5e-417b-a613-df40731e0863 -->
# Tree Growth Visualization Implementation

## Objective

Replace the "Track your binge-free progress in the Journal tab" placeholder on the home screen with a dynamic tree that grows as users progress through levels 1-5, complete with level-up growth animations.

## Key Deliverables

### 1. Tree Assets

- Create a `trees` directory structure with 5 tree images:
- `level_1_seed.png` - Seed
- `level_2_sprout.png` - Sprout
- `level_3_young_tree.png` - Young Tree
- `level_4_leafy_tree.png` - Leafy Tree
- `level_5_small_grove.png` - Small Grove
- Add images to `assets/trees/` and update `pubspec.yaml`

### 2. Tree Growth Widget (`lib/widgets/tree_growth_widget.dart`)

- Create a stateful widget that:
- Displays the appropriate tree image based on user's current level
- Shows the next level hint text below the tree (e.g., "Level 2: Sprout")
- Animates on level changes with a growth effect (scale + fade animation)
- Handles loading states gracefully

### 3. Tree Service (`lib/core/services/tree_service.dart`)

- Map user levels (1-5) to tree assets
- Provide helper methods to get tree image paths and display names
- Map levels to descriptive tree names

### 4. Modify Home Screen (`lib/screens/home_screen.dart`)

- Replace the `_buildTimerPlaceholder()` widget implementation
- Remove the text message and empty space placeholders
- Integrate `TreeGrowthWidget` as the main content in the 280px space
- Connect to `userExpProvider` to get current level and trigger animations on updates

## Technical Approach

**Widget Structure:**

- `TreeGrowthWidget` will be a `StatefulWidget` with `AnimationController`
- Listen to level changes via `userExpProvider`
- Trigger scale animation (1.0 → 1.3 → 1.0) and fade effect on level up
- Use `Hero` animation for smooth tree transitions

**Animation Spec:**

- Trigger: When `userExp.level` changes
- Duration: 600ms for growth pulse
- Effect: ScaleTransition + FadeTransition combo

**Error Handling:**

- Provide placeholder if user is not logged in
- Display loading state while fetching user exp

## Files to Create/Modify

- **Create:** `lib/widgets/tree_growth_widget.dart`
- **Create:** `lib/core/services/tree_service.dart`
- **Modify:** `lib/screens/home_screen.dart` (replace `_buildTimerPlaceholder()`)
- **Modify:** `assets/pubspec.yaml` (add tree image assets)
- **Modify:** `pubspec.yaml` (reference in assets section if needed)

### To-dos

- [ ] Obtain or create 5 tree stage PNG images (Seed, Sprout, Young Tree, Leafy Tree, Small Grove) and save to assets/trees/ directory
- [ ] Create lib/core/services/tree_service.dart with level-to-tree mapping and helper functions
- [ ] Create lib/widgets/tree_growth_widget.dart with animation logic, level display, and error handling
- [ ] Modify lib/screens/home_screen.dart to replace _buildTimerPlaceholder() with TreeGrowthWidget integration
- [ ] Update pubspec.yaml to include tree image assets in assets section
- [ ] Test tree display across different levels and verify level-up animation triggers correctly