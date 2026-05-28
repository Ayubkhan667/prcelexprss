import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../widgets/common/status_badge.dart';
import 'add_edit_staff_screen.dart';

class StaffDetailScreen extends ConsumerWidget {
  final String staffId;
  const StaffDetailScreen({super.key, required this.staffId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(mockDataServiceProvider);
    final staff = service.getStaffById(staffId);
    if (staff == null) {
      return const Scaffold(body: Center(child: Text('Staff not found')));
    }
    final attendance = ref.read(attendanceListProvider(staffId));
    final kpi = ref.read(kpiListProvider(staffId));
    final loans = ref.read(loanListProvider(staffId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => AddEditStaffScreen(staffId: staffId))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration:
                    const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(AppUtils.getInitials(staff.name),
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                    ),
                    const SizedBox(height: 10),
                    Text(staff.name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text('${staff.staffCode} • ${staff.jobTitle}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8))),
                    const SizedBox(height: 6),
                    StatusBadge(status: staff.status),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI summary
                  if (kpi.isNotEmpty) ...[
                    _section('KPI Performance'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecor(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _kpiItem(
                              'KPI Score',
                              kpi.first.totalKpiScore.toStringAsFixed(1),
                              AppUtils.getKpiColor(kpi.first.totalKpiScore)),
                          _kpiItem('Rating', kpi.first.rating,
                              AppUtils.getStatusColor(kpi.first.rating)),
                          _kpiItem(
                              'Attendance',
                              '${kpi.first.attendanceRate.toStringAsFixed(0)}%',
                              AppColors.present),
                          _kpiItem('Late Days', kpi.first.lateCount.toString(),
                              AppColors.late),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Personal info
                  _section('Personal Information'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecor(),
                    child: Column(
                      children: [
                        _infoRow(Icons.phone_outlined, 'Mobile', staff.mobile),
                        _infoRow(Icons.email_outlined, 'Email', staff.email),
                        if (staff.idCardNumber != null)
                          _infoRow(Icons.credit_card_outlined, 'ID Card',
                              staff.idCardNumber!),
                        _infoRow(Icons.category_outlined, 'Category',
                            staff.category),
                        _infoRow(Icons.business_outlined, 'Department',
                            staff.department),
                        _infoRow(Icons.location_city_outlined, 'Branch',
                            staff.branchName),
                        _infoRow(
                          Icons.radar_outlined,
                          'Assigned Range',
                          staff.allowedLocationRadiusMeters == null
                              ? 'Branch default'
                              : '${staff.allowedLocationRadiusMeters!.toStringAsFixed(0)}m',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Work info
                  _section('Work Information'),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _cardDecor(),
                    child: Column(
                      children: [
                        _infoRow(
                            Icons.work_outline, 'Job Title', staff.jobTitle),
                        _infoRow(
                            Icons.schedule_outlined, 'Shift', staff.shiftName),
                        _infoRow(Icons.event_available_outlined, 'Joining Date',
                            AppUtils.formatDate(staff.joiningDate)),
                        _infoRow(
                            Icons.payments_outlined,
                            'Basic Salary',
                            AppUtils.formatCurrency(staff.basicSalary,
                                symbol: 'PKR ')),
                        _infoRow(Icons.more_time_outlined, 'Overtime Rate',
                            'PKR ${staff.overtimeRate.toStringAsFixed(0)}/hr'),
                        _infoRow(Icons.weekend_outlined, 'Weekly Off',
                            staff.weeklyOffDay),
                        _infoRow(Icons.free_breakfast_outlined, 'Daily Break',
                            '${staff.dailyBreakMinutes} minutes'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Loan info
                  if (loans.isNotEmpty) ...[
                    _section('Loan Status'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: _cardDecor(),
                      child: Column(
                        children: loans
                            .map((l) => Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(l.purpose ?? 'Loan',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600)),
                                        StatusBadge(status: l.status),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: l.repaymentProgress,
                                      backgroundColor: AppColors.divider,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              AppColors.primary),
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Paid: PKR ${l.paidAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.success)),
                                        Text(
                                            'Balance: PKR ${l.balanceAmount.toStringAsFixed(0)}',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.error)),
                                      ],
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Recent attendance
                  _section('Recent Attendance'),
                  Container(
                    decoration: _cardDecor(),
                    child: Column(
                      children: attendance
                          .take(7)
                          .map((a) => ListTile(
                                dense: true,
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppUtils.getStatusColor(a.status)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(_statusIcon(a.status),
                                      size: 18,
                                      color: AppUtils.getStatusColor(a.status)),
                                ),
                                title: Text(AppUtils.formatDate(a.date),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                subtitle: a.checkInTime != null
                                    ? Text(
                                        'In: ${AppUtils.formatTime(a.checkInTime!)} • Out: ${a.checkOutTime != null ? AppUtils.formatTime(a.checkOutTime!) : "--"}',
                                        style: const TextStyle(fontSize: 11))
                                    : null,
                                trailing:
                                    StatusBadge(status: a.status, fontSize: 10),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }

  BoxDecoration _cardDecor() => BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
      );

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
              width: 100,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _kpiItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Present':
        return Icons.check_circle_outline;
      case 'Late':
        return Icons.access_time;
      case 'Absent':
        return Icons.cancel_outlined;
      case 'On Leave':
        return Icons.beach_access_outlined;
      case 'Overtime':
        return Icons.more_time;
      default:
        return Icons.help_outline;
    }
  }
}
