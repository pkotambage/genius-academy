import '../models/lesson.dart';
import '../services/lesson_service.dart';

class LessonRepository {
  final LessonService _lessonService;

  LessonRepository({LessonService? lessonService})
    : _lessonService = lessonService ?? LessonService();

  Future<List<Lesson>> getLessons() {
    return _lessonService.loadLessons();
  }

  Future<Lesson?> getLessonById(String id) {
    return _lessonService.getLessonById(id);
  }

  Future<List<Lesson>> getLessonsByBranch(String branchId) {
    return _lessonService.loadLessonsByBranch(branchId);
  }

  Future<List<Lesson>> getLessonsByProgramme(String programmeId) {
    return _lessonService.loadLessonsByProgramme(programmeId);
  }

  Future<List<Lesson>> getLessonsBySubject(String subjectId) {
    return _lessonService.loadLessonsBySubject(subjectId);
  }

  Future<List<Lesson>> getLessonsByTopic(String topicId) {
    return _lessonService.loadLessonsByTopic(topicId);
  }

  Future<List<Lesson>> getFreeLessons() {
    return _lessonService.loadFreeLessons();
  }

  Future<List<Lesson>> getPremiumLessons() {
    return _lessonService.loadPremiumLessons();
  }
}
