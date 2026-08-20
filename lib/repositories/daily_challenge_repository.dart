import '../models/daily_challenge.dart';
import '../services/daily_challenge_service.dart';

class DailyChallengeRepository {
  final DailyChallengeService _dailyChallengeService;

  DailyChallengeRepository({
    DailyChallengeService? dailyChallengeService,
  }) : _dailyChallengeService =
           dailyChallengeService ?? DailyChallengeService();

  Future<List<DailyChallenge>> getDailyChallenges() {
    return _dailyChallengeService.loadDailyChallenges();
  }

  Future<DailyChallenge?> getChallengeForDate(DateTime date) {
    return _dailyChallengeService.getChallengeForDate(date);
  }

  Future<DailyChallenge?> getTodayChallenge() {
    return _dailyChallengeService.getTodayChallenge();
  }
}