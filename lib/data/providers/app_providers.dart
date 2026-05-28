import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../services/mock_data_service.dart';
import '../models/staff_model.dart';
import '../models/attendance_model.dart';
import '../models/branch_model.dart';
import '../models/shift_model.dart';
import '../models/salary_model.dart';
import '../models/loan_model.dart';
import '../models/leave_model.dart';
import '../models/kpi_model.dart';
import '../models/notification_model.dart';
import '../models/attendance_edit_log_model.dart';
import '../models/document_alert_model.dart';
import '../models/task_model.dart';
import '../models/expense_model.dart';
import '../models/helpdesk_ticket_model.dart';
import '../models/holiday_model.dart';
import '../models/shift_roster_model.dart';
import '../models/shift_swap_request_model.dart';
import '../remote/attendance_remote_data_source.dart';
import '../remote/branch_remote_data_source.dart';
import '../remote/hr_operations_remote_data_source.dart';
import '../remote/shift_remote_data_source.dart';
import '../remote/staff_remote_data_source.dart';
import '../repositories/attendance_repository.dart';
import '../repositories/branch_repository.dart';
import '../repositories/hr_operations_repository.dart';
import '../repositories/shift_repository.dart';
import '../repositories/staff_repository.dart';
import 'api_config_provider.dart';
import 'auth_provider.dart';

final mockDataServiceProvider =
    Provider<MockDataService>((ref) => MockDataService());
final mockDataRevisionProvider = StateProvider<int>((ref) => 0);
final useRemoteDataProvider =
    Provider<bool>((ref) => ref.watch(apiConfigProvider).canUseRemote);

final staffRemoteDataSourceProvider = Provider<StaffRemoteDataSource>((ref) {
  return ApiStaffRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final branchRemoteDataSourceProvider = Provider<BranchRemoteDataSource>((ref) {
  return ApiBranchRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final shiftRemoteDataSourceProvider = Provider<ShiftRemoteDataSource>((ref) {
  return ApiShiftRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final attendanceRemoteDataSourceProvider =
    Provider<AttendanceRemoteDataSource>((ref) {
  return ApiAttendanceRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final hrOperationsRemoteDataSourceProvider =
    Provider<HrOperationsRemoteDataSource>((ref) {
  return ApiHrOperationsRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
});

final staffRepositoryProvider = Provider<StaffRepository>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) {
    return MockStaffRepository(
      dataService: ref.watch(mockDataServiceProvider),
    );
  }

  return RemoteStaffRepository(
    remoteDataSource: ref.watch(staffRemoteDataSourceProvider),
  );
});

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) {
    return MockBranchRepository(
      dataService: ref.watch(mockDataServiceProvider),
    );
  }

  return RemoteBranchRepository(
    remoteDataSource: ref.watch(branchRemoteDataSourceProvider),
  );
});

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) {
    return MockShiftRepository(
      dataService: ref.watch(mockDataServiceProvider),
    );
  }

  return RemoteShiftRepository(
    remoteDataSource: ref.watch(shiftRemoteDataSourceProvider),
  );
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) {
    return MockAttendanceRepository(
      dataService: ref.watch(mockDataServiceProvider),
    );
  }

  return RemoteAttendanceRepository(
    remoteDataSource: ref.watch(attendanceRemoteDataSourceProvider),
  );
});

final hrOperationsRepositoryProvider = Provider<HrOperationsRepository>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) {
    return MockHrOperationsRepository(
      dataService: ref.watch(mockDataServiceProvider),
    );
  }

  return RemoteHrOperationsRepository(
    remoteDataSource: ref.watch(hrOperationsRemoteDataSourceProvider),
  );
});

// --- Staff Providers ---

class StaffFilter {
  final String? branchId;
  final String? department;
  final String? category;
  final String? status;
  final String? searchQuery;

  const StaffFilter(
      {this.branchId,
      this.department,
      this.category,
      this.status,
      this.searchQuery});

