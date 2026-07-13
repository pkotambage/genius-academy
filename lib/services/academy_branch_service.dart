import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/academy_branch.dart';

class AcademyBranchService {
  static const String _assetPath = 'assets/data/academy_branches.json';

  Future<List<AcademyBranch>> loadBranches() async {
    final jsonString = await rootBundle.loadString(_assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Academy branch JSON must contain a list.');
    }

    final branches = decoded
        .map(
          (item) =>
              AcademyBranch.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .where((branch) => branch.isActive)
        .toList();

    branches.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return branches;
  }

  Future<AcademyBranch?> getBranchById(String id) async {
    final branches = await loadBranches();

    try {
      return branches.firstWhere(
        (branch) => branch.id.trim().toLowerCase() == id.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<AcademyBranch>> loadFreeBranches() async {
    final branches = await loadBranches();

    return branches.where((branch) => !branch.isPremium).toList();
  }

  Future<List<AcademyBranch>> loadPremiumBranches() async {
    final branches = await loadBranches();

    return branches.where((branch) => branch.isPremium).toList();
  }
}
