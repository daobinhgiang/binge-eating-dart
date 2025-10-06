import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildStageCard(context, stage1),
              const SizedBox(height: 12),
              _buildStageCard(context, stage2),
              const SizedBox(height: 12),
              _buildStageCard(context, stage3),
              const SizedBox(height: 24),
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
  
  

  Widget _buildProgressIndicator(BuildContext context, String label, int total, int completed) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$completed/$total',
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStageCard(BuildContext context, Stage stage) {
    final stageTheme = _getStageTheme(stage.stageNumber);
    final totalLessons = stage.chapters.fold(0, (sum, chapter) => sum + chapter.lessons.length);
    
    return _buildStageCardContent(context, stage, stageTheme, totalLessons);
  }

  Widget _buildStageCardContent(BuildContext context, Stage stage, Map<String, dynamic> stageTheme, int totalLessons) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileSize = MediaQuery.of(context).size.width * 0.85;
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          alignment: Alignment.center,
          child: StatefulBuilder(
            builder: (context, setState) {
              bool isHovered = false;
              return MouseRegion(
                onEnter: (_) => setState(() => isHovered = true),
                onExit: (_) => setState(() => isHovered = false),
                child: AnimatedContainer(
                  width: tileSize,
                  height: tileSize,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: isHovered ? [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ] : [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LessonsScreen(stageNumber: stage.stageNumber),
                          ),
                        );
                      },
                      child: (stage.stageNumber >= 1 && stage.stageNumber <= 3)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Column(
                                children: [
                                  // Top photo section
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage('assets/lessons/stages/stage_${stage.stageNumber}.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Bottom white overlay section - sized to content
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, -2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Stage ${stage.stageNumber}: ${stage.title}',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Theme.of(context).colorScheme.onSurface,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _getStageDescription(stage.stageNumber),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.grey[700],
                                                height: 1.3,
                                              ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${stage.chapters.length} chapters',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4CAF50).withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      stageTheme['icon'],
                                      color: const Color(0xFF4CAF50),
                                      size: 36,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Stage ${stage.stageNumber}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: const Color(0xFF4CAF50).withOpacity(0.7),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    stage.title,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStageTheme(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return {
          'gradient': [
            const Color(0xFF66BB6A), // Bright vibrant green
            const Color(0xFF4CAF50), // Material green
          ],
          'shadowColor': const Color(0xFF66BB6A).withOpacity(0.2),
          'icon': Icons.auto_stories,
        };
      case 2:
        return {
          'gradient': [
            const Color(0xFF81C784), // Brighter light green
            const Color(0xFF66BB6A), // Bright green
          ],
          'shadowColor': const Color(0xFF81C784).withOpacity(0.2),
          'icon': Icons.psychology,
        };
      case 3:
        return {
          'gradient': [
            const Color(0xFF4CAF50), // Material green
            const Color(0xFF43A047), // Slightly darker green
          ],
          'shadowColor': const Color(0xFF4CAF50).withOpacity(0.2),
          'icon': Icons.celebration,
        };
      default:
        return {
          'gradient': [
            const Color(0xFF66BB6A),
            const Color(0xFF4CAF50),
          ],
          'shadowColor': const Color(0xFF66BB6A).withOpacity(0.2),
          'icon': Icons.school,
        };
    }
  }

  String _getStageDescription(int stageNumber) {
    switch (stageNumber) {
      case 1:
        return 'Introduce psychoeducation, regular eating and start monitoring to build momentum.';
      case 2:
        return 'Review progress, plan the core work, and strengthen key skills.';
      case 3:
        return 'Consolidate gains, prepare for setbacks, and sustain long-term change.';
      default:
        return 'Explore lessons designed to guide you through recovery.';
    }
  }

  
}