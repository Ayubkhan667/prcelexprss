import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/models/branch_model.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/common/custom_text_field.dart';

class BranchManagementScreen extends ConsumerWidget {
  const BranchManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Branch Management')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBranchDialog(context, ref),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Branch'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: branches.length,
        itemBuilder: (ctx, i) => _branchCard(context, ref, branches[i]),
      ),
    );
  }

  Widget _branchCard(BuildContext context, WidgetRef ref, BranchModel branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_on,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(branch.branchName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      if (branch.address != null)
                        Text(branch.address!,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(status: branch.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _infoItem(Icons.my_location, 'Lat/Long',
                        '${branch.latitude.toStringAsFixed(4)}, ${branch.longitude.toStringAsFixed(4)}'),
                    _infoItem(Icons.radio_button_checked, 'Radius',
                        '${branch.allowedRadius.toStringAsFixed(0)} meters'),
                    if (branch.staffCount != null)
                      _infoItem(Icons.people_outline, 'Staff',
                          branch.staffCount.toString()),
                  ],
                ),
                if (branch.wifiSsid != null && branch.wifiSsid!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            branch.wifiSsid!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        onPressed: () => _showBranchDialog(
                          context,
                          ref,
                          branch: branch,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text('View Map'),
                        onPressed: () => _showBranchLocation(context, branch),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
              textAlign: TextAlign.center),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  void _showBranchDialog(BuildContext context, WidgetRef ref,
      {BranchModel? branch}) {
    final nameCtrl = TextEditingController(text: branch?.branchName ?? '');
    final latCtrl =
        TextEditingController(text: branch?.latitude.toString() ?? '');
    final lngCtrl =
        TextEditingController(text: branch?.longitude.toString() ?? '');
    final radiusCtrl =
        TextEditingController(text: branch?.allowedRadius.toString() ?? '100');
    final addressCtrl = TextEditingController(text: branch?.address ?? '');
    final wifiCtrl = TextEditingController(text: branch?.wifiSsid ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(branch != null ? 'Edit Branch' : 'Add Branch'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                  controller: nameCtrl,
                  label: 'Branch Name',
                  prefixIcon: Icons.business),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: addressCtrl,
                  label: 'Address',
                  prefixIcon: Icons.location_on_outlined),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: CustomTextField(
                          controller: latCtrl,
                          label: 'Latitude',
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: CustomTextField(
                          controller: lngCtrl,
                          label: 'Longitude',
                          keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 10),
              CustomTextField(
                  controller: radiusCtrl,
                  label: 'Allowed Radius (meters)',
                  prefixIcon: Icons.radio_button_checked,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              CustomTextField(
                controller: wifiCtrl,
                label: 'Office Wi-Fi SSID',
                prefixIcon: Icons.wifi_rounded,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final address = addressCtrl.text.trim();
              final latitude = double.tryParse(latCtrl.text.trim());
              final longitude = double.tryParse(lngCtrl.text.trim());
              final radius = double.tryParse(radiusCtrl.text.trim());
              final wifiSsid = wifiCtrl.text.trim();

              if (name.isEmpty ||
                  address.isEmpty ||
                  latitude == null ||
                  longitude == null ||
                  radius == null ||
                  wifiSsid.isEmpty) {
                AppUtils.showSnackBar(
                  context,
                  'Enter valid branch and office Wi-Fi details before saving.',
                  isError: true,
                );
                return;
              }

              try {
                final useRemote = ref.read(useRemoteDataProvider);
                await ref.read(branchRepositoryProvider).saveBranch(
                      branch: BranchModel(
                        id: branch?.id ??
                            (useRemote
                                ? ''
                                : 'b${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                        branchName: name,
                        latitude: latitude,
                        longitude: longitude,
                        allowedRadius: radius,
                        status: branch?.status ?? 'Active',
                        address: address,
                        staffCount: branch?.staffCount ?? 0,
                        wifiSsid: wifiSsid,
                      ),
                      isEdit: branch != null,
                    );
                if (!context.mounted || !ctx.mounted) {
                  return;
                }
                ref.read(mockDataRevisionProvider.notifier).state++;
                Navigator.pop(ctx);
                AppUtils.showSnackBar(
                  context,
                  branch != null ? 'Branch updated' : 'Branch added',
                );
              } catch (_) {
                AppUtils.showSnackBar(
                  context,
                  'Unable to save branch right now.',
                  isError: true,
                );
              }
            },
            child: Text(branch != null ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _showBranchLocation(BuildContext context, BranchModel branch) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(branch.branchName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch.address ?? 'No address available'),
            const SizedBox(height: 12),
            Text('Latitude: ${branch.latitude.toStringAsFixed(5)}'),
            Text('Longitude: ${branch.longitude.toStringAsFixed(5)}'),
            Text('Radius: ${branch.allowedRadius.toStringAsFixed(0)} meters'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
