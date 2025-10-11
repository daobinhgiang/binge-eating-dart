import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter3Screen extends StatefulWidget {
  const QuizChapter3Screen({super.key});

  @override
  State<QuizChapter3Screen> createState() => _QuizChapter3ScreenState();
}

class _QuizChapter3ScreenState extends State<QuizChapter3Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter3Quiz();
  }

  @override
  Widget build(BuildContext context) {
    return AssessmentWidget(
      assessment: _quiz,
      onCompleted: () {
        Navigator.of(context).pop();
      },
    );
  }
}
