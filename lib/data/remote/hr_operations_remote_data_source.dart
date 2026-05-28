import 'package:dio/dio.dart';

import '../models/attendance_edit_log_model.dart';
import '../models/expense_model.dart';
import '../models/holiday_model.dart';
import '../models/kpi_model.dart';
import '../models/leave_model.dart';
import '../models/loan_model.dart';
import '../models/notification_model.dart';
import '../models/salary_model.dart';
import '../models/staff_model.dart';
import '../models/task_model.dart';
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
  Future<List<SalaryModel>> fetchSalaries({String? staffId, String? month}) async {
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
  Future<List<LeaveModel>> fetchLeaves({String? staffId, String? status}) async {
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
        if (targetRole != null && targetRole.isNotEmpty) 'target_role': targetRole,
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
  Future<List<ExpenseModel>> fetchExpenses({String? staffId, String? status}) async {
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
