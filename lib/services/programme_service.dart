import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/programme.dart';

class ProgrammeService {
  static const String _assetPath = 'assets/data/programmes.json';

  Future<List<Programme>> loadProgrammes() async {
    final String jsonString = await rootBundle.loadString(_assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Programmes JSON must contain a list.');
    }

    final programmes = decoded
        .whereType<Map>()
        .map((item) => Programme.fromJson(Map<String, dynamic>.from(item)))
        .where((programme) => programme.isActive)
        .toList();

    programmes.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return programmes;
  }

  Future<Programme?> getProgrammeById(String id) async {
    final programmes = await loadProgrammes();

    try {
      return programmes.firstWhere(
        (programme) =>
            programme.id.trim().toLowerCase() == id.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<Programme>> loadProgrammesByBranch(String branchId) async {
    final programmes = await loadProgrammes();

    return programmes.where((programme) {
      return programme.branchId.trim().toLowerCase() ==
          branchId.trim().toLowerCase();
    }).toList();
  }

  Future<List<Programme>> loadFreeProgrammes() async {
    final programmes = await loadProgrammes();

    return programmes.where((programme) => !programme.isPremium).toList();
  }

  Future<List<Programme>> loadPremiumProgrammes() async {
    final programmes = await loadProgrammes();

    return programmes.where((programme) => programme.isPremium).toList();
  }
}
