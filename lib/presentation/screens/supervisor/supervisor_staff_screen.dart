import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../widgets/common/status_badge.dart';
import '../../../core/l10n/app_localizations.dart';

class SupervisorStaffScreen extends ConsumerStatefulWidget {
  const SupervisorStaffScreen({super.key});

  @override
  ConsumerState<SupervisorStaffScreen> createState() =>
      _SupervisorStaffScreenState();
}

class _SupervisorStaffScreenState extends ConsumerState<SupervisorStaffScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffList = ref.watch(allStaffListProvider).where((staff) {
      final matchesSearch = _searchQuery.isEmpty ||
          staff.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.staffCode.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter.isEmpty || staff.status == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: staffList.isEmpty
                ? Center(
                    child: Text(context.tr('no_staff_found'),
                        style: const TextStyle(color: AppColors.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: staffList.length,
                    itemBuilder: (_, i) => _staffCard(staffList[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search staff name or code...',
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      })
                  : null,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['', 'Active', 'Inactive', 'Suspended'].map((status) {
                final isSelected = _statusFilter == status;
                final label = status.isEmpty ? 'All' : status;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _statusFilter = status),
                    selectedColor: AppColors.primary.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(StaffModel s) {
    final status = s.todayStatus ?? 'Unknown';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              child: Text(
                s.name.isNotEmpty ? s.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      StatusBadge(status: s.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${s.staffCode} · ${s.category} · ${s.department}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _infoChip(Icons.fingerprint, status),
                      const SizedBox(width: 8),
                      if ((s.kpiScore ?? 0) > 0)
                        _infoChip(
                          Icons.bar_chart,
                          'KPI: ${s.kpiScore!.toStringAsFixed(0)}',
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'In: ${s.todayCheckIn?.isNotEmpty == true ? s.todayCheckIn! : '--'}  '
                        'Out: ${s.todayCheckOut?.isNotEmpty == true ? s.todayCheckOut! : '--'}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