  StaffFilter copyWith(
      {String? branchId,
      String? department,
      String? category,
      String? status,
      String? searchQuery}) {
    return StaffFilter(
      branchId: branchId ?? this.branchId,
      department: department ?? this.department,
      category: category ?? this.category,
      status: status ?? this.status,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final staffFilterProvider =
    StateProvider<StaffFilter>((ref) => const StaffFilter());

final allStaffListAsyncProvider = FutureProvider<List<StaffModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(staffRepositoryProvider).getStaffList();
});

final allStaffListProvider = Provider<List<StaffModel>>((ref) {
  return ref.watch(allStaffListAsyncProvider).valueOrNull ?? const [];
});

final staffListAsyncProvider = FutureProvider<List<StaffModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  final filter = ref.watch(staffFilterProvider);
  return ref.watch(staffRepositoryProvider).getStaffList(
        branchId: filter.branchId,
        department: filter.department,
        category: filter.category,
        status: filter.status,
        searchQuery: filter.searchQuery,
      );
});

final staffListProvider = Provider<List<StaffModel>>((ref) {
  return ref.watch(staffListAsyncProvider).valueOrNull ?? const [];
});

final staffByIdProvider = Provider.family<StaffModel?, String>((ref, id) {
  final staffList = ref.watch(allStaffListProvider);
  for (final staff in staffList) {
    if (staff.id == id) {
      return staff;
    }
  }
  return null;
});

final staffByUserIdProvider =
    Provider.family<StaffModel?, String>((ref, userId) {
  final staffList = ref.watch(allStaffListProvider);
  for (final staff in staffList) {
    if (staff.userId == userId) {
      return staff;
    }
  }
  return null;
});

// --- Attendance Providers ---

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final attendanceListAsyncProvider =
    FutureProvider.family<List<AttendanceModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref
      .watch(attendanceRepositoryProvider)
      .getAttendance(staffId: staffId);
});

final attendanceListProvider =
    Provider.family<List<AttendanceModel>, String?>((ref, staffId) {
  return ref.watch(attendanceListAsyncProvider(staffId)).valueOrNull ??
      const [];
});

final attendanceByDateAsyncProvider =
    FutureProvider.family<List<AttendanceModel>, DateTime>((ref, date) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(attendanceRepositoryProvider).getAttendance(date: date);
});

final todayAttendanceForStaffProvider =
    Provider.family<AttendanceModel?, String?>((ref, staffId) {
  if (staffId == null) {
    return null;
  }

  final records = ref.watch(attendanceListProvider(staffId));
  final now = DateTime.now();

  for (final record in records) {
    if (record.date.year == now.year &&
        record.date.month == now.month &&
        record.date.day == now.day) {
      return record;
    }
  }

  return null;
});

final todayAttendanceProvider = Provider<List<AttendanceModel>>((ref) {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(attendanceByDateAsyncProvider(date)).valueOrNull ?? const [];
});

// --- Branch Providers ---

final branchListAsyncProvider = FutureProvider<List<BranchModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(branchRepositoryProvider).getBranches();
});

final branchListProvider = Provider<List<BranchModel>>((ref) {
  return ref.watch(branchListAsyncProvider).valueOrNull ?? const [];
});

final branchByIdProvider = Provider.family<BranchModel?, String>((ref, id) {
  final branches = ref.watch(branchListProvider);
  for (final branch in branches) {
    if (branch.id == id) {
      return branch;
    }
  }
  return null;
});

final shiftListAsyncProvider = FutureProvider<List<ShiftModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(shiftRepositoryProvider).getShifts();
});

final shiftListProvider = Provider<List<ShiftModel>>((ref) {
  return ref.watch(shiftListAsyncProvider).valueOrNull ?? const [];
});

final shiftByIdProvider = Provider.family<ShiftModel?, String>((ref, id) {
  final shifts = ref.watch(shiftListProvider);
  for (final shift in shifts) {
    if (shift.id == id) {
      return shift;
    }
  }
  return null;
});

// --- Salary Providers ---

final salaryListAsyncProvider =
    FutureProvider.family<List<SalaryModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref
      .watch(hrOperationsRepositoryProvider)
      .getSalaries(staffId: staffId);
});

final salaryListProvider = Provider.family<List<SalaryModel>, String?>(
  (ref, staffId) =>
      ref.watch(salaryListAsyncProvider(staffId)).valueOrNull ?? const [],
);

