import '../models/attendance_edit_log_model.dart';
import '../models/helpdesk_ticket_model.dart';
import '../models/expense_model.dart';
import '../models/holiday_model.dart';
import '../models/kpi_model.dart';
import '../models/leave_model.dart';
import '../models/loan_model.dart';
import '../models/notification_model.dart';
import '../models/salary_model.dart';
import '../models/staff_model.dart';
import '../models/task_model.dart';
import '../models/shift_roster_model.dart';
import '../models/shift_swap_request_model.dart';
import '../remote/hr_operations_remote_data_source.dart';
import '../services/mock_data_service.dart';

abstract class HrOperationsRepository {
  Future<List<SalaryModel>> getSalaries({String? staffId, String? month});
  Future<SalaryModel?> markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  });
  Future<int> generateSalariesForMonth(DateTime forMonth);

  Future<List<LoanModel>> getLoans({String? staffId});
  Future<void> addLoan(LoanModel loan);

  Future<List<LeaveModel>> getLeaves({String? staffId, String? status});
  Future<void> addLeave(LeaveModel leave, {String? attachmentPath});
  Future<LeaveModel?> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  });

  Future<List<KpiModel>> getKpiRecords({String? staffId, String? month});

  Future<List<TaskModel>> getTasks({String? staffId, String? status});
  Future<List<TaskModel>> assignTask({
    required String title,
    required String description,
    required String assignedBy,
    required String assignedByRole,
    required List<StaffModel> assignees,
    required bool assignToAll,
    required bool isDailyTask,
    required DateTime dueDate,
  });
  Future<TaskModel?> markTaskCompleted(String taskId);
  Future<TaskModel?> terminateTask(String taskId);

  Future<List<NotificationModel>> getNotifications({
    String? targetRole,
    String? staffId,
    String? type,
  });
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markNotificationsAsRead({
    String? targetRole,
    String? staffId,
    String? type,
  });
  Future<NotificationModel?> publishAnnouncement({
    required String title,
    required String body,
    required String targetRole,
  });

  Future<List<ExpenseModel>> getExpenses({String? staffId, String? status});
  Future<void> addExpense(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  });
  Future<ExpenseModel?> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  });

  Future<List<HolidayModel>> getHolidays({int? year});
  Future<void> addHoliday(HolidayModel holiday);
  Future<void> removeHoliday(String id);

  Future<List<ShiftRosterModel>> getShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<ShiftRosterModel?> saveShiftRoster({
    required ShiftRosterModel roster,
    required bool isEdit,
  });
  Future<List<ShiftSwapRequestModel>> getShiftSwapRequests({String? status});
  Future<ShiftSwapRequestModel?> addShiftSwapRequest(
    ShiftSwapRequestModel request,
  );
  Future<ShiftSwapRequestModel?> updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  });

  Future<List<HelpdeskTicketModel>> getHelpdeskTickets({
    String? staffId,
    String? status,
  });
  Future<HelpdeskTicketModel?> addHelpdeskTicket(HelpdeskTicketModel ticket);
  Future<HelpdeskTicketModel?> updateHelpdeskTicketStatus({
    required String ticketId,
    required String status,
    String? response,
  });

  Future<void> registerPushToken({
    required String token,
    required String platform,
  });
  Future<void> deletePushToken({String? token});

  Future<List<AttendanceEditLogModel>> getEditLogs({
    String? staffId,
    String? approvalStatus,
  });
  Future<void> addEditLog(AttendanceEditLogModel log);
  Future<AttendanceEditLogModel?> updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  });

  Future<Map<String, dynamic>> getDashboardStats(DateTime date);
}

class MockHrOperationsRepository implements HrOperationsRepository {
  MockHrOperationsRepository({required MockDataService dataService})
      : _dataService = dataService;

  final MockDataService _dataService;

  @override
  Future<List<SalaryModel>> getSalaries(
      {String? staffId, String? month}) async {
    return _dataService.getSalaries(staffId: staffId, month: month);
  }

