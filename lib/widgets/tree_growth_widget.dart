import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/exp_provider.dart';
import '../providers/tree_animation_provider.dart';
import '../core/services/tree_service.dart';

class TreeGrowthWidget extends ConsumerStatefulWidget {
  final GlobalKey? treeImageKey;
  
  const TreeGrowthWidget({super.key, this.treeImageKey});

  @override
  ConsumerState<TreeGrowthWidget> createState() => _TreeGrowthWidgetState();
}

class _TreeGrowthWidgetState extends ConsumerState<TreeGrowthWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  late AnimationController _growthAnimationController;
  late Animation<double> _growthScaleAnimation;
  late Animation<double> _crossFadeAnimation;
  
  int _previousLevel = 1;
  int? _displayLevel; // The level currently being displayed
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Growth animation controller for tree evolution
    _growthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 3700), // 1200ms old tree fade + 2500ms new tree growth
      vsync: this,
    );

    _growthScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 32.4, // Phase 0 (0-1200ms): Old tree shrinks down
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 16.2, // Phase 1 (1200-1800ms): New tree slight shrink (anticipation)
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.85, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 32.4, // Phase 2 (1800-3200ms): New tree burst out
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 18.9, // Phase 3 (3200-3700ms): New tree settles
      ),
    ]).animate(_growthAnimationController);

    _crossFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 32.4, // Phase 0 (0-1200ms): Old tree fades out
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.0),
        weight: 16.2, // Phase 1 (1200-1800ms): New tree invisible during anticipation
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 32.4, // Phase 2 (1800-3200ms): New tree fades in during burst
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 18.9, // Phase 3 (3200-3700ms): New tree fully visible
      ),
    ]).animate(_growthAnimationController);

    _growthAnimationController.addStatusListener((status) {
      print('🎞️  [TreeGrowthWidget] Animation status changed: $status');
      if (status == AnimationStatus.completed) {
        print('🏁 [TreeGrowthWidget] Growth animation completed!');
        setState(() {
          _isAnimating = false;
        });
        // Reset the tree animation state
        ref.read(treeAnimationProvider.notifier).resetAnimation();
        print('🔄 [TreeGrowthWidget] Animation state reset called');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _growthAnimationController.dispose();
    super.dispose();
  }

  /// Triggers a dramatic growth animation from one level to another
  void _startGrowthAnimation(int fromLevel, int toLevel) {
    if (!mounted) {
      print('❌ [TreeGrowthWidget] _startGrowthAnimation: Not mounted, aborting');
      return;
    }
    
    print('🎬 [TreeGrowthWidget] Starting growth animation: $fromLevel -> $toLevel');
    
    // Start with the old tree
    setState(() {
      _displayLevel = fromLevel;
    });
    print('🌱 [TreeGrowthWidget] Display level set to old level: $fromLevel');
    
    // Use animation listener to switch tree at the right moment
    // Phase 0 is 32.4% of total animation (1200ms out of 3700ms)
    bool hasDisplayedNewTree = false;
    
    _growthAnimationController.addListener(() {
      final progress = _growthAnimationController.value;
      
      // At 32.4% progress (end of phase 0), switch to new tree
      if (progress >= 0.324 && !hasDisplayedNewTree) {
        hasDisplayedNewTree = true;
        print('⏱️  [TreeGrowthWidget] Animation reached 32.4%, switching to new tree');
        if (mounted) {
          setState(() {
            _displayLevel = toLevel;
          });
          print('🌳 [TreeGrowthWidget] Display level updated to new level: $toLevel');
        }
      }
    });
    
    // Start the growth animation
    _growthAnimationController.forward(from: 0.0);
    print('▶️  [TreeGrowthWidget] Growth animation controller started (3700ms)');
  }

  @override
  Widget build(BuildContext context) {
    final userExpData = ref.watch(userExpProvider);
    final treeAnimationState = ref.watch(treeAnimationProvider);

    print('🏗️  [TreeGrowthWidget] Build called - shouldAnimate: ${treeAnimationState.shouldAnimate}, _isAnimating: $_isAnimating');
    
    if (userExpData == null) {
      print('⚠️  [TreeGrowthWidget] userExpData is null, showing loading state');
      return _buildLoadingState();
    }

    // Listen to tree animation provider for explicit growth animations
    if (treeAnimationState.shouldAnimate && 
        !_isAnimating &&
        treeAnimationState.fromLevel != null &&
        treeAnimationState.toLevel != null) {
      print('🎯 [TreeGrowthWidget] Animation trigger detected!');
      print('   - fromLevel: ${treeAnimationState.fromLevel}');
      print('   - toLevel: ${treeAnimationState.toLevel}');
      print('   - _isAnimating: $_isAnimating');
      
      // Start the growth animation sequence
      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('📅 [TreeGrowthWidget] PostFrameCallback executing');
        if (mounted) {
          print('✅ [TreeGrowthWidget] Mounted, setting state and starting animation');
          setState(() {
            _isAnimating = true;
            _displayLevel = treeAnimationState.fromLevel;
          });
          _startGrowthAnimation(
            treeAnimationState.fromLevel!,
            treeAnimationState.toLevel!,
          );
        } else {
          print('❌ [TreeGrowthWidget] Not mounted in postFrameCallback');
        }
      });
    } else if (treeAnimationState.shouldAnimate) {
      print('⚠️  [TreeGrowthWidget] shouldAnimate is true but conditions not met:');
      print('   - _isAnimating: $_isAnimating');
      print('   - fromLevel null: ${treeAnimationState.fromLevel == null}');
      print('   - toLevel null: ${treeAnimationState.toLevel == null}');
    }

    // Check if level changed and trigger simple animation (for non-explicit changes)
    if (userExpData.level != _previousLevel && !_isAnimating) {
      _previousLevel = userExpData.level;
      _animationController.forward(from: 0.0);
    }

    final treeService = TreeService();
    // Use display level during animation, otherwise use current level
    final effectiveLevel = _isAnimating && _displayLevel != null 
        ? _displayLevel! 
        : userExpData.level;
    final currentTreeData = treeService.getTreeDataForLevel(effectiveLevel);
    final nextTreeName = treeService.getNextTreeDisplayName(userExpData.level);
    final isMaxLevel = userExpData.level >= 5;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tree display with animation - apply the key here to avoid duplicate key errors
        Container(
          key: widget.treeImageKey, // Apply the GlobalKey once at this level
          child: _isAnimating
              ? ScaleTransition(
                  scale: _growthScaleAnimation,
                  child: _buildTreeImageWithCrossFade(currentTreeData),
                )
              : ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildTreeImage(currentTreeData),
                  ),
                ),
        ),
        const SizedBox(height: 20),
        // Current level display
        Text(
          'Level ${userExpData.level}: ${currentTreeData.displayName}',
          style: GoogleFonts.fredoka(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Description
        Text(
          currentTreeData.description,
          style: GoogleFonts.fredoka(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        // Next level hint or max level message
        if (isMaxLevel)
          Text(
            'You\'ve reached the maximum level!',
            style: GoogleFonts.fredoka(
              color: const Color(0xFF4CAF50),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          )
        else if (nextTreeName != null)
          Text(
            'Next: $nextTreeName',
            style: GoogleFonts.fredoka(
              color: Colors.grey[500],
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }

  Widget _buildTreeImage(TreeData treeData) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Image.asset(
        treeData.imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[400],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tree image not found',
                    style: GoogleFonts.fredoka(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTreeImageWithCrossFade(TreeData treeData) {
    return SizedBox(
      height: 200,
      width: 200,
      child: FadeTransition(
        opacity: _crossFadeAnimation,
        child: Image.asset(
          treeData.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tree image not found',
                      style: GoogleFonts.fredoka(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 200,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.grey[400]!,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Loading your tree...',
          style: GoogleFonts.fredoka(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
