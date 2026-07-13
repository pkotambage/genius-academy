import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class QuestionService {
  Future<List<Question>> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions/iq_questions.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData.map((item) => Question.fromJson(item)).toList();
  }
}