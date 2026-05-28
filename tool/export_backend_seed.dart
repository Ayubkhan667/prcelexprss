// ignore_for_file: avoid_relative_lib_imports

import 'dart:convert';
import 'dart:io';

import '../lib/data/models/attendance_edit_log_model.dart';
import '../lib/data/models/expense_model.dart';
import '../lib/data/models/holiday_model.dart';
import '../lib/data/models/notification_model.dart';
import '../lib/data/services/mock_data_service.dart';

Future<void> main(List<String> args) async {
  final outputPath = args.isNotEmpty ? args.first : 'tool/mock_seed.json';
  final service = MockDataService();

  final payload = <String, dynamic>{
    'meta': {
      'generated_at': DateTime.now().toIso8601String(),
      'default_password': 'password123',
      'source': 'MockDataService',
    },
    'users': service.getUsers().map((user) => user.toMap()).toList(),
    'branches': service.getBranches().map((branch) => branch.toMap()).toList(),
    'shifts': service.getShifts().map((shift) => shift.toMap()).toList(),
    'staff': service.getStaffList().map((staff) => staff.toMap()).toList(),
    'attendance':
        service.getAttendance().map((attendance) => attendance.toMap()).toList(),
    'salaries': service.getSalaries().map((salary) => salary.toMap()).toList(),
    'loans': service.getLoans().map((loan) => loan.toMap()).toList(),
    'leaves': service.getLeaves().map((leave) => leave.toMap()).toList(),
    'kpis': service.getKpiRecords().map((kpi) => kpi.toMap()).toList(),
    'expenses': service.getExpenses().map(_expenseToMap).toList(),
    'edit_logs': service.getEditLogs().map(_editLogToMap).toList(),
    'notifications':
        service.getNotifications().map(_notificationToMap).toList(),
    'tasks': service.getTasks().map((task) => task.toMap()).toList(),
    'holidays': service.getHolidays().map(_holidayToMap).toList(),
  };

  final file = File(outputPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(payload),
  );

  stdout.writeln('Seed data written to ${file.path}');
}

Map<String, dynamic> _expenseToMap(ExpenseModel expense) {
  return {
    'id': expense.id,
    'staff_id': expense.staffId,
    'staff_name': expense.staffName,
    'staff_code': expense.staffCode,
    'expense_type': expense.expenseType,
    'amount': expense.amount,
    'expense_date': expense.expenseDate.toIso8601String(),
    'description': expense.description,
    'receipt_images': expense.receiptImages,
    'status': expense.status,
    'approved_by': expense.approvedBy,
    'rejection_reason': expense.rejectionReason,
    'created_at': expense.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _editLogToMap(AttendanceEditLogModel log) {
  return {
    'id': log.id,
    'attendance_id': log.attendanceId,
    'staff_id': log.staffId,
    'staff_name': log.staffName,
    'staff_code': log.staffCode,
    'edited_by': log.editedBy,
    'edited_by_role': log.editedByRole,
    'field_changed': log.fieldChanged,
    'old_value': log.oldValue,
    'new_value': log.newValue,
    'reason': log.reason,
    'approval_status': log.approvalStatus,
    'approved_by': log.approvedBy,
    'approved_at': log.approvedAt?.toIso8601String(),
    'created_at': log.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _notificationToMap(NotificationModel notification) {
  return {
    'id': notification.id,
    'title': notification.title,
    'body': notification.body,
    'type': notification.type,
    'staff_id': notification.staffId,
    'staff_name': notification.staffName,
    'is_read': notification.isRead,
    'target_role': notification.targetRole,
    'created_at': notification.createdAt.toIso8601String(),
  };
}

Map<String, dynamic> _holidayToMap(HolidayModel holiday) {
  return {
    'id': holiday.id,
    'name': holiday.name,
    'date': holiday.date.toIso8601String(),
    'type': holiday.type,
    'ot_multiplier': holiday.otMultiplier,
  };
}
