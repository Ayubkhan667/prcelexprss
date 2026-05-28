import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/app_utils.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/shift_model.dart';
import '../../../data/providers/app_providers.dart';

class ShiftManagementScreen extends ConsumerWidget {
  const ShiftManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shifts = ref.watch(shiftListProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Shift Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShiftSheet(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
        backgroundColor: AppColors.primary,
      ),
      body: shifts.isEmpty
          ? const Center(child: Text('No shifts found'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: shifts.length,
              itemBuilder: (_, i) => _shiftCard(context, ref, shifts[i]),
            ),
    );
  }

  Widget _shiftCard(BuildContext context, WidgetRef ref, ShiftModel shift) {
    final isActive = shift.status == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.schedule, color: Colors.white, size: 22),
        ),
        title: Text(shift.shiftName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 3),
            Text('${shift.startTime} – ${shift.endTime}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
                '${shift.standardHours.toStringAsFixed(0)}h  •  ${shift.graceMinutes}min grace',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textHint)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isActive ? AppColors.successLight : AppColors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                shift.status,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.success : AppColors.error),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.primary),
              onPressed: () => _showShiftSheet(context, ref, shift),
            ),
          ],
        ),
      ),
    );
  }

  void _showShiftSheet(
      BuildContext context, WidgetRef ref, ShiftModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShiftSheet(existing: existing),
    );
  }
}

class _ShiftSheet extends ConsumerStatefulWidget {
  final ShiftModel? existing;
  const _ShiftSheet({this.existing});

  @override
  ConsumerState<_ShiftSheet> createState() => _ShiftSheetState();
}

class _ShiftSheetState extends ConsumerState<_ShiftSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late String _startTime;
  late String _endTime;
  late TextEditingController _hoursCtrl;
  late TextEditingController _graceCtrl;
  bool _isActive = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.existing;
    _nameCtrl = TextEditingController(text: s?.shiftName ?? '');
    _startTime = s?.startTime ?? '08:00';
    _endTime = s?.endTime ?? '16:00';
    _hoursCtrl =
        TextEditingController(text: s?.standardHours.toStringAsFixed(0) ?? '8');
    _graceCtrl = TextEditingController(text: '${s?.graceMinutes ?? 15}');
    _isActive = (s?.status ?? 'Active') == 'Active';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _hoursCtrl.dispose();
    _graceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final parts = (isStart ? _startTime : _endTime).split(':');
    final initial =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      final str =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() => isStart ? _startTime = str : _endTime = str);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);
    final useRemote = ref.read(useRemoteDataProvider);

    final shift = ShiftModel(
      id: widget.existing?.id ??
          (useRemote ? '' : 'shift_${DateTime.now().millisecondsSinceEpoch}'),
      shiftName: _nameCtrl.text.trim(),
      startTime: _startTime,
      endTime: _endTime,
      standardHours: double.tryParse(_hoursCtrl.text) ?? 8,
      graceMinutes: int.tryParse(_graceCtrl.text) ?? 15,
      status: _isActive ? 'Active' : 'Inactive',
    );

    try {
      await ref.read(shiftRepositoryProvider).saveShift(
            shift: shift,
            isEdit: widget.existing != null,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSaving = false);
      AppUtils.showSnackBar(
        context,
        'Unable to save shift right now.',
        isError: true,
      );
      return;
    }
    if (mounted) {
      Navigator.pop(context);
      AppUtils.showSnackBar(
        context,
        widget.existing == null
            ? 'Shift created successfully'
            : 'Shift updated',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.schedule, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.existing == null ? 'Add Shift' : 'Edit Shift',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: _inputDecor('Shift Name', Icons.badge_outlined),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter shift name' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _timeTile(
                      'Start Time', _startTime, () => _pickTime(true)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child:
                      _timeTile('End Time', _endTime, () => _pickTime(false)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _hoursCtrl,
                    keyboardType: TextInputType.number,
                    decoration:
                        _inputDecor('Standard Hours', Icons.timer_outlined),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _graceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecor('Grace (mins)', Icons.access_time),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Active',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Switch(
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.existing == null
                            ? 'Create Shift'
                            : 'Save Changes',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeTile(String label, String time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(time,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
      prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
      filled: true,
      fillColor: const Color(0xFFF6F8FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2)),
    );
  }
}
