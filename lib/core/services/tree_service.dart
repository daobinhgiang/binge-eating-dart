class TreeService {
  static final TreeService _instance = TreeService._internal();
  factory TreeService() => _instance;
  TreeService._internal();

  // Mapping of levels to tree data
  static const Map<int, TreeData> _levelTreeMap = {
    1: TreeData(
      imagePath: 'assets/trees/level_1_seed.png',
      displayName: 'Seed',
      description: 'Your recovery journey begins here',
    ),
    2: TreeData(
      imagePath: 'assets/trees/level_2_sprout.png',
      displayName: 'Sprout',
      description: 'Growing stronger each day',
    ),
    3: TreeData(
      imagePath: 'assets/trees/level_3_young_tree.png',
      displayName: 'Young Tree',
      description: 'Your growth is visible',
    ),
    4: TreeData(
      imagePath: 'assets/trees/level_4_leafy_tree.png',
      displayName: 'Leafy Tree',
      description: 'Thriving and flourishing',
    ),
    5: TreeData(
      imagePath: 'assets/trees/level_5_small_grove.png',
      displayName: 'Small Grove',
      description: 'A testament to your strength',
    ),
  };

  /// Get tree data for a specific level
  TreeData getTreeDataForLevel(int level) {
    final clampedLevel = level.clamp(1, 5);
    return _levelTreeMap[clampedLevel] ??
        _levelTreeMap[1]!;
  }

  /// Get the display name for a level's tree
  String getTreeDisplayName(int level) {
    return getTreeDataForLevel(level).displayName;
  }

  /// Get the image path for a level's tree
  String getTreeImagePath(int level) {
    return getTreeDataForLevel(level).imagePath;
  }

  /// Get the description for a level's tree
  String getTreeDescription(int level) {
    return getTreeDataForLevel(level).description;
  }

  /// Get the next level's tree data (for "unlock next" hints)
  TreeData? getNextTreeData(int currentLevel) {
    if (currentLevel >= 5) return null; // Max level has no next
    return _levelTreeMap[currentLevel + 1];
  }

  /// Get the next level's display name
  String? getNextTreeDisplayName(int currentLevel) {
    return getNextTreeData(currentLevel)?.displayName;
  }
}

/// Data class for tree information
class TreeData {
  final String imagePath;
  final String displayName;
  final String description;

  const TreeData({
    required this.imagePath,
    required this.displayName,
    required this.description,
  });
}
