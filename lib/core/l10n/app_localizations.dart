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
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode);

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
