import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/quiz_category.dart';

class CategoryService {
  static const String _assetPath = 'assets/data/quiz_categories.json';

  Future<List<QuizCategory>> loadCategories() async {
    final jsonString = await rootBundle.loadString(_assetPath);

    final dynamic decoded = jsonDecode(jsonString);

    if (decoded is! List) {
      throw const FormatException('Category JSON must contain a list.');
    }

    final categories = decoded
        .map(
          (item) =>
              QuizCategory.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .where((category) => category.isActive)
        .toList();

    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return categories;
  }

  Future<QuizCategory?> getCategoryById(String id) async {
    final categories = await loadCategories();

    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<QuizCategory>> loadFreeCategories() async {
    final categories = await loadCategories();

    return categories.where((category) => !category.isPremium).toList();
  }

  Future<List<QuizCategory>> loadPremiumCategories() async {
    final categories = await loadCategories();

    return categories.where((category) => category.isPremium).toList();
  }
}