  @override
  Future<SalaryModel?> markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  }) async {
    _dataService.markSalaryPaid(
      salaryId: salaryId,
      paidDate: paidDate,
      notes: notes,
    );
    return _dataService
        .getSalaries()
        .firstWhere((salary) => salary.id == salaryId);
  }

  @override
  Future<int> generateSalariesForMonth(DateTime forMonth) async {
    return _dataService.generateSalariesForMonth(forMonth);
  }

  @override
  Future<List<LoanModel>> getLoans({String? staffId}) async {
    return _dataService.getLoans(staffId: staffId);
  }

  @override
  Future<void> addLoan(LoanModel loan) async {
    _dataService.addLoan(loan);
  }

  @override
  Future<List<LeaveModel>> getLeaves({String? staffId, String? status}) async {
    return _dataService.getLeaves(staffId: staffId, status: status);
  }

  @override
  Future<void> addLeave(LeaveModel leave, {String? attachmentPath}) async {
    _dataService.addLeave(leave);
  }

  @override
  Future<LeaveModel?> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    _dataService.updateLeaveStatus(
      leaveId: leaveId,
      status: status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
    return _dataService.getLeaves().firstWhere((leave) => leave.id == leaveId);
  }

  @override
  Future<List<KpiModel>> getKpiRecords({String? staffId, String? month}) async {
    return _dataService.getKpiRecords(staffId: staffId, month: month);
  }

  @override
  Future<List<TaskModel>> getTasks({String? staffId, String? status}) async {
    return _dataService.getTasks(staffId: staffId, status: status);
  }

  @override
  Future<List<TaskModel>> assignTask({
    required String title,
    required String description,
    required String assignedBy,
    required String assignedByRole,
    required List<StaffModel> assignees,
    required bool assignToAll,
    required bool isDailyTask,
    required DateTime dueDate,
  }) async {
    return _dataService.assignTask(
      title: title,
      description: description,
      assignedBy: assignedBy,
      assignedByRole: assignedByRole,
      assignees: assignees,
      assignToAll: assignToAll,
      isDailyTask: isDailyTask,
      dueDate: dueDate,
    );
  }

  @override
  Future<TaskModel?> markTaskCompleted(String taskId) async {
    return _dataService.markTaskCompleted(taskId);
  }

  @override
  Future<TaskModel?> terminateTask(String taskId) async {
    return _dataService.terminateTask(taskId);
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    String? targetRole,
    String? staffId,
    String? type,
  }) async {
    var list =
        _dataService.getNotifications(targetRole: targetRole, staffId: staffId);
    if (type != null && type.isNotEmpty) {
      list = list.where((notification) => notification.type == type).toList();
    }
    return list;
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    _dataService.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markNotificationsAsRead({
    String? targetRole,
    String? staffId,
    String? type,
  }) async {
    _dataService.markNotificationsAsRead(
      targetRole: targetRole,
      staffId: staffId,
      type: type,
    );
  }

  @override
  Future<NotificationModel?> publishAnnouncement({
    required String title,
    required String body,
    required String targetRole,
  }) async {
    final announcement = NotificationModel(
      id: 'announcement_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: 'announcement',
      targetRole: targetRole,
      createdAt: DateTime.now(),
    );
    _dataService.addNotification(announcement);
    return announcement;
  }

  @override
  Future<List<ExpenseModel>> getExpenses(
      {String? staffId, String? status}) async {
    return _dataService.getExpenses(staffId: staffId, status: status);
  }

  @override
  Future<void> addExpense(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  }) async {
    _dataService.addExpense(expense);
  }

  @override
  Future<ExpenseModel?> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    _dataService.updateExpenseStatus(
      expenseId,
      status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
    return _dataService
        .getExpenses()
        .firstWhere((expense) => expense.id == expenseId);
  }

  @override
  Future<List<HolidayModel>> getHolidays({int? year}) async {
    return _dataService.getHolidays(year: year);
  }

  @override
  Future<void> addHoliday(HolidayModel holiday) async {
    _dataService.addHoliday(holiday);
  }

  @override
  Future<void> removeHoliday(String id) async {
    _dataService.removeHoliday(id);
  }

  @override
  Future<List<ShiftRosterModel>> getShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return _dataService.getShiftRosters(
      staffId: staffId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<ShiftRosterModel?> saveShiftRoster({
    required ShiftRosterModel roster,
    required bool isEdit,
  }) async {
    _dataService.saveShiftRoster(roster, isEdit: isEdit);
    return _dataService.getShiftRosters().firstWhere((item) =>
        item.staffId == roster.staffId &&
        item.rosterDate.year == roster.rosterDate.year &&
        item.rosterDate.month == roster.rosterDate.month &&
        item.rosterDate.day == roster.rosterDate.day);
  }

  @override
  Future<List<ShiftSwapRequestModel>> getShiftSwapRequests({
    String? status,
  }) async {
    return _dataService.getShiftSwapRequests(status: status);
  }

  @override
  Future<ShiftSwapRequestModel?> addShiftSwapRequest(
    ShiftSwapRequestModel request,
  ) async {
    _dataService.addShiftSwapRequest(request);
    return _dataService
        .getShiftSwapRequests()
        .firstWhere((item) => item.id == request.id);
  }

  @override
  Future<ShiftSwapRequestModel?> updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) async {
    _dataService.updateShiftSwapRequestStatus(
      requestId: requestId,
      status: status,
      rejectionReason: rejectionReason,
      approvedBy: 'Admin',
    );
    return _dataService
        .getShiftSwapRequests()
        .firstWhere((item) => item.id == requestId);
  }

  @override
  Future<List<HelpdeskTicketModel>> getHelpdeskTickets({
    String? staffId,
    String? status,
  }) async {
    return _dataService.getHelpdeskTickets(staffId: staffId, status: status);
  }

  @override
  Future<HelpdeskTicketModel?> addHelpdeskTicket(
      HelpdeskTicketModel ticket) async {
    _dataService.addHelpdeskTicket(ticket);
    return _dataService
        .getHelpdeskTickets()
        .firstWhere((item) => item.id == ticket.id);
  }

  @override
  Future<HelpdeskTicketModel?> updateHelpdeskTicketStatus({
    required String ticketId,
    required String status,
    String? response,
  }) async {
    _dataService.updateHelpdeskTicketStatus(
      ticketId: ticketId,
      status: status,
      response: response,
      respondedBy: 'Admin',
    );
    return _dataService
        .getHelpdeskTickets()
        .firstWhere((item) => item.id == ticketId);
  }

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {}

  @override
  Future<void> deletePushToken({String? token}) async {}

  @override
  Future<List<AttendanceEditLogModel>> getEditLogs({
    String? staffId,
    String? approvalStatus,
  }) async {
    return _dataService.getEditLogs(
      staffId: staffId,
      approvalStatus: approvalStatus,
    );
  }

  @override
  Future<void> addEditLog(AttendanceEditLogModel log) async {
    _dataService.addEditLog(log);
  }

  @override
  Future<AttendanceEditLogModel?> updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  }) async {
    _dataService.updateEditLogApprovalStatus(
      logId: logId,
      status: status,
      approvedBy: approvedBy,
    );
    return _dataService.getEditLogs().firstWhere((log) => log.id == logId);
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats(DateTime date) async {
    return _dataService.getDashboardStats(date);
  }
}

