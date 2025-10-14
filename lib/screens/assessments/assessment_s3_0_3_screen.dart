import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class AssessmentS303Screen extends StatefulWidget {
  const AssessmentS303Screen({super.key});

  @override
  State<AssessmentS303Screen> createState() => _AssessmentS303ScreenState();
}

class _AssessmentS303ScreenState extends State<AssessmentS303Screen> {
  late Assessment _assessment;

  @override
  void initState() {
    super.initState();
    // Get EDE-Q assessment and override lessonId for Stage 3
    _assessment = AssessmentData.getEDEQAssessment().copyWith(
      lessonId: 'lesson_s3_0_3',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AssessmentWidget(
      assessment: _assessment,
      onCompleted: () {
        Navigator.of(context).pop();
      },
    );
  }
}
