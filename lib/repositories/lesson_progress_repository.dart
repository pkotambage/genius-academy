import '../models/lesson_progress.dart';
import '../services/lesson_progress_service.dart';

class LessonProgressRepository {
  final LessonProgressService _lessonProgressService;

  LessonProgressRepository({LessonProgressService? lessonProgressService})
    : _lessonProgressService = lessonProgressService ?? LessonProgressService();

  Future<Map<String, LessonProgress>> getAllProgress() {
    return _lessonProgressService.loadAllProgress();
  }

  Future<LessonProgress> getProgress(String lessonId) {
    return _lessonProgressService.getProgress(lessonId);
  }

  Future<void> markLessonOpened(String lessonId) {
    return _lessonProgressService.markLessonOpened(lessonId);
  }

  Future<void> completeLesson(String lessonId) {
    return _lessonProgressService.completeLesson(lessonId);
  }

  Future<void> resetLesson(String lessonId) {
    return _lessonProgressService.resetLesson(lessonId);
  }

  Future<void> clearAllProgress() {
    return _lessonProgressService.clearAllProgress();
  }
}
