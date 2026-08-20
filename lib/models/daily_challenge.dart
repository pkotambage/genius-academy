class DailyChallenge {
  final String id;
  final String title;
  final String description;

  /// Connects Daily Challenge to the existing Assessment Engine.
  final String questionSetId;

  /// Inclusive starting date in YYYY-MM-DD format.
  ///
  /// Null means the challenge has no lower date boundary.
  final String? availableFrom;

  /// Inclusive ending date in YYYY-MM-DD format.
  ///
  /// Null means the challenge remains available indefinitely.
  final String? availableUntil;

  final bool isActive;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.questionSetId,
    required this.isActive,
    this.availableFrom,
    this.availableUntil,
  });

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: _parseString(json['id']),
      title: _parseString(
        json['title'],
        defaultValue: 'Daily Challenge',
      ),
      description: _parseString(json['description']),
      questionSetId: _parseString(json['questionSetId']),
      availableFrom: _parseNullableString(json['availableFrom']),
      availableUntil: _parseNullableString(json['availableUntil']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  bool isAvailableOn(DateTime date) {
    if (!isActive) {
      return false;
    }

    final targetDate = DateTime(date.year, date.month, date.day);

    final startDate = _parseDate(availableFrom);
    final endDate = _parseDate(availableUntil);

    if (startDate != null && targetDate.isBefore(startDate)) {
      return false;
    }

    if (endDate != null && targetDate.isAfter(endDate)) {
      return false;
    }

    return true;
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = DateTime.tryParse(value.trim());

    if (parsed == null) {
      return null;
    }

    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static String _parseString(
    dynamic value, {
    String defaultValue = '',
  }) {
    final text = value?.toString().trim() ?? '';

    return text.isEmpty ? defaultValue : text;
  }

  static String? _parseNullableString(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return text;
  }

  static bool _parseBool(
    dynamic value, {
    bool defaultValue = false,
  }) {
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
}