final allSalariesAsyncProvider = FutureProvider<List<SalaryModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getSalaries();
});

final allSalariesProvider = Provider<List<SalaryModel>>((ref) {
  return ref.watch(allSalariesAsyncProvider).valueOrNull ?? const [];
});

// --- Loan Providers ---

final loanListAsyncProvider =
    FutureProvider.family<List<LoanModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getLoans(staffId: staffId);
});

final loanListProvider = Provider.family<List<LoanModel>, String?>(
  (ref, staffId) =>
      ref.watch(loanListAsyncProvider(staffId)).valueOrNull ?? const [],
);

final allLoansAsyncProvider = FutureProvider<List<LoanModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getLoans();
});

final allLoansProvider = Provider<List<LoanModel>>((ref) {
  return ref.watch(allLoansAsyncProvider).valueOrNull ?? const [];
});

// --- Leave Providers ---

class LeaveNotifier extends StateNotifier<List<LeaveModel>> {
  final Ref _ref;
  final HrOperationsRepository _repository;
  final String? staffId;

  LeaveNotifier(this._ref, this._repository, this.staffId) : super(const []) {
    refresh();
  }

  Future<void> submit(LeaveModel leave, {String? attachmentPath}) async {
    await _repository.addLeave(leave, attachmentPath: attachmentPath);
    _bumpRevision();
    try { await refresh(); } catch (_) {}
  }

  Future<void> updateStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    await _repository.updateLeaveStatus(
      leaveId: leaveId,
      status: status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
    _bumpRevision();
    try { await refresh(); } catch (_) {}
  }

  Future<void> refresh() async {
    state = await _repository.getLeaves(staffId: staffId);
  }

  void _bumpRevision() {
    _ref.read(mockDataRevisionProvider.notifier).state++;
  }
}

final leaveNotifierProvider =
    StateNotifierProvider.family<LeaveNotifier, List<LeaveModel>, String?>(
  (ref, staffId) => LeaveNotifier(
    ref,
    ref.watch(hrOperationsRepositoryProvider),
    staffId,
  ),
);

final leaveListAsyncProvider =
    FutureProvider.family<List<LeaveModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getLeaves(staffId: staffId);
});

final leaveListProvider = Provider.family<List<LeaveModel>, String?>(
  (ref, staffId) =>
      ref.watch(leaveListAsyncProvider(staffId)).valueOrNull ?? const [],
);

final pendingLeavesProvider = Provider<List<LeaveModel>>((ref) {
  return ref
      .watch(leaveListProvider(null))
      .where((leave) => leave.status == AppConstants.leaveStatusPending)
      .toList();
});

// --- KPI Providers ---

final kpiListAsyncProvider =
    FutureProvider.family<List<KpiModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref
      .watch(hrOperationsRepositoryProvider)
      .getKpiRecords(staffId: staffId);
});

final kpiListProvider = Provider.family<List<KpiModel>, String?>(
  (ref, staffId) =>
      ref.watch(kpiListAsyncProvider(staffId)).valueOrNull ?? const [],
);

final allKpiAsyncProvider = FutureProvider<List<KpiModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getKpiRecords();
});

final allKpiProvider = Provider<List<KpiModel>>((ref) {
  return ref.watch(allKpiAsyncProvider).valueOrNull ?? const [];
});

// --- Task Providers ---

final taskListAsyncProvider =
    FutureProvider.family<List<TaskModel>, String?>((ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getTasks(staffId: staffId);
});

final taskListProvider = Provider.family<List<TaskModel>, String?>(
  (ref, staffId) =>
      ref.watch(taskListAsyncProvider(staffId)).valueOrNull ?? const [],
);

final allTasksAsyncProvider = FutureProvider<List<TaskModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getTasks();
});

final allTasksProvider = Provider<List<TaskModel>>((ref) {
  return ref.watch(allTasksAsyncProvider).valueOrNull ?? const [];
});

final activeTaskCountProvider = Provider.family<int, String?>((ref, staffId) {
  final tasks = ref.watch(taskListProvider(staffId));
  return tasks.where((task) => task.status == 'Pending').length;
});

// --- Dashboard Provider ---

final dashboardStatsAsyncProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  final date = ref.watch(selectedDateProvider);
  return ref.watch(hrOperationsRepositoryProvider).getDashboardStats(date);
});

final dashboardStatsProvider = Provider<Map<String, dynamic>>((ref) {
  return ref.watch(dashboardStatsAsyncProvider).valueOrNull ??
      const {
        'total_staff': 0,
        'present_today': 0,
        'absent_today': 0,
        'late_today': 0,
        'on_leave': 0,
        'total_overtime_hours': 0.0,
        'salary_pending': 0,
        'total_loan_balance': 0.0,
        'kpi_average': 0.0,
        'overtime_count': 0,
        'best_staff': null,
        'lowest_kpi_staff': null,
        'highest_overtime_staff': null,
        'expiring_documents': 0,
        'expired_documents': 0,
      };
});

final notificationsAsyncProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return const [];
  }

  final staffId = user.role == AppConstants.roleStaff
      ? ref.watch(staffByUserIdProvider(user.id))?.id ??
          ref.watch(currentStaffProvider)?.id
      : null;

  return ref.watch(hrOperationsRepositoryProvider).getNotifications(
        targetRole: user.role,
        staffId: staffId,
      );
});

final notificationsProvider = Provider<List<NotificationModel>>((ref) {
  return ref.watch(notificationsAsyncProvider).valueOrNull ?? const [];
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((notification) => !notification.isRead).length;
});

// --- Expense Providers ---

class ExpenseNotifier extends StateNotifier<List<ExpenseModel>> {
  final Ref _ref;
  final HrOperationsRepository _repository;
  final String? staffId;

  ExpenseNotifier(this._ref, this._repository, this.staffId) : super(const []) {
    refresh();
  }

  Future<void> submit(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  }) async {
    await _repository.addExpense(
      expense,
      receiptFilePaths: receiptFilePaths,
    );
    _bumpRevision();
    try { await refresh(); } catch (_) {}
  }

  Future<void> refresh() async {
    state = await _repository.getExpenses(staffId: staffId);
  }

  void _bumpRevision() {
    _ref.read(mockDataRevisionProvider.notifier).state++;
  }
}

final expenseNotifierProvider =
    StateNotifierProvider.family<ExpenseNotifier, List<ExpenseModel>, String?>(
  (ref, staffId) => ExpenseNotifier(
    ref,
    ref.watch(hrOperationsRepositoryProvider),
    staffId,
  ),
);

final expenseListProvider =
    Provider.family<List<ExpenseModel>, String?>((ref, staffId) {
  return ref.watch(expenseNotifierProvider(staffId));
});

final allExpensesAsyncProvider =
    FutureProvider<List<ExpenseModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getExpenses();
});

final allExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref.watch(allExpensesAsyncProvider).valueOrNull ?? const [];
});

final pendingExpensesProvider = Provider<List<ExpenseModel>>((ref) {
  return ref
      .watch(allExpensesProvider)
      .where((expense) => expense.status == 'Pending')
      .toList();
});

// --- Holiday Providers ---

class HolidayNotifier extends StateNotifier<List<HolidayModel>> {
  final Ref _ref;
  final HrOperationsRepository _repository;

  HolidayNotifier(this._ref, this._repository) : super(const []) {
    refresh();
  }

  Future<void> add(HolidayModel holiday) async {
    await _repository.addHoliday(holiday);
    _bumpRevision();
    try { await refresh(); } catch (_) {}
  }

  Future<void> remove(String id) async {
    await _repository.removeHoliday(id);
    _bumpRevision();
    try { await refresh(); } catch (_) {}
  }

  Future<void> refresh() async {
    state = await _repository.getHolidays();
  }

  void _bumpRevision() {
    _ref.read(mockDataRevisionProvider.notifier).state++;
  }
}

final holidayNotifierProvider =
    StateNotifierProvider<HolidayNotifier, List<HolidayModel>>(
  (ref) => HolidayNotifier(ref, ref.watch(hrOperationsRepositoryProvider)),
);

final holidayListProvider = Provider<List<HolidayModel>>((ref) {
  return ref.watch(holidayNotifierProvider);
});

