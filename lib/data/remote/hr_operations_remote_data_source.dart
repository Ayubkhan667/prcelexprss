import 'package:dio/dio.dart';

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
import 'api_client.dart';
import 'remote_payload_parser.dart';

abstract class HrOperationsRemoteDataSource {
  Future<List<SalaryModel>> fetchSalaries({String? staffId, String? month});
  Future<SalaryModel?> markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  });
  Future<int> generateSalariesForMonth(DateTime forMonth);

  Future<List<LoanModel>> fetchLoans({String? staffId});
  Future<void> saveLoan(LoanModel loan);

  Future<List<LeaveModel>> fetchLeaves({String? staffId, String? status});
  Future<void> saveLeave(LeaveModel leave, {String? attachmentPath});
  Future<LeaveModel?> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  });

  Future<List<KpiModel>> fetchKpis({String? staffId, String? month});

  Future<List<TaskModel>> fetchTasks({String? staffId, String? status});
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

  Future<List<NotificationModel>> fetchNotifications({
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

  Future<List<ExpenseModel>> fetchExpenses({String? staffId, String? status});
  Future<void> saveExpense(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  });
  Future<ExpenseModel?> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  });

  Future<List<HolidayModel>> fetchHolidays({int? year});
  Future<void> saveHoliday(HolidayModel holiday);
  Future<void> deleteHoliday(String id);

  Future<List<ShiftRosterModel>> fetchShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<ShiftRosterModel?> saveShiftRoster({
    required ShiftRosterModel roster,
    required bool isEdit,
  });
  Future<List<ShiftSwapRequestModel>> fetchShiftSwapRequests({
    String? status,
  });
  Future<ShiftSwapRequestModel?> saveShiftSwapRequest(
    ShiftSwapRequestModel request,
  );
  Future<ShiftSwapRequestModel?> updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  });

  Future<List<HelpdeskTicketModel>> fetchHelpdeskTickets({
    String? staffId,
    String? status,
  });
  Future<HelpdeskTicketModel?> saveHelpdeskTicket(HelpdeskTicketModel ticket);
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

  Future<List<AttendanceEditLogModel>> fetchEditLogs({
    String? staffId,
    String? approvalStatus,
  });
  Future<void> saveEditLog(AttendanceEditLogModel log);
  Future<AttendanceEditLogModel?> updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  });

  Future<Map<String, dynamic>> fetchDashboardStats(DateTime date);
}

class ApiHrOperationsRemoteDataSource implements HrOperationsRemoteDataSource {
  ApiHrOperationsRemoteDataSource({required ApiClient apiClient})
      : client = apiClient.client;

  final Dio client;

