class AppConstants {
  static const String appName = 'Parcel Express';
  static const String appVersion = '1.0.0';
  static const String defaultApiBaseUrl = 'https://api.smarthr.local';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultApiBaseUrl,
  );
  static const bool useRemoteData = bool.fromEnvironment(
    'USE_REMOTE_DATA',
    defaultValue: false,
  );
  static const bool hasConfiguredApiBaseUrl = apiBaseUrl != defaultApiBaseUrl;
  static const bool canUseRemoteData = useRemoteData && hasConfiguredApiBaseUrl;

  // Routes
  static const String routeSplash = '/splash';
  static const String routeLogin = '/login';
  static const String routeAdmin = '/admin';
  static const String routeSupervisor = '/supervisor';
  static const String routeStaff = '/staff';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleSupervisor = 'supervisor';
  static const String roleStaff = 'staff';

  // Staff Categories
  static const List<String> staffCategories = [
    'Driver',
    'Warehouse',
    'Admin',
    'Supervisor',
    'Accountant',
    'Manager',
  ];

  // Departments
  static const List<String> departments = [
    'Operations',
    'Logistics',
    'Finance',
    'HR',
    'IT',
    'Customer Service',
    'Warehouse',
    'Management',
  ];

  // Leave Types — per Oman Labour Law (RD 35/2003 & amendments)
  static const List<String> leaveTypes = [
    'Annual Leave', // 30 days/year — Art. 61
    'Sick Leave', // Full pay 2wks, half pay 4wks — Art. 66
    'Emergency Leave',
    'Maternity Leave', // 50 days — Art. 83
    'Paternity Leave', // 3 days
    'Hajj Leave', // 15 working days once in service — Art. 65
    'Iddah Leave', // 130 days (death of husband) — Art. 84
    'Unpaid Leave',
    'Compensatory Leave',
  ];

  // Status values
  static const String statusActive = 'Active';
  static const String statusInactive = 'Inactive';
  static const String statusSuspended = 'Suspended';

  static const String attendancePresent = 'Present';
  static const String attendanceAbsent = 'Absent';
  static const String attendanceLate = 'Late';
  static const String attendanceOnLeave = 'On Leave';
  static const String attendanceEarlyOut = 'Early Out';
  static const String attendanceMissingCheckout = 'Missing Checkout';
  static const String attendanceOvertime = 'Overtime';
  static const String attendanceDutyPaused = 'Duty Paused';
  static const String attendanceVisit = 'Visit';

  static const String dutyStatusActive = 'Active';
  static const String dutyStatusPaused = 'Paused';
  static const String dutyStatusCompleted = 'Completed';

  static const String leaveStatusPending = 'Pending';
  static const String leaveStatusApproved = 'Approved';
  static const String leaveStatusRejected = 'Rejected';

  static const String salaryStatusPending = 'Pending';
  static const String salaryStatusPaid = 'Paid';
  static const String salaryStatusHold = 'Hold';

  static const String loanStatusActive = 'Active';
  static const String loanStatusPaid = 'Paid';
  static const String loanStatusCancelled = 'Cancelled';

  static const String overtimeStatusPending = 'Pending';
  static const String overtimeStatusApproved = 'Approved';
  static const String overtimeStatusRejected = 'Rejected';

  static const String taskStatusPending = 'Pending';
  static const String taskStatusCompleted = 'Completed';
  static const String taskStatusTerminated = 'Terminated';

  // KPI Ratings
  static const String kpiExcellent = 'Excellent';
  static const String kpiVeryGood = 'Very Good';
  static const String kpiGood = 'Good';
  static const String kpiNeedsImprovement = 'Needs Improvement';
  static const String kpiPoor = 'Poor';

  // KPI Score thresholds
  static const int kpiExcellentMin = 90;
  static const int kpiVeryGoodMin = 80;
  static const int kpiGoodMin = 70;
  static const int kpiNeedsImprovementMin = 60;

  // KPI Score weights
  static const int kpiTaskWeight = 35;
  static const int kpiAttendanceWeight = 25;
  static const int kpiPunctualityWeight = 15;
  static const int kpiOvertimeWeight = 10;
  static const int kpiLocationWeight = 10;
  static const int kpiDisciplineWeight = 5;

  // Default geofence radius in meters
  static const double defaultGeofenceRadius = 100.0;
  static const int defaultDailyBreakMinutes = 60;

  // Standard shift hours
  static const double standardShiftHours = 8.0;

  // SharedPreferences keys
  static const String prefUserId = 'user_id';
  static const String prefUserRole = 'user_role';
  static const String prefDeviceId = 'device_id';
  static const String prefIsLoggedIn = 'is_logged_in';
  static const String prefToken = 'auth_token';

  static String homeRouteForRole(String role) {
    switch (role) {
      case roleAdmin:
        return routeAdmin;
      case roleSupervisor:
        return routeSupervisor;
      case roleStaff:
      default:
        return routeStaff;
    }
  }

  static bool isRouteAllowedForRole({
    required String role,
    required String location,
  }) {
    if (location == routeSplash || location == routeLogin) {
      return true;
    }

    switch (role) {
      case roleAdmin:
        return location.startsWith(routeAdmin);
      case roleSupervisor:
        return location.startsWith(routeSupervisor);
      case roleStaff:
      default:
        return location.startsWith(routeStaff);
    }
  }
}
