import 'package:flutter/material.dart';

class QuizCategory {
  final String id;
  final String name;
  final String questionCategory;
  final String iconName;
  final int colorValue;
  final bool isPremium;
  final int sortOrder;
  final bool isActive;

  const QuizCategory({
    required this.id,
    required this.name,
    required this.questionCategory,
    required this.iconName,
    required this.colorValue,
    required this.isPremium,
    required this.sortOrder,
    required this.isActive,
  });

  Color get color => Color(colorValue);

  IconData get icon {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology_alt_outlined;

      case 'calculate':
        return Icons.calculate_outlined;

      case 'patterns':
        return Icons.grid_view_rounded;

      case 'relationship':
        return Icons.account_tree_outlined;

      case 'mathematical_intelligence':
        return Icons.functions_outlined;

      default:
        return Icons.quiz_outlined;
    }
  }

  factory QuizCategory.fromJson(Map<String, dynamic> json) {
    return QuizCategory(
      id: json['id']?.toString().trim() ?? '',
      name: json['name']?.toString().trim() ?? '',
      questionCategory: json['questionCategory']?.toString().trim() ?? '',
      iconName: json['iconName']?.toString().trim() ?? 'quiz',
      colorValue: _parseColorValue(json['colorValue']),
      isPremium: _parseBool(json['isPremium']),
      sortOrder: _parseInt(json['sortOrder']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static int _parseColorValue(dynamic value) {
    if (value is int) {
      return value;
    }

    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return 0xFF1565C0;
    }

    final normalized = text
        .replaceFirst('#', '')
        .replaceFirst('0x', '')
        .replaceFirst('0X', '');

    final parsedValue = int.tryParse(normalized, radix: 16);

    if (parsedValue == null) {
      return 0xFF1565C0;
    }

    if (normalized.length == 6) {
      return 0xFF000000 | parsedValue;
    }

    return parsedValue;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) {
      return defaultValue;
    }

    if (value is bool) {
      return value;
    }

    final text = value.toString().trim().toLowerCase();

    if (text == 'true' || text == '1' || text == 'yes') {
      return true;
    }

    if (text == 'false' || text == '0' || text == 'no') {
      return false;
    }

    return defaultValue;
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}
