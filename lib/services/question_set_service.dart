import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/question_set.dart';

class QuestionSetService {
  static const String _manifestAssetPath =
      'assets/data/assessment/manifests/question_set_manifest.json';

  Future<List<QuestionSet>> loadQuestionSets() async {
    final modulePaths = await _loadModulePaths();
    final questionSets = <QuestionSet>[];

    for (final modulePath in modulePaths) {
      final questionSet = await _loadQuestionSetModule(modulePath);

      if (questionSet.isActive) {
        questionSets.add(questionSet);
      }
    }

    return questionSets;
  }

  Future<List<String>> _loadModulePaths() async {
    final jsonString = await rootBundle.loadString(_manifestAssetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'Question-set manifest must contain a JSON object.',
      );
    }

    final manifest = Map<String, dynamic>.from(decoded);
    final modulesData = manifest['questionSetModules'];

    if (modulesData is! List) {
      throw const FormatException(
        'Question-set manifest must contain a questionSetModules list.',
      );
    }

    return modulesData
        .map((item) => item.toString().trim())
        .where((path) => path.isNotEmpty)
        .toList();
  }

  Future<QuestionSet> _loadQuestionSetModule(String modulePath) async {
    final jsonString = await rootBundle.loadString(modulePath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw FormatException(
        'Question-set module must contain a JSON object: '
        '$modulePath',
      );
    }

    return QuestionSet.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<QuestionSet?> getQuestionSetById(String id) async {
    final questionSets = await loadQuestionSets();
    final normalizedId = id.trim().toLowerCase();

    try {
      return questionSets.firstWhere(
        (questionSet) => questionSet.id.trim().toLowerCase() == normalizedId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<QuestionSet>> loadQuestionSetsByLesson(String lessonId) async {
    final questionSets = await loadQuestionSets();
    final normalizedLessonId = lessonId.trim().toLowerCase();

    return questionSets.where((questionSet) {
      return questionSet.lessonId?.trim().toLowerCase() == normalizedLessonId;
    }).toList();
  }

  Future<List<QuestionSet>> loadQuestionSetsByTopic(String topicId) async {
    final questionSets = await loadQuestionSets();
    final normalizedTopicId = topicId.trim().toLowerCase();

    return questionSets.where((questionSet) {
      return questionSet.topicId.trim().toLowerCase() == normalizedTopicId;
    }).toList();
  }

  Future<List<QuestionSet>> loadQuestionSetsBySubject(String subjectId) async {
    final questionSets = await loadQuestionSets();
    final normalizedSubjectId = subjectId.trim().toLowerCase();

    return questionSets.where((questionSet) {
      return questionSet.subjectId.trim().toLowerCase() == normalizedSubjectId;
    }).toList();
  }
}
