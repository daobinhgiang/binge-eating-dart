import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter1Stage2Screen extends StatefulWidget {
  const QuizChapter1Stage2Screen({super.key});

  @override
  State<QuizChapter1Stage2Screen> createState() => _QuizChapter1Stage2ScreenState();
}

class _QuizChapter1Stage2ScreenState extends State<QuizChapter1Stage2Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter1Stage2Quiz();
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
