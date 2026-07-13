import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';

class LessonService {
  static const String _manifestAssetPath =
      'assets/data/lesson_manifest.json';

  Future<List<Lesson>> loadLessons() async {
    final modulePaths = await _loadLessonModulePaths();

    final lessons = <Lesson>[];

    for (final modulePath in modulePaths) {
      final moduleLessons = await _loadLessonModule(modulePath);
      lessons.addAll(moduleLessons);
    }

    lessons.sort((a, b) {
      final topicComparison = a.topicId.compareTo(b.topicId);

      if (topicComparison != 0) {
        return topicComparison;
      }

      return a.sortOrder.compareTo(b.sortOrder);
    });

    return lessons;
  }

  Future<List<String>> _loadLessonModulePaths() async {
    final jsonString = await rootBundle.loadString(
      _manifestAssetPath,
    );

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'Lesson manifest must contain a JSON object.',
      );
    }

    final manifest = Map<String, dynamic>.from(decoded);
    final modulesData = manifest['lessonModules'];

    if (modulesData is! List) {
      throw const FormatException(
        'Lesson manifest must contain a lessonModules list.',
      );
    }

    final modulePaths = modulesData
        .map((item) => item.toString().trim())
        .where((path) => path.isNotEmpty)
        .toList();

    if (modulePaths.isEmpty) {
      throw const FormatException(
        'Lesson manifest contains no lesson modules.',
      );
    }

    return modulePaths;
  }

  Future<List<Lesson>> _loadLessonModule(
    String modulePath,
  ) async {
    final jsonString = await rootBundle.loadString(modulePath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw FormatException(
        'Lesson module must contain a JSON list: $modulePath',
      );
    }

    return decoded
        .whereType<Map>()
        .map(
          (item) => Lesson.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where((lesson) => lesson.isActive)
        .toList();
  }

  Future<Lesson?> getLessonById(String id) async {
    final lessons = await loadLessons();

    try {
      return lessons.firstWhere(
        (lesson) =>
            lesson.id.trim().toLowerCase() ==
            id.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Lesson>> loadLessonsByBranch(
    String branchId,
  ) async {
    final lessons = await loadLessons();

    return lessons.where((lesson) {
      return lesson.branchId.trim().toLowerCase() ==
          branchId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Lesson>> loadLessonsByProgramme(
    String programmeId,
  ) async {
    final lessons = await loadLessons();

    return lessons.where((lesson) {
      return lesson.programmeId.trim().toLowerCase() ==
          programmeId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Lesson>> loadLessonsBySubject(
    String subjectId,
  ) async {
    final lessons = await loadLessons();

    return lessons.where((lesson) {
      return lesson.subjectId.trim().toLowerCase() ==
          subjectId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Lesson>> loadLessonsByTopic(
    String topicId,
  ) async {
    final lessons = await loadLessons();

    return lessons.where((lesson) {
      return lesson.topicId.trim().toLowerCase() ==
          topicId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Lesson>> loadFreeLessons() async {
    final lessons = await loadLessons();

    return lessons
        .where((lesson) => !lesson.isPremium)
        .toList();
  }

  Future<List<Lesson>> loadPremiumLessons() async {
    final lessons = await loadLessons();

    return lessons
        .where((lesson) => lesson.isPremium)
        .toList();
  }
}