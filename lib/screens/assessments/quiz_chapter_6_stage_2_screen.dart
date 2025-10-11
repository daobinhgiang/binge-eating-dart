import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter6Stage2Screen extends StatefulWidget {
  const QuizChapter6Stage2Screen({super.key});

  @override
  State<QuizChapter6Stage2Screen> createState() => _QuizChapter6Stage2ScreenState();
}

class _QuizChapter6Stage2ScreenState extends State<QuizChapter6Stage2Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter6Stage2Quiz();
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
