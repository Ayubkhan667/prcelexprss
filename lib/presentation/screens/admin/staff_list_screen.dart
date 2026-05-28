import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/staff_model.dart';
import '../../widgets/common/status_badge.dart';
import 'add_edit_staff_screen.dart';
import 'staff_detail_screen.dart';
import '../../../core/l10n/app_localizations.dart';

class StaffListScreen extends ConsumerStatefulWidget {
  const StaffListScreen({super.key});

  @override
  ConsumerState<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends ConsumerState<StaffListScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = '';
  String _selectedStatus = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffList = ref.watch(staffListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr('staff_directory')),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddEditStaffScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, mobile...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilter(ref);
                            })
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.divider)),
                  ),
                  onChanged: (_) => _applyFilter(ref),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip('All', _selectedStatus.isEmpty,
                          () => _setStatus('', ref)),
                      _filterChip('Active', _selectedStatus == 'Active',
                          () => _setStatus('Active', ref)),
                      _filterChip('Inactive', _selectedStatus == 'Inactive',
                          () => _setStatus('Inactive', ref)),
                      _filterChip('Suspended', _selectedStatus == 'Suspended',
                          () => _setStatus('Suspended', ref)),
                      const SizedBox(width: 8),
                      _categoryDropdown(ref),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text('${staffList.length} staff found',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          // Staff list
          Expanded(
            child: staffList.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: staffList.length,
                    itemBuilder: (ctx, i) => _staffCard(ctx, staffList[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _staffCard(BuildContext context, StaffModel staff) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => StaffDetailScreen(staffId: staff.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(AppUtils.getInitials(staff.name),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text(staff.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                overflow: TextOverflow.ellipsis)),
                        StatusBadge(status: staff.status, fontSize: 10),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${staff.staffCode} • ${staff.category}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 2),
                    Text(staff.department,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _infoChip(Icons.location_on_outlined, staff.branchName,
                            AppColors.primary),
                        const SizedBox(width: 6),
                        if (staff.todayStatus != null &&
                            staff.todayStatus!.isNotEmpty)
                          StatusBadge(status: staff.todayStatus!, fontSize: 10),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // KPI + Attendance
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (staff.kpiScore != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppUtils.getKpiColor(staff.kpiScore!)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        staff.kpiScore!.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppUtils.getKpiColor(staff.kpiScore!)),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(staff.todayCheckIn ?? '--:--',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                  Text(
                      staff.todayCheckOut?.isNotEmpty == true
                          ? staff.todayCheckOut!
                          : '--:--',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(text.length > 16 ? '${text.substring(0, 14)}...' : text,
            style: TextStyle(fontSize: 10, color: color)),
      ],
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }

  Widget _categoryDropdown(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: _selectedCategory.isEmpty
            ? AppColors.background
            : AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _selectedCategory.isEmpty
                ? AppColors.divider
                : AppColors.primary),
      ),
      child: DropdownButton<String>(
        value: _selectedCategory.isEmpty ? null : _selectedCategory,
        hint: const Text('Category', style: TextStyle(fontSize: 12)),
        underline: const SizedBox(),
        isDense: true,
        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        items: [
          DropdownMenuItem(value: '', child: Text(context.tr('all_categories'))),
          ...AppConstants.staffCategories
              .map((c) => DropdownMenuItem(value: c, child: Text(c))),
        ],
        onChanged: (v) {
          setState(() => _selectedCategory = v ?? '');
          _applyFilter(ref);
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(context.tr('no_staff_found'),
              style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _applyFilter(WidgetRef ref) {
    ref.read(staffFilterProvider.notifier).state = StaffFilter(
      searchQuery: _searchController.text,
      status: _selectedStatus,
      category: _selectedCategory,
    );
  }

  void _setStatus(String status, WidgetRef ref) {
    setState(() => _selectedStatus = status);
    _applyFilter(ref);
  }
}
