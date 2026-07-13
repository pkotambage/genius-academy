class Topic {
  final String id;
  final String subjectId;

  final String title;
  final String description;

  final String iconName;
  final int colorValue;

  final int sortOrder;
  final bool isPremium;
  final bool isActive;

  const Topic({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.iconName,
    required this.colorValue,
    required this.sortOrder,
    required this.isPremium,
    required this.isActive,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id']?.toString().trim() ?? '',
      subjectId: json['subjectId']?.toString().trim() ?? '',
      title: json['title']?.toString().trim() ?? '',
      description: json['description']?.toString().trim() ?? '',
      iconName: json['iconName']?.toString().trim() ?? 'category',
      colorValue: _parseColorValue(json['colorValue']),
      sortOrder: _parseInt(json['sortOrder']),
      isPremium: _parseBool(json['isPremium']),
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

    final parsed = int.tryParse(normalized, radix: 16);

    if (parsed == null) {
      return 0xFF1565C0;
    }

    if (normalized.length == 6) {
      return 0xFF000000 | parsed;
    }

    return parsed;
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