class RemoteHrOperationsRepository implements HrOperationsRepository {
  RemoteHrOperationsRepository({
    required HrOperationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final HrOperationsRemoteDataSource _remoteDataSource;

  @override
  Future<List<SalaryModel>> getSalaries({String? staffId, String? month}) {
    return _remoteDataSource.fetchSalaries(staffId: staffId, month: month);
  }

  @override
  Future<SalaryModel?> markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  }) {
    return _remoteDataSource.markSalaryPaid(
      salaryId: salaryId,
      paidDate: paidDate,
      notes: notes,
    );
  }

  @override
  Future<int> generateSalariesForMonth(DateTime forMonth) {
    return _remoteDataSource.generateSalariesForMonth(forMonth);
  }

  @override
  Future<List<LoanModel>> getLoans({String? staffId}) {
    return _remoteDataSource.fetchLoans(staffId: staffId);
  }

  @override
  Future<void> addLoan(LoanModel loan) {
    return _remoteDataSource.saveLoan(loan);
  }

  @override
  Future<List<LeaveModel>> getLeaves({String? staffId, String? status}) {
    return _remoteDataSource.fetchLeaves(staffId: staffId, status: status);
  }

  @override
  Future<void> addLeave(LeaveModel leave, {String? attachmentPath}) {
    return _remoteDataSource.saveLeave(
      leave,
      attachmentPath: attachmentPath,
    );
  }

