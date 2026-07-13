import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/subject.dart';

class SubjectService {
  static const String _assetPath = 'assets/data/subjects.json';

  Future<List<Subject>> loadSubjects() async {
    final String jsonString = await rootBundle.loadString(_assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Subjects JSON must contain a list.');
    }

    final subjects = decoded
        .whereType<Map>()
        .map((item) => Subject.fromJson(Map<String, dynamic>.from(item)))
        .where((subject) => subject.isActive)
        .toList();

    subjects.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return subjects;
  }

  Future<Subject?> getSubjectById(String id) async {
    final subjects = await loadSubjects();

    try {
      return subjects.firstWhere(
        (subject) => subject.id.trim().toLowerCase() == id.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Subject>> loadSubjectsByProgramme(String programmeId) async {
    final subjects = await loadSubjects();

    return subjects.where((subject) {
      return subject.programmeId.trim().toLowerCase() ==
          programmeId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Subject>> loadFreeSubjects() async {
    final subjects = await loadSubjects();

    return subjects.where((subject) => !subject.isPremium).toList();
  }

  Future<List<Subject>> loadPremiumSubjects() async {
    final subjects = await loadSubjects();

    return subjects.where((subject) => subject.isPremium).toList();
  }
}
