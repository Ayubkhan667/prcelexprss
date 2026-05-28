import '../models/staff_model.dart';
import '../models/attendance_model.dart';
import '../models/branch_model.dart';
import '../models/shift_model.dart';
import '../models/salary_model.dart';
import '../models/loan_model.dart';
import '../models/leave_model.dart';
import '../models/kpi_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/attendance_edit_log_model.dart';
import '../models/task_model.dart';
import '../models/expense_model.dart';
import '../models/holiday_model.dart';
import '../models/helpdesk_ticket_model.dart';
import '../models/shift_roster_model.dart';
import '../models/shift_swap_request_model.dart';
import '../../core/constants/app_constants.dart';
import 'package:intl/intl.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._();
  factory MockDataService() => _instance;
  MockDataService._();

  // Demo users for login
  static final List<UserModel> _users = [
    UserModel(
      id: 'u001',
      name: 'Saif Al-Bulushi',
      email: 'admin@smarthr.com',
      mobile: '+968 9512 3456',
      role: 'admin',
      status: 'Active',
      deviceId: 'device_admin_001',
      createdAt: DateTime(2023, 1, 1),
    ),
    UserModel(
      id: 'u002',
      name: 'Ahmad Al-Kindi',
      email: 'supervisor@smarthr.com',
      mobile: '+968 9623 4567',
      role: 'supervisor',
      status: 'Active',
      createdAt: DateTime(2023, 2, 1),
    ),
    UserModel(
      id: 'u003',
      name: 'Salma Al-Rashdi',
      email: 'staff@smarthr.com',
      mobile: '+968 9734 5678',
      role: 'staff',
      status: 'Active',
      createdAt: DateTime(2023, 3, 1),
    ),
  ];

  static final List<BranchModel> _branches = [
    BranchModel(
        id: 'b001',
        branchName: 'Muscat HQ',
        latitude: 23.5880,
        longitude: 58.3829,
        allowedRadius: 150,
        status: 'Active',
        address: 'Al Khuwair, Muscat Governorate',
        staffCount: 25,
        wifiSsid: 'PE-MUSCAT-HQ'),
    BranchModel(
        id: 'b002',
        branchName: 'Salalah Branch',
        latitude: 17.0200,
        longitude: 54.0924,
        allowedRadius: 100,
        status: 'Active',
        address: 'Al Haffa, Salalah, Dhofar',
        staffCount: 18,
        wifiSsid: 'PE-SALALAH'),
    BranchModel(
        id: 'b003',
        branchName: 'Sohar Branch',
        latitude: 24.3476,
        longitude: 56.7050,
        allowedRadius: 120,
        status: 'Active',
        address: 'Al Falaj, Sohar, Al Batinah',
        staffCount: 12,
        wifiSsid: 'PE-SOHAR'),
    BranchModel(
        id: 'b004',
        branchName: 'Nizwa Branch',
        latitude: 22.9333,
        longitude: 57.5333,
        allowedRadius: 100,
        status: 'Inactive',
        address: 'Al Qalah, Nizwa, Ad Dakhiliyah',
        staffCount: 8,
        wifiSsid: 'PE-NIZWA'),
  ];

  static final List<ShiftModel> _shifts = [
    ShiftModel(
        id: 's001',
        shiftName: 'Morning Shift',
        startTime: '08:00',
        endTime: '16:00',
        standardHours: 8,
        graceMinutes: 15,
        status: 'Active'),
    ShiftModel(
        id: 's002',
        shiftName: 'Day Shift',
        startTime: '09:00',
        endTime: '17:00',
        standardHours: 8,
        graceMinutes: 15,
        status: 'Active'),
    ShiftModel(
        id: 's003',
        shiftName: 'Evening Shift',
        startTime: '14:00',
        endTime: '22:00',
        standardHours: 8,
        graceMinutes: 15,
        status: 'Active'),
    ShiftModel(
        id: 's004',
        shiftName: 'Night Shift',
        startTime: '22:00',
        endTime: '06:00',
        standardHours: 8,
        graceMinutes: 15,
        status: 'Active'),
  ];

  static final List<StaffModel> _staff = [
    // Oman staff — salaries in OMR (Omani Rial), weekend: Friday–Saturday
    StaffModel(
        id: 'st001',
        userId: 'u003',
        staffCode: 'SHR-001',
        name: 'Salma Al-Rashdi',
        email: 'salma@smarthr.com',
        mobile: '+968 9734 5678',
        idCardNumber: '12345678',
        jobTitle: 'Senior Driver',
        category: 'Driver',
        department: 'Operations',
        branchId: 'b001',
        branchName: 'Muscat HQ',
        shiftId: 's001',
        shiftName: 'Morning Shift',
        joiningDate: DateTime(2022, 3, 15),
        basicSalary: 350,
        overtimeRate: 2.0,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 92.5,
        kpiRating: 'Excellent',
        loanBalance: 0,
        overtimeHours: 12.5,
        todayCheckIn: '08:05',
        todayCheckOut: '16:30',
        todayStatus: 'Present',
        // Personal extended
        preferredName: 'Salma',
        firstName: 'Salma',
        lastName: 'Al-Rashdi',
        dateOfBirth: DateTime(1995, 6, 20),
        nationality: 'Omani',
        gender: 'Female',
        maritalStatus: 'Married',
        personalEmail: 'salma.rashdi@gmail.com',
        workPhone: '+968 2448 1100',
        personalAddress: 'Villa 12, Al Ghubra North, Muscat, Oman',
        aboutMe:
            'Dedicated logistics professional with 4+ years of experience in fleet operations across Muscat Governorate.',
        whatIDo:
            'Manage daily fleet routes, coordinate deliveries, and ensure timely distribution across Muscat.',
        skills: [
          'Fleet Management',
          'Route Optimisation',
          'GPS Navigation',
          'Vehicle Inspection',
          'Team Coordination'
        ],
        socialMedia: {
          'LinkedIn': 'linkedin.com/in/salma-rashdi',
          'WhatsApp': '+968 9734 5678',
        },
        hobbies: ['Reading', 'Hiking', 'Cooking', 'Volunteering'],
        // Documents
        sponsorName: 'Saif Al-Bulushi',
        civilId: 'OM-12345678',
        civilIdExpireDate: DateTime(2027, 9, 30),
        passportNumber: 'OA4512378',
        passportExpireDate: DateTime(2028, 3, 19),
        passportStatus: 'Valid',
        // Contract
        contractType: 'Limited',
        contractTerms: '2 Years',
        contractStartDate: DateTime(2022, 3, 15),
        contractExpireDate: DateTime(2024, 3, 14),
        salaryType: 'Monthly',
        // Bank
        nameAsPerBank: 'Salma Mohammed Al-Rashdi',
        bankName: 'Bank Muscat',
        swiftCode: 'BMUSOMRX',
        accountNumber: '0196-0011234567',
        // Emergency contact
        emergencyContactName: 'Mohammed Al-Rashdi',
        emergencyContactRelation: 'Husband',
        emergencyContactPhone: '+968 9811 2233',
        // HR document status
        passportSubmissionStatus: 'Submitted',
        passportCollectionStatus: 'Pending'),
    StaffModel(
        id: 'st002',
        userId: 'u004',
        staffCode: 'SHR-002',
        name: 'Khalid Al-Balushi',
        email: 'khalid@smarthr.com',
        mobile: '+968 9845 6789',
        idCardNumber: '23456789',
        jobTitle: 'Warehouse Supervisor',
        category: 'Warehouse',
        department: 'Logistics',
        branchId: 'b001',
        branchName: 'Muscat HQ',
        shiftId: 's002',
        shiftName: 'Day Shift',
        joiningDate: DateTime(2021, 6, 1),
        basicSalary: 450,
        overtimeRate: 2.5,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 85.0,
        kpiRating: 'Very Good',
        loanBalance: 100,
        overtimeHours: 8.0,
        todayCheckIn: '09:12',
        todayCheckOut: '',
        todayStatus: 'Missing Checkout'),
    StaffModel(
        id: 'st003',
        userId: 'u005',
        staffCode: 'SHR-003',
        name: 'Fatima Al-Zahraa',
        email: 'fatima@smarthr.com',
        mobile: '+968 9956 7890',
        idCardNumber: '34567890',
        jobTitle: 'Accountant',
        category: 'Accountant',
        department: 'Finance',
        branchId: 'b002',
        branchName: 'Salalah Branch',
        shiftId: 's002',
        shiftName: 'Day Shift',
        joiningDate: DateTime(2022, 9, 1),
        basicSalary: 550,
        overtimeRate: 3.5,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 78.5,
        kpiRating: 'Good',
        loanBalance: 50,
        overtimeHours: 5.5,
        todayCheckIn: '09:45',
        todayCheckOut: '17:00',
        todayStatus: 'Late'),
    StaffModel(
        id: 'st004',
        userId: 'u006',
        staffCode: 'SHR-004',
        name: 'Sultan Al-Hinai',
        email: 'sultan@smarthr.com',
        mobile: '+968 9467 8901',
        idCardNumber: '45678901',
        jobTitle: 'Delivery Driver',
        category: 'Driver',
        department: 'Operations',
        branchId: 'b001',
        branchName: 'Muscat HQ',
        shiftId: 's001',
        shiftName: 'Morning Shift',
        joiningDate: DateTime(2023, 1, 10),
        basicSalary: 300,
        overtimeRate: 1.8,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 55.0,
        kpiRating: 'Poor',
        loanBalance: 150,
        overtimeHours: 2.0,
        todayCheckIn: '',
        todayCheckOut: '',
        todayStatus: 'Absent'),
    StaffModel(
        id: 'st005',
        userId: 'u007',
        staffCode: 'SHR-005',
        name: 'Mariam Al-Kindi',
        email: 'mariam@smarthr.com',
        mobile: '+968 9578 9012',
        idCardNumber: '56789012',
        jobTitle: 'HR Officer',
        category: 'Admin',
        department: 'HR',
        branchId: 'b003',
        branchName: 'Sohar Branch',
        shiftId: 's002',
        shiftName: 'Day Shift',
        joiningDate: DateTime(2021, 4, 5),
        basicSalary: 600,
        overtimeRate: 3.5,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 88.0,
        kpiRating: 'Very Good',
        loanBalance: 0,
        overtimeHours: 6.0,
        todayCheckIn: '09:00',
        todayCheckOut: '',
        todayStatus: 'On Leave'),
    StaffModel(
        id: 'st006',
        userId: 'u008',
        staffCode: 'SHR-006',
        name: 'Hassan Al-Abri',
        email: 'hassan@smarthr.com',
        mobile: '+968 9689 0123',
        idCardNumber: '67890123',
        jobTitle: 'Operations Manager',
        category: 'Manager',
        department: 'Operations',
        branchId: 'b002',
        branchName: 'Salalah Branch',
        shiftId: 's002',
        shiftName: 'Day Shift',
        joiningDate: DateTime(2020, 8, 15),
        basicSalary: 850,
        overtimeRate: 5.0,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 95.0,
        kpiRating: 'Excellent',
        loanBalance: 0,
        overtimeHours: 20.0,
        todayCheckIn: '07:55',
        todayCheckOut: '18:30',
        todayStatus: 'Overtime'),
    StaffModel(
        id: 'st007',
        userId: 'u009',
        staffCode: 'SHR-007',
        name: 'Rania Al-Musawi',
        email: 'rania@smarthr.com',
        mobile: '+968 9790 1234',
        idCardNumber: '78901234',
        jobTitle: 'Warehouse Staff',
        category: 'Warehouse',
        department: 'Logistics',
        branchId: 'b001',
        branchName: 'Muscat HQ',
        shiftId: 's003',
        shiftName: 'Evening Shift',
        joiningDate: DateTime(2023, 5, 20),
        basicSalary: 280,
        overtimeRate: 1.7,
        weeklyOffDay: 'Friday',
        status: 'Active',
        kpiScore: 72.0,
        kpiRating: 'Good',
        loanBalance: 80,
        overtimeHours: 3.0,
        todayCheckIn: '14:05',
        todayCheckOut: '22:00',
        todayStatus: 'Present'),
    StaffModel(
        id: 'st008',
        userId: 'u010',
        staffCode: 'SHR-008',
        name: 'Omar Al-Lawati',
        email: 'omar@smarthr.com',
        mobile: '+968 9801 2345',
        idCardNumber: '89012345',
        jobTitle: 'Supervisor',
        category: 'Supervisor',
        department: 'Operations',
        branchId: 'b002',
        branchName: 'Salalah Branch',
        shiftId: 's001',
        shiftName: 'Morning Shift',
        joiningDate: DateTime(2022, 11, 1),
        basicSalary: 500,
        overtimeRate: 3.0,
        weeklyOffDay: 'Friday',
        status: 'Suspended',
        kpiScore: 42.0,
        kpiRating: 'Poor',
        loanBalance: 250,
        overtimeHours: 0,
        todayCheckIn: '',
        todayCheckOut: '',
        todayStatus: 'Absent'),
  ];

  static List<AttendanceModel> _generateAttendance() {
    final list = <AttendanceModel>[];
    final now = DateTime.now();
    for (var staff in _staff) {
      for (int i = 0; i < 30; i++) {
        final date = now.subtract(Duration(days: i));
        final isWeekend = date.weekday == DateTime.friday ||
            date.weekday == DateTime.saturday;
        if (isWeekend) continue;
        final rand = (staff.id.hashCode + i) % 10;
        DateTime? checkIn, checkOut;
        String status;
        int lateMin = 0;
        double workHours = 0;
        double otHours = 0;
        if (rand < 1) {
          status = 'Absent';
        } else if (rand < 2) {
          status = 'On Leave';
        } else {
          final lateRand = (staff.id.hashCode * i) % 5;
          if (lateRand == 0) {
            checkIn = DateTime(date.year, date.month, date.day, 9, 25);
            lateMin = 25;
            status = 'Late';
          } else {
            checkIn = DateTime(date.year, date.month, date.day, 8, 55);
            status = 'Present';
          }
          final otRand = (staff.id.hashCode + i * 3) % 8;
          if (otRand == 0) {
            checkOut = DateTime(date.year, date.month, date.day, 18, 30);
            workHours = 9.5;
            otHours = 1.5;
            status = i == 0 ? status : 'Overtime';
          } else {
            checkOut = DateTime(date.year, date.month, date.day, 17, 0);
            workHours = 8.0;
          }
        }
        list.add(AttendanceModel(
          id: 'att_${staff.id}_$i',
          staffId: staff.id,
          staffName: staff.name,
          staffCode: staff.staffCode,
          date: date,
          checkInTime: checkIn,
          checkOutTime: checkOut,
          checkInLatitude: 24.8607,
          checkInLongitude: 67.0011,
          checkOutLatitude: 24.8607,
          checkOutLongitude: 67.0011,
          workingHours: workHours,
          overtimeHours: otHours,
          lateMinutes: lateMin,
          earlyCheckoutMinutes: 0,
          status: status,
          isLocationValid: true,
          isMockGps: false,
          approvalStatus: 'Auto',
          createdAt: date,
        ));
      }
    }
    return list;
  }

  static final List<AttendanceModel> _attendance = _generateAttendance();

  // Salaries in OMR — basic + housing/transport allowance per Oman HR norms
  static final List<SalaryModel> _salaries = [
    SalaryModel(
        id: 'sal001',
        staffId: 'st001',
        staffName: 'Salma Al-Rashdi',
        staffCode: 'SHR-001',
        month: 'May 2026',
        basicSalary: 350,
        overtimeAmount: 25, // 12.5 hrs × 2.0 OMR/hr
        allowance: 150, // housing 100 + transport 50
        deduction: 0,
        loanDeduction: 0,
        absenceDeduction: 0,
        penalty: 0,
        netSalary: 525,
        paymentStatus: 'Paid',
        paidDate: DateTime(2026, 5, 30),
        createdAt: DateTime(2026, 5, 1)),
    SalaryModel(
        id: 'sal002',
        staffId: 'st002',
        staffName: 'Khalid Al-Balushi',
        staffCode: 'SHR-002',
        month: 'May 2026',
        basicSalary: 450,
        overtimeAmount: 20, // 8 hrs × 2.5 OMR/hr
        allowance: 180, // housing 120 + transport 60
        deduction: 0,
        loanDeduction: 20,
        absenceDeduction: 0,
        penalty: 0,
        netSalary: 630,
        paymentStatus: 'Pending',
        createdAt: DateTime(2026, 5, 1)),
    SalaryModel(
        id: 'sal003',
        staffId: 'st003',
        staffName: 'Fatima Al-Zahraa',
        staffCode: 'SHR-003',
        month: 'May 2026',
        basicSalary: 550,
        overtimeAmount: 19, // 5.5 hrs × 3.5 OMR/hr
        allowance: 220, // housing 150 + transport 70
        deduction: 0,
        loanDeduction: 15,
        absenceDeduction: 18, // 1 day absence deduction
        penalty: 0,
        netSalary: 756,
        paymentStatus: 'Pending',
        createdAt: DateTime(2026, 5, 1)),
    SalaryModel(
        id: 'sal004',
        staffId: 'st004',
        staffName: 'Sultan Al-Hinai',
        staffCode: 'SHR-004',
        month: 'May 2026',
        basicSalary: 300,
        overtimeAmount: 4, // 2 hrs × 1.8 OMR/hr
        allowance: 130, // housing 80 + transport 50
        deduction: 0,
        loanDeduction: 30,
        absenceDeduction: 30, // 3 days absence
        penalty: 5,
        netSalary: 369,
        paymentStatus: 'Hold',
        createdAt: DateTime(2026, 5, 1)),
    SalaryModel(
        id: 'sal005',
        staffId: 'st005',
        staffName: 'Mariam Al-Kindi',
        staffCode: 'SHR-005',
        month: 'May 2026',
        basicSalary: 600,
        overtimeAmount: 21, // 6 hrs × 3.5 OMR/hr
        allowance: 230, // housing 150 + transport 80
        deduction: 0,
        loanDeduction: 0,
        absenceDeduction: 0,
        penalty: 0,
        netSalary: 851,
        paymentStatus: 'Paid',
        paidDate: DateTime(2026, 5, 30),
        createdAt: DateTime(2026, 5, 1)),
    SalaryModel(
        id: 'sal006',
        staffId: 'st006',
        staffName: 'Hassan Al-Abri',
        staffCode: 'SHR-006',
        month: 'May 2026',
        basicSalary: 850,
        overtimeAmount: 100, // 20 hrs × 5.0 OMR/hr
        allowance: 350, // housing 200 + transport 100 + other 50
        deduction: 0,
        loanDeduction: 0,
        absenceDeduction: 0,
        penalty: 0,
        netSalary: 1300,
        paymentStatus: 'Pending',
        createdAt: DateTime(2026, 5, 1)),
  ];

  // Loans in OMR
  static final List<LoanModel> _loans = [
    LoanModel(
        id: 'ln001',
        staffId: 'st002',
        staffName: 'Khalid Al-Balushi',
        staffCode: 'SHR-002',
        loanAmount: 500,
        paidAmount: 400,
        balanceAmount: 100,
        monthlyDeduction: 20,
        loanDate: DateTime(2025, 8, 1),
        status: 'Active',
        purpose: 'Medical Emergency',
        createdAt: DateTime(2025, 8, 1)),
    LoanModel(
        id: 'ln002',
        staffId: 'st003',
        staffName: 'Fatima Al-Zahraa',
        staffCode: 'SHR-003',
        loanAmount: 300,
        paidAmount: 250,
        balanceAmount: 50,
        monthlyDeduction: 15,
        loanDate: DateTime(2025, 10, 1),
        status: 'Active',
        purpose: 'Home Repair',
        createdAt: DateTime(2025, 10, 1)),
    LoanModel(
        id: 'ln003',
        staffId: 'st004',
        staffName: 'Sultan Al-Hinai',
        staffCode: 'SHR-004',
        loanAmount: 600,
        paidAmount: 450,
        balanceAmount: 150,
        monthlyDeduction: 30,
        loanDate: DateTime(2025, 6, 1),
        status: 'Active',
        purpose: 'Personal',
        createdAt: DateTime(2025, 6, 1)),
    LoanModel(
        id: 'ln004',
        staffId: 'st007',
        staffName: 'Rania Al-Musawi',
        staffCode: 'SHR-007',
        loanAmount: 400,
        paidAmount: 320,
        balanceAmount: 80,
        monthlyDeduction: 20,
        loanDate: DateTime(2025, 9, 1),
        status: 'Active',
        purpose: 'Education',
        createdAt: DateTime(2025, 9, 1)),
    LoanModel(
        id: 'ln005',
        staffId: 'st008',
        staffName: 'Omar Al-Lawati',
        staffCode: 'SHR-008',
        loanAmount: 1000,
        paidAmount: 750,
        balanceAmount: 250,
        monthlyDeduction: 50,
        loanDate: DateTime(2025, 3, 1),
        status: 'Active',
        purpose: 'Vehicle',
        createdAt: DateTime(2025, 3, 1)),
  ];

  // Leaves per Oman Labour Law (RD 35/2003 & amendments)
  // Annual: 30 days/yr | Sick: full pay 2wks, half 4wks | Maternity: 50 days | Hajj: 15 days once
  static final List<LeaveModel> _leaves = [
    LeaveModel(
        id: 'lv001',
        staffId: 'st005',
        staffName: 'Mariam Al-Kindi',
        staffCode: 'SHR-005',
        leaveType: 'Annual Leave',
        fromDate: DateTime(2026, 5, 22),
        toDate: DateTime(2026, 5, 24),
        reason: 'Personal family matter',
        status: 'Approved',
        approvedBy: 'Saif Al-Bulushi',
        createdAt: DateTime(2026, 5, 18)),
    LeaveModel(
        id: 'lv002',
        staffId: 'st003',
        staffName: 'Fatima Al-Zahraa',
        staffCode: 'SHR-003',
        leaveType: 'Sick Leave',
        fromDate: DateTime(2026, 5, 20),
        toDate: DateTime(2026, 5, 20),
        reason: 'Fever — medical certificate attached',
        status: 'Approved',
        approvedBy: 'Saif Al-Bulushi',
        createdAt: DateTime(2026, 5, 19)),
    LeaveModel(
        id: 'lv003',
        staffId: 'st001',
        staffName: 'Salma Al-Rashdi',
        staffCode: 'SHR-001',
        leaveType: 'Annual Leave',
        fromDate: DateTime(2026, 6, 1),
        toDate: DateTime(2026, 6, 5),
        reason: 'Family trip to Salalah',
        status: 'Pending',
        createdAt: DateTime(2026, 5, 22)),
    LeaveModel(
        id: 'lv004',
        staffId: 'st007',
        staffName: 'Rania Al-Musawi',
        staffCode: 'SHR-007',
        leaveType: 'Emergency Leave',
        fromDate: DateTime(2026, 5, 25),
        toDate: DateTime(2026, 5, 26),
        reason: 'Family emergency — hospitalization',
        status: 'Pending',
        createdAt: DateTime(2026, 5, 22)),
    LeaveModel(
        id: 'lv005',
        staffId: 'st006',
        staffName: 'Hassan Al-Abri',
        staffCode: 'SHR-006',
        leaveType: 'Compensatory Leave',
        fromDate: DateTime(2026, 5, 30),
        toDate: DateTime(2026, 5, 30),
        reason: 'Worked on Oman National Day',
        status: 'Rejected',
        rejectionReason: 'Peak operational period — compensated as OT pay',
        createdAt: DateTime(2026, 5, 15)),
    LeaveModel(
        id: 'lv006',
        staffId: 'st002',
        staffName: 'Khalid Al-Balushi',
        staffCode: 'SHR-002',
        leaveType: 'Hajj Leave',
        fromDate: DateTime(2026, 6, 10),
        toDate: DateTime(2026, 6, 24),
        reason:
            'Performing Hajj pilgrimage — entitlement per Art. 65 Labour Law',
        status: 'Approved',
        approvedBy: 'Saif Al-Bulushi',
        createdAt: DateTime(2026, 5, 10)),
  ];

  static final List<KpiModel> _kpiRecords = [
    KpiModel(
        id: 'kpi001',
        staffId: 'st001',
        staffName: 'Salma Al-Rashdi',
        staffCode: 'SHR-001',
        month: 'May 2026',
        attendanceRate: 96,
        absenceRate: 4,
        lateCount: 1,
        earlyCheckoutCount: 0,
        totalWorkingHours: 176,
        avgDailyWorkingHours: 8.4,
        overtimeHours: 12.5,
        missingCheckoutCount: 0,
        validLocationCount: 22,
        invalidLocationCount: 0,
        fakeGpsCount: 0,
        leaveCount: 0,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 38.4,
        punctualityScore: 24.0,
        overtimeScore: 15.0,
        locationScore: 10.0,
        disciplineScore: 5.1,
        taskScore: 0,
        totalKpiScore: 92.5,
        rating: 'Excellent',
        createdAt: DateTime(2026, 5, 1)),
    KpiModel(
        id: 'kpi002',
        staffId: 'st002',
        staffName: 'Khalid Al-Balushi',
        staffCode: 'SHR-002',
        month: 'May 2026',
        attendanceRate: 92,
        absenceRate: 8,
        lateCount: 2,
        earlyCheckoutCount: 1,
        totalWorkingHours: 164,
        avgDailyWorkingHours: 7.8,
        overtimeHours: 8,
        missingCheckoutCount: 2,
        validLocationCount: 20,
        invalidLocationCount: 0,
        fakeGpsCount: 0,
        leaveCount: 0,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 36.8,
        punctualityScore: 22.0,
        overtimeScore: 12.0,
        locationScore: 10.0,
        disciplineScore: 4.2,
        taskScore: 0,
        totalKpiScore: 85.0,
        rating: 'Very Good',
        createdAt: DateTime(2026, 5, 1)),
    KpiModel(
        id: 'kpi003',
        staffId: 'st003',
        staffName: 'Fatima Al-Zahraa',
        staffCode: 'SHR-003',
        month: 'May 2026',
        attendanceRate: 88,
        absenceRate: 12,
        lateCount: 4,
        earlyCheckoutCount: 2,
        totalWorkingHours: 155,
        avgDailyWorkingHours: 7.4,
        overtimeHours: 5.5,
        missingCheckoutCount: 1,
        validLocationCount: 19,
        invalidLocationCount: 1,
        fakeGpsCount: 0,
        leaveCount: 1,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 35.2,
        punctualityScore: 19.5,
        overtimeScore: 10.0,
        locationScore: 9.5,
        disciplineScore: 4.3,
        taskScore: 0,
        totalKpiScore: 78.5,
        rating: 'Good',
        createdAt: DateTime(2026, 5, 1)),
    KpiModel(
        id: 'kpi004',
        staffId: 'st004',
        staffName: 'Sultan Al-Hinai',
        staffCode: 'SHR-004',
        month: 'May 2026',
        attendanceRate: 72,
        absenceRate: 28,
        lateCount: 8,
        earlyCheckoutCount: 3,
        totalWorkingHours: 124,
        avgDailyWorkingHours: 6.2,
        overtimeHours: 2,
        missingCheckoutCount: 4,
        validLocationCount: 15,
        invalidLocationCount: 2,
        fakeGpsCount: 1,
        leaveCount: 0,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 28.8,
        punctualityScore: 12.5,
        overtimeScore: 5.0,
        locationScore: 6.5,
        disciplineScore: 2.2,
        taskScore: 0,
        totalKpiScore: 55.0,
        rating: 'Poor',
        createdAt: DateTime(2026, 5, 1)),
    KpiModel(
        id: 'kpi005',
        staffId: 'st005',
        staffName: 'Mariam Al-Kindi',
        staffCode: 'SHR-005',
        month: 'May 2026',
        attendanceRate: 90,
        absenceRate: 10,
        lateCount: 2,
        earlyCheckoutCount: 0,
        totalWorkingHours: 162,
        avgDailyWorkingHours: 7.7,
        overtimeHours: 6,
        missingCheckoutCount: 0,
        validLocationCount: 20,
        invalidLocationCount: 0,
        fakeGpsCount: 0,
        leaveCount: 3,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 36.0,
        punctualityScore: 23.0,
        overtimeScore: 11.0,
        locationScore: 10.0,
        disciplineScore: 8.0,
        taskScore: 0,
        totalKpiScore: 88.0,
        rating: 'Very Good',
        createdAt: DateTime(2026, 5, 1)),
    KpiModel(
        id: 'kpi006',
        staffId: 'st006',
        staffName: 'Hassan Al-Abri',
        staffCode: 'SHR-006',
        month: 'May 2026',
        attendanceRate: 100,
        absenceRate: 0,
        lateCount: 0,
        earlyCheckoutCount: 0,
        totalWorkingHours: 196,
        avgDailyWorkingHours: 9.3,
        overtimeHours: 20,
        missingCheckoutCount: 0,
        validLocationCount: 22,
        invalidLocationCount: 0,
        fakeGpsCount: 0,
        leaveCount: 0,
        taskAssignedCount: 0,
        taskCompletedCount: 0,
        taskCompletionRate: 0,
        attendanceScore: 40.0,
        punctualityScore: 25.0,
        overtimeScore: 15.0,
        locationScore: 10.0,
        disciplineScore: 5.0,
        taskScore: 0,
        totalKpiScore: 95.0,
        rating: 'Excellent',
        createdAt: DateTime(2026, 5, 1)),
  ];

  static final List<AttendanceEditLogModel> _editLogs = [
    AttendanceEditLogModel(
      id: 'log001',
      attendanceId: 'att_st004_2',
      staffId: 'st004',
      staffName: 'Sultan Al-Hinai',
      staffCode: 'SHR-004',
      editedBy: 'Saif Al-Bulushi',
      editedByRole: 'Admin',
      fieldChanged: 'Check-In Time',
      oldValue: '09:45',
      newValue: '08:55',
      reason:
          'Staff reported system error during check-in. CCTV verified presence at 08:55.',
      approvalStatus: 'Approved',
      approvedBy: 'Saif Al-Bulushi',
      approvedAt: DateTime(2026, 5, 20, 10, 30),
      createdAt: DateTime(2026, 5, 20, 10, 15),
    ),
    AttendanceEditLogModel(
      id: 'log002',
      attendanceId: 'att_st002_1',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      staffCode: 'SHR-002',
      editedBy: 'Saif Al-Bulushi',
      editedByRole: 'Admin',
      fieldChanged: 'Attendance Status',
      oldValue: 'Absent',
      newValue: 'Sick Leave',
      reason:
          'Staff submitted medical certificate — covered under Oman Labour Law Art. 66.',
      approvalStatus: 'Approved',
      approvedBy: 'Saif Al-Bulushi',
      approvedAt: DateTime(2026, 5, 19, 14, 0),
      createdAt: DateTime(2026, 5, 19, 13, 45),
    ),
    AttendanceEditLogModel(
      id: 'log003',
      attendanceId: 'att_st007_0',
      staffId: 'st007',
      staffName: 'Rania Al-Musawi',
      staffCode: 'SHR-007',
      editedBy: 'Ahmad Al-Kindi',
      editedByRole: 'Supervisor',
      fieldChanged: 'Check-Out Time',
      oldValue: '--',
      newValue: '22:10',
      reason:
          'Staff forgot to check out. Supervisor confirmed shift end via duty roster.',
      approvalStatus: 'Pending',
      createdAt: DateTime(2026, 5, 22, 8, 0),
    ),
    AttendanceEditLogModel(
      id: 'log004',
      attendanceId: 'att_st003_3',
      staffId: 'st003',
      staffName: 'Fatima Al-Zahraa',
      staffCode: 'SHR-003',
      editedBy: 'Saif Al-Bulushi',
      editedByRole: 'Admin',
      fieldChanged: 'Late Minutes',
      oldValue: '45',
      newValue: '0',
      reason:
          'Muscat HQ server clock was out of sync. Actual check-in was on time per camera log.',
      approvalStatus: 'Pending',
      createdAt: DateTime(2026, 5, 21, 11, 20),
    ),
    AttendanceEditLogModel(
      id: 'log005',
      attendanceId: 'att_st001_5',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      editedBy: 'Saif Al-Bulushi',
      editedByRole: 'Admin',
      fieldChanged: 'Attendance Status',
      oldValue: 'Absent',
      newValue: 'Present',
      reason:
          'GPS check-in failed due to app crash. Manual verification confirmed presence.',
      approvalStatus: 'Rejected',
      approvedBy: 'Saif Al-Bulushi',
      approvedAt: DateTime(2026, 5, 18, 9, 0),
      createdAt: DateTime(2026, 5, 17, 16, 30),
    ),
  ];

  static final List<NotificationModel> _notifications = [
    NotificationModel(
      id: 'notif001',
      title: 'Check-In Successful',
      body: 'Salma Al-Rashdi checked in at 08:05 — Muscat HQ',
      type: 'checkin',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 23, 8, 5),
    ),
    NotificationModel(
      id: 'notif002',
      title: 'Late Check-In Alert',
      body: 'Fatima Al-Zahraa checked in 45 minutes late at Salalah Branch',
      type: 'late',
      staffId: 'st003',
      staffName: 'Fatima Al-Zahraa',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 23, 9, 45),
    ),
    NotificationModel(
      id: 'notif003',
      title: 'Missing Check-Out',
      body: 'Khalid Al-Balushi has not checked out. Shift ended 2 hours ago.',
      type: 'missing_checkout',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 22, 19, 0),
    ),
    NotificationModel(
      id: 'notif004',
      title: 'Fake GPS Detected',
      body:
          'Suspicious GPS activity detected for Sultan Al-Hinai. Location mocked.',
      type: 'fake_gps',
      staffId: 'st004',
      staffName: 'Sultan Al-Hinai',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 21, 10, 12),
    ),
    NotificationModel(
      id: 'notif005',
      title: 'Leave Approved',
      body: 'Your Annual Leave request (22–24 May) has been approved.',
      type: 'leave',
      staffId: 'st005',
      staffName: 'Mariam Al-Kindi',
      targetRole: 'staff',
      isRead: true,
      createdAt: DateTime(2026, 5, 20, 14, 30),
    ),
    NotificationModel(
      id: 'notif006',
      title: 'Salary Generated',
      body: 'Your salary for May 2026 has been processed. Net: OMR 525.',
      type: 'salary',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      targetRole: 'staff',
      createdAt: DateTime(2026, 5, 30, 9, 0),
    ),
    NotificationModel(
      id: 'notif007',
      title: 'Loan Deduction Applied',
      body: 'OMR 20 loan deduction applied for May 2026. Balance: OMR 100.',
      type: 'loan',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      targetRole: 'staff',
      createdAt: DateTime(2026, 5, 30, 9, 5),
    ),
    NotificationModel(
      id: 'notif008',
      title: 'Outside Work Location',
      body: 'Hassan Al-Abri is outside assigned branch radius. Please verify.',
      type: 'location_alert',
      staffId: 'st006',
      staffName: 'Hassan Al-Abri',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 22, 17, 45),
    ),
    NotificationModel(
      id: 'notif009',
      title: 'Overtime Approved',
      body: 'Your 3.5 hours overtime for 20 May 2026 has been approved.',
      type: 'overtime',
      staffId: 'st006',
      staffName: 'Hassan Al-Abri',
      targetRole: 'staff',
      isRead: true,
      createdAt: DateTime(2026, 5, 21, 11, 0),
    ),
    NotificationModel(
      id: 'notif010',
      title: 'Leave Request Submitted',
      body: 'Salma Al-Rashdi applied for Annual Leave from 1–5 June 2026.',
      type: 'leave',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      targetRole: 'admin',
      createdAt: DateTime(2026, 5, 22, 16, 0),
    ),
    NotificationModel(
      id: 'notif011',
      title: 'Weekly operations briefing',
      body: 'Friday shift handover will start 30 minutes earlier this week.',
      type: 'announcement',
      targetRole: 'all',
      createdAt: DateTime(2026, 5, 25, 9, 0),
    ),
  ];

  static final List<ShiftRosterModel> _shiftRosters = [
    ShiftRosterModel(
      id: 'roster001',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      rosterDate: DateTime(2026, 5, 28),
      shiftId: 's001',
      shiftName: 'Morning Shift',
      startTime: '08:00',
      endTime: '16:00',
      status: 'Scheduled',
      notes: 'Primary delivery route',
      assignedBy: 'Saif Al-Bulushi',
      createdAt: DateTime(2026, 5, 25, 9, 0),
    ),
    ShiftRosterModel(
      id: 'roster002',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      staffCode: 'SHR-002',
      rosterDate: DateTime(2026, 5, 28),
      shiftId: 's002',
      shiftName: 'Day Shift',
      startTime: '09:00',
      endTime: '17:00',
      status: 'Scheduled',
      notes: 'Warehouse coverage',
      assignedBy: 'Saif Al-Bulushi',
      createdAt: DateTime(2026, 5, 25, 9, 0),
    ),
  ];

  static final List<ShiftSwapRequestModel> _shiftSwapRequests = [
    ShiftSwapRequestModel(
      id: 'swap001',
      requesterStaffId: 'st001',
      requesterName: 'Salma Al-Rashdi',
      requesterCode: 'SHR-001',
      targetStaffId: 'st002',
      targetName: 'Khalid Al-Balushi',
      targetCode: 'SHR-002',
      rosterDate: DateTime(2026, 5, 28),
      requesterShiftId: 's001',
      requesterShiftName: 'Morning Shift',
      targetShiftId: 's002',
      targetShiftName: 'Day Shift',
      reason: 'Personal appointment in the morning.',
      status: 'Pending',
      createdAt: DateTime(2026, 5, 26, 10, 15),
    ),
  ];

  static final List<HelpdeskTicketModel> _helpdeskTickets = [
    HelpdeskTicketModel(
      id: 'help001',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      subject: 'Attendance selfie upload issue',
      category: 'Attendance',
      message:
          'Check-out selfie failed on weak connection and the queue retried twice.',
      status: 'In Progress',
      response: 'We are reviewing the sync logs and device network state.',
      respondedBy: 'Saif Al-Bulushi',
      respondedAt: DateTime(2026, 5, 26, 11, 0),
      createdAt: DateTime(2026, 5, 26, 9, 30),
    ),
  ];

  static final List<TaskModel> _tasks = [
    TaskModel(
      id: 'task001',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Complete vehicle, PPE, and route safety checklist before duty handover.',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusCompleted,
      createdAt: DateTime(2026, 5, 23, 7, 30),
      completedAt: DateTime(2026, 5, 23, 8, 5),
    ),
    TaskModel(
      id: 'task002',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Complete warehouse, PPE, and dispatch checklist before shift close.',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      staffCode: 'SHR-002',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusPending,
      createdAt: DateTime(2026, 5, 23, 7, 30),
    ),
    TaskModel(
      id: 'task003',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Submit front-office readiness checklist and confirm branch cash policy review.',
      staffId: 'st003',
      staffName: 'Fatima Al-Zahraa',
      staffCode: 'SHR-003',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusCompleted,
      createdAt: DateTime(2026, 5, 23, 7, 30),
      completedAt: DateTime(2026, 5, 23, 15, 20),
    ),
    TaskModel(
      id: 'task004',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Submit delivery checklist and route deviation report before dispatch end.',
      staffId: 'st004',
      staffName: 'Sultan Al-Hinai',
      staffCode: 'SHR-004',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusTerminated,
      createdAt: DateTime(2026, 5, 23, 7, 30),
      terminatedAt: DateTime(2026, 5, 23, 12, 15),
    ),
    TaskModel(
      id: 'task005',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Review branch compliance log and close missing leave files for today.',
      staffId: 'st005',
      staffName: 'Mariam Al-Kindi',
      staffCode: 'SHR-005',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusPending,
      createdAt: DateTime(2026, 5, 23, 7, 30),
    ),
    TaskModel(
      id: 'task006',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Validate shift coverage, OT exceptions, and dispatch escalation log.',
      staffId: 'st006',
      staffName: 'Hassan Al-Abri',
      staffCode: 'SHR-006',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusCompleted,
      createdAt: DateTime(2026, 5, 23, 7, 30),
      completedAt: DateTime(2026, 5, 23, 14, 10),
    ),
    TaskModel(
      id: 'task007',
      groupId: 'group_daily_20260523',
      title: 'Daily Safety Checklist',
      description:
          'Close aisle inspection report and confirm stock transfer checklist.',
      staffId: 'st007',
      staffName: 'Rania Al-Musawi',
      staffCode: 'SHR-007',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: true,
      isDailyTask: true,
      dueDate: DateTime(2026, 5, 23, 17, 0),
      status: AppConstants.taskStatusPending,
      createdAt: DateTime(2026, 5, 23, 7, 30),
    ),
    TaskModel(
      id: 'task008',
      groupId: 'group_ops_20260522',
      title: 'Fuel Log Reconciliation',
      description:
          'Reconcile weekly fuel slips and submit variance note to finance.',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: false,
      isDailyTask: false,
      dueDate: DateTime(2026, 5, 24, 15, 0),
      status: AppConstants.taskStatusCompleted,
      createdAt: DateTime(2026, 5, 22, 10, 0),
      completedAt: DateTime(2026, 5, 22, 13, 45),
    ),
    TaskModel(
      id: 'task009',
      groupId: 'group_finance_20260520',
      title: 'Inventory Variance Review',
      description:
          'Review branch variance sheet and submit discrepancy summary.',
      staffId: 'st003',
      staffName: 'Fatima Al-Zahraa',
      staffCode: 'SHR-003',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: false,
      isDailyTask: false,
      dueDate: DateTime(2026, 5, 21, 16, 0),
      status: AppConstants.taskStatusCompleted,
      createdAt: DateTime(2026, 5, 20, 11, 30),
      completedAt: DateTime(2026, 5, 21, 14, 5),
    ),
    TaskModel(
      id: 'task010',
      groupId: 'group_hr_20260521',
      title: 'Pending Leave File Audit',
      description:
          'Audit pending leave files and flag missing supporting documents.',
      staffId: 'st005',
      staffName: 'Mariam Al-Kindi',
      staffCode: 'SHR-005',
      assignedBy: 'Saif Al-Bulushi',
      assignedByRole: 'Admin',
      assignedToAll: false,
      isDailyTask: false,
      dueDate: DateTime(2026, 5, 23, 13, 0),
      status: AppConstants.taskStatusPending,
      createdAt: DateTime(2026, 5, 21, 9, 45),
    ),
  ];

  // --- Public API ---

  UserModel? loginUser(String email, String password) {
    const validPassword = 'password123';
    if (password != validPassword) return null;
    try {
      return _users.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  List<UserModel> getUsers() => List<UserModel>.from(_users);

  UserModel? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  List<StaffModel> getStaffList(
      {String? branchId,
      String? department,
      String? category,
      String? searchQuery,
      String? status}) {
    var list = List<StaffModel>.from(_staff);
    if (branchId != null && branchId.isNotEmpty) {
      list = list.where((s) => s.branchId == branchId).toList();
    }
    if (department != null && department.isNotEmpty) {
      list = list.where((s) => s.department == department).toList();
    }
    if (category != null && category.isNotEmpty) {
      list = list.where((s) => s.category == category).toList();
    }
    if (status != null && status.isNotEmpty) {
      list = list.where((s) => s.status == status).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.staffCode.toLowerCase().contains(q) ||
              s.mobile.contains(q))
          .toList();
    }
    return list;
  }

  StaffModel? getStaffById(String id) {
    try {
      return _staff.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  StaffModel? getStaffByUserId(String userId) {
    try {
      return _staff.firstWhere((s) => s.userId == userId);
    } catch (_) {
      return null;
    }
  }

  List<AttendanceModel> getAttendance(
      {String? staffId, DateTime? date, DateTime? fromDate, DateTime? toDate}) {
    var list = List<AttendanceModel>.from(_attendance);
    if (staffId != null) {
      list = list.where((a) => a.staffId == staffId).toList();
    }
    if (date != null) {
      list = list
          .where((a) =>
              a.date.year == date.year &&
              a.date.month == date.month &&
              a.date.day == date.day)
          .toList();
    }
    if (fromDate != null) {
      list = list
          .where(
              (a) => a.date.isAfter(fromDate.subtract(const Duration(days: 1))))
          .toList();
    }
    if (toDate != null) {
      list = list
          .where((a) => a.date.isBefore(toDate.add(const Duration(days: 1))))
          .toList();
    }
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<BranchModel> getBranches() => List.from(_branches);

  void upsertBranch(BranchModel branch) {
    final index = _branches.indexWhere((item) => item.id == branch.id);
    if (index >= 0) {
      _branches[index] = branch;
      return;
    }
    _branches.insert(0, branch);
  }

  BranchModel? getBranchById(String id) {
    try {
      return _branches.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ShiftModel> getShifts() => List.from(_shifts);

  void saveShift(ShiftModel shift) {
    final index = _shifts.indexWhere((s) => s.id == shift.id);
    if (index >= 0) {
      _shifts[index] = shift;
    } else {
      _shifts.add(shift);
    }
  }

  ShiftModel? getShiftById(String id) {
    try {
      return _shifts.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  AttendanceModel? getTodayAttendanceForStaff(String staffId,
      {DateTime? date}) {
    try {
      final targetDate = date ?? DateTime.now();
      return _attendance.firstWhere(
        (attendance) =>
            attendance.staffId == staffId &&
            attendance.date.year == targetDate.year &&
            attendance.date.month == targetDate.month &&
            attendance.date.day == targetDate.day,
      );
    } catch (_) {
      return null;
    }
  }

  AttendanceModel saveAttendance(AttendanceModel attendance) {
    final existingIndex = _attendance.indexWhere(
      (record) =>
          record.staffId == attendance.staffId &&
          record.date.year == attendance.date.year &&
          record.date.month == attendance.date.month &&
          record.date.day == attendance.date.day,
    );

    if (existingIndex >= 0) {
      _attendance[existingIndex] = attendance;
    } else {
      _attendance.insert(0, attendance);
    }

    _updateStaffTodaySnapshot(
      staffId: attendance.staffId,
      checkInTime: attendance.checkInTime,
      checkOutTime: attendance.checkOutTime,
      status: attendance.checkOutTime == null &&
              attendance.dutyStatus == AppConstants.dutyStatusPaused
          ? AppConstants.attendanceDutyPaused
          : attendance.status,
    );

    return attendance;
  }

  AttendanceModel recordCheckIn({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkInTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) {
    final shiftStart = _mergeDateWithTime(checkInTime, shift.startTime);
    final lateMinutes = _calculateLateMinutes(checkInTime, shiftStart);
    final status = lateMinutes > shift.graceMinutes
        ? AppConstants.attendanceLate
        : AppConstants.attendancePresent;

    final existing = getTodayAttendanceForStaff(staff.id, date: checkInTime);
    final attendance = AttendanceModel(
      id: existing?.id ??
          'att_${staff.id}_${checkInTime.millisecondsSinceEpoch}',
      staffId: staff.id,
      staffName: staff.name,
      staffCode: staff.staffCode,
      date: DateTime(checkInTime.year, checkInTime.month, checkInTime.day),
      checkInTime: checkInTime,
      checkOutTime: existing?.checkOutTime,
      checkInLatitude: latitude,
      checkInLongitude: longitude,
      checkOutLatitude: existing?.checkOutLatitude,
      checkOutLongitude: existing?.checkOutLongitude,
      workingHours: existing?.workingHours ?? 0.0,
      overtimeHours: existing?.overtimeHours ?? 0.0,
      lateMinutes: lateMinutes,
      earlyCheckoutMinutes: existing?.earlyCheckoutMinutes ?? 0,
      status: existing?.checkOutTime != null ? existing!.status : status,
      selfieCheckInUrl: selfiePath,
      selfieCheckOutUrl: existing?.selfieCheckOutUrl,
      deviceId: deviceId,
      requiredWifiSsid: branch.wifiSsid,
      checkInWifiSsid: wifiSsid,
      checkOutWifiSsid: existing?.checkOutWifiSsid,
      isLocationValid: isLocationValid,
      isMockGps: isMockGps,
      pausedMinutes: existing?.pausedMinutes ?? 0,
      pauseStartedAt: null,
      dutyStatus: AppConstants.dutyStatusActive,
      approvalStatus: _approvalStatus(
        isLocationValid: isLocationValid,
        isMockGps: isMockGps,
      ),
      notes: notes,
      createdAt: existing?.createdAt ?? checkInTime,
    );

    return saveAttendance(attendance);
  }

  AttendanceModel? recordCheckOut({
    required StaffModel staff,
    required BranchModel branch,
    required ShiftModel shift,
    required DateTime checkOutTime,
    required double latitude,
    required double longitude,
    required String deviceId,
    required bool isLocationValid,
    required bool isMockGps,
    required String? wifiSsid,
    String? selfiePath,
    String? notes,
  }) {
    final existing = getTodayAttendanceForStaff(staff.id, date: checkOutTime);
    if (existing == null || existing.checkInTime == null) {
      return null;
    }

    final livePausedMinutes = existing.pauseStartedAt != null
        ? checkOutTime.difference(existing.pauseStartedAt!).inMinutes
        : 0;
    final pausedMinutes = existing.pausedMinutes + livePausedMinutes;
    final workingHours = (_calculateWorkingHours(
              existing.checkInTime!,
              checkOutTime,
            ) -
            (pausedMinutes / 60.0))
        .clamp(0.0, double.infinity);
    final overtimeHours = workingHours > shift.standardHours
        ? workingHours - shift.standardHours
        : 0.0;
    final shiftEnd = _mergeDateWithTime(checkOutTime, shift.endTime);
    final earlyCheckoutMinutes = shiftEnd.isAfter(checkOutTime)
        ? shiftEnd.difference(checkOutTime).inMinutes
        : 0;

    String status;
    if (existing.lateMinutes > shift.graceMinutes) {
      status = AppConstants.attendanceLate;
    } else if (earlyCheckoutMinutes > 0) {
      status = AppConstants.attendanceEarlyOut;
    } else if (overtimeHours > 0) {
      status = AppConstants.attendanceOvertime;
    } else {
      status = AppConstants.attendancePresent;
    }

    final attendance = AttendanceModel(
      id: existing.id,
      staffId: existing.staffId,
      staffName: existing.staffName,
      staffCode: existing.staffCode,
      date: existing.date,
      checkInTime: existing.checkInTime,
      checkOutTime: checkOutTime,
      checkInLatitude: existing.checkInLatitude,
      checkInLongitude: existing.checkInLongitude,
      checkOutLatitude: latitude,
      checkOutLongitude: longitude,
      workingHours: workingHours,
      overtimeHours: overtimeHours,
      lateMinutes: existing.lateMinutes,
      earlyCheckoutMinutes: earlyCheckoutMinutes,
      status: status,
      selfieCheckInUrl: existing.selfieCheckInUrl,
      selfieCheckOutUrl: selfiePath,
      deviceId: deviceId,
      requiredWifiSsid: existing.requiredWifiSsid ?? branch.wifiSsid,
      checkInWifiSsid: existing.checkInWifiSsid,
      checkOutWifiSsid: wifiSsid,
      isLocationValid: existing.isLocationValid && isLocationValid,
      isMockGps: existing.isMockGps || isMockGps,
      pausedMinutes: pausedMinutes,
      pauseStartedAt: null,
      dutyStatus: AppConstants.dutyStatusCompleted,
      approvalStatus: _approvalStatus(
        isLocationValid: existing.isLocationValid && isLocationValid,
        isMockGps: existing.isMockGps || isMockGps,
      ),
      notes: _combineNotes(existing.notes, notes),
      createdAt: existing.createdAt,
    );

    return saveAttendance(attendance);
  }

  AttendanceModel? pauseDuty({
    required String attendanceId,
    required DateTime pausedAt,
    String? reason,
  }) {
    final index =
        _attendance.indexWhere((attendance) => attendance.id == attendanceId);
    if (index < 0) {
      return null;
    }

    final existing = _attendance[index];
    if (existing.checkInTime == null || existing.checkOutTime != null) {
      return null;
    }

    if (existing.dutyStatus == AppConstants.dutyStatusPaused &&
        existing.pauseStartedAt != null) {
      return existing;
    }

    return saveAttendance(
      existing.copyWith(
        dutyStatus: AppConstants.dutyStatusPaused,
        pauseStartedAt: pausedAt,
        notes: _combineNotes(existing.notes, reason),
      ),
    );
  }

  AttendanceModel? resumeDuty({
    required String attendanceId,
    required DateTime resumedAt,
    String? reason,
  }) {
    final index =
        _attendance.indexWhere((attendance) => attendance.id == attendanceId);
    if (index < 0) {
      return null;
    }

    final existing = _attendance[index];
    if (existing.checkInTime == null ||
        existing.checkOutTime != null ||
        existing.pauseStartedAt == null) {
      return existing;
    }

    final additionalPausedMinutes =
        resumedAt.difference(existing.pauseStartedAt!).inMinutes;

    return saveAttendance(
      existing.copyWith(
        dutyStatus: AppConstants.dutyStatusActive,
        pausedMinutes: existing.pausedMinutes +
            (additionalPausedMinutes > 0 ? additionalPausedMinutes : 0),
        pauseStartedAt: null,
        notes: _combineNotes(existing.notes, reason),
      ),
    );
  }

  List<SalaryModel> getSalaries({String? staffId, String? month}) {
    var list = List<SalaryModel>.from(_salaries);
    if (staffId != null) {
      list = list.where((s) => s.staffId == staffId).toList();
    }
    if (month != null && month.isNotEmpty) {
      list = list.where((s) => s.month == month).toList();
    }
    return list;
  }

  void addSalary(SalaryModel salary) {
    final index = _salaries.indexWhere((item) => item.id == salary.id);
    if (index >= 0) {
      _salaries[index] = salary;
      return;
    }
    _salaries.insert(0, salary);
  }

  void markSalaryPaid({
    required String salaryId,
    DateTime? paidDate,
    String? notes,
  }) {
    final index = _salaries.indexWhere((salary) => salary.id == salaryId);
    if (index < 0) {
      return;
    }

    final updated = _salaries[index].copyWith(
      paymentStatus: AppConstants.salaryStatusPaid,
      paidDate: paidDate ?? DateTime.now(),
      notes: notes,
    );
    _salaries[index] = updated;

    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_salary_${updated.id}',
        title: 'Salary Paid',
        body:
            'Your ${updated.month} salary of OMR ${updated.netSalary.toStringAsFixed(0)} has been marked as paid.',
        type: 'salary',
        staffId: updated.staffId,
        staffName: updated.staffName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<LoanModel> getLoans({String? staffId}) {
    var list = List<LoanModel>.from(_loans);
    if (staffId != null) {
      list = list.where((l) => l.staffId == staffId).toList();
    }
    return list;
  }

  void addLoan(LoanModel loan) {
    final index = _loans.indexWhere((item) => item.id == loan.id);
    if (index >= 0) {
      _loans[index] = loan;
      return;
    }
    _loans.insert(0, loan);
  }

  List<LeaveModel> getLeaves({String? staffId, String? status}) {
    var list = List<LeaveModel>.from(_leaves);
    if (staffId != null) {
      list = list.where((l) => l.staffId == staffId).toList();
    }
    if (status != null && status.isNotEmpty) {
      list = list.where((l) => l.status == status).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addLeave(LeaveModel leave) {
    _leaves.add(leave);
  }

  void updateLeaveStatus({
    required String leaveId,
    required String status,
    String? approvedBy,
    String? rejectionReason,
  }) {
    final index = _leaves.indexWhere((leave) => leave.id == leaveId);
    if (index < 0) {
      return;
    }

    final updated = _leaves[index].copyWith(
      status: status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
    );
    _leaves[index] = updated;

    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_leave_${updated.id}_$status',
        title:
            'Leave ${status == AppConstants.leaveStatusApproved ? 'Approved' : 'Rejected'}',
        body: status == AppConstants.leaveStatusApproved
            ? 'Your ${updated.leaveType} request (${DateFormat('dd MMM').format(updated.fromDate)}-${DateFormat('dd MMM').format(updated.toDate)}) has been approved.'
            : 'Your ${updated.leaveType} request was rejected${rejectionReason != null && rejectionReason.isNotEmpty ? ': $rejectionReason' : '.'}',
        type: 'leave',
        staffId: updated.staffId,
        staffName: updated.staffName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ── Expenses ────────────────────────────────────────────────────────────

  static final List<ExpenseModel> _expenses = [
    ExpenseModel(
      id: 'exp001',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      expenseType: 'Fuel',
      amount: 18.500,
      expenseDate: DateTime.now().subtract(const Duration(days: 5)),
      description: 'Fuel for delivery route — Muscat to Seeb and back.',
      receiptImages: [],
      status: 'Approved',
      approvedBy: 'Saif Al-Bulushi',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ExpenseModel(
      id: 'exp002',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      expenseType: 'Meals',
      amount: 4.200,
      expenseDate: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Lunch during extended shift.',
      receiptImages: [],
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ExpenseModel(
      id: 'exp003',
      staffId: 'st001',
      staffName: 'Salma Al-Rashdi',
      staffCode: 'SHR-001',
      expenseType: 'Vehicle Maintenance',
      amount: 35.000,
      expenseDate: DateTime.now().subtract(const Duration(days: 10)),
      description: 'Oil change and tyre check for company vehicle.',
      receiptImages: [],
      status: 'Rejected',
      rejectionReason: 'Maintenance not pre-approved by operations manager.',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    ExpenseModel(
      id: 'exp004',
      staffId: 'st002',
      staffName: 'Khalid Al-Balushi',
      staffCode: 'SHR-002',
      expenseType: 'Travel',
      amount: 12.000,
      expenseDate: DateTime.now().subtract(const Duration(days: 2)),
      description: 'Taxi to Muscat airport for cargo pickup.',
      receiptImages: [],
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<ExpenseModel> getExpenses({String? staffId, String? status}) {
    var list = List<ExpenseModel>.from(_expenses);
    if (staffId != null) {
      list = list.where((e) => e.staffId == staffId).toList();
    }
    if (status != null && status.isNotEmpty) {
      list = list.where((e) => e.status == status).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addExpense(ExpenseModel expense) {
    _expenses.add(expense);
  }

  void updateExpenseStatus(String expenseId, String status,
      {String? approvedBy, String? rejectionReason}) {
    final idx = _expenses.indexWhere((e) => e.id == expenseId);
    if (idx == -1) return;
    final old = _expenses[idx];
    _expenses[idx] = ExpenseModel(
      id: old.id,
      staffId: old.staffId,
      staffName: old.staffName,
      staffCode: old.staffCode,
      expenseType: old.expenseType,
      amount: old.amount,
      expenseDate: old.expenseDate,
      description: old.description,
      receiptImages: old.receiptImages,
      status: status,
      approvedBy: approvedBy ?? old.approvedBy,
      rejectionReason: rejectionReason ?? old.rejectionReason,
      createdAt: old.createdAt,
    );
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_expense_${old.id}_$status',
        title: 'Expense $status',
        body: status == 'Approved'
            ? 'Your ${old.expenseType} expense claim was approved.'
            : status == 'Rejected'
                ? 'Your ${old.expenseType} expense claim was rejected.'
                : 'Your ${old.expenseType} expense claim is pending review.',
        type: 'expense',
        staffId: old.staffId,
        staffName: old.staffName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<AttendanceEditLogModel> getEditLogs(
      {String? staffId, String? approvalStatus}) {
    var list = List<AttendanceEditLogModel>.from(_editLogs);
    if (staffId != null) {
      list = list.where((l) => l.staffId == staffId).toList();
    }
    if (approvalStatus != null && approvalStatus.isNotEmpty) {
      list = list.where((l) => l.approvalStatus == approvalStatus).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addEditLog(AttendanceEditLogModel log) {
    final index = _editLogs.indexWhere((item) => item.id == log.id);
    if (index >= 0) {
      _editLogs[index] = log;
      return;
    }
    _editLogs.insert(0, log);
  }

  void updateEditLogApprovalStatus({
    required String logId,
    required String status,
    required String approvedBy,
  }) {
    final index = _editLogs.indexWhere((log) => log.id == logId);
    if (index < 0) {
      return;
    }

    _editLogs[index] = _editLogs[index].copyWith(
      approvalStatus: status,
      approvedBy: approvedBy,
      approvedAt: DateTime.now(),
    );
  }

  List<NotificationModel> getNotifications(
      {String? targetRole, String? staffId}) {
    var list = List<NotificationModel>.from(_notifications);
    if (targetRole == AppConstants.roleAdmin) {
      // Admin can review all notifications across roles.
    } else if (targetRole != null && targetRole.isNotEmpty) {
      list = list
          .where((n) => n.targetRole == targetRole || n.targetRole == 'all')
          .toList();
    }
    if (staffId != null) {
      list =
          list.where((n) => n.staffId == null || n.staffId == staffId).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0 || _notifications[index].isRead) {
      return;
    }

    _notifications[index] = _notifications[index].copyWith(isRead: true);
  }

  void markNotificationsAsRead({
    String? targetRole,
    String? staffId,
    String? type,
  }) {
    for (var index = 0; index < _notifications.length; index++) {
      final notification = _notifications[index];
      final roleMatches = targetRole == null ||
          targetRole.isEmpty ||
          notification.targetRole == targetRole ||
          notification.targetRole == 'all';
      final staffMatches = staffId == null ||
          notification.staffId == null ||
          notification.staffId == staffId;
      final typeMatches =
          type == null || type.isEmpty || notification.type == type;

      if (roleMatches && staffMatches && typeMatches && !notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
      }
    }
  }

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
  }

  List<ShiftRosterModel> getShiftRosters({
    String? staffId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    var list = List<ShiftRosterModel>.from(_shiftRosters);
    if (staffId != null && staffId.isNotEmpty) {
      list = list.where((item) => item.staffId == staffId).toList();
    }
    if (fromDate != null) {
      list = list.where((item) => !item.rosterDate.isBefore(fromDate)).toList();
    }
    if (toDate != null) {
      list = list.where((item) => !item.rosterDate.isAfter(toDate)).toList();
    }
    list.sort((a, b) => a.rosterDate.compareTo(b.rosterDate));
    return list;
  }

  void saveShiftRoster(ShiftRosterModel roster, {required bool isEdit}) {
    final index = _shiftRosters.indexWhere((item) =>
        item.id == roster.id ||
        (item.staffId == roster.staffId &&
            item.rosterDate.year == roster.rosterDate.year &&
            item.rosterDate.month == roster.rosterDate.month &&
            item.rosterDate.day == roster.rosterDate.day));
    if (index >= 0) {
      _shiftRosters[index] = roster;
    } else {
      _shiftRosters.add(roster);
    }
  }

  List<ShiftSwapRequestModel> getShiftSwapRequests({String? status}) {
    var list = List<ShiftSwapRequestModel>.from(_shiftSwapRequests);
    if (status != null && status.isNotEmpty) {
      list = list.where((item) => item.status == status).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addShiftSwapRequest(ShiftSwapRequestModel request) {
    _shiftSwapRequests.insert(0, request);
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_swap_${request.id}',
        title: 'Shift swap requested',
        body: '${request.requesterName} requested a shift swap.',
        type: 'shift_swap',
        staffId: request.requesterStaffId,
        staffName: request.requesterName,
        targetRole: AppConstants.roleAdmin,
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateShiftSwapRequestStatus({
    required String requestId,
    required String status,
    required String approvedBy,
    String? rejectionReason,
  }) {
    final index = _shiftSwapRequests.indexWhere((item) => item.id == requestId);
    if (index < 0) {
      return;
    }

    final current = _shiftSwapRequests[index];
    _shiftSwapRequests[index] = ShiftSwapRequestModel(
      id: current.id,
      requesterStaffId: current.requesterStaffId,
      requesterName: current.requesterName,
      requesterCode: current.requesterCode,
      targetStaffId: current.targetStaffId,
      targetName: current.targetName,
      targetCode: current.targetCode,
      rosterDate: current.rosterDate,
      requesterShiftId: current.requesterShiftId,
      requesterShiftName: current.requesterShiftName,
      targetShiftId: current.targetShiftId,
      targetShiftName: current.targetShiftName,
      reason: current.reason,
      status: status,
      approvedBy: approvedBy,
      approvedAt: DateTime.now(),
      rejectionReason: rejectionReason,
      createdAt: current.createdAt,
    );

    if (status == 'Approved') {
      final requesterRosterIndex = _shiftRosters.indexWhere((item) =>
          item.staffId == current.requesterStaffId &&
          item.rosterDate.year == current.rosterDate.year &&
          item.rosterDate.month == current.rosterDate.month &&
          item.rosterDate.day == current.rosterDate.day);
      final targetRosterIndex = _shiftRosters.indexWhere((item) =>
          item.staffId == current.targetStaffId &&
          item.rosterDate.year == current.rosterDate.year &&
          item.rosterDate.month == current.rosterDate.month &&
          item.rosterDate.day == current.rosterDate.day);
      if (requesterRosterIndex >= 0 && targetRosterIndex >= 0) {
        final requesterRoster = _shiftRosters[requesterRosterIndex];
        final targetRoster = _shiftRosters[targetRosterIndex];
        _shiftRosters[requesterRosterIndex] = ShiftRosterModel(
          id: requesterRoster.id,
          staffId: requesterRoster.staffId,
          staffName: requesterRoster.staffName,
          staffCode: requesterRoster.staffCode,
          rosterDate: requesterRoster.rosterDate,
          shiftId: targetRoster.shiftId,
          shiftName: targetRoster.shiftName,
          startTime: targetRoster.startTime,
          endTime: targetRoster.endTime,
          status: requesterRoster.status,
          notes: requesterRoster.notes,
          assignedBy: requesterRoster.assignedBy,
          createdAt: requesterRoster.createdAt,
        );
        _shiftRosters[targetRosterIndex] = ShiftRosterModel(
          id: targetRoster.id,
          staffId: targetRoster.staffId,
          staffName: targetRoster.staffName,
          staffCode: targetRoster.staffCode,
          rosterDate: targetRoster.rosterDate,
          shiftId: requesterRoster.shiftId,
          shiftName: requesterRoster.shiftName,
          startTime: requesterRoster.startTime,
          endTime: requesterRoster.endTime,
          status: targetRoster.status,
          notes: targetRoster.notes,
          assignedBy: targetRoster.assignedBy,
          createdAt: targetRoster.createdAt,
        );
      }
    }

    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_swap_status_$requestId',
        title: 'Shift swap $status',
        body: 'Your shift swap request is now $status.',
        type: 'shift_swap',
        staffId: current.requesterStaffId,
        staffName: current.requesterName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<HelpdeskTicketModel> getHelpdeskTickets({
    String? staffId,
    String? status,
  }) {
    var list = List<HelpdeskTicketModel>.from(_helpdeskTickets);
    if (staffId != null && staffId.isNotEmpty) {
      list = list.where((item) => item.staffId == staffId).toList();
    }
    if (status != null && status.isNotEmpty) {
      list = list.where((item) => item.status == status).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void addHelpdeskTicket(HelpdeskTicketModel ticket) {
    _helpdeskTickets.insert(0, ticket);
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_helpdesk_${ticket.id}',
        title: 'New helpdesk ticket',
        body: '${ticket.staffName} submitted ${ticket.subject}.',
        type: 'helpdesk',
        staffId: ticket.staffId,
        staffName: ticket.staffName,
        targetRole: AppConstants.roleAdmin,
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateHelpdeskTicketStatus({
    required String ticketId,
    required String status,
    required String respondedBy,
    String? response,
  }) {
    final index = _helpdeskTickets.indexWhere((item) => item.id == ticketId);
    if (index < 0) {
      return;
    }

    final current = _helpdeskTickets[index];
    _helpdeskTickets[index] = HelpdeskTicketModel(
      id: current.id,
      staffId: current.staffId,
      staffName: current.staffName,
      staffCode: current.staffCode,
      subject: current.subject,
      category: current.category,
      message: current.message,
      status: status,
      response: response ?? current.response,
      respondedBy: respondedBy,
      respondedAt: DateTime.now(),
      createdAt: current.createdAt,
    );

    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_helpdesk_status_$ticketId',
        title: 'Helpdesk ticket updated',
        body: '${current.subject} is now $status.',
        type: 'helpdesk',
        staffId: current.staffId,
        staffName: current.staffName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
  }

  List<TaskModel> getTasks({String? staffId, String? status}) {
    var list = List<TaskModel>.from(_tasks);

    if (staffId != null && staffId.isNotEmpty) {
      list = list.where((task) => task.staffId == staffId).toList();
    }

    if (status != null && status.isNotEmpty) {
      list = list.where((task) => task.status == status).toList();
    }

    const statusPriority = <String, int>{
      AppConstants.taskStatusPending: 0,
      AppConstants.taskStatusCompleted: 1,
      AppConstants.taskStatusTerminated: 2,
    };

    list.sort((a, b) {
      final priorityCompare = (statusPriority[a.status] ?? 9)
          .compareTo(statusPriority[b.status] ?? 9);
      if (priorityCompare != 0) {
        return priorityCompare;
      }
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  List<TaskModel> assignTask({
    required String title,
    required String description,
    required String assignedBy,
    required String assignedByRole,
    required List<StaffModel> assignees,
    required bool assignToAll,
    required bool isDailyTask,
    required DateTime dueDate,
  }) {
    final now = DateTime.now();
    final groupId = 'task_group_${now.microsecondsSinceEpoch}';
    final createdTasks = <TaskModel>[];

    for (var index = 0; index < assignees.length; index++) {
      final staff = assignees[index];
      final task = TaskModel(
        id: 'task_${staff.id}_${now.microsecondsSinceEpoch}_$index',
        groupId: groupId,
        title: title,
        description: description,
        staffId: staff.id,
        staffName: staff.name,
        staffCode: staff.staffCode,
        assignedBy: assignedBy,
        assignedByRole: assignedByRole,
        assignedToAll: assignToAll,
        isDailyTask: isDailyTask,
        dueDate: dueDate,
        status: AppConstants.taskStatusPending,
        createdAt: now,
      );
      _tasks.insert(0, task);
      createdTasks.add(task);
      _notifications.insert(
        0,
        NotificationModel(
          id: 'notif_task_${task.id}',
          title: 'New Task Assigned',
          body:
              '$title has been assigned. Due ${DateFormat('dd MMM, hh:mm a').format(dueDate)}.',
          type: 'task',
          staffId: staff.id,
          staffName: staff.name,
          targetRole: AppConstants.roleStaff,
          createdAt: now,
        ),
      );
    }

    return createdTasks;
  }

  TaskModel? markTaskCompleted(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      return null;
    }

    final current = _tasks[index];
    if (current.status != AppConstants.taskStatusPending) {
      return current;
    }

    final updated = current.copyWith(
      status: AppConstants.taskStatusCompleted,
      completedAt: DateTime.now(),
    );
    _tasks[index] = updated;
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_complete_${updated.id}',
        title: 'Task Completed',
        body: '${updated.staffName} completed "${updated.title}".',
        type: 'task',
        staffId: updated.staffId,
        staffName: updated.staffName,
        targetRole: AppConstants.roleAdmin,
        createdAt: DateTime.now(),
      ),
    );
    return updated;
  }

  TaskModel? terminateTask(String taskId) {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      return null;
    }

    final current = _tasks[index];
    if (current.status != AppConstants.taskStatusPending) {
      return current;
    }

    final updated = current.copyWith(
      status: AppConstants.taskStatusTerminated,
      terminatedAt: DateTime.now(),
    );
    _tasks[index] = updated;
    _notifications.insert(
      0,
      NotificationModel(
        id: 'notif_terminate_${updated.id}',
        title: 'Task Closed',
        body: '${updated.title} was closed by admin.',
        type: 'task',
        staffId: updated.staffId,
        staffName: updated.staffName,
        targetRole: AppConstants.roleStaff,
        createdAt: DateTime.now(),
      ),
    );
    return updated;
  }

  AttendanceModel? updateOvertimeApprovalStatus({
    required String attendanceId,
    required String status,
  }) {
    final index =
        _attendance.indexWhere((attendance) => attendance.id == attendanceId);
    if (index < 0) {
      return null;
    }

    final updated = _attendance[index].copyWith(approvalStatus: status);
    _attendance[index] = updated;

    if (status == AppConstants.overtimeStatusApproved ||
        status == AppConstants.overtimeStatusRejected) {
      final verb = status == AppConstants.overtimeStatusApproved
          ? 'approved'
          : 'rejected';
      _notifications.insert(
        0,
        NotificationModel(
          id: 'notif_ot_${updated.id}_$status',
          title: 'Overtime $status',
          body:
              'Your ${updated.overtimeHours.toStringAsFixed(1)} hours overtime for ${DateFormat('dd MMM yyyy').format(updated.date)} was $verb.',
          type: 'overtime',
          staffId: updated.staffId,
          staffName: updated.staffName,
          targetRole: AppConstants.roleStaff,
          createdAt: DateTime.now(),
        ),
      );
    }

    return updated;
  }

  int generateSalariesForMonth(DateTime forMonth) {
    final monthLabel = DateFormat('MMMM yyyy').format(forMonth);
    final activeStaff = getStaffList(status: AppConstants.statusActive);
    var generatedCount = 0;

    for (final staff in activeStaff) {
      final alreadyExists = _salaries.any(
        (salary) => salary.staffId == staff.id && salary.month == monthLabel,
      );
      if (alreadyExists) {
        continue;
      }

      final monthAttendance = _attendance.where((attendance) {
        return attendance.staffId == staff.id &&
            attendance.date.year == forMonth.year &&
            attendance.date.month == forMonth.month;
      }).toList();

      final overtimeAmount = (staff.overtimeHours ?? 0) * staff.overtimeRate;
      final absenceDays = monthAttendance
          .where(
            (attendance) => attendance.status == AppConstants.attendanceAbsent,
          )
          .length;
      final absenceDeduction = absenceDays * (staff.basicSalary / 30);
      final loanDeduction = _loans
          .where((loan) =>
              loan.staffId == staff.id &&
              loan.status == AppConstants.loanStatusActive)
          .fold<double>(0, (sum, loan) => sum + loan.monthlyDeduction);
      const allowance = 0.0;
      const deduction = 0.0;
      const penalty = 0.0;
      final netSalary = staff.basicSalary +
          overtimeAmount +
          allowance -
          deduction -
          loanDeduction -
          absenceDeduction -
          penalty;

      _salaries.insert(
        0,
        SalaryModel(
          id: 'sal_${staff.id}_${forMonth.year}_${forMonth.month}',
          staffId: staff.id,
          staffName: staff.name,
          staffCode: staff.staffCode,
          month: monthLabel,
          basicSalary: staff.basicSalary,
          overtimeAmount: overtimeAmount,
          allowance: allowance,
          deduction: deduction,
          loanDeduction: loanDeduction,
          absenceDeduction: absenceDeduction,
          penalty: penalty,
          netSalary: netSalary,
          paymentStatus: AppConstants.salaryStatusPending,
          notes: 'Auto-generated payroll for $monthLabel',
          createdAt: DateTime.now(),
        ),
      );
      generatedCount++;
    }

    return generatedCount;
  }

  void upsertStaff({
    required StaffModel staff,
    required UserModel user,
  }) {
    final staffIndex = _staff.indexWhere((item) => item.id == staff.id);
    if (staffIndex >= 0) {
      _staff[staffIndex] = staff;
    } else {
      _staff.insert(0, staff);
    }

    final userIndex = _users.indexWhere((item) => item.id == user.id);
    if (userIndex >= 0) {
      _users[userIndex] = user;
    } else {
      _users.add(user);
    }
  }

  void resetStaffDeviceBinding(String staffId) {
    final staff = getStaffById(staffId);
    if (staff == null || staff.userId.isEmpty) {
      return;
    }

    final userIndex = _users.indexWhere((item) => item.id == staff.userId);
    if (userIndex < 0) {
      return;
    }

    _users[userIndex] = _users[userIndex].copyWith(deviceId: null);
  }

  List<KpiModel> getKpiRecords({String? staffId, String? month}) {
    var list =
        List<KpiModel>.from(_kpiRecords).map(_kpiWithTaskMetrics).toList();
    if (staffId != null) {
      list = list.where((k) => k.staffId == staffId).toList();
    }
    if (month != null) list = list.where((k) => k.month == month).toList();
    return list;
  }

  // Dashboard stats
  Map<String, dynamic> getDashboardStats(DateTime date) {
    final todayAttendance = getAttendance(date: date);
    final staffList = getStaffList(status: 'Active');
    final kpiRecords = getKpiRecords();
    int present = 0, absent = 0, late = 0, onLeave = 0, overtime = 0;

    // Monthly breakdown for the attendance chart
    final monthlyAttendance = _attendance.where((a) {
      return a.date.year == date.year && a.date.month == date.month;
    }).toList();
    int mPresent = 0, mAbsent = 0, mLate = 0, mOnLeave = 0, mOvertime = 0;
    for (final att in monthlyAttendance) {
      switch (att.status) {
        case 'Present':
          mPresent++;
          break;
        case 'Late':
          mLate++;
          mPresent++;
          break;
        case 'On Leave':
          mOnLeave++;
          break;
        case 'Overtime':
          mOvertime++;
          mPresent++;
          break;
        case 'Missing Checkout':
          mPresent++;
          break;
        case 'Absent':
          mAbsent++;
          break;
      }
    }

    for (final att in todayAttendance) {
      switch (att.status) {
        case 'Present':
          present++;
          break;
        case 'Late':
          late++;
          present++;
          break;
        case 'On Leave':
          onLeave++;
          break;
        case 'Overtime':
          overtime++;
          present++;
          break;
        case 'Missing Checkout':
          present++;
          break;
        case 'Absent':
          absent++;
          break;
      }
    }
    final absentCount = staffList.length - present - onLeave;
    final totalOtHours =
        kpiRecords.fold<double>(0, (sum, k) => sum + k.overtimeHours);
    final avgKpi = kpiRecords.isEmpty
        ? 0.0
        : kpiRecords.fold<double>(0, (s, k) => s + k.totalKpiScore) /
            kpiRecords.length;
    final totalLoan = _loans
        .where((l) => l.status == 'Active')
        .fold<double>(0, (s, l) => s + l.balanceAmount);
    final pendingSalaries =
        _salaries.where((s) => s.paymentStatus == 'Pending').length;
    var expiringDocuments = 0;
    var expiredDocuments = 0;
    final today = DateTime(date.year, date.month, date.day);
    for (final staff in staffList) {
      for (final expiryDate in [
        staff.passportExpireDate,
        staff.civilIdExpireDate,
        staff.contractExpireDate,
      ]) {
        if (expiryDate == null) {
          continue;
        }
        final daysRemaining = DateTime(
          expiryDate.year,
          expiryDate.month,
          expiryDate.day,
        ).difference(today).inDays;
        if (daysRemaining > 30) {
          continue;
        }
        if (daysRemaining < 0) {
          expiredDocuments++;
        } else {
          expiringDocuments++;
        }
      }
    }
    KpiModel? bestStaff, lowestKpi, highestOt;
    for (final k in kpiRecords) {
      if (bestStaff == null || k.totalKpiScore > bestStaff.totalKpiScore) {
        bestStaff = k;
      }
      if (lowestKpi == null || k.totalKpiScore < lowestKpi.totalKpiScore) {
        lowestKpi = k;
      }
      if (highestOt == null || k.overtimeHours > highestOt.overtimeHours) {
        highestOt = k;
      }
    }
    return {
      'total_staff': staffList.length,
      'present_today': present,
      'absent_today': absentCount > 0 ? absentCount : absent,
      'late_today': late,
      'on_leave': onLeave,
      'overtime_count': overtime,
      'monthly_present': mPresent,
      'monthly_absent': mAbsent,
      'monthly_late': mLate,
      'monthly_on_leave': mOnLeave,
      'monthly_overtime': mOvertime,
      'total_overtime_hours': totalOtHours,
      'salary_pending': pendingSalaries,
      'total_loan_balance': totalLoan,
      'kpi_average': avgKpi,
      'best_staff': bestStaff?.staffName ?? '-',
      'lowest_kpi_staff': lowestKpi?.staffName ?? '-',
      'highest_overtime_staff': highestOt?.staffName ?? '-',
      'expiring_documents': expiringDocuments,
      'expired_documents': expiredDocuments,
    };
  }

  KpiModel _kpiWithTaskMetrics(KpiModel base) {
    final period = DateFormat('MMMM yyyy').parse(base.month);
    final periodTasks = _tasks.where((task) {
      return task.staffId == base.staffId &&
          task.createdAt.year == period.year &&
          task.createdAt.month == period.month;
    }).toList();

    final scoredTasks = periodTasks
        .where((task) => task.status != AppConstants.taskStatusTerminated)
        .toList();
    final completedTasks = scoredTasks
        .where((task) => task.status == AppConstants.taskStatusCompleted)
        .length;
    final assignedTasks = scoredTasks.length;
    final completionRate =
        assignedTasks == 0 ? 0.0 : (completedTasks / assignedTasks) * 100;
    final attendanceScore = _rebalanceKpiScore(
      currentScore: base.attendanceScore,
      legacyWeight: 40,
      newWeight: AppConstants.kpiAttendanceWeight.toDouble(),
    );
    final punctualityScore = _rebalanceKpiScore(
      currentScore: base.punctualityScore,
      legacyWeight: 25,
      newWeight: AppConstants.kpiPunctualityWeight.toDouble(),
    );
    final overtimeScore = _rebalanceKpiScore(
      currentScore: base.overtimeScore,
      legacyWeight: 15,
      newWeight: AppConstants.kpiOvertimeWeight.toDouble(),
    );
    final locationScore = _rebalanceKpiScore(
      currentScore: base.locationScore,
      legacyWeight: 10,
      newWeight: AppConstants.kpiLocationWeight.toDouble(),
    );
    final disciplineScore = _rebalanceKpiScore(
      currentScore: base.disciplineScore,
      legacyWeight: 10,
      newWeight: AppConstants.kpiDisciplineWeight.toDouble(),
    );
    final taskRatio = assignedTasks == 0 ? 1.0 : completedTasks / assignedTasks;
    final taskScore = taskRatio * AppConstants.kpiTaskWeight;
    final totalScore = (attendanceScore +
            punctualityScore +
            overtimeScore +
            locationScore +
            disciplineScore +
            taskScore)
        .clamp(0, 100)
        .toDouble();

    return base.copyWith(
      attendanceScore: attendanceScore,
      punctualityScore: punctualityScore,
      overtimeScore: overtimeScore,
      locationScore: locationScore,
      disciplineScore: disciplineScore,
      taskAssignedCount: assignedTasks,
      taskCompletedCount: completedTasks,
      taskCompletionRate: completionRate,
      taskScore: taskScore,
      totalKpiScore: totalScore,
      rating: _kpiRatingFromScore(totalScore),
    );
  }

  void _updateStaffTodaySnapshot({
    required String staffId,
    required DateTime? checkInTime,
    required DateTime? checkOutTime,
    required String status,
  }) {
    final staffIndex = _staff.indexWhere((staff) => staff.id == staffId);
    if (staffIndex < 0) {
      return;
    }

    _staff[staffIndex] = _staff[staffIndex].copyWith(
      todayCheckIn: checkInTime != null ? _formatTime24(checkInTime) : '',
      todayCheckOut: checkOutTime != null ? _formatTime24(checkOutTime) : '',
      todayStatus: status,
    );
  }

  DateTime _mergeDateWithTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  int _calculateLateMinutes(DateTime checkInTime, DateTime shiftStart) {
    if (!checkInTime.isAfter(shiftStart)) {
      return 0;
    }
    return checkInTime.difference(shiftStart).inMinutes;
  }

  double _calculateWorkingHours(DateTime checkInTime, DateTime checkOutTime) {
    return checkOutTime.difference(checkInTime).inMinutes / 60.0;
  }

  String _approvalStatus({
    required bool isLocationValid,
    required bool isMockGps,
  }) {
    if (isLocationValid && !isMockGps) {
      return 'Auto';
    }
    return 'Needs Review';
  }

  String? _combineNotes(String? currentNotes, String? nextNotes) {
    if (currentNotes == null || currentNotes.isEmpty) {
      return nextNotes;
    }
    if (nextNotes == null || nextNotes.isEmpty || nextNotes == currentNotes) {
      return currentNotes;
    }
    return '$currentNotes\n$nextNotes';
  }

  String _formatTime24(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _kpiRatingFromScore(double score) {
    if (score >= AppConstants.kpiExcellentMin) {
      return AppConstants.kpiExcellent;
    }
    if (score >= AppConstants.kpiVeryGoodMin) {
      return AppConstants.kpiVeryGood;
    }
    if (score >= AppConstants.kpiGoodMin) {
      return AppConstants.kpiGood;
    }
    if (score >= AppConstants.kpiNeedsImprovementMin) {
      return AppConstants.kpiNeedsImprovement;
    }
    return AppConstants.kpiPoor;
  }

  double _rebalanceKpiScore({
    required double currentScore,
    required double legacyWeight,
    required double newWeight,
  }) {
    if (legacyWeight <= 0) {
      return 0;
    }

    final normalized = (currentScore / legacyWeight).clamp(0, 1);
    return normalized * newWeight;
  }

  // ─── HOLIDAYS ───────────────────────────────────────────────────────────────

  static final List<HolidayModel> _holidays = [
    // Eid Al-Fitr 2025 (3 days) — Oman Labour Law Art. 68
    HolidayModel(
        id: 'h001',
        name: 'Eid Al-Fitr',
        date: DateTime(2025, 3, 30),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h002',
        name: 'Eid Al-Fitr',
        date: DateTime(2025, 3, 31),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h003',
        name: 'Eid Al-Fitr',
        date: DateTime(2025, 4, 1),
        type: 'Eid',
        otMultiplier: 2.0),
    // Eid Al-Adha 2025 (3 days)
    HolidayModel(
        id: 'h004',
        name: 'Eid Al-Adha',
        date: DateTime(2025, 6, 6),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h005',
        name: 'Eid Al-Adha',
        date: DateTime(2025, 6, 7),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h006',
        name: 'Eid Al-Adha',
        date: DateTime(2025, 6, 8),
        type: 'Eid',
        otMultiplier: 2.0),
    // Islamic New Year 2025
    HolidayModel(
        id: 'h007',
        name: 'Islamic New Year',
        date: DateTime(2025, 6, 26),
        type: 'Public',
        otMultiplier: 2.0),
    // Prophet's Birthday 2025
    HolidayModel(
        id: 'h008',
        name: "Prophet's Birthday",
        date: DateTime(2025, 9, 4),
        type: 'Public',
        otMultiplier: 2.0),
    // Oman National Day 2025
    HolidayModel(
        id: 'h009',
        name: 'National Day',
        date: DateTime(2025, 11, 18),
        type: 'Public',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h010',
        name: 'National Day',
        date: DateTime(2025, 11, 19),
        type: 'Public',
        otMultiplier: 2.0),
    // Eid Al-Fitr 2026 (3 days)
    HolidayModel(
        id: 'h011',
        name: 'Eid Al-Fitr',
        date: DateTime(2026, 3, 19),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h012',
        name: 'Eid Al-Fitr',
        date: DateTime(2026, 3, 20),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h013',
        name: 'Eid Al-Fitr',
        date: DateTime(2026, 3, 21),
        type: 'Eid',
        otMultiplier: 2.0),
    // Eid Al-Adha 2026 (3 days)
    HolidayModel(
        id: 'h014',
        name: 'Eid Al-Adha',
        date: DateTime(2026, 5, 26),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h015',
        name: 'Eid Al-Adha',
        date: DateTime(2026, 5, 27),
        type: 'Eid',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h016',
        name: 'Eid Al-Adha',
        date: DateTime(2026, 5, 28),
        type: 'Eid',
        otMultiplier: 2.0),
    // Oman National Day 2026
    HolidayModel(
        id: 'h017',
        name: 'National Day',
        date: DateTime(2026, 11, 18),
        type: 'Public',
        otMultiplier: 2.0),
    HolidayModel(
        id: 'h018',
        name: 'National Day',
        date: DateTime(2026, 11, 19),
        type: 'Public',
        otMultiplier: 2.0),
  ];

  List<HolidayModel> getHolidays({int? year}) {
    if (year == null) return List.unmodifiable(_holidays);
    return _holidays.where((h) => h.date.year == year).toList();
  }

  void addHoliday(HolidayModel holiday) => _holidays.add(holiday);

  void removeHoliday(String id) => _holidays.removeWhere((h) => h.id == id);

  HolidayModel? getHolidayForDate(DateTime date) {
    for (final h in _holidays) {
      if (h.date.year == date.year &&
          h.date.month == date.month &&
          h.date.day == date.day) {
        return h;
      }
    }
    return null;
  }

  bool isHolidayDate(DateTime date) {
    if (date.weekday == DateTime.friday) return true;
    return getHolidayForDate(date) != null;
  }

  // Friday = 1.5x, Public/Eid holiday = 2.0x, normal OT = 1.5x
  double getOtMultiplierForDate(DateTime date) {
    final holiday = getHolidayForDate(date);
    if (holiday != null) return holiday.otMultiplier;
    if (date.weekday == DateTime.friday) return 1.5;
    return 1.5;
  }

  String getOtLabelForDate(DateTime date) {
    final holiday = getHolidayForDate(date);
    if (holiday != null) return '${holiday.name} OT';
    if (date.weekday == DateTime.friday) return 'Friday OT';
    return 'OT';
  }
}
