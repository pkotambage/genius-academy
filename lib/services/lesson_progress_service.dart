import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_progress.dart';

class LessonProgressService {
  static const String _storageKey = 'lesson_progress';

  Future<Map<String, LessonProgress>> loadAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      return {};
    }

    final Map<String, LessonProgress> result = {};

    decoded.forEach((key, value) {
      result[key.toString()] = LessonProgress.fromJson(
        Map<String, dynamic>.from(value),
      );
    });

    return result;
  }

  Future<LessonProgress> getProgress(String lessonId) async {
    final progress = await loadAllProgress();

    return progress[lessonId] ?? LessonProgress.notStarted(lessonId: lessonId);
  }

  Future<void> saveProgress(LessonProgress progress) async {
    final prefs = await SharedPreferences.getInstance();

    final progressMap = await loadAllProgress();

    progressMap[progress.lessonId] = progress;

    final json = <String, dynamic>{};

    progressMap.forEach((key, value) {
      json[key] = value.toJson();
    });

    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Future<void> markLessonOpened(String lessonId) async {
    final current = await getProgress(lessonId);

    if (current.isCompleted) {
      return;
    }

    await saveProgress(
      current.copyWith(
        status: LessonProgressStatus.inProgress,
        progressPercentage: current.progressPercentage == 0
            ? 5
            : current.progressPercentage,
        lastOpenedAt: DateTime.now(),
      ),
    );
  }

  Future<void> completeLesson(String lessonId) async {
    final current = await getProgress(lessonId);

    await saveProgress(
      current.copyWith(
        status: LessonProgressStatus.completed,
        progressPercentage: 100,
        lastOpenedAt: DateTime.now(),
        completedAt: DateTime.now(),
      ),
    );
  }

  Future<void> resetLesson(String lessonId) async {
    final progress = await loadAllProgress();

    progress.remove(lessonId);

    final json = <String, dynamic>{};

    progress.forEach((key, value) {
      json[key] = value.toJson();
    });

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }
}
