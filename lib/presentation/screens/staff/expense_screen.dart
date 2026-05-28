import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/expense_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_text_field.dart';

const _expenseTypes = [
  'Fuel',
  'Meals',
  'Travel',
  'Accommodation',
  'Vehicle Maintenance',
  'Office Supplies',
  'Medical',
  'Communication',
  'Other',
];

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final expenses = staff != null
        ? ref.watch(expenseListProvider(staff.id))
        : <ExpenseModel>[];

    final pending = expenses.where((e) => e.status == 'Pending').length;
    final approved = expenses.where((e) => e.status == 'Approved').length;
    final totalApproved = expenses
        .where((e) => e.status == 'Approved')
        .fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Work Expenses'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(text: 'Submit Expense'),
            Tab(text: pending > 0 ? 'My Claims ($pending)' : 'My Claims'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary strip
          Container(
            color: AppColors.primary.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _summaryChip('Pending', pending.toString(), AppColors.warning),
                const SizedBox(width: 10),
                _summaryChip(
                    'Approved', approved.toString(), AppColors.success),
                const Spacer(),
                Text(
                  'Reimbursed: OMR ${totalApproved.toStringAsFixed(3)}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _SubmitExpenseTab(
                  onSubmitted: () => _tabController.animateTo(1),
                ),
                _MyExpensesTab(expenses: expenses),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Text(label,
              style:
                  TextStyle(fontSize: 11, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}

// ── Submit Tab ────────────────────────────────────────────────────────────────

class _SubmitExpenseTab extends ConsumerStatefulWidget {
  final VoidCallback onSubmitted;
  const _SubmitExpenseTab({required this.onSubmitted});

  @override
  ConsumerState<_SubmitExpenseTab> createState() => _SubmitExpenseTabState();
}

class _SubmitExpenseTabState extends ConsumerState<_SubmitExpenseTab> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _expenseType = _expenseTypes.first;
  DateTime _expenseDate = DateTime.now();
  final List<XFile> _images = [];
  bool _submitting = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 5) {
      AppUtils.showSnackBar(context, 'Maximum 5 images per claim');
      return;
    }
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (file != null) setState(() => _images.add(file));
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.accent),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final staff = ref.read(currentStaffProvider);
    if (staff == null) return;

    setState(() => _submitting = true);

    final expense = ExpenseModel(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      staffId: staff.id,
      staffName: staff.name,
      staffCode: staff.staffCode,
      expenseType: _expenseType,
      amount: double.tryParse(_amountCtrl.text.trim()) ?? 0,
      expenseDate: _expenseDate,
      description: _descCtrl.text.trim(),
      receiptImages: const [],
      status: 'Pending',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(expenseNotifierProvider(staff.id).notifier).submit(
            expense,
            receiptFilePaths: _images.map((file) => file.path).toList(),
          );
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _submitting = false);
      AppUtils.showSnackBar(
        context,
        'Unable to submit expense claim right now.',
        isError: true,
      );
      return;
    }

    setState(() {
      _submitting = false;
      _amountCtrl.clear();
      _descCtrl.clear();
      _expenseType = _expenseTypes.first;
      _expenseDate = DateTime.now();
      _images.clear();
    });

    if (!mounted) return;
    AppUtils.showSnackBar(
        context, 'Expense claim submitted — pending approval');
    widget.onSubmitted();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type
            _label('Expense Type'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _expenseType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary),
                  items: _expenseTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => setState(() => _expenseType = v!),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Amount
            _label('Amount (OMR)'),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _amountCtrl,
              label: 'e.g. 12.500',
              prefixIcon: Icons.payments_outlined,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter amount';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a valid amount';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Date
            _label('Expense Date'),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expenseDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 90)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _expenseDate = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, size: 18),
                  border: OutlineInputBorder(),
                ),
                child: Text(AppUtils.formatDate(_expenseDate),
                    style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(height: 14),

            // Description
            _label('Description'),
            const SizedBox(height: 6),
            CustomTextField(
              controller: _descCtrl,
              label: 'Describe the expense...',
              prefixIcon: Icons.notes_outlined,
              maxLines: 3,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Add a description' : null,
            ),
            const SizedBox(height: 18),

            // Receipt photos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Receipt / Evidence Photos'),
                Text('${_images.length}/5',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 8),

            // Image grid
            if (_images.isNotEmpty) ...[
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    if (i == _images.length) {
                      return _addPhotoButton();
                    }
                    return _imageThumb(_images[i], i);
                  },
                ),
              ),
            ] else ...[
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.divider, style: BorderStyle.solid),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 32, color: AppColors.textHint),
                      SizedBox(height: 6),
                      Text('Tap to add receipt photos',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                      Text('Camera or Gallery • Max 5 images',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textHint)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_outlined),
                label: Text(_submitting ? 'Submitting…' : 'Submit Claim'),
                onPressed: _submitting ? null : _submit,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary));

  Widget _addPhotoButton() => GestureDetector(
        onTap: _showImageSourceDialog,
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline,
                  color: AppColors.primary, size: 28),
              SizedBox(height: 4),
              Text('Add More',
                  style: TextStyle(fontSize: 10, color: AppColors.primary)),
            ],
          ),
        ),
      );

  Widget _imageThumb(XFile file, int index) => Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.file(File(file.path),
                width: 100, height: 100, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => setState(() => _images.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      );
}

