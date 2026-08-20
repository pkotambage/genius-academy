import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_challenge_progress.dart';

class DailyChallengeProgressService {
  static const String _storageKey = 'daily_challenge_progress';

  Future<Map<String, DailyChallengeProgress>> loadAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    final decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      return {};
    }

    final result = <String, DailyChallengeProgress>{};

    decoded.forEach((key, value) {
      if (value is Map) {
        result[key.toString()] = DailyChallengeProgress.fromJson(
          Map<String, dynamic>.from(value),
        );
      }
    });

    return result;
  }

  Future<DailyChallengeProgress?> getProgressForDate(
    DateTime date,
  ) async {
    final allProgress = await loadAllProgress();

    return allProgress[_dateKey(date)];
  }

  Future<DailyChallengeProgress?> getTodayProgress() {
    return getProgressForDate(DateTime.now());
  }

  Future<bool> isCompletedOn(DateTime date) async {
    final progress = await getProgressForDate(date);

    return progress != null;
  }

  Future<bool> isCompletedToday() {
    return isCompletedOn(DateTime.now());
  }

  Future<int> getCurrentStreak() async {
    final progress = await loadAllProgress();

    if (progress.isEmpty) {
      return 0;
    }

    var date = DateTime.now();

    final todayKey = _dateKey(date);

    if (!progress.containsKey(todayKey)) {
      date = date.subtract(const Duration(days: 1));
    }

    var streak = 0;

    while (progress.containsKey(_dateKey(date))) {
      streak++;

      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  Future<int> getCompletedDaysCount() async {
    final progress = await loadAllProgress();

    return progress.length;
  }

  Future<void> saveCompletion({
    required DateTime date,
    required String challengeId,
    required String questionSetId,
    required int score,
    required int totalQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final progressMap = await loadAllProgress();

    final dateKey = _dateKey(date);

    final existing = progressMap[dateKey];

    final progress = DailyChallengeProgress(
      dateKey: dateKey,
      challengeId: challengeId,
      questionSetId: questionSetId,
      score: existing == null
          ? score
          : score > existing.score
          ? score
          : existing.score,
      totalQuestions: totalQuestions,
      completedAt: existing?.completedAt ?? DateTime.now(),
    );

    progressMap[dateKey] = progress;

    final json = <String, dynamic>{};

    progressMap.forEach((key, value) {
      json[key] = value.toJson();
    });

    await prefs.setString(_storageKey, jsonEncode(json));
  }

  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_storageKey);
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}