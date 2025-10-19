import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State class to hold tree animation information
class TreeAnimationState {
  final bool shouldAnimate;
  final int? fromLevel;
  final int? toLevel;
  final DateTime? triggeredAt;

  const TreeAnimationState({
    this.shouldAnimate = false,
    this.fromLevel,
    this.toLevel,
    this.triggeredAt,
  });

  TreeAnimationState copyWith({
    bool? shouldAnimate,
    int? fromLevel,
    int? toLevel,
    DateTime? triggeredAt,
  }) {
    return TreeAnimationState(
      shouldAnimate: shouldAnimate ?? this.shouldAnimate,
      fromLevel: fromLevel ?? this.fromLevel,
      toLevel: toLevel ?? this.toLevel,
      triggeredAt: triggeredAt ?? this.triggeredAt,
    );
  }
}

/// Notifier to manage tree animation state
class TreeAnimationNotifier extends StateNotifier<TreeAnimationState> {
  TreeAnimationNotifier() : super(const TreeAnimationState());

  /// Trigger a tree growth animation from oldLevel to newLevel
  void triggerGrowthAnimation(int fromLevel, int toLevel) {
    print('🔔 [TreeAnimationProvider] triggerGrowthAnimation called: $fromLevel -> $toLevel');
    state = TreeAnimationState(
      shouldAnimate: true,
      fromLevel: fromLevel,
      toLevel: toLevel,
      triggeredAt: DateTime.now(),
    );
    print('✨ [TreeAnimationProvider] State updated - shouldAnimate: ${state.shouldAnimate}');
  }

  /// Reset the animation state after it completes
  void resetAnimation() {
    print('🔄 [TreeAnimationProvider] resetAnimation called');
    state = const TreeAnimationState(
      shouldAnimate: false,
    );
    print('💤 [TreeAnimationProvider] State reset - shouldAnimate: ${state.shouldAnimate}');
  }
}

/// Provider for tree animation state
final treeAnimationProvider =
    StateNotifierProvider<TreeAnimationNotifier, TreeAnimationState>((ref) {
  return TreeAnimationNotifier();
});

