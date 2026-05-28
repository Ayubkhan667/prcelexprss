import '../models/shift_model.dart';
import '../remote/shift_remote_data_source.dart';
import '../services/mock_data_service.dart';

abstract class ShiftRepository {
  Future<List<ShiftModel>> getShifts();

  Future<ShiftModel?> getShiftById(String id);

  Future<void> saveShift({
    required ShiftModel shift,
    required bool isEdit,
  });
}

class MockShiftRepository implements ShiftRepository {
  MockShiftRepository({required MockDataService dataService})
      : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<List<ShiftModel>> getShifts() async {
    return _dataService.getShifts();
  }

  @override
  Future<ShiftModel?> getShiftById(String id) async {
    return _dataService.getShiftById(id);
  }

  @override
  Future<void> saveShift({
    required ShiftModel shift,
    required bool isEdit,
  }) async {
    _dataService.saveShift(shift);
  }
}

class RemoteShiftRepository implements ShiftRepository {
  RemoteShiftRepository({required ShiftRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ShiftRemoteDataSource _remoteDataSource;

  @override
  Future<List<ShiftModel>> getShifts() {
    return _remoteDataSource.fetchShifts();
  }

  @override
  Future<ShiftModel?> getShiftById(String id) {
    return _remoteDataSource.fetchShiftById(id);
  }

  @override
  Future<void> saveShift({
    required ShiftModel shift,
    required bool isEdit,
  }) {
    return _remoteDataSource.saveShift(shift: shift, isEdit: isEdit);
  }
}
