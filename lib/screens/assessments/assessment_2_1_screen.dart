import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class Assessment21Screen extends StatefulWidget {
  const Assessment21Screen({super.key});

  @override
  State<Assessment21Screen> createState() => _Assessment21ScreenState();
}

class _Assessment21ScreenState extends State<Assessment21Screen> {
  late Assessment _assessment;

  @override
  void initState() {
    super.initState();
    _assessment = AssessmentData.getEDEQAssessment();
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
