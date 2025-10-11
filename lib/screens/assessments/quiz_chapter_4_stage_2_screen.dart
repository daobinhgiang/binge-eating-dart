import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter4Stage2Screen extends StatefulWidget {
  const QuizChapter4Stage2Screen({super.key});

  @override
  State<QuizChapter4Stage2Screen> createState() => _QuizChapter4Stage2ScreenState();
}

class _QuizChapter4Stage2ScreenState extends State<QuizChapter4Stage2Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter4Stage2Quiz();
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
