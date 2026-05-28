import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/holiday_model.dart';
import '../../../data/providers/app_providers.dart';

class HolidayCalendarScreen extends ConsumerStatefulWidget {
  const HolidayCalendarScreen({super.key});

  @override
  ConsumerState<HolidayCalendarScreen> createState() =>
      _HolidayCalendarScreenState();
}

class _HolidayCalendarScreenState extends ConsumerState<HolidayCalendarScreen> {
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final holidays = ref.watch(holidayListByYearProvider(_selectedYear));
    final grouped = _groupByMonth(holidays);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
            tooltip: 'Add Holiday',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildLegend(),
          Expanded(
            child: holidays.isEmpty
                ? _buildEmpty()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      _buildFridayNote(),
                      const SizedBox(height: 12),
                      ...grouped.entries.map((entry) =>
                          _buildMonthSection(entry.key, entry.value)),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () => setState(() => _selectedYear--),
          ),
          Text(
            '$_selectedYear',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () => setState(() => _selectedYear++),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _legendDot(const Color(0xFF6A1B9A), 'Eid Holiday (2x OT)'),
          const SizedBox(width: 16),
          _legendDot(AppColors.accent, 'Public Holiday (2x OT)'),
          const SizedBox(width: 16),
          _legendDot(AppColors.success, 'Friday (1.5x OT)'),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildFridayNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Every Friday — Weekly Rest Day',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  'Work on Friday = 1.5x OT pay (Oman Labour Law Art. 68)',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_outlined,
              size: 60, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text('No holidays set for $_selectedYear',
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showAddDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Holiday'),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSection(int month, List<HolidayModel> items) {
    final monthName = DateFormat('MMMM').format(DateTime(_selectedYear, month));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(monthName,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.textPrimary)),
        ),
        ...items.map((h) => _buildHolidayTile(h)),
      ],
    );
  }

  Widget _buildHolidayTile(HolidayModel holiday) {
    final color = _typeColor(holiday.type);
    final isUpcoming = holiday.date.isAfter(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(holiday.date),
              style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 18, color: color),
            ),
            Text(
              DateFormat('EEE').format(holiday.date),
              style:
                  const TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        title: Text(holiday.name,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textPrimary)),
        subtitle: Row(
          children: [
            _typeBadge(holiday.type, color),
            const SizedBox(width: 8),
            _otBadge(holiday.otMultiplier),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUpcoming)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Upcoming',
                    style: TextStyle(fontSize: 10, color: AppColors.info)),
              ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: AppColors.error),
              onPressed: () => _confirmDelete(holiday),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _otBadge(double multiplier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text('${multiplier}x OT',
          style: const TextStyle(
              fontSize: 10,
              color: AppColors.warning,
              fontWeight: FontWeight.w600)),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Eid':
        return const Color(0xFF6A1B9A);
      case 'Public':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }

  Map<int, List<HolidayModel>> _groupByMonth(List<HolidayModel> holidays) {
    final map = <int, List<HolidayModel>>{};
    final sorted = [...holidays]..sort((a, b) => a.date.compareTo(b.date));
    for (final h in sorted) {
      map.putIfAbsent(h.date.month, () => []).add(h);
    }
    return map;
  }

  void _confirmDelete(HolidayModel holiday) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Holiday?'),
        content: Text(
            'Remove "${holiday.name}" on ${DateFormat('d MMM yyyy').format(holiday.date)}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(holidayNotifierProvider.notifier).remove(holiday.id);
              Navigator.pop(context);
            },
            child:
                const Text('Remove', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String selectedType = 'Public';
    double selectedMultiplier = 2.0;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Add Holiday'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Holiday Name',
                    hintText: 'e.g. Eid Al-Fitr',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),
                // Date picker
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDlgState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(DateFormat('d MMM yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Type dropdown
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: ['Eid', 'Public']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDlgState(() => selectedType = v);
                  },
                ),
                const SizedBox(height: 14),
                // OT multiplier
                DropdownButtonFormField<double>(
                  value: selectedMultiplier,
                  decoration: const InputDecoration(
                    labelText: 'OT Multiplier',
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [1.5, 2.0]
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text('${m}x pay')))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDlgState(() => selectedMultiplier = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white),
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final id = 'h${DateTime.now().millisecondsSinceEpoch}';
                ref.read(holidayNotifierProvider.notifier).add(
                      HolidayModel(
                        id: id,
                        name: name,
                        date: selectedDate,
                        type: selectedType,
                        otMultiplier: selectedMultiplier,
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
