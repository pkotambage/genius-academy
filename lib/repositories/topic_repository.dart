import '../models/topic.dart';
import '../services/topic_service.dart';

class TopicRepository {
  final TopicService _topicService;

  TopicRepository({TopicService? topicService})
    : _topicService = topicService ?? TopicService();

  Future<List<Topic>> getTopics() {
    return _topicService.loadTopics();
  }

  Future<Topic?> getTopicById(String id) {
    return _topicService.getTopicById(id);
  }

  Future<List<Topic>> getTopicsBySubject(String subjectId) {
    return _topicService.loadTopicsBySubject(subjectId);
  }

  Future<List<Topic>> getFreeTopics() {
    return _topicService.loadFreeTopics();
  }

  Future<List<Topic>> getPremiumTopics() {
    return _topicService.loadPremiumTopics();
  }
}
