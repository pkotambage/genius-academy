import '../models/daily_challenge_progress.dart';
import '../services/daily_challenge_progress_service.dart';

class DailyChallengeProgressRepository {
  final DailyChallengeProgressService _progressService;

  DailyChallengeProgressRepository({
    DailyChallengeProgressService? progressService,
  }) : _progressService =
           progressService ?? DailyChallengeProgressService();

  Future<Map<String, DailyChallengeProgress>> getAllProgress() {
    return _progressService.loadAllProgress();
  }

  Future<DailyChallengeProgress?> getProgressForDate(
    DateTime date,
  ) {
    return _progressService.getProgressForDate(date);
  }

  Future<DailyChallengeProgress?> getTodayProgress() {
    return _progressService.getTodayProgress();
  }

  Future<bool> isCompletedToday() {
    return _progressService.isCompletedToday();
  }

  Future<int> getCurrentStreak() {
    return _progressService.getCurrentStreak();
  }

  Future<int> getCompletedDaysCount() {
    return _progressService.getCompletedDaysCount();
  }

  Future<void> saveCompletion({
    required DateTime date,
    required String challengeId,
    required String questionSetId,
    required int score,
    required int totalQuestions,
  }) {
    return _progressService.saveCompletion(
      date: date,
      challengeId: challengeId,
      questionSetId: questionSetId,
      score: score,
      totalQuestions: totalQuestions,
    );
  }

  Future<void> clearAllProgress() {
    return _progressService.clearAllProgress();
  }
}