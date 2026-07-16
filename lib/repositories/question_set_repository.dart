import '../models/question_set.dart';
import '../services/question_set_service.dart';

class QuestionSetRepository {
  final QuestionSetService _questionSetService;

  QuestionSetRepository({QuestionSetService? questionSetService})
    : _questionSetService = questionSetService ?? QuestionSetService();

  Future<List<QuestionSet>> getQuestionSets() {
    return _questionSetService.loadQuestionSets();
  }

  Future<QuestionSet?> getQuestionSetById(String id) {
    return _questionSetService.getQuestionSetById(id);
  }

  Future<List<QuestionSet>> getQuestionSetsByLesson(String lessonId) {
    return _questionSetService.loadQuestionSetsByLesson(lessonId);
  }

  Future<List<QuestionSet>> getQuestionSetsByTopic(String topicId) {
    return _questionSetService.loadQuestionSetsByTopic(topicId);
  }

  Future<List<QuestionSet>> getQuestionSetsBySubject(String subjectId) {
    return _questionSetService.loadQuestionSetsBySubject(subjectId);
  }
}
