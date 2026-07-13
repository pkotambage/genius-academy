import '../models/question.dart';
import '../services/question_service.dart';

class QuestionRepository {
  final QuestionService _questionService;

  QuestionRepository({QuestionService? questionService})
    : _questionService = questionService ?? QuestionService();

  Future<List<Question>> getAllQuestions() {
    return _questionService.loadQuestions();
  }

  Future<List<Question>> getQuestionsByCategory(
    String category, {
    bool includePremium = true,
  }) {
    return _questionService.loadQuestionsByCategory(
      category,
      includePremium: includePremium,
    );
  }

  Future<List<Question>> getQuestionsByDifficulty(
    String difficulty, {
    bool includePremium = true,
  }) {
    return _questionService.loadQuestionsByDifficulty(
      difficulty,
      includePremium: includePremium,
    );
  }

  Future<List<Question>> getFreeQuestions() {
    return _questionService.loadFreeQuestions();
  }

  Future<List<Question>> getPremiumQuestions() {
    return _questionService.loadPremiumQuestions();
  }
}
