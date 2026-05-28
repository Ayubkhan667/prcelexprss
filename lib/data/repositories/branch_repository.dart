import '../models/branch_model.dart';
import '../remote/branch_remote_data_source.dart';
import '../services/mock_data_service.dart';

abstract class BranchRepository {
  Future<List<BranchModel>> getBranches();

  Future<BranchModel?> getBranchById(String id);

  Future<void> saveBranch({
    required BranchModel branch,
    required bool isEdit,
  });
}

class MockBranchRepository implements BranchRepository {
  MockBranchRepository({required MockDataService dataService})
      : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<List<BranchModel>> getBranches() async {
    return _dataService.getBranches();
  }

  @override
  Future<BranchModel?> getBranchById(String id) async {
    return _dataService.getBranchById(id);
  }

  @override
  Future<void> saveBranch({
    required BranchModel branch,
    required bool isEdit,
  }) async {
    _dataService.upsertBranch(branch);
  }
}

class RemoteBranchRepository implements BranchRepository {
  RemoteBranchRepository({required BranchRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final BranchRemoteDataSource _remoteDataSource;

  @override
  Future<List<BranchModel>> getBranches() {
    return _remoteDataSource.fetchBranches();
  }

  @override
  Future<BranchModel?> getBranchById(String id) {
    return _remoteDataSource.fetchBranchById(id);
  }

  @override
  Future<void> saveBranch({
    required BranchModel branch,
    required bool isEdit,
  }) {
    return _remoteDataSource.saveBranch(branch: branch, isEdit: isEdit);
  }
}
