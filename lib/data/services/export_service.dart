import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/attendance_model.dart';
import '../models/salary_model.dart';
import '../models/loan_model.dart';
import '../models/kpi_model.dart';
import '../models/staff_model.dart';
import '../models/task_model.dart';
import '../models/leave_model.dart';

class ExportService {
  static Future<String> _getTempPath(String filename) async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/$filename';
  }

  // ─── ATTENDANCE EXCEL ───────────────────────────────────────────────────────

  static Future<void> exportAttendanceToExcel(
    List<AttendanceModel> records, {
    String title = 'Attendance Report',
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Attendance'];

    final headers = [
      'Staff Code',
      'Staff Name',
      'Date',
      'Check In',
      'Check Out',
      'Working Hours',
      'Overtime Hours',
      'Late Minutes',
      'Status',
      'Location Valid',
      'Mock GPS',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      final row = i + 1;
      _writeExcelRow(sheet, row, [
        r.staffCode,
        r.staffName,
        _formatDate(r.date),
        r.checkInTime != null ? _formatTime(r.checkInTime!) : '-',
        r.checkOutTime != null ? _formatTime(r.checkOutTime!) : '-',
        r.workingHours.toStringAsFixed(2),
        r.overtimeHours.toStringAsFixed(2),
        r.lateMinutes.toString(),
        r.status,
        r.isLocationValid ? 'Yes' : 'No',
        r.isMockGps ? 'YES - ALERT' : 'No',
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('attendance_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── SALARY EXCEL ───────────────────────────────────────────────────────────

  static Future<void> exportSalaryToExcel(
    List<SalaryModel> records, {
    String title = 'Salary Report',
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Salary'];

    final headers = [
      'Staff Code',
      'Staff Name',
      'Month',
      'Basic Salary',
      'Overtime',
      'Allowance',
      'Deduction',
      'Loan Deduction',
      'Absence Deduction',
      'Penalty',
      'Net Salary',
      'Payment Status',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      _writeExcelRow(sheet, i + 1, [
        r.staffCode,
        r.staffName,
        r.month,
        r.basicSalary.toStringAsFixed(0),
        r.overtimeAmount.toStringAsFixed(0),
        r.allowance.toStringAsFixed(0),
        r.deduction.toStringAsFixed(0),
        r.loanDeduction.toStringAsFixed(0),
        r.absenceDeduction.toStringAsFixed(0),
        r.penalty.toStringAsFixed(0),
        r.netSalary.toStringAsFixed(0),
        r.paymentStatus,
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('salary_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── KPI EXCEL ──────────────────────────────────────────────────────────────

  static Future<void> exportKpiToExcel(
    List<KpiModel> records, {
    String title = 'KPI Report',
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['KPI'];

    final headers = [
      'Staff Code',
      'Staff Name',
      'Month',
      'Attendance Rate%',
      'Late Count',
      'Early Checkout',
      'Missing Checkout',
      'Total Hours',
      'Overtime Hours',
      'Fake GPS Alerts',
      'Tasks Assigned',
      'Tasks Completed',
      'Task Completion%',
      'Task Score',
      'Attendance Score',
      'Punctuality Score',
      'Overtime Score',
      'Location Score',
      'Discipline Score',
      'KPI Score',
      'Rating',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      _writeExcelRow(sheet, i + 1, [
        r.staffCode,
        r.staffName,
        r.month,
        '${r.attendanceRate}%',
        r.lateCount.toString(),
        r.earlyCheckoutCount.toString(),
        r.missingCheckoutCount.toString(),
        r.totalWorkingHours.toStringAsFixed(1),
        r.overtimeHours.toStringAsFixed(1),
        r.fakeGpsCount.toString(),
        r.taskAssignedCount.toString(),
        r.taskCompletedCount.toString(),
        r.taskCompletionRate.toStringAsFixed(1),
        r.taskScore.toStringAsFixed(1),
        r.attendanceScore.toStringAsFixed(1),
        r.punctualityScore.toStringAsFixed(1),
        r.overtimeScore.toStringAsFixed(1),
        r.locationScore.toStringAsFixed(1),
        r.disciplineScore.toStringAsFixed(1),
        r.totalKpiScore.toStringAsFixed(1),
        r.rating,
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('kpi_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── LOAN EXCEL ─────────────────────────────────────────────────────────────

  static Future<void> exportLoanToExcel(List<LoanModel> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Loans'];

    final headers = [
      'Staff Code',
      'Staff Name',
      'Loan Date',
      'Purpose',
      'Loan Amount',
      'Paid Amount',
      'Balance',
      'Monthly Deduction',
      'Status',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      _writeExcelRow(sheet, i + 1, [
        r.staffCode,
        r.staffName,
        _formatDate(r.loanDate),
        r.purpose ?? '-',
        r.loanAmount.toStringAsFixed(0),
        r.paidAmount.toStringAsFixed(0),
        r.balanceAmount.toStringAsFixed(0),
        r.monthlyDeduction.toStringAsFixed(0),
        r.status,
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('loan_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── STAFF EXCEL ────────────────────────────────────────────────────────────

  static Future<void> exportStaffToExcel(List<StaffModel> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Staff'];

    final headers = [
      'Staff Code',
      'Name',
      'Mobile',
      'Email',
      'Category',
      'Department',
      'Branch',
      'Shift',
      'Joining Date',
      'Basic Salary',
      'OT Rate',
      'Weekly Off',
      'Status',
      'KPI Score',
      'Rating',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final r = records[i];
      _writeExcelRow(sheet, i + 1, [
        r.staffCode,
        r.name,
        r.mobile,
        r.email,
        r.category,
        r.department,
        r.branchName,
        r.shiftName,
        _formatDate(r.joiningDate),
        r.basicSalary.toStringAsFixed(0),
        r.overtimeRate.toStringAsFixed(0),
        r.weeklyOffDay,
        r.status,
        (r.kpiScore ?? 0).toStringAsFixed(1),
        r.kpiRating ?? '-',
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('staff_list.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── TASKS EXCEL ────────────────────────────────────────────────────────────

  static Future<void> exportTasksToExcel(List<TaskModel> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Tasks'];

    final headers = [
      'Task ID',
      'Group ID',
      'Title',
      'Staff Code',
      'Staff Name',
      'Assigned By',
      'Assigned Role',
      'Assigned To All',
      'Daily Task',
      'Due Date',
      'Status',
      'Created At',
      'Completed At',
      'Terminated At',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final task = records[i];
      _writeExcelRow(sheet, i + 1, [
        task.id,
        task.groupId,
        task.title,
        task.staffCode,
        task.staffName,
        task.assignedBy,
        task.assignedByRole,
        task.assignedToAll ? 'Yes' : 'No',
        task.isDailyTask ? 'Yes' : 'No',
        _formatDate(task.dueDate),
        task.status,
        _formatDate(task.createdAt),
        task.completedAt != null ? _formatDate(task.completedAt!) : '-',
        task.terminatedAt != null ? _formatDate(task.terminatedAt!) : '-',
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('task_cards_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── LEAVES EXCEL ───────────────────────────────────────────────────────────

  static Future<void> exportLeavesToExcel(List<LeaveModel> records) async {
    final excel = Excel.createExcel();
    final sheet = excel['Leaves'];

    final headers = [
      'Staff Code',
      'Staff Name',
      'Leave Type',
      'From',
      'To',
      'Days',
      'Reason',
      'Status',
      'Approved By',
      'Rejection Reason',
      'Created At',
    ];
    _writeExcelHeader(sheet, headers);

    for (int i = 0; i < records.length; i++) {
      final leave = records[i];
      _writeExcelRow(sheet, i + 1, [
        leave.staffCode,
        leave.staffName,
        leave.leaveType,
        _formatDate(leave.fromDate),
        _formatDate(leave.toDate),
        leave.totalDays.toString(),
        leave.reason,
        leave.status,
        leave.approvedBy ?? '-',
        leave.rejectionReason ?? '-',
        _formatDate(leave.createdAt),
      ]);
    }

    _autoFitColumns(sheet, headers.length);
    final path = await _getTempPath('leave_report.xlsx');
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await OpenFilex.open(path);
    }
  }

  // ─── DATABASE BACKUP JSON ───────────────────────────────────────────────────

  static Future<void> exportDatabaseBackupToJson({
    required List<StaffModel> staff,
    required List<AttendanceModel> attendance,
    required List<TaskModel> tasks,
    required List<KpiModel> kpis,
    required List<LeaveModel> leaves,
  }) async {
    final createdAt = DateTime.now();
    final payload = {
      'meta': {
        'app': 'Parcel Express HR',
        'created_at': createdAt.toIso8601String(),
        'format': 'smart_hr_backup_v1',
      },
      'staff': staff.map((item) => item.toMap()).toList(),
      'attendance': attendance.map((item) => item.toMap()).toList(),
      'tasks': tasks.map((item) => item.toMap()).toList(),
      'kpis': kpis.map((item) => item.toMap()).toList(),
      'leaves': leaves.map((item) => item.toMap()).toList(),
    };

    final filename =
        'smart_hr_backup_${createdAt.year}${createdAt.month.toString().padLeft(2, '0')}${createdAt.day.toString().padLeft(2, '0')}.json';
    final path = await _getTempPath(filename);
    const encoder = JsonEncoder.withIndent('  ');
    await File(path).writeAsString(encoder.convert(payload));
    await OpenFilex.open(path);
  }

  // ─── ATTENDANCE PDF ──────────────────────────────────────────────────────────

  static Future<void> exportAttendanceToPdf(
    List<AttendanceModel> records, {
    String title = 'Attendance Report',
    String subtitle = '',
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (ctx) => _pdfHeader(title, subtitle),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Staff Code',
              'Name',
              'Date',
              'Check In',
              'Check Out',
              'Hours',
              'OT',
              'Late',
              'Status',
            ],
            data: records
                .map((r) => [
                      r.staffCode,
                      r.staffName,
                      _formatDate(r.date),
                      r.checkInTime != null ? _formatTime(r.checkInTime!) : '-',
                      r.checkOutTime != null
                          ? _formatTime(r.checkOutTime!)
                          : '-',
                      r.workingHours.toStringAsFixed(1),
                      r.overtimeHours.toStringAsFixed(1),
                      '${r.lateMinutes}m',
                      r.status,
                    ])
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            border: pw.TableBorder.all(color: PdfColors.grey300),
            cellAlignments: {0: pw.Alignment.centerLeft},
          ),
        ],
      ),
    );

    final path = await _getTempPath('attendance_report.pdf');
    await File(path).writeAsBytes(await pdf.save());
    await OpenFilex.open(path);
  }

  // ─── SALARY PDF ──────────────────────────────────────────────────────────────

  static Future<void> exportSalaryToPdf(
    List<SalaryModel> records, {
    String title = 'Salary Report',
    String subtitle = '',
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (ctx) => _pdfHeader(title, subtitle),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Code',
              'Name',
              'Month',
              'Basic',
              'OT',
              'Allowance',
              'Loan Ded.',
              'Absence Ded.',
              'Net Salary',
              'Status',
            ],
            data: records
                .map((r) => [
                      r.staffCode,
                      r.staffName,
                      r.month,
                      'OMR ${r.basicSalary.toStringAsFixed(3)}',
                      'OMR ${r.overtimeAmount.toStringAsFixed(3)}',
                      'OMR ${r.allowance.toStringAsFixed(3)}',
                      'OMR ${r.loanDeduction.toStringAsFixed(3)}',
                      'OMR ${r.absenceDeduction.toStringAsFixed(3)}',
                      'OMR ${r.netSalary.toStringAsFixed(3)}',
                      r.paymentStatus,
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            border: pw.TableBorder.all(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    final path = await _getTempPath('salary_report.pdf');
    await File(path).writeAsBytes(await pdf.save());
    await OpenFilex.open(path);
  }

  // ─── KPI PDF ─────────────────────────────────────────────────────────────────

  static Future<void> exportKpiToPdf(
    List<KpiModel> records, {
    String title = 'KPI Report',
    String subtitle = '',
  }) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: (ctx) => _pdfHeader(title, subtitle),
        build: (ctx) => [
          pw.TableHelper.fromTextArray(
            headers: [
              'Code',
              'Name',
              'Month',
              'Tasks',
              'Completed',
              'Task Score',
              'Attendance%',
              'Late',
              'Missing CO',
              'OT Hours',
              'Fake GPS',
              'KPI Score',
              'Rating',
            ],
            data: records
                .map((r) => [
                      r.staffCode,
                      r.staffName,
                      r.month,
                      r.taskAssignedCount.toString(),
                      r.taskCompletedCount.toString(),
                      r.taskScore.toStringAsFixed(1),
                      '${r.attendanceRate}%',
                      r.lateCount.toString(),
                      r.missingCheckoutCount.toString(),
                      r.overtimeHours.toStringAsFixed(1),
                      r.fakeGpsCount.toString(),
                      r.totalKpiScore.toStringAsFixed(1),
                      r.rating,
                    ])
                .toList(),
            headerStyle:
                pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
            cellStyle: const pw.TextStyle(fontSize: 8),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            border: pw.TableBorder.all(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    final path = await _getTempPath('kpi_report.pdf');
    await File(path).writeAsBytes(await pdf.save());
    await OpenFilex.open(path);
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────────

  static void _writeExcelHeader(Sheet sheet, List<String> headers) {
    for (int i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle =
          CellStyle(bold: true, backgroundColorHex: ExcelColor.blue100);
    }
  }

  static void _writeExcelRow(Sheet sheet, int row, List<String> values) {
    for (int i = 0; i < values.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(values[i]);
    }
  }

  static void _autoFitColumns(Sheet sheet, int count) {
    for (int i = 0; i < count; i++) {
      sheet.setColumnWidth(i, 18.0);
    }
  }

  static pw.Widget _pdfHeader(String title, String subtitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Parcel Express HR',
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        if (subtitle.isNotEmpty)
          pw.Text(subtitle, style: const pw.TextStyle(fontSize: 10)),
        pw.Divider(),
        pw.SizedBox(height: 4),
      ],
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
