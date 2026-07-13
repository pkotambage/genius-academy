import '../models/subject.dart';
import '../services/subject_service.dart';

class SubjectRepository {
  final SubjectService _subjectService;

  SubjectRepository({SubjectService? subjectService})
    : _subjectService = subjectService ?? SubjectService();

  Future<List<Subject>> getSubjects() {
    return _subjectService.loadSubjects();
  }

  Future<Subject?> getSubjectById(String id) {
    return _subjectService.getSubjectById(id);
  }

  Future<List<Subject>> getSubjectsByProgramme(String programmeId) {
    return _subjectService.loadSubjectsByProgramme(programmeId);
  }

  Future<List<Subject>> getFreeSubjects() {
    return _subjectService.loadFreeSubjects();
  }

  Future<List<Subject>> getPremiumSubjects() {
    return _subjectService.loadPremiumSubjects();
  }
}
