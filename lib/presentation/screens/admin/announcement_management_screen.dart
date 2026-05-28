import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/providers/app_providers.dart';

class AnnouncementManagementScreen extends ConsumerStatefulWidget {
  const AnnouncementManagementScreen({super.key});

  @override
  ConsumerState<AnnouncementManagementScreen> createState() =>
      _AnnouncementManagementScreenState();
}

class _AnnouncementManagementScreenState
    extends ConsumerState<AnnouncementManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  String _targetRole = 'all';
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final announcements = ref.watch(announcementsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Announcements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Published'),
            Tab(text: 'Compose'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _publishedTab(announcements),
          _composeTab(),
        ],
      ),
    );
  }

  Widget _publishedTab(List<NotificationModel> announcements) {
    if (announcements.isEmpty) {
      return const Center(child: Text('No announcements published yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: announcements.length,
      itemBuilder: (_, index) {
        final item = announcements[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.campaign_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Target: ${item.targetRole}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(item.body),
              const SizedBox(height: 8),
              Text(
                AppUtils.formatDate(item.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _composeTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _targetRole,
          decoration: const InputDecoration(
            labelText: 'Audience',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All')),
            DropdownMenuItem(value: 'staff', child: Text('Staff')),
            DropdownMenuItem(value: 'supervisor', child: Text('Supervisor')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (value) => setState(() => _targetRole = value ?? 'all'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bodyCtrl,
          minLines: 5,
          maxLines: 7,
          decoration: const InputDecoration(
            labelText: 'Announcement body',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isPublishing ? null : _publish,
          icon: _isPublishing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_outlined),
          label: Text(_isPublishing ? 'Publishing...' : 'Publish'),
        ),
      ],
    );
  }

  Future<void> _publish() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty || body.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Title and body are required.',
        isError: true,
      );
      return;
    }

    setState(() => _isPublishing = true);
    try {
      await ref.read(hrOperationsRepositoryProvider).publishAnnouncement(
            title: title,
            body: body,
            targetRole: _targetRole,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      _titleCtrl.clear();
      _bodyCtrl.clear();
      if (!mounted) {
        return;
      }
      setState(() => _isPublishing = false);
      _tabController.animateTo(0);
      AppUtils.showSnackBar(context, 'Announcement published');
    } catch (_) {
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      setState(() => _isPublishing = false);
      AppUtils.showSnackBar(
        context,
        'Unable to publish announcement.',
        isError: true,
      );
    }
  }
}
