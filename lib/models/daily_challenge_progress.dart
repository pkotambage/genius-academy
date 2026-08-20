class DailyChallengeProgress {
  final String dateKey;
  final String challengeId;
  final String questionSetId;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  const DailyChallengeProgress({
    required this.dateKey,
    required this.challengeId,
    required this.questionSetId,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  double get percentage {
    if (totalQuestions <= 0) {
      return 0;
    }

    return (score / totalQuestions) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'challengeId': challengeId,
      'questionSetId': questionSetId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory DailyChallengeProgress.fromJson(Map<String, dynamic> json) {
    return DailyChallengeProgress(
      dateKey: json['dateKey']?.toString().trim() ?? '',
      challengeId: json['challengeId']?.toString().trim() ?? '',
      questionSetId: json['questionSetId']?.toString().trim() ?? '',
      score: _parseInt(json['score']),
      totalQuestions: _parseInt(json['totalQuestions']),
      completedAt:
          DateTime.tryParse(
            json['completedAt']?.toString().trim() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString().trim() ?? '') ?? 0;
  }
}