// ── My Expenses Tab ───────────────────────────────────────────────────────────

class _MyExpensesTab extends StatelessWidget {
  final List<ExpenseModel> expenses;
  const _MyExpensesTab({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 72, color: AppColors.textHint),
            SizedBox(height: 16),
            Text('No expense claims yet',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
            SizedBox(height: 6),
            Text('Submit your first claim from the other tab',
                style: TextStyle(color: AppColors.textHint, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: expenses.length,
      itemBuilder: (_, i) => _ExpenseCard(expense: expenses[i]),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  const _ExpenseCard({required this.expense});

  Color get _statusColor {
    switch (expense.status) {
      case 'Approved':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)
        ],
        border: Border(left: BorderSide(color: _statusColor, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_typeIcon(expense.expenseType),
                      size: 20, color: _statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(expense.expenseType,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(AppUtils.formatDate(expense.expenseDate),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('OMR ${expense.amount.toStringAsFixed(3)}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _statusColor)),
                    const SizedBox(height: 4),
                    StatusBadge(status: expense.status, fontSize: 10),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(expense.description,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),

            // Receipt images
            if (expense.receiptImages.isNotEmpty) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: expense.receiptImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 6),
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => _viewImage(ctx, expense.receiptImages[i]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _receiptPreview(expense.receiptImages[i]),
                    ),
                  ),
                ),
              ),
            ],

            if (expense.approvedBy != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 13, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('Approved by ${expense.approvedBy}',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.success,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
            if (expense.rejectionReason != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.cancel_outlined,
                      size: 13, color: AppColors.error),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Rejected: ${expense.rejectionReason}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text('Submitted: ${AppUtils.formatDate(expense.createdAt)}',
                style:
                    const TextStyle(fontSize: 10, color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  void _viewImage(BuildContext context, String path) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Receipt'),
          ),
          body: Center(
            child: InteractiveViewer(child: _fullScreenReceipt(path)),
          ),
        ),
      ),
    );
  }

  bool _isRemoteAsset(String path) {
    final uri = Uri.tryParse(path);
    if (uri == null) {
      return false;
    }
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Widget _receiptPreview(String path) {
    if (_isRemoteAsset(path)) {
      return Image.network(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _brokenReceiptPlaceholder(),
      );
    }

    return Image.file(
      File(path),
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _brokenReceiptPlaceholder(),
    );
  }

  Widget _fullScreenReceipt(String path) {
    if (_isRemoteAsset(path)) {
      return Image.network(
        path,
        errorBuilder: (_, __, ___) => _brokenReceiptPlaceholder(),
      );
    }

    return Image.file(
      File(path),
      errorBuilder: (_, __, ___) => _brokenReceiptPlaceholder(),
    );
  }

  Widget _brokenReceiptPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image_outlined),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Fuel':
        return Icons.local_gas_station_outlined;
      case 'Meals':
        return Icons.restaurant_outlined;
      case 'Travel':
        return Icons.directions_car_outlined;
      case 'Accommodation':
        return Icons.hotel_outlined;
      case 'Vehicle Maintenance':
        return Icons.build_outlined;
      case 'Office Supplies':
        return Icons.inventory_2_outlined;
      case 'Medical':
        return Icons.medical_services_outlined;
      case 'Communication':
        return Icons.phone_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }
}
