class QuestionSet {
  final String id;
  final String title;
  final String description;
  final String assessmentType;

  final String branchId;
  final String programmeId;
  final String subjectId;
  final String topicId;
  final String? lessonId;

  final List<String> questionIds;

  final bool shuffleQuestions;
  final bool shuffleOptions;

  final int? maximumQuestions;
  final int? timeLimitSeconds;
  final double passPercentage;

  final bool isPremium;
  final bool isActive;

  const QuestionSet({
    required this.id,
    required this.title,
    required this.description,
    required this.assessmentType,
    required this.branchId,
    required this.programmeId,
    required this.subjectId,
    required this.topicId,
    required this.questionIds,
    required this.shuffleQuestions,
    required this.shuffleOptions,
    required this.passPercentage,
    required this.isPremium,
    required this.isActive,
    this.lessonId,
    this.maximumQuestions,
    this.timeLimitSeconds,
  });

  bool get isTimed {
    return timeLimitSeconds != null && timeLimitSeconds! > 0;
  }

  bool get hasQuestionLimit {
    return maximumQuestions != null && maximumQuestions! > 0;
  }

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    return QuestionSet(
      id: _parseString(json['id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      assessmentType: _parseString(
        json['assessmentType'],
        defaultValue: 'lesson_quiz',
      ),
      branchId: _parseString(json['branchId']),
      programmeId: _parseString(json['programmeId']),
      subjectId: _parseString(json['subjectId']),
      topicId: _parseString(json['topicId']),
      lessonId: _parseNullableString(json['lessonId']),
      questionIds: _parseStringList(json['questionIds']),
      shuffleQuestions: _parseBool(
        json['shuffleQuestions'],
        defaultValue: false,
      ),
      shuffleOptions: _parseBool(json['shuffleOptions'], defaultValue: false),
      maximumQuestions: _parseNullableInt(json['maximumQuestions']),
      timeLimitSeconds: _parseNullableInt(json['timeLimitSeconds']),
      passPercentage: _parseDouble(json['passPercentage'], defaultValue: 70),
      isPremium: _parseBool(json['isPremium']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
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

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString().trim());
  }

  static double _parseDouble(dynamic value, {required double defaultValue}) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString().trim() ?? '') ?? defaultValue;
  }
}
