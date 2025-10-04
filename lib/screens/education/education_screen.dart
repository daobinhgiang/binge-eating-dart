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
      body: EducationBackground(
        child: _buildStageHierarchy(context),
      ),
    );
  }

  Widget _buildStageHierarchy(BuildContext context) {
    final stage1 = Stage1Data.getStage1();
    final stage2 = Stage2Data.getStage2();
    final stage3 = Stage3Data.getStage3();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStageCard(context, stage1),
        const SizedBox(height: 16),
        _buildStageCard(context, stage2),
        const SizedBox(height: 16),
        _buildStageCard(context, stage3),
      ],
    );
  }

  Widget _buildStageCard(BuildContext context, Stage stage) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LessonsScreen(stageNumber: stage.stageNumber),
              ),
            );
          },
          child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                  width: 60,
                  height: 60,
                      decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                    Icons.school,
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                        stage.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                        '${stage.chapters.length} chapters • ${stage.chapters.fold(0, (sum, chapter) => sum + chapter.lessons.length)} lessons',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}