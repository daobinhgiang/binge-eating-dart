import 'package:flutter/material.dart';
import '../../data/assessment_data.dart';
import '../../widgets/assessment_widget.dart';
import '../../models/assessment.dart';

class QuizChapter1Screen extends StatefulWidget {
  const QuizChapter1Screen({super.key});

  @override
  State<QuizChapter1Screen> createState() => _QuizChapter1ScreenState();
}

class _QuizChapter1ScreenState extends State<QuizChapter1Screen> {
  late Assessment _quiz;

  @override
  void initState() {
    super.initState();
    _quiz = AssessmentData.getChapter1Quiz();
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