  @override
  Future<LeaveModel?> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) {
    return _remoteDataSource.updateLeaveStatus(
      leaveId: leaveId,
      status: status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
  }

  @override
  Future<List<KpiModel>> getKpiRecords({String? staffId, String? month}) {
    return _remoteDataSource.fetchKpis(staffId: staffId, month: month);
  }

  @override
  Future<List<TaskModel>> getTasks({String? staffId, String? status}) {
    return _remoteDataSource.fetchTasks(staffId: staffId, status: status);
  }

  @override
  Future<List<TaskModel>> assignTask({
    required String title,
    required String description,
    required String assignedBy,
    required String assignedByRole,
    required List<StaffModel> assignees,
    required bool assignToAll,
    required bool isDailyTask,
    required DateTime dueDate,
  }) {
    return _remoteDataSource.assignTask(
      title: title,
      description: description,
      assignedBy: assignedBy,
      assignedByRole: assignedByRole,
      assignees: assignees,
      assignToAll: assignToAll,
      isDailyTask: isDailyTask,
      dueDate: dueDate,
    );
  }

  @override
  Future<TaskModel?> markTaskCompleted(String taskId) {
    return _remoteDataSource.markTaskCompleted(taskId);
  }

  @override
  Future<TaskModel?> terminateTask(String taskId) {
    return _remoteDataSource.terminateTask(taskId);
  }

  @override
  Future<List<NotificationModel>> getNotifications({
    String? targetRole,
    String? staffId,
    String? type,
  }) {
    return _remoteDataSource.fetchNotifications(
      targetRole: targetRole,
      staffId: staffId,
      type: type,
    );
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) {
    return _remoteDataSource.markNotificationAsRead(notificationId);
  }

  @override
  Future<void> markNotificationsAsRead({
    String? targetRole,
    String? staffId,
    String? type,
  }) {
    return _remoteDataSource.markNotificationsAsRead(
      targetRole: targetRole,
      staffId: staffId,
      type: type,
    );
  }

  @override
  Future<NotificationModel?> publishAnnouncement({
    required String title,
    required String body,
    required String targetRole,
  }) {
    return _remoteDataSource.publishAnnouncement(
      title: title,
      body: body,
      targetRole: targetRole,
    );
  }

  @override
  Future<List<ExpenseModel>> getExpenses({String? staffId, String? status}) {
    return _remoteDataSource.fetchExpenses(staffId: staffId, status: status);
  }

  @override
  Future<void> addExpense(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  }) {
    return _remoteDataSource.saveExpense(
      expense,
      receiptFilePaths: receiptFilePaths,
    );
  }

  @override
  Future<ExpenseModel?> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) {
    return _remoteDataSource.updateExpenseStatus(
      expenseId: expenseId,
      status: status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
  }

  @override
  Future<List<HolidayModel>> getHolidays({int? year}) {
    return _remoteDataSource.fetchHolidays(year: year);
  }

  @override
  Future<void> addHoliday(HolidayModel holiday) {
    return _remoteDataSource.saveHoliday(holiday);
  }

  @override
  Future<void> removeHoliday(String id) {
    return _remoteDataSource.deleteHoliday(id);
  }

  @override
  Future<List<ShiftRosterModel>> getShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _remoteDataSource.fetchShiftRosters(
      staffId: staffId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  @override
  Future<ShiftRosterModel?> saveShiftRoster({
    required ShiftRosterModel roster,
    required bool isEdit,
  }) {
    return _remoteDataSource.saveShiftRoster(
      roster: roster,
      isEdit: isEdit,
    );
  }

  @override
  Future<List<ShiftSwapRequestModel>> getShiftSwapRequests({
    String? status,
  }) {
    return _remoteDataSource.fetchShiftSwapRequests(status: status);
  }

  @override
  Future<ShiftSwapRequestModel?> addShiftSwapRequest(
    ShiftSwapRequestModel request,
  ) {
    return _remoteDataSource.saveShiftSwapRequest(request);
  }

  @override
  Future<ShiftSwapRequestModel?> updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) {
    return _remoteDataSource.updateShiftSwapRequestStatus(
      requestId: requestId,
      status: status,
      rejectionReason: rejectionReason,
    );
  }

  @override
  Future<List<HelpdeskTicketModel>> getHelpdeskTickets({
    String? staffId,
    String? status,
  }) {
    return _remoteDataSource.fetchHelpdeskTickets(
      staffId: staffId,
      status: status,
    );
  }

  @override
  Future<HelpdeskTicketModel?> addHelpdeskTicket(HelpdeskTicketModel ticket) {
    return _remoteDataSource.saveHelpdeskTicket(ticket);
  }

  @override
  Future<HelpdeskTicketModel?> updateHelpdeskTicketStatus({
    required String ticketId,
    required String status,
    String? response,
  }) {
    return _remoteDataSource.updateHelpdeskTicketStatus(
      ticketId: ticketId,
      status: status,
      response: response,
    );
  }

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) {
    return _remoteDataSource.registerPushToken(
      token: token,
      platform: platform,
    );
  }

  @override
  Future<void> deletePushToken({String? token}) {
    return _remoteDataSource.deletePushToken(token: token);
  }

  @override
  Future<List<AttendanceEditLogModel>> getEditLogs({
    String? staffId,
    String? approvalStatus,
  }) {
    return _remoteDataSource.fetchEditLogs(
      staffId: staffId,
      approvalStatus: approvalStatus,
    );
  }

  @override
  Future<void> addEditLog(AttendanceEditLogModel log) {
    return _remoteDataSource.saveEditLog(log);
  }

  @override
  Future<AttendanceEditLogModel?> updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  }) {
    return _remoteDataSource.updateEditLogApprovalStatus(
      logId: logId,
      status: status,
      approvedBy: approvedBy,
    );
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats(DateTime date) {
    return _remoteDataSource.fetchDashboardStats(date);
  }
}
