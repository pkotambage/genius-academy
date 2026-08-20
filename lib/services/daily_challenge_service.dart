import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/daily_challenge.dart';

class DailyChallengeService {
  static const String _manifestAssetPath =
      'assets/data/daily_challenges/daily_challenge_manifest.json';

  Future<List<DailyChallenge>> loadDailyChallenges() async {
    final modulePaths = await _loadModulePaths();
    final challenges = <DailyChallenge>[];

    for (final modulePath in modulePaths) {
      final challenge = await _loadChallengeModule(modulePath);

      if (challenge.isActive) {
        challenges.add(challenge);
      }
    }

    return challenges;
  }

  Future<DailyChallenge?> getChallengeForDate(DateTime date) async {
    final challenges = await loadDailyChallenges();

    final availableChallenges = challenges.where((challenge) {
      return challenge.isAvailableOn(date);
    }).toList();

    if (availableChallenges.isEmpty) {
      return null;
    }

    return availableChallenges.first;
  }

  Future<DailyChallenge?> getTodayChallenge() {
    return getChallengeForDate(DateTime.now());
  }

  Future<List<String>> _loadModulePaths() async {
    final jsonString = await rootBundle.loadString(_manifestAssetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw const FormatException(
        'Daily Challenge manifest must contain a JSON object.',
      );
    }

    final manifest = Map<String, dynamic>.from(decoded);
    final modulesData = manifest['dailyChallengeModules'];

    if (modulesData is! List) {
      throw const FormatException(
        'Daily Challenge manifest must contain a '
        'dailyChallengeModules list.',
      );
    }

    return modulesData
        .map((item) => item.toString().trim())
        .where((path) => path.isNotEmpty)
        .toList();
  }

  Future<DailyChallenge> _loadChallengeModule(
    String modulePath,
  ) async {
    final jsonString = await rootBundle.loadString(modulePath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! Map) {
      throw FormatException(
        'Daily Challenge module must contain a JSON object: '
        '$modulePath',
      );
    }

    return DailyChallenge.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}