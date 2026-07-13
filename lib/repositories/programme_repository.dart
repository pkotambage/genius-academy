import '../models/programme.dart';
import '../services/programme_service.dart';

class ProgrammeRepository {
  final ProgrammeService _programmeService;

  ProgrammeRepository({ProgrammeService? programmeService})
    : _programmeService = programmeService ?? ProgrammeService();

  Future<List<Programme>> getProgrammes() {
    return _programmeService.loadProgrammes();
  }

  Future<Programme?> getProgrammeById(String id) {
    return _programmeService.getProgrammeById(id);
  }

  Future<List<Programme>> getProgrammesByBranch(String branchId) {
    return _programmeService.loadProgrammesByBranch(branchId);
  }

  Future<List<Programme>> getFreeProgrammes() {
    return _programmeService.loadFreeProgrammes();
  }

  Future<List<Programme>> getPremiumProgrammes() {
    return _programmeService.loadPremiumProgrammes();
  }
}
