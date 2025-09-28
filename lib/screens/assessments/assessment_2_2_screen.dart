import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class Assessment22Screen extends StatefulWidget {
  const Assessment22Screen({super.key});

  @override
  State<Assessment22Screen> createState() => _Assessment22ScreenState();
}

class _Assessment22ScreenState extends State<Assessment22Screen> {
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
