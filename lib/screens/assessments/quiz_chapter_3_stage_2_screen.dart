import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter3Stage2Screen extends StatefulWidget {
  const QuizChapter3Stage2Screen({super.key});

  @override
  State<QuizChapter3Stage2Screen> createState() => _QuizChapter3Stage2ScreenState();
}

class _QuizChapter3Stage2ScreenState extends State<QuizChapter3Stage2Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter3Stage2Quiz();
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
