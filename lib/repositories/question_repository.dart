import '../models/question.dart';
import '../services/question_service.dart';

class QuestionRepository {
  final QuestionService _questionService;

  QuestionRepository({QuestionService? questionService})
    : _questionService = questionService ?? QuestionService();

  Future<List<Question>> getAllQuestions() {
    return _questionService.loadQuestions();
  }

  Future<Question?> getQuestionById(String id) {
    return _questionService.getQuestionById(id);
  }

  Future<List<Question>> getQuestionsByIds(
    List<String> questionIds, {
    bool includePremium = true,
  }) {
    return _questionService.loadQuestionsByIds(
      questionIds,
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
