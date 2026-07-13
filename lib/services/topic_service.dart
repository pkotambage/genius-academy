import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/topic.dart';

class TopicService {
  static const String _assetPath = 'assets/data/topics.json';

  Future<List<Topic>> loadTopics() async {
    final String jsonString = await rootBundle.loadString(_assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Topics JSON must contain a list.');
    }

    final topics = decoded
        .whereType<Map>()
        .map((item) => Topic.fromJson(Map<String, dynamic>.from(item)))
        .where((topic) => topic.isActive)
        .toList();

    topics.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return topics;
  }

  Future<Topic?> getTopicById(String id) async {
    final topics = await loadTopics();

    try {
      return topics.firstWhere(
        (topic) => topic.id.trim().toLowerCase() == id.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Topic>> loadTopicsBySubject(String subjectId) async {
    final topics = await loadTopics();

    return topics.where((topic) {
      return topic.subjectId.trim().toLowerCase() ==
          subjectId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Topic>> loadFreeTopics() async {
    final topics = await loadTopics();

    return topics.where((topic) => !topic.isPremium).toList();
  }

  Future<List<Topic>> loadPremiumTopics() async {
    final topics = await loadTopics();

    return topics.where((topic) => topic.isPremium).toList();
  }
}