  @override
  Future<List<SalaryModel>> fetchSalaries(
      {String? staffId, String? month}) async {
    final response = await client.get(
      '/salaries',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (month != null && month.isNotEmpty) 'month': month,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(SalaryModel.fromMap)
        .toList();
  }

  @override
  Future<SalaryModel?> markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  }) async {
    final response = await client.patch(
      '/salaries/$salaryId/mark-paid',
      data: {
        if (paidDate != null) 'paid_date': paidDate.toIso8601String(),
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : SalaryModel.fromMap(payload);
  }

  @override
  Future<int> generateSalariesForMonth(DateTime forMonth) async {
    final response = await client.post(
      '/salaries/generate',
      data: {'for_month': forMonth.toIso8601String()},
    );
    final payload = RemotePayloadParser.parseMap(response.data);
    return payload['generated'] ?? 0;
  }

  @override
  Future<List<LoanModel>> fetchLoans({String? staffId}) async {
    final response = await client.get(
      '/loans',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(LoanModel.fromMap)
        .toList();
  }

  @override
  Future<void> saveLoan(LoanModel loan) async {
    await client.post('/loans', data: loan.toMap());
  }

  @override
  Future<List<LeaveModel>> fetchLeaves(
      {String? staffId, String? status}) async {
    final response = await client.get(
      '/leaves',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(LeaveModel.fromMap)
        .toList();
  }

  @override
  Future<void> saveLeave(LeaveModel leave, {String? attachmentPath}) async {
    final payload = Map<String, dynamic>.from(leave.toMap())
      ..remove('attachment_url');

    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      payload['attachment'] = await MultipartFile.fromFile(
        attachmentPath,
      );
      await client.post('/leaves', data: FormData.fromMap(payload));
      return;
    }

    await client.post('/leaves', data: payload);
  }

  @override
  Future<LeaveModel?> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    final response = await client.patch(
      '/leaves/$leaveId/status',
      data: {
        'status': status,
        'approved_by': approvedBy,
        'rejection_reason': rejectionReason,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : LeaveModel.fromMap(payload);
  }

  @override
  Future<List<KpiModel>> fetchKpis({String? staffId, String? month}) async {
    final response = await client.get(
      '/kpis',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (month != null && month.isNotEmpty) 'month': month,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(KpiModel.fromMap)
        .toList();
  }

  @override
  Future<List<TaskModel>> fetchTasks({String? staffId, String? status}) async {
    final response = await client.get(
      '/tasks',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(TaskModel.fromMap)
        .toList();
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
    final response = await client.post(
      '/tasks/assign',
      data: {
        'title': title,
        'description': description,
        'assigned_by': assignedBy,
        'assigned_by_role': assignedByRole,
        'assign_to_all': assignToAll,
        'is_daily_task': isDailyTask,
        'due_date': dueDate.toIso8601String(),
        'assignees': assignees
            .map(
              (staff) => {
                'id': staff.id,
                'name': staff.name,
                'staff_code': staff.staffCode,
              },
            )
            .toList(),
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(TaskModel.fromMap)
        .toList();
  }

  @override
  Future<TaskModel?> markTaskCompleted(String taskId) async {
    final response = await client.patch('/tasks/$taskId/complete');
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : TaskModel.fromMap(payload);
  }

  @override
  Future<TaskModel?> terminateTask(String taskId) async {
    final response = await client.patch('/tasks/$taskId/terminate');
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : TaskModel.fromMap(payload);
  }

  @override
  Future<List<NotificationModel>> fetchNotifications({
    String? targetRole,
    String? staffId,
    String? type,
  }) async {
    final response = await client.get(
      '/notifications',
      queryParameters: {
        if (targetRole != null && targetRole.isNotEmpty)
          'target_role': targetRole,
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (type != null && type.isNotEmpty) 'type': type,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(NotificationModel.fromMap)
        .toList();
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    await client.patch('/notifications/$notificationId/read');
  }

  @override
  Future<void> markNotificationsAsRead({
    String? targetRole,
    String? staffId,
    String? type,
  }) async {
    await client.patch(
      '/notifications/read-all',
      data: {
        'target_role': targetRole,
        'staff_id': staffId,
        'type': type,
      },
    );
  }

  @override
  Future<NotificationModel?> publishAnnouncement({
    required String title,
    required String body,
    required String targetRole,
  }) async {
    final response = await client.post(
      '/announcements',
      data: {
        'title': title,
        'body': body,
        'target_role': targetRole,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : NotificationModel.fromMap(payload);
  }

  @override
  Future<List<ExpenseModel>> fetchExpenses(
      {String? staffId, String? status}) async {
    final response = await client.get(
      '/expenses',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(ExpenseModel.fromMap)
        .toList();
  }

  @override
  Future<void> saveExpense(
    ExpenseModel expense, {
    List<String> receiptFilePaths = const [],
  }) async {
    final payload = Map<String, dynamic>.from(expense.toMap())
      ..remove('receipt_images');

    if (receiptFilePaths.isNotEmpty) {
      final formData = FormData();
      payload.forEach((key, value) {
        formData.fields.add(MapEntry(key, '$value'));
      });

      for (final path in receiptFilePaths.where((path) => path.isNotEmpty)) {
        formData.files.add(
          MapEntry(
            'receipt_files[]',
            await MultipartFile.fromFile(path),
          ),
        );
      }

      await client.post('/expenses', data: formData);
      return;
    }

    await client.post('/expenses', data: payload);
  }

  @override
  Future<ExpenseModel?> updateExpenseStatus({
    required String expenseId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) async {
    final response = await client.patch(
      '/expenses/$expenseId/status',
      data: {
        'status': status,
        'approved_by': approvedBy,
        'rejection_reason': rejectionReason,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : ExpenseModel.fromMap(payload);
  }

  @override
  Future<List<HolidayModel>> fetchHolidays({int? year}) async {
    final response = await client.get(
      '/holidays',
      queryParameters: {
        if (year != null) 'year': year,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(HolidayModel.fromMap)
        .toList();
  }

  @override
  Future<void> saveHoliday(HolidayModel holiday) async {
    await client.post('/holidays', data: holiday.toMap());
  }

  @override
  Future<void> deleteHoliday(String id) async {
    await client.delete('/holidays/$id');
  }

  @override
  Future<List<ShiftRosterModel>> fetchShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final response = await client.get(
      '/shift-rosters',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(ShiftRosterModel.fromMap)
        .toList();
  }

  @override
  Future<ShiftRosterModel?> saveShiftRoster({
    required ShiftRosterModel roster,
    required bool isEdit,
  }) async {
    final response = isEdit
        ? await client.put(
            '/shift-rosters/${roster.id}',
            data: {
              'shift_id': roster.shiftId,
              'status': roster.status,
              'notes': roster.notes,
            },
          )
        : await client.post(
            '/shift-rosters',
            data: {
              'staff_id': roster.staffId,
              'roster_date': roster.rosterDate.toIso8601String(),
              'shift_id': roster.shiftId,
              'status': roster.status,
              'notes': roster.notes,
            },
          );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : ShiftRosterModel.fromMap(payload);
  }

  @override
  Future<List<ShiftSwapRequestModel>> fetchShiftSwapRequests({
    String? status,
  }) async {
    final response = await client.get(
      '/shift-swap-requests',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(ShiftSwapRequestModel.fromMap)
        .toList();
  }

  @override
  Future<ShiftSwapRequestModel?> saveShiftSwapRequest(
    ShiftSwapRequestModel request,
  ) async {
    final response = await client.post(
      '/shift-swap-requests',
      data: {
        'requester_staff_id': request.requesterStaffId,
        'target_staff_id': request.targetStaffId,
        'roster_date': request.rosterDate.toIso8601String(),
        'reason': request.reason,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : ShiftSwapRequestModel.fromMap(payload);
  }

  @override
  Future<ShiftSwapRequestModel?> updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    String? rejectionReason,
  }) async {
    final response = await client.patch(
      '/shift-swap-requests/$requestId/status',
      data: {
        'status': status,
        'rejection_reason': rejectionReason,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : ShiftSwapRequestModel.fromMap(payload);
  }

  @override
  Future<List<HelpdeskTicketModel>> fetchHelpdeskTickets({
    String? staffId,
    String? status,
  }) async {
    final response = await client.get(
      '/helpdesk-tickets',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(HelpdeskTicketModel.fromMap)
        .toList();
  }

  @override
  Future<HelpdeskTicketModel?> saveHelpdeskTicket(
      HelpdeskTicketModel ticket) async {
    final response = await client.post(
      '/helpdesk-tickets',
      data: {
        'staff_id': ticket.staffId,
        'subject': ticket.subject,
        'category': ticket.category,
        'message': ticket.message,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : HelpdeskTicketModel.fromMap(payload);
  }

  @override
  Future<HelpdeskTicketModel?> updateHelpdeskTicketStatus({
    required String ticketId,
    required String status,
    String? response,
  }) async {
    final result = await client.patch(
      '/helpdesk-tickets/$ticketId/status',
      data: {
        'status': status,
        'response': response,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(result.data);
    return payload == null ? null : HelpdeskTicketModel.fromMap(payload);
  }

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    await client.post(
      '/push-tokens',
      data: {
        'token': token,
        'platform': platform,
      },
    );
  }

  @override
  Future<void> deletePushToken({String? token}) async {
    await client.delete(
      '/push-tokens',
      data: token == null ? null : {'token': token},
    );
  }

  @override
  Future<List<AttendanceEditLogModel>> fetchEditLogs({
    String? staffId,
    String? approvalStatus,
  }) async {
    final response = await client.get(
      '/attendance-edit-logs',
      queryParameters: {
        if (staffId != null && staffId.isNotEmpty) 'staff_id': staffId,
        if (approvalStatus != null && approvalStatus.isNotEmpty)
          'approval_status': approvalStatus,
      },
    );

    return RemotePayloadParser.parseList(response.data)
        .map(AttendanceEditLogModel.fromMap)
        .toList();
  }

  @override
  Future<void> saveEditLog(AttendanceEditLogModel log) async {
    await client.post('/attendance-edit-logs', data: log.toMap());
  }

  @override
  Future<AttendanceEditLogModel?> updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  }) async {
    final response = await client.patch(
      '/attendance-edit-logs/$logId/status',
      data: {
        'status': status,
        'approved_by': approvedBy,
      },
    );
    final payload = RemotePayloadParser.parseOptionalMap(response.data);
    return payload == null ? null : AttendanceEditLogModel.fromMap(payload);
  }

  @override
  Future<Map<String, dynamic>> fetchDashboardStats(DateTime date) async {
    final response = await client.get(
      '/dashboard/stats',
      queryParameters: {'date': date.toIso8601String()},
    );

    return RemotePayloadParser.parseMap(response.data);
  }
}
