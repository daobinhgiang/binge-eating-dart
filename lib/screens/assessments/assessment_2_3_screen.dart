import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class Assessment23Screen extends StatefulWidget {
  const Assessment23Screen({super.key});

  @override
  State<Assessment23Screen> createState() => _Assessment23ScreenState();
}

class _Assessment23ScreenState extends State<Assessment23Screen> {
  late Assessment _assessment;

  @override
  void initState() {
    super.initState();
    _assessment = AssessmentData.getGeneralPsychiatricAssessment();
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
