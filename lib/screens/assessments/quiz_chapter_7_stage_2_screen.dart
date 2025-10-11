import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter7Stage2Screen extends StatefulWidget {
  const QuizChapter7Stage2Screen({super.key});

  @override
  State<QuizChapter7Stage2Screen> createState() => _QuizChapter7Stage2ScreenState();
}

class _QuizChapter7Stage2ScreenState extends State<QuizChapter7Stage2Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter7Stage2Quiz();
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
