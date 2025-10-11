import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter0Screen extends StatefulWidget {
  const QuizChapter0Screen({super.key});

  @override
  State<QuizChapter0Screen> createState() => _QuizChapter0ScreenState();
}

class _QuizChapter0ScreenState extends State<QuizChapter0Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter0Quiz();
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
