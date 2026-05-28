import '../models/staff_model.dart';
import '../models/staff_save_result.dart';
import '../models/user_model.dart';
import '../remote/staff_remote_data_source.dart';
import '../services/mock_data_service.dart';

abstract class StaffRepository {
  Future<List<StaffModel>> getStaffList({
    String? branchId,
    String? department,
    String? category,
    String? status,
    String? searchQuery,
  });

  Future<StaffModel?> getStaffById(String id);

  Future<StaffModel?> getStaffByUserId(String userId);

  Future<StaffSaveResult> saveStaff({
    required StaffModel staff,
    required UserModel user,
    required bool isEdit,
  });

  Future<void> resetDeviceBinding(String staffId);
}

class MockStaffRepository implements StaffRepository {
  MockStaffRepository({required MockDataService dataService})
      : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<List<StaffModel>> getStaffList({
    String? branchId,
    String? department,
    String? category,
    String? status,
    String? searchQuery,
  }) async {
    return _dataService.getStaffList(
      branchId: branchId,
      department: department,
      category: category,
      status: status,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<StaffModel?> getStaffById(String id) async {
    return _dataService.getStaffById(id);
  }

  @override
  Future<StaffModel?> getStaffByUserId(String userId) async {
    return _dataService.getStaffByUserId(userId);
  }

  @override
  Future<StaffSaveResult> saveStaff({
    required StaffModel staff,
    required UserModel user,
    required bool isEdit,
  }) async {
    _dataService.upsertStaff(staff: staff, user: user);
    return const StaffSaveResult();
  }

  @override
  Future<void> resetDeviceBinding(String staffId) async {
    _dataService.resetStaffDeviceBinding(staffId);
  }
}

class RemoteStaffRepository implements StaffRepository {
  RemoteStaffRepository({required StaffRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final StaffRemoteDataSource _remoteDataSource;

  @override
  Future<List<StaffModel>> getStaffList({
    String? branchId,
    String? department,
    String? category,
    String? status,
    String? searchQuery,
  }) {
    return _remoteDataSource.fetchStaffList(
      branchId: branchId,
      department: department,
      category: category,
      status: status,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<StaffModel?> getStaffById(String id) {
    return _remoteDataSource.fetchStaffById(id);
  }

  @override
  Future<StaffModel?> getStaffByUserId(String userId) {
    return _remoteDataSource.fetchStaffByUserId(userId);
  }

  @override
  Future<StaffSaveResult> saveStaff({
    required StaffModel staff,
    required UserModel user,
    required bool isEdit,
  }) {
    return _remoteDataSource.saveStaff(
      staff: staff,
      user: user,
      isEdit: isEdit,
    );
  }

  @override
  Future<void> resetDeviceBinding(String staffId) {
    return _remoteDataSource.resetDeviceBinding(staffId);
  }
}
