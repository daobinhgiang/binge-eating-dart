import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import '../../data/stage_1_data.dart';
import '../../data/stage_2_data.dart';
import '../../data/stage_3_data.dart';
import '../../models/stage.dart';
import 'lessons_screen.dart';
import '../../widgets/education_background.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: EducationBackground(
          child: _buildStageHierarchy(context),
        ),
      ),
    );
  }

  Widget _buildStageHierarchy(BuildContext context) {
    final stage1 = Stage1Data.getStage1();
    final stage2 = Stage2Data.getStage2();
    final stage3 = Stage3Data.getStage3();
    
    return Column(
      children: [
        _buildHeader(context),
        const SizedBox(height: 24),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStageCard(context, stage1),
              const SizedBox(height: 40),
              _buildStageCard(context, stage2),
              const SizedBox(height: 40),
              _buildStageCard(context, stage3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _buildHeaderContent(context);
  }

  Widget _buildHeaderContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Lessons',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ) ??
                const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey[300],
        ),
      ],
    );
  }
  
  

  Widget _buildStageCard(BuildContext context, Stage stage) {
    return _build3DStageButton(context, stage);
  }

  Widget _build3DStageButton(BuildContext context, Stage stage) {
    return Center(
      child: Column(
        children: [
          // START text above the button
          Text(
            'START',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.white,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // 3D Button
          _buildDuolingoStyleButton(context, stage),
        ],
      ),
    );
  }

  Widget _buildDuolingoStyleButton(BuildContext context, Stage stage) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        
        return GestureDetector(
          onTapDown: (_) {
            setState(() => isPressed = true);
            HapticFeedback.mediumImpact();
          },
          onTapUp: (_) {
            setState(() => isPressed = false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LessonsScreen(),
              ),
            );
          },
          onTapCancel: () {
            setState(() => isPressed = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 100,
            height: 100,
            transform: Matrix4.identity()
              ..translateByVector3(vector_math.Vector3(0.0, isPressed ? 3.0 : 0.0, 0.0)),
            child: Stack(
              children: [
                // Outer ring (orange progress ring)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF9500),
                      width: 8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9500).withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Main green button
                Container(
                  width: 84,
                  height: 84,
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF58CC02), // Light green
                        const Color(0xFF46A302), // Darker green
                      ],
                    ),
                    boxShadow: [
                      // Glow effect
                      BoxShadow(
                        color: const Color(0xFF58CC02).withValues(alpha: 0.4),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                      // Main shadow
                      BoxShadow(
                        color: const Color(0xFF46A302).withValues(alpha: 0.6),
                        blurRadius: isPressed ? 6 : 12,
                        offset: Offset(0, isPressed ? 3 : 6),
                        spreadRadius: 1,
                      ),
                      // Additional depth shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: isPressed ? 2 : 4,
                        offset: Offset(0, isPressed ? 1 : 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _getStageIcon(stage.stageNumber),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getStageIcon(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return Icons.auto_stories;
      case 2:
        return Icons.psychology;
      case 3:
        return Icons.celebration;
      default:
        return Icons.school;
    }
  }



  
}