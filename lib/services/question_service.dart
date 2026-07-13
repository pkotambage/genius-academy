import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';

class QuestionService {
  static const String _questionsAssetPath =
      'assets/questions/iq_questions.json';

  Future<List<Question>> loadQuestions() async {
    final String jsonString = await rootBundle.loadString(_questionsAssetPath);

    final dynamic decodedData = jsonDecode(jsonString);

    if (decodedData is! List) {
      throw const FormatException(
        'The questions JSON file must contain a list of questions.',
      );
    }

    return decodedData
        .map(
          (item) => Question.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<String>> loadCategories() async {
    final questions = await loadQuestions();

    final categories = questions
        .map((question) => question.category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return categories;
  }

  Future<List<Question>> loadQuestionsByCategory(
    String category, {
    bool includePremium = true,
  }) async {
    final questions = await loadQuestions();

    return questions.where((question) {
      final matchesCategory =
          question.category.trim().toLowerCase() ==
          category.trim().toLowerCase();

      final canAccessQuestion = includePremium || !question.isPremium;

      return matchesCategory && canAccessQuestion;
    }).toList();
  }

  Future<List<Question>> loadQuestionsByDifficulty(
    String difficulty, {
    bool includePremium = true,
  }) async {
    final questions = await loadQuestions();

    return questions.where((question) {
      final matchesDifficulty =
          question.difficulty.trim().toLowerCase() ==
          difficulty.trim().toLowerCase();

      final canAccessQuestion = includePremium || !question.isPremium;

      return matchesDifficulty && canAccessQuestion;
    }).toList();
  }

  Future<List<Question>> loadFreeQuestions() async {
    final questions = await loadQuestions();

    return questions.where((question) => !question.isPremium).toList();
  }

  Future<List<Question>> loadPremiumQuestions() async {
    final questions = await loadQuestions();

    return questions.where((question) => question.isPremium).toList();
  }
}