final holidayListByYearProvider =
    Provider.family<List<HolidayModel>, int>((ref, year) {
  return ref
      .watch(holidayNotifierProvider)
      .where((h) => h.date.year == year)
      .toList();
});

// --- Shift Roster Providers ---

final shiftRostersAsyncProvider =
    FutureProvider.family<List<ShiftRosterModel>, String?>(
        (ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getShiftRosters(
        staffId: staffId,
      );
});

final shiftRostersProvider =
    Provider.family<List<ShiftRosterModel>, String?>((ref, staffId) {
  return ref.watch(shiftRostersAsyncProvider(staffId)).valueOrNull ?? const [];
});

final shiftSwapRequestsAsyncProvider =
    FutureProvider<List<ShiftSwapRequestModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getShiftSwapRequests();
});

final shiftSwapRequestsProvider = Provider<List<ShiftSwapRequestModel>>((ref) {
  return ref.watch(shiftSwapRequestsAsyncProvider).valueOrNull ?? const [];
});

final pendingShiftSwapRequestsProvider =
    Provider<List<ShiftSwapRequestModel>>((ref) {
  return ref
      .watch(shiftSwapRequestsProvider)
      .where((item) => item.status == 'Pending')
      .toList();
});

// --- Helpdesk Providers ---

final helpdeskTicketsAsyncProvider =
    FutureProvider.family<List<HelpdeskTicketModel>, String?>(
        (ref, staffId) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getHelpdeskTickets(
        staffId: staffId,
      );
});

final helpdeskTicketsProvider =
    Provider.family<List<HelpdeskTicketModel>, String?>((ref, staffId) {
  return ref.watch(helpdeskTicketsAsyncProvider(staffId)).valueOrNull ??
      const [];
});

final openHelpdeskTicketsProvider = Provider<List<HelpdeskTicketModel>>((ref) {
  return ref
      .watch(helpdeskTicketsProvider(null))
      .where((item) => item.status != 'Resolved' && item.status != 'Closed')
      .toList();
});

// --- Announcement Providers ---

final announcementsProvider = Provider<List<NotificationModel>>((ref) {
  return ref
      .watch(notificationsProvider)
      .where((item) => item.type == 'announcement')
      .toList();
});

// --- Document Alerts ---

final documentAlertsProvider = Provider<List<DocumentAlertModel>>((ref) {
  final today = DateTime.now();
  final alerts = <DocumentAlertModel>[];

  for (final staff in ref.watch(allStaffListProvider)) {
    final documents = <String, DateTime?>{
      'Passport': staff.passportExpireDate,
      'Civil ID': staff.civilIdExpireDate,
      'Contract': staff.contractExpireDate,
    };

    for (final entry in documents.entries) {
      final expiryDate = entry.value;
      if (expiryDate == null) {
        continue;
      }
      final daysRemaining = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      ).difference(DateTime(today.year, today.month, today.day)).inDays;
      if (daysRemaining > 30) {
        continue;
      }
      alerts.add(
        DocumentAlertModel(
          staffId: staff.id,
          staffName: staff.name,
          staffCode: staff.staffCode,
          documentType: entry.key,
          expiryDate: expiryDate,
          daysRemaining: daysRemaining,
        ),
      );
    }
  }

  alerts.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
  return alerts;
});

// --- Attendance Edit Log Providers ---

final attendanceEditLogListAsyncProvider =
    FutureProvider<List<AttendanceEditLogModel>>((ref) async {
  ref.watch(mockDataRevisionProvider);
  return ref.watch(hrOperationsRepositoryProvider).getEditLogs();
});

final attendanceEditLogListProvider =
    Provider<List<AttendanceEditLogModel>>((ref) {
  return ref.watch(attendanceEditLogListAsyncProvider).valueOrNull ?? const [];
});

// Bumps mockDataRevisionProvider every 30 seconds when remote backend is active,
// so all FutureProviders re-fetch and other devices see new data.
final autoRefreshProvider = Provider<void>((ref) {
  final useRemote = ref.watch(useRemoteDataProvider);
  if (!useRemote) return;

  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    ref.read(mockDataRevisionProvider.notifier).state++;
  });
  ref.onDispose(timer.cancel);
});
