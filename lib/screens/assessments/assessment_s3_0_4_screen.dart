import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class AssessmentS304Screen extends StatefulWidget {
  const AssessmentS304Screen({super.key});

  @override
  State<AssessmentS304Screen> createState() => _AssessmentS304ScreenState();
}

class _AssessmentS304ScreenState extends State<AssessmentS304Screen> {
  late Assessment _assessment;

  @override
  void initState() {
    super.initState();
    _assessment = AssessmentData.getCIAAssessment();
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
