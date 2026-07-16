import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question.dart';

class QuestionService {
  static const String _manifestAssetPath =
      'assets/data/assessment/manifests/question_manifest.json';

  Future<List<Question>> loadQuestions() async {
    final modulePaths = await _loadQuestionModulePaths();
    final questionsById = <String, Question>{};

    for (final modulePath in modulePaths) {
      final moduleQuestions = await _loadQuestionModule(modulePath);

      for (final question in moduleQuestions) {
        questionsById[question.id.trim().toLowerCase()] = question;
      }
    }

    return questionsById.values.where((question) => question.isActive).toList();
  }

  Future<List<String>> _loadQuestionModulePaths() async {
    final jsonString = await rootBundle.loadString(_manifestAssetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'Question manifest must contain a JSON object.',
      );
    }

    final manifest = Map<String, dynamic>.from(decoded);
    final modulesData = manifest['questionModules'];

    if (modulesData is! List) {
      throw const FormatException(
        'Question manifest must contain a questionModules list.',
      );
    }

    return modulesData
        .map((item) => item.toString().trim())
        .where((path) => path.isNotEmpty)
        .toList();
  }

  Future<List<Question>> _loadQuestionModule(String modulePath) async {
    final jsonString = await rootBundle.loadString(modulePath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw FormatException(
        'Question module must contain a JSON list: '
        '$modulePath',
      );
    }

    return decoded
        .whereType<Map>()
        .map((item) => Question.fromJson(Map<String, dynamic>.from(item)))
        .where((question) => question.isActive)
        .toList();
  }

  Future<Question?> getQuestionById(String id) async {
    final questions = await loadQuestions();
    final normalizedId = id.trim().toLowerCase();

    try {
      return questions.firstWhere(
        (question) => question.id.trim().toLowerCase() == normalizedId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Question>> loadQuestionsByIds(
    List<String> questionIds, {
    bool includePremium = true,
  }) async {
    final questions = await loadQuestions();

    final questionMap = {
      for (final question in questions)
        question.id.trim().toLowerCase(): question,
    };

    final selectedQuestions = <Question>[];

    for (final questionId in questionIds) {
      final question = questionMap[questionId.trim().toLowerCase()];

      if (question == null) {
        continue;
      }

      if (!includePremium && question.isPremium) {
        continue;
      }

      selectedQuestions.add(question);
    }

    return selectedQuestions;
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
