enum LessonProgressStatus { notStarted, inProgress, completed }

class LessonProgress {
  final String lessonId;
  final LessonProgressStatus status;
  final int progressPercentage;
  final DateTime? lastOpenedAt;
  final DateTime? completedAt;

  const LessonProgress({
    required this.lessonId,
    required this.status,
    required this.progressPercentage,
    this.lastOpenedAt,
    this.completedAt,
  });

  factory LessonProgress.notStarted({required String lessonId}) {
    return LessonProgress(
      lessonId: lessonId,
      status: LessonProgressStatus.notStarted,
      progressPercentage: 0,
    );
  }

  bool get isStarted {
    return status != LessonProgressStatus.notStarted;
  }

  bool get isCompleted {
    return status == LessonProgressStatus.completed;
  }

  LessonProgress copyWith({
    String? lessonId,
    LessonProgressStatus? status,
    int? progressPercentage,
    DateTime? lastOpenedAt,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return LessonProgress(
      lessonId: lessonId ?? this.lessonId,
      status: status ?? this.status,
      progressPercentage: _normalizePercentage(
        progressPercentage ?? this.progressPercentage,
      ),
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'status': status.name,
      'progressPercentage': progressPercentage,
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId']?.toString().trim() ?? '',
      status: _parseStatus(json['status']),
      progressPercentage: _normalizePercentage(
        _parseInt(json['progressPercentage']),
      ),
      lastOpenedAt: _parseDateTime(json['lastOpenedAt']),
      completedAt: _parseDateTime(json['completedAt']),
    );
  }

  static LessonProgressStatus _parseStatus(dynamic value) {
    final text = value?.toString().trim().toLowerCase();

    switch (text) {
      case 'inprogress':
      case 'in_progress':
      case 'in-progress':
        return LessonProgressStatus.inProgress;

      case 'completed':
        return LessonProgressStatus.completed;

      case 'notstarted':
      case 'not_started':
      case 'not-started':
      default:
        return LessonProgressStatus.notStarted;
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString().trim();

    if (text == null || text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }

  static int _normalizePercentage(int value) {
    return value.clamp(0, 100);
  }
}
