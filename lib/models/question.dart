class Question {
  final String id;

  // Existing quiz grouping field.
  final String category;

  // Curriculum mapping.
  final String branchId;
  final String programmeId;
  final String subjectId;
  final String topicId;
  final String? lessonId;

  // Question content.
  final String question;
  final List<String> options;
  final String correctAnswer;

  // Explanation content.
  final String explanation;
  final String? explanationVideoUrl;
  final String? explanationVideoProvider;
  final String? explanationVideoTitle;

  // Optional visual content.
  final String? questionImageUrl;
  final String? explanationImageUrl;

  // Classification and reuse.
  final String difficulty;
  final List<String> competencyIds;
  final List<String> examTags;

  // Source information from your tutes.
  final String? sourceTitle;
  final String? sourceReference;

  final bool isPremium;
  final bool isActive;

  const Question({
    required this.id,
    required this.category,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.difficulty,
    required this.isPremium,
    this.branchId = '',
    this.programmeId = '',
    this.subjectId = '',
    this.topicId = '',
    this.lessonId,
    this.explanationVideoUrl,
    this.explanationVideoProvider,
    this.explanationVideoTitle,
    this.questionImageUrl,
    this.explanationImageUrl,
    this.competencyIds = const [],
    this.examTags = const [],
    this.sourceTitle,
    this.sourceReference,
    this.isActive = true,
  });

  bool get hasExplanation {
    return explanation.trim().isNotEmpty;
  }

  bool get hasExplanationVideo {
    return explanationVideoUrl != null &&
        explanationVideoUrl!.trim().isNotEmpty;
  }

  bool get hasQuestionImage {
    return questionImageUrl != null && questionImageUrl!.trim().isNotEmpty;
  }

  bool get hasExplanationImage {
    return explanationImageUrl != null &&
        explanationImageUrl!.trim().isNotEmpty;
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: _parseString(json['id']),
      category: _parseString(json['category']),
      branchId: _parseString(json['branchId']),
      programmeId: _parseString(json['programmeId']),
      subjectId: _parseString(json['subjectId']),
      topicId: _parseString(json['topicId']),
      lessonId: _parseNullableString(json['lessonId']),
      question: _parseString(json['question']),
      options: _parseOptions(json['options']),
      correctAnswer: _parseString(json['correctAnswer']),
      explanation: _parseString(json['explanation']),
      explanationVideoUrl: _parseNullableString(json['explanationVideoUrl']),
      explanationVideoProvider: _parseNullableString(
        json['explanationVideoProvider'],
      ),
      explanationVideoTitle: _parseNullableString(
        json['explanationVideoTitle'],
      ),
      questionImageUrl: _parseNullableString(json['questionImageUrl']),
      explanationImageUrl: _parseNullableString(json['explanationImageUrl']),
      difficulty: _parseString(json['difficulty'], defaultValue: 'Foundation'),
      competencyIds: _parseStringList(json['competencyIds']),
      examTags: _parseStringList(json['examTags']),
      sourceTitle: _parseNullableString(json['sourceTitle']),
      sourceReference: _parseNullableString(json['sourceReference']),
      isPremium: _parseBool(json['isPremium']),
      isActive: _parseBool(json['isActive'], defaultValue: true),
    );
  }

  static List<String> _parseOptions(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return const [];
    }

    return text
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return const [];
    }

    return text
        .split('|')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
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
}
