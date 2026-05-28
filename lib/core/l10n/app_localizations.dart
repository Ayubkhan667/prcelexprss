import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const delegate = _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  String tr(String key) {
    final map = isArabic ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ---------------------------------------------------------------------------
  // English strings
  // ---------------------------------------------------------------------------
  static const _en = <String, String>{
    // Navigation
    'dashboard': 'Dashboard',
    'staff': 'Staff',
    'attendance': 'Attendance',
    'kpi': 'KPI',
    'more': 'More',
    'settings': 'Settings',
    'notifications': 'Notifications',

    // Screen titles
    'admin_dashboard': 'Admin Dashboard',
    'staff_directory': 'Staff Directory',
    'attendance_reports': 'Attendance Reports',
    'kpi_dashboard': 'KPI Dashboard',
    'leave_approvals': 'Leave Approvals',
    'overtime_approval': 'Overtime Approval',
    'salary_management': 'Salary Management',
    'loan_management': 'Loan Management',
    'task_cards': 'Task Cards',
    'holiday_calendar': 'Holiday Calendar',
    'shift_management': 'Shift Management',
    'branch_management': 'Branch Management',
    'backup_export': 'Backup & Export',
    'admin_audit_logs': 'Admin Audit Logs',
    'supervisor_permissions': 'Supervisor Permissions',
    'manual_attendance_entry': 'Manual Attendance Entry',
    'attendance_edit_logs': 'Attendance Edit Logs',
    'attendance_history': 'Attendance History',
    'app_settings': 'App Settings',
    'quick_actions': 'Quick Actions',
    'work_expenses': 'Work Expenses',
    'my_kpi_report': 'My KPI Report',
    'my_tasks': 'My Tasks',
    'my_team': 'My Team',
    'my_salary': 'My Salary',
    'my_loans': 'My Loans',
    'my_profile': 'My Profile',
    'leave_management': 'Leave Management',
    'leave_requests': 'Leave Requests',
    'team_attendance': 'Team Attendance',

    // Common actions
    'save': 'Save',
    'save_changes': 'Save Changes',
    'cancel': 'Cancel',
    'edit': 'Edit',
    'delete': 'Delete',
    'approve': 'Approve',
    'reject': 'Reject',
    'close': 'Close',
    'done': 'Done',
    'ok': 'OK',
    'add': 'Add',
    'remove': 'Remove',
    'update': 'Update',
    'continue': 'Continue',
    'generate': 'Generate',
    'sync': 'Sync',
    'view_details': 'View Details',
    'view_map': 'View Map',
    'mark_all_read': 'Mark All Read',
    'mark_paid': 'Mark Paid',
    'mark_as_completed': 'Mark as Completed',
    'mark_visit': 'Mark Visit',
    'pick_date': 'Pick Date',
    'date': 'Date',
    'time': 'Time',
    'category': 'Category',
    'add_more': 'Add More',
    'filter_by_approval_status': 'Filter by Approval Status',
    'more_options': 'More Options',
    'upcoming': 'Upcoming',
    'recent_activity': 'Recent Activity',
    'this_month_stats': 'This Month Stats',
    'out_of_100': 'out of 100',
    'active': 'Active',
    'submitted': 'Submitted',
    'net_salary': 'Net Salary',
    'net_salary_caps': 'NET SALARY',
    'all_employees': 'All Employees',
    'all_categories': 'All Categories',

    // Staff
    'add_staff': 'Add Staff',
    'edit_staff': 'Edit Staff',
    'staff_not_found': 'Staff not found',
    'staff_profile_not_found': 'Staff profile not found.',
    'no_staff_found': 'No staff found',
    'terminate': 'Terminate',

    // Attendance
    'no_attendance_records_found': 'No attendance records found',
    'no_attendance_for_date': 'No attendance records for this date',
    'no_records_for_date': 'No records for this date',
    'no_records_for_month': 'No records for this month',
    'no_records_found': 'No records found',
    'no_edit_logs_found': 'No edit logs found',

    // Leave
    'apply_for_leave': 'Apply for Leave',
    'submit_leave_request': 'Submit Leave Request',
    'no_leave_requests_yet': 'No leave requests yet',
    'no_leave_requests': 'No leave requests',
    'reject_leave': 'Reject Leave',

    // KPI
    'kpi_score': 'KPI Score',
    'kpi_performance': 'KPI Performance',
    'no_kpi_data': 'No KPI data available',
    'kpi_calculated_end_month': 'KPI is calculated at end of each month',

    // Salary
    'generate_salary': 'Generate Salary',
    'no_salary_records': 'No salary records found',

    // Loans
    'add_loan': 'Add Loan',
    'add_new_loan': 'Add New Loan',
    'no_active_loans': 'No active loans',
    'no_loans_found': 'No loans found',

    // Tasks
    'assign_task': 'Assign Task',
    'daily_task': 'Daily task',
    'assign_to_all_active': 'Assign to all active employees',
    'creates_task_card_for_each': 'Creates a task card for each employee',
    'send_task_card': 'Send Task Card',

    // Auth
    'biometric_login': 'Biometric Login',
    'temporary_password': 'Temporary Password',
    'device_not_allowed': 'Device Not Allowed',
    'set_up_biometrics': 'Set Up Biometrics',
    'logout_all': 'Logout All',
    'logout_all_devices': 'Logout All Devices',
    'not_available_on_device': 'Not available on this device',

    // Settings / Company
    'company_settings': 'Company Settings',
    'location_settings': 'Location Settings',
    'export_formats': 'Export Formats',
    'departments': 'Departments',
    'api_server_url': 'API Server URL',
    'save_url': 'Save URL',
    'account_actions': 'Account Actions',
    'update_company_info': 'Update company information',
    'app_version': 'Parcel Express HR v1.0.0',
    'language': 'Language',
    'arabic': 'العربية',
    'english': 'English',
    'select_language': 'Select Language',

    // Notifications
    'no_notifications': 'No notifications',

    // Expenses
    'no_expense_claims': 'No expense claims yet',
    'submit_first_claim': 'Submit your first claim from the other tab',
    'receipt': 'Receipt',
    'take_photo': 'Take Photo',
    'choose_from_gallery': 'Choose from Gallery',
    'tap_to_add_receipt': 'Tap to add receipt photos',
    'camera_or_gallery_max_5': 'Camera or Gallery • Max 5 images',

    // Holidays
    'add_holiday': 'Add Holiday',
    'every_friday_weekly_rest': 'Every Friday — Weekly Rest Day',
    'remove_holiday': 'Remove Holiday?',

    // Shifts
    'add_shift': 'Add Shift',
    'no_shifts_found': 'No shifts found',
    'branch_shift_config_missing': 'Branch or shift configuration is missing.',
    'can_be_closed_same_day': 'Can be closed on the same day by admin',

    // Branches
    'add_branch': 'Add Branch',

    // Greetings
    'good_morning': 'Good Morning',
    'good_afternoon': 'Good Afternoon',
    'good_evening': 'Good Evening',

    // Dashboard section headers
    'todays_overview': "Today's Overview",
    'attendance_breakdown': 'Attendance Breakdown (This Month)',
    'performance_highlights': 'Performance Highlights',

    // Misc
    'error_prefix': 'Error',
    'no_data': 'No data available',
    'salary': 'Salary',
    'loan': 'Loan',
    'overtime': 'Overtime',
    'attendance_label': 'Attendance',
    'kpi_label': 'KPI',
    'leave': 'Leave',
    'task': 'Task',
    'branch': 'Branch',
    'shift': 'Shift',
    'check_in': 'Check In',
    'check_out': 'Check Out',
    'present': 'Present',
    'absent': 'Absent',
    'late': 'Late',
    'on_leave': 'On Leave',
    'today': 'Today',
    'this_month': 'This Month',
    'staff_count': 'Staff Count',
    'view_all': 'View All',
    'see_all': 'See All',

    // Dashboard stat labels
    'total_staff': 'Total Staff',
    'present_today': 'Present Today',
    'absent_today': 'Absent Today',
    'late_today': 'Late Today',
    'ot_hours': 'OT Hours',
    'salary_pending': 'Salary Pending',
    'loan_balance': 'Loan Balance',
    'kpi_average': 'KPI Average',
    'overtime_staff': 'Overtime Staff',
    'all_staff_title': 'All Staff',
    'best_staff_month': 'Best Staff of Month',
    'lowest_kpi_staff': 'Lowest KPI Staff',
    'highest_overtime': 'Highest Overtime',

    // Staff home
    'todays_attendance': "Today's Attendance",
    'my_kpi': 'My KPI',
    'expenses': 'Expenses',
    'present_days': 'Present Days',
    'late_days': 'Late Days',
    'overtime_hrs': 'Overtime hrs',
    'no_pending_tasks': 'No pending tasks',

    // Settings sections
    'hr_configuration': 'HR Configuration',
    'attendance_rules': 'Attendance Rules',
    'salary_payroll': 'Salary & Payroll',
    'security': 'Security',
    'reports_export': 'Reports & Export',
    'backend_configuration': 'Backend Configuration',

    // Settings tile titles
    'grace_period': 'Grace Period',
    'standard_hours_title': 'Standard Hours',
    'standard_working_hours': 'Standard Working Hours',
    'gps_enforcement': 'GPS Enforcement',
    'selfie_requirement': 'Selfie Requirement',
    'salary_cycle': 'Salary Cycle',
    'salary_cycle_day': 'Salary Cycle Day',
    'overtime_policy': 'Overtime Policy',
    'overtime_starts_after': 'Overtime Starts After',
    'deduction_rules': 'Deduction Rules',
    'absence_deduction': 'Absence Deduction',
    'push_notifications_title': 'Push Notifications',
    'app_sounds': 'App Sounds',
    'sms_alerts': 'SMS Alerts',
    'remote_backend_mode': 'Remote Backend Mode',
    'device_binding': 'Device Binding',
    'mock_gps_detection': 'Mock GPS Detection',
    'change_password': 'Change Password',
    'update_password': 'Update your password',

    // Settings subtitles
    'create_edit_shifts': 'Create & edit shifts',
    'manage_branches_geofences': 'Manage branches & geofences',
    'control_supervisor_access': 'Control supervisor module access',
    'managed_backend_security': 'Managed by backend security policy',
    'sounds_on_subtitle': 'Click & feedback sounds on',
    'sounds_off_subtitle': 'All app sounds muted',
    'sms_gateway_required': 'Requires SMS gateway integration',
    'enforced_backend_signin': 'Enforced by backend at sign-in',
    'sign_out_all_sessions': 'Sign out of all active sessions',
    'staff_data_export_desc': 'Staff, attendance, tasks, KPI, leaves',
    'fake_location_blocked': 'Fake location detected & blocked',
    'mock_gps_off': 'Mock GPS detection off',
    'using_api_backend': 'Using API backend',
    'api_url_required': 'API URL required before sign in',
    'using_local_demo': 'Using local demo data',
    'managed_build_config': 'Managed by build configuration',
    'notifications_enabled_subtitle': 'App notifications enabled',
    'notifications_disabled_subtitle': 'Notifications disabled',
    'selfie_required_subtitle': 'Required for check-in',
    'selfie_not_required': 'Selfie not required',
    'minutes_unit': 'minutes',
    'hours_per_day_unit': 'hours/day',
    'hours_unit': 'hours',
    'percent_per_absent': '% of daily salary',

    // Dialogs
    'logout_all_title_dialog': 'Logout All Devices',
    'logout_all_content':
        'This will sign you out of all active sessions on all devices.',
    'logout_all_btn': 'Logout All',
    'enable_remote_backend': 'Enable Remote Backend',
    'enable_demo_mode': 'Enable Demo Mode',
    'switch_backend_warning':
        'Switching backend mode will sign you out and reload the app data source.',
    'remote_backend_enabled_msg': 'Remote backend mode enabled',
    'demo_mode_enabled_msg': 'Demo mode enabled',

    // Leave approval tabs & details
    'pending_tab': 'Pending',
    'approved_tab': 'Approved',
    'rejected_tab': 'Rejected',
    'approved_by': 'Approved by',
    'rejection_prefix': 'Rejection',
    'rejection_reason': 'Rejection reason',

    // Salary details
    'total_payroll': 'Total Payroll',
    'pending_status': 'Pending',
    'paid_status': 'Paid',
    'basic_salary': 'Basic Salary',
    'allowance': 'Allowance',
    'deduction': 'Deduction',
    'loan_deduction': 'Loan Deduction',
    'absence_ded_short': 'Absence Ded.',
    'other_deduction': 'Other Deduction',
    'penalty': 'Penalty',
    'overtime_amount': 'Overtime Amount',
    'salary_details': 'Salary Details',
    'generate_salary_confirm':
        'Generate salary for all active staff for the current month?',

    // Loan details
    'total_balance': 'Total Balance',
    'active_loans': 'Active Loans',
    'total_loans': 'Total Loans',
    'percent_paid': '% Paid',
    'remaining_balance': 'remaining',
    'total_label': 'Total',
    'paid_label': 'Paid',
    'monthly_label': 'Monthly',
    'loan_date': 'Loan Date',
    'select_staff': 'Select Staff',
    'loan_amount_label': 'Loan Amount',
    'monthly_deduction_label': 'Monthly Deduction',
    'purpose_reason': 'Purpose / Reason',
    'loan_added': 'Loan added',

    // KPI dashboard
    'average_kpi': 'Average KPI',
    'best_score': 'Best Score',
    'staff_kpi_scores': 'Staff KPI Scores',
    'top_performers': 'Top Performers',
    'all_staff_kpi': 'All Staff KPI',
    'score_breakdown_weights': 'Score Breakdown Weights',
    'punctuality': 'Punctuality',
    'overtime_extra_support': 'Overtime / Extra Support',
    'location_compliance': 'Location Compliance',
    'discipline_violation': 'Discipline / Violation',
    'pts_label': 'pts',
    'location_short': 'Location',
    'discipline_short': 'Discipline',

    // Task management
    'pending_label': 'Pending',
    'done_label': 'Done',
    'closed_label': 'Closed',
    'completed_label': 'Completed',
    'search_task_employee': 'Search task or employee',
    'employee_filter': 'Employee Filter',
    'all_label': 'All',
    'all_staff_batch': 'All Staff Batch',
    'no_task_cards': 'No task cards found',
    'terminate_task': 'Terminate Task',
    'task_title': 'Task title',
    'task_description': 'Task description',
    'select_employee': 'Select employee',
    'due_date_time': 'Due Date & Time',
    'task_terminated_msg': 'Task terminated',
    'due_prefix': 'Due',
    'by_prefix': 'By',
    'completed_at': 'Completed',
    'closed_at': 'Closed',

    // Attendance/Overtime report
    'daily_tab': 'Daily',
    'all_staff_tab': 'All Staff',
    'no_overtime_records': 'No overtime records',
    'records_label': 'records',
    'late_by_label': 'Late by',
    'ot_hrs': 'OT hrs',
    'total_hours': 'Total Hours',
    'ot_amount': 'OT Amount',

    // Checkin/out screen
    'location_verification': 'Location Verification',
    'wifi_verification': 'Office Wi-Fi Verification',
    'worked_label': 'Worked',
    'paused_label': 'Paused',
    'break_left': 'Break Left',
    'outside_assigned_range': 'Outside assigned range',
    'assigned_range_rule': 'Assigned Range Rule',
    'daily_break_limit_label': 'Daily break limit',
    'minutes_short': 'min',
    'checkout_successful': 'Check-Out Successful',
    'checkout_verified_desc':
        'Duty closed with Wi-Fi and location verification.',
    'camera_access_required': 'Camera Access Required',
    'selfie_required_label': 'Selfie Required',
    'duty_active_desc': 'Duty timer is active and being monitored.',
    'duty_paused_desc':
        'Duty timer is paused until office Wi-Fi and location are verified again.',
    'manual_wifi_entry': 'Manual Wi-Fi Entry',
    'test_camera': 'Test Camera',
    'open_app_settings_btn': 'Open App Settings',
    'mark_visit_btn': 'Mark Visit',
    'break_running': 'Break Running',
    'start_break': 'Start Break',
    'break_needs_checkin': 'Break needs Check In',
  };

  // ---------------------------------------------------------------------------
  // Arabic strings
  // ---------------------------------------------------------------------------
  static const _ar = <String, String>{
    // Navigation
    'dashboard': 'لوحة التحكم',
    'staff': 'الموظفون',
    'attendance': 'الحضور',
    'kpi': 'مؤشرات الأداء',
    'more': 'المزيد',
    'settings': 'الإعدادات',
    'notifications': 'الإشعارات',

    // Screen titles
    'admin_dashboard': 'لوحة تحكم المدير',
    'staff_directory': 'دليل الموظفين',
    'attendance_reports': 'تقارير الحضور',
    'kpi_dashboard': 'لوحة مؤشرات الأداء',
    'leave_approvals': 'طلبات الإجازات',
    'overtime_approval': 'موافقة الوقت الإضافي',
    'salary_management': 'إدارة الرواتب',
    'loan_management': 'إدارة القروض',
    'task_cards': 'بطاقات المهام',
    'holiday_calendar': 'تقويم الإجازات',
    'shift_management': 'إدارة المناوبات',
    'branch_management': 'إدارة الفروع',
    'backup_export': 'النسخ الاحتياطي والتصدير',
    'admin_audit_logs': 'سجلات المراجعة الإدارية',
    'supervisor_permissions': 'صلاحيات المشرف',
    'manual_attendance_entry': 'إدخال الحضور اليدوي',
    'attendance_edit_logs': 'سجلات تعديل الحضور',
    'attendance_history': 'سجل الحضور',
    'app_settings': 'إعدادات التطبيق',
    'quick_actions': 'الإجراءات السريعة',
    'work_expenses': 'مصاريف العمل',
    'my_kpi_report': 'تقرير أدائي',
    'my_tasks': 'مهامي',
    'my_team': 'فريقي',
    'my_salary': 'راتبي',
    'my_loans': 'قروضي',
    'my_profile': 'ملفي الشخصي',
    'leave_management': 'إدارة الإجازات',
    'leave_requests': 'طلبات الإجازات',
    'team_attendance': 'حضور الفريق',

    // Common actions
    'save': 'حفظ',
    'save_changes': 'حفظ التغييرات',
    'cancel': 'إلغاء',
    'edit': 'تعديل',
    'delete': 'حذف',
    'approve': 'موافقة',
    'reject': 'رفض',
    'close': 'إغلاق',
    'done': 'تم',
    'ok': 'حسناً',
    'add': 'إضافة',
    'remove': 'إزالة',
    'update': 'تحديث',
    'continue': 'متابعة',
    'generate': 'إنشاء',
    'sync': 'مزامنة',
    'view_details': 'عرض التفاصيل',
    'view_map': 'عرض الخريطة',
    'mark_all_read': 'تحديد الكل كمقروء',
    'mark_paid': 'تحديد كمدفوع',
    'mark_as_completed': 'تحديد كمكتمل',
    'mark_visit': 'تسجيل الزيارة',
    'pick_date': 'اختر تاريخاً',
    'date': 'التاريخ',
    'time': 'الوقت',
    'category': 'الفئة',
    'add_more': 'إضافة المزيد',
    'filter_by_approval_status': 'تصفية حسب حالة الموافقة',
    'more_options': 'المزيد من الخيارات',
    'upcoming': 'القادمة',
    'recent_activity': 'النشاط الأخير',
    'this_month_stats': 'إحصاءات هذا الشهر',
    'out_of_100': 'من 100',
    'active': 'نشط',
    'submitted': 'مقدم',
    'net_salary': 'صافي الراتب',
    'net_salary_caps': 'صافي الراتب',
    'all_employees': 'جميع الموظفين',
    'all_categories': 'جميع الفئات',

    // Staff
    'add_staff': 'إضافة موظف',
    'edit_staff': 'تعديل موظف',
    'staff_not_found': 'الموظف غير موجود',
    'staff_profile_not_found': 'ملف الموظف غير موجود.',
    'no_staff_found': 'لا يوجد موظفون',
    'terminate': 'إنهاء الخدمة',

    // Attendance
    'no_attendance_records_found': 'لا توجد سجلات حضور',
    'no_attendance_for_date': 'لا توجد سجلات حضور لهذا التاريخ',
    'no_records_for_date': 'لا توجد سجلات لهذا التاريخ',
    'no_records_for_month': 'لا توجد سجلات لهذا الشهر',
    'no_records_found': 'لا توجد سجلات',
    'no_edit_logs_found': 'لا توجد سجلات تعديل',

    // Leave
    'apply_for_leave': 'تقديم طلب إجازة',
    'submit_leave_request': 'تقديم طلب الإجازة',
    'no_leave_requests_yet': 'لا توجد طلبات إجازات بعد',
    'no_leave_requests': 'لا توجد طلبات إجازات',
    'reject_leave': 'رفض الإجازة',

    // KPI
    'kpi_score': 'نقاط الأداء',
    'kpi_performance': 'أداء مؤشرات الأداء',
    'no_kpi_data': 'لا تتوفر بيانات مؤشرات الأداء',
    'kpi_calculated_end_month': 'يتم احتساب مؤشر الأداء في نهاية كل شهر',

    // Salary
    'generate_salary': 'إنشاء الراتب',
    'no_salary_records': 'لا توجد سجلات رواتب',

    // Loans
    'add_loan': 'إضافة قرض',
    'add_new_loan': 'إضافة قرض جديد',
    'no_active_loans': 'لا توجد قروض نشطة',
    'no_loans_found': 'لا توجد قروض',

    // Tasks
    'assign_task': 'تعيين مهمة',
    'daily_task': 'المهمة اليومية',
    'assign_to_all_active': 'تعيين لجميع الموظفين النشطين',
    'creates_task_card_for_each': 'ينشئ بطاقة مهمة لكل موظف',
    'send_task_card': 'إرسال بطاقة المهمة',

    // Auth
    'biometric_login': 'تسجيل الدخول بالبصمة',
    'temporary_password': 'كلمة مرور مؤقتة',
    'device_not_allowed': 'الجهاز غير مسموح',
    'set_up_biometrics': 'إعداد البصمة',
    'logout_all': 'تسجيل خروج الكل',
    'logout_all_devices': 'تسجيل خروج من جميع الأجهزة',
    'not_available_on_device': 'غير متاح على هذا الجهاز',

    // Settings / Company
    'company_settings': 'إعدادات الشركة',
    'location_settings': 'إعدادات الموقع',
    'export_formats': 'صيغ التصدير',
    'departments': 'الأقسام',
    'api_server_url': 'رابط خادم API',
    'save_url': 'حفظ الرابط',
    'account_actions': 'إجراءات الحساب',
    'update_company_info': 'تحديث معلومات الشركة',
    'app_version': 'Parcel Express HR v1.0.0',
    'language': 'اللغة',
    'arabic': 'العربية',
    'english': 'English',
    'select_language': 'اختر اللغة',

    // Notifications
    'no_notifications': 'لا توجد إشعارات',

    // Expenses
    'no_expense_claims': 'لا توجد مطالبات مصاريف بعد',
    'submit_first_claim': 'قدم أول مطالبة من التبويب الآخر',
    'receipt': 'الإيصال',
    'take_photo': 'التقاط صورة',
    'choose_from_gallery': 'اختر من المعرض',
    'tap_to_add_receipt': 'اضغط لإضافة صور الإيصالات',
    'camera_or_gallery_max_5': 'الكاميرا أو المعرض • بحد أقصى 5 صور',

    // Holidays
    'add_holiday': 'إضافة عطلة',
    'every_friday_weekly_rest': 'كل جمعة — يوم الراحة الأسبوعية',
    'remove_holiday': 'إزالة العطلة؟',

    // Shifts
    'add_shift': 'إضافة مناوبة',
    'no_shifts_found': 'لا توجد مناوبات',
    'branch_shift_config_missing': 'تكوين الفرع أو المناوبة مفقود.',
    'can_be_closed_same_day': 'يمكن إغلاقه في نفس اليوم من قبل الإدارة',

    // Branches
    'add_branch': 'إضافة فرع',

    // Greetings
    'good_morning': 'صباح الخير',
    'good_afternoon': 'مساء الخير',
    'good_evening': 'مساء النور',

    // Dashboard section headers
    'todays_overview': 'نظرة اليوم',
    'attendance_breakdown': 'تفصيل الحضور (هذا الشهر)',
    'performance_highlights': 'أبرز الأداء',

    // Misc
    'error_prefix': 'خطأ',
    'no_data': 'لا تتوفر بيانات',
    'salary': 'الراتب',
    'loan': 'القرض',
    'overtime': 'الوقت الإضافي',
    'attendance_label': 'الحضور',
    'kpi_label': 'مؤشرات الأداء',
    'leave': 'الإجازة',
    'task': 'المهمة',
    'branch': 'الفرع',
    'shift': 'المناوبة',
    'check_in': 'تسجيل الدخول',
    'check_out': 'تسجيل الخروج',
    'present': 'حاضر',
    'absent': 'غائب',
    'late': 'متأخر',
    'on_leave': 'في إجازة',
    'today': 'اليوم',
    'this_month': 'هذا الشهر',
    'staff_count': 'عدد الموظفين',
    'view_all': 'عرض الكل',
    'see_all': 'رؤية الكل',

    // Dashboard stat labels
    'total_staff': 'إجمالي الموظفين',
    'present_today': 'حاضرون اليوم',
    'absent_today': 'غائبون اليوم',
    'late_today': 'متأخرون اليوم',
    'ot_hours': 'ساعات إضافية',
    'salary_pending': 'رواتب معلقة',
    'loan_balance': 'رصيد القروض',
    'kpi_average': 'متوسط الأداء',
    'overtime_staff': 'موظفو الإضافي',
    'all_staff_title': 'جميع الموظفين',
    'best_staff_month': 'أفضل موظف في الشهر',
    'lowest_kpi_staff': 'أضعف موظف في الأداء',
    'highest_overtime': 'أعلى وقت إضافي',

    // Staff home
    'todays_attendance': 'حضور اليوم',
    'my_kpi': 'أدائي',
    'expenses': 'المصاريف',
    'present_days': 'أيام الحضور',
    'late_days': 'أيام التأخر',
    'overtime_hrs': 'ساعات إضافية',
    'no_pending_tasks': 'لا مهام معلقة',

    // Settings sections
    'hr_configuration': 'إعداد الموارد البشرية',
    'attendance_rules': 'قواعد الحضور',
    'salary_payroll': 'الرواتب وكشوف المرتبات',
    'security': 'الأمان',
    'reports_export': 'التقارير والتصدير',
    'backend_configuration': 'إعداد الخادم',

    // Settings tile titles
    'grace_period': 'فترة السماح',
    'standard_hours_title': 'ساعات العمل',
    'standard_working_hours': 'ساعات العمل المعيارية',
    'gps_enforcement': 'تطبيق GPS',
    'selfie_requirement': 'متطلب الصورة الشخصية',
    'salary_cycle': 'دورة الراتب',
    'salary_cycle_day': 'يوم دورة الراتب',
    'overtime_policy': 'سياسة الوقت الإضافي',
    'overtime_starts_after': 'يبدأ الوقت الإضافي بعد',
    'deduction_rules': 'قواعد الخصم',
    'absence_deduction': 'خصم الغياب',
    'push_notifications_title': 'الإشعارات الفورية',
    'app_sounds': 'أصوات التطبيق',
    'sms_alerts': 'تنبيهات SMS',
    'remote_backend_mode': 'وضع الخادم البعيد',
    'device_binding': 'ربط الجهاز',
    'mock_gps_detection': 'كشف GPS المزيف',
    'change_password': 'تغيير كلمة المرور',
    'update_password': 'تحديث كلمة المرور',

    // Settings subtitles
    'create_edit_shifts': 'إنشاء وتعديل المناوبات',
    'manage_branches_geofences': 'إدارة الفروع والحدود الجغرافية',
    'control_supervisor_access': 'التحكم في وصول المشرف للوحدات',
    'managed_backend_security': 'يُدار بواسطة سياسة أمان الخادم',
    'sounds_on_subtitle': 'أصوات الضغط والتغذية الراجعة مفعلة',
    'sounds_off_subtitle': 'جميع أصوات التطبيق مكتومة',
    'sms_gateway_required': 'يتطلب تكامل بوابة الرسائل القصيرة',
    'enforced_backend_signin': 'مطبق من الخادم عند تسجيل الدخول',
    'sign_out_all_sessions': 'تسجيل الخروج من جميع الجلسات النشطة',
    'staff_data_export_desc': 'الموظفون، الحضور، المهام، الأداء، الإجازات',
    'fake_location_blocked': 'تم اكتشاف موقع مزيف وحجبه',
    'mock_gps_off': 'كشف GPS المزيف معطل',
    'using_api_backend': 'استخدام الخادم الخارجي',
    'api_url_required': 'مطلوب رابط API قبل تسجيل الدخول',
    'using_local_demo': 'استخدام بيانات تجريبية محلية',
    'managed_build_config': 'يُدار بواسطة إعدادات البناء',
    'notifications_enabled_subtitle': 'إشعارات التطبيق مفعلة',
    'notifications_disabled_subtitle': 'الإشعارات معطلة',
    'selfie_required_subtitle': 'مطلوب عند تسجيل الدخول',
    'selfie_not_required': 'الصورة الشخصية غير مطلوبة',
    'minutes_unit': 'دقيقة',
    'hours_per_day_unit': 'ساعة/يوم',
    'hours_unit': 'ساعة',
    'percent_per_absent': '% من الراتب اليومي',

    // Dialogs
    'logout_all_title_dialog': 'تسجيل خروج من جميع الأجهزة',
    'logout_all_content':
        'سيتم تسجيل خروجك من جميع الجلسات النشطة على جميع الأجهزة.',
    'logout_all_btn': 'تسجيل خروج الكل',
    'enable_remote_backend': 'تفعيل الخادم البعيد',
    'enable_demo_mode': 'تفعيل الوضع التجريبي',
    'switch_backend_warning':
        'تبديل وضع الخادم سيقوم بتسجيل خروجك وإعادة تحميل مصدر البيانات.',
    'remote_backend_enabled_msg': 'تم تفعيل وضع الخادم البعيد',
    'demo_mode_enabled_msg': 'تم تفعيل الوضع التجريبي',

    // Leave approval tabs & details
    'pending_tab': 'قيد الانتظار',
    'approved_tab': 'موافق عليه',
    'rejected_tab': 'مرفوض',
    'approved_by': 'وافق عليه',
    'rejection_prefix': 'الرفض',
    'rejection_reason': 'سبب الرفض',

    // Salary details
    'total_payroll': 'إجمالي الرواتب',
    'pending_status': 'معلق',
    'paid_status': 'مدفوع',
    'basic_salary': 'الراتب الأساسي',
    'allowance': 'البدل',
    'deduction': 'الخصم',
    'loan_deduction': 'خصم القرض',
    'absence_ded_short': 'خصم الغياب',
    'other_deduction': 'خصومات أخرى',
    'penalty': 'الغرامة',
    'overtime_amount': 'مبلغ الوقت الإضافي',
    'salary_details': 'تفاصيل الراتب',
    'generate_salary_confirm': 'إنشاء راتب لجميع الموظفين النشطين للشهر الحالي؟',

    // Loan details
    'total_balance': 'الرصيد الكلي',
    'active_loans': 'القروض النشطة',
    'total_loans': 'إجمالي القروض',
    'percent_paid': '٪ مدفوع',
    'remaining_balance': 'متبقي',
    'total_label': 'الإجمالي',
    'paid_label': 'المدفوع',
    'monthly_label': 'الشهري',
    'loan_date': 'تاريخ القرض',
    'select_staff': 'اختر موظفاً',
    'loan_amount_label': 'مبلغ القرض',
    'monthly_deduction_label': 'الخصم الشهري',
    'purpose_reason': 'الغرض / السبب',
    'loan_added': 'تمت إضافة القرض',

    // KPI dashboard
    'average_kpi': 'متوسط الأداء',
    'best_score': 'أعلى نتيجة',
    'staff_kpi_scores': 'نتائج أداء الموظفين',
    'top_performers': 'أفضل الموظفين',
    'all_staff_kpi': 'مؤشر أداء جميع الموظفين',
    'score_breakdown_weights': 'أوزان تفصيل الدرجات',
    'punctuality': 'الانتظام',
    'overtime_extra_support': 'الوقت الإضافي / دعم إضافي',
    'location_compliance': 'الالتزام بالموقع',
    'discipline_violation': 'الانضباط / المخالفة',
    'pts_label': 'نقطة',
    'location_short': 'الموقع',
    'discipline_short': 'الانضباط',

    // Task management
    'pending_label': 'قيد الانتظار',
    'done_label': 'تم',
    'closed_label': 'مغلق',
    'completed_label': 'مكتمل',
    'search_task_employee': 'البحث عن مهمة أو موظف',
    'employee_filter': 'تصفية الموظفين',
    'all_label': 'الكل',
    'all_staff_batch': 'دفعة لجميع الموظفين',
    'no_task_cards': 'لا توجد بطاقات مهام',
    'terminate_task': 'إغلاق المهمة',
    'task_title': 'عنوان المهمة',
    'task_description': 'وصف المهمة',
    'select_employee': 'اختر موظفاً',
    'due_date_time': 'تاريخ ووقت الاستحقاق',
    'task_terminated_msg': 'تم إغلاق المهمة',
    'due_prefix': 'موعد التسليم',
    'by_prefix': 'بواسطة',
    'completed_at': 'أُنجز',
    'closed_at': 'أُغلق',

    // Attendance/Overtime report
    'daily_tab': 'يومي',
    'all_staff_tab': 'جميع الموظفين',
    'no_overtime_records': 'لا توجد سجلات وقت إضافي',
    'records_label': 'سجلات',
    'late_by_label': 'متأخر بـ',
    'ot_hrs': 'ساعات إضافية',
    'total_hours': 'إجمالي الساعات',
    'ot_amount': 'مبلغ الإضافي',

    // Checkin/out screen
    'location_verification': 'التحقق من الموقع',
    'wifi_verification': 'التحقق من Wi-Fi المكتب',
    'worked_label': 'عمل',
    'paused_label': 'موقوف',
    'break_left': 'الاستراحة المتبقية',
    'outside_assigned_range': 'خارج النطاق المحدد',
    'assigned_range_rule': 'قاعدة النطاق المحدد',
    'daily_break_limit_label': 'حد الاستراحة اليومية',
    'minutes_short': 'دقيقة',
    'checkout_successful': 'تسجيل الخروج ناجح',
    'checkout_verified_desc': 'تم إغلاق الدوام بعد التحقق من Wi-Fi والموقع.',
    'camera_access_required': 'مطلوب صلاحية الكاميرا',
    'selfie_required_label': 'صورة شخصية مطلوبة',
    'duty_active_desc': 'مؤقت الدوام يعمل ويتم مراقبته.',
    'duty_paused_desc': 'مؤقت الدوام موقوف حتى يتم التحقق من Wi-Fi المكتب والموقع مرة أخرى.',
    'manual_wifi_entry': 'إدخال Wi-Fi يدوياً',
    'test_camera': 'اختبار الكاميرا',
    'open_app_settings_btn': 'فتح إعدادات التطبيق',
    'mark_visit_btn': 'تسجيل زيارة',
    'break_running': 'الاستراحة جارية',
    'start_break': 'بدء الاستراحة',
    'break_needs_checkin': 'سجل الدخول للاستراحة',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
