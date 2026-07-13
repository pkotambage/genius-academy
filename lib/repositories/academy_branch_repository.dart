import '../models/academy_branch.dart';
import '../services/academy_branch_service.dart';

class AcademyBranchRepository {
  final AcademyBranchService _academyBranchService;

  AcademyBranchRepository({AcademyBranchService? academyBranchService})
    : _academyBranchService = academyBranchService ?? AcademyBranchService();

  Future<List<AcademyBranch>> getBranches() {
    return _academyBranchService.loadBranches();
  }

  Future<AcademyBranch?> getBranchById(String id) {
    return _academyBranchService.getBranchById(id);
  }

  Future<List<AcademyBranch>> getFreeBranches() {
    return _academyBranchService.loadFreeBranches();
  }

  Future<List<AcademyBranch>> getPremiumBranches() {
    return _academyBranchService.loadPremiumBranches();
  }
}
