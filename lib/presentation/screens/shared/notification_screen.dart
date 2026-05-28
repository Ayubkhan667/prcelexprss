import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/notification_model.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String _typeFilter = '';

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final role = user?.role ?? 'staff';
    final staffId = role == 'staff' && user != null
        ? ref.watch(staffByUserIdProvider(user.id))?.id ??
            ref.watch(currentStaffProvider)?.id
        : null;

    var notifications = ref.watch(notificationsProvider);
    if (_typeFilter.isNotEmpty) {
      notifications =
          notifications.where((n) => n.type == _typeFilter).toList();
    }

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: unreadCount == 0
                ? null
                : () async {
                    try {
                      await ref.read(hrOperationsRepositoryProvider).markNotificationsAsRead(
                            targetRole: role,
                            staffId: staffId,
                            type: _typeFilter.isEmpty ? null : _typeFilter,
                          );
                      ref.read(mockDataRevisionProvider.notifier).state++;
                    } catch (_) {
                      if (!context.mounted) {
                        return;
                      }
                      AppUtils.showSnackBar(
                        context,
                        'Unable to mark notifications as read.',
                        isError: true,
                      );
                    }
                  },
            child: const Text('Mark All Read',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeFilters(role),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: notifications.length,
                    itemBuilder: (_, i) => _notifCard(notifications[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters(String role) {
    final types = _typesForRole(role);
    return Container(
      height: 48,
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _filterChip('', 'All'),
          ...types.map((t) => _filterChip(t['value']!, t['label']!)),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _typeFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _typeFilter = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _notifCard(NotificationModel n) {
    final iconData = _iconForType(n.type);
    final color = _colorForType(n.type);
    final isUnread = !n.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        if (!isUnread) {
          return;
        }

        try {
          await ref.read(hrOperationsRepositoryProvider).markNotificationAsRead(n.id);
          ref.read(mockDataRevisionProvider.notifier).state++;
        } catch (_) {
          if (!mounted) {
            return;
          }
          AppUtils.showSnackBar(
            context,
            'Unable to update notification.',
            isError: true,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primarySurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isUnread
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(iconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            size: 11, color: AppColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(n.createdAt),
                          style: const TextStyle(
                              color: AppColors.textHint, fontSize: 11),
                        ),
                        if (n.staffName != null) ...[
                          const SizedBox(width: 10),
                          Icon(Icons.person_outline,
                              size: 11, color: AppColors.textHint),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              n.staffName!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: AppColors.textHint, fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: AppColors.textHint),
          const SizedBox(height: 12),
          const Text('No notifications',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('You\'re all caught up!',
              style: TextStyle(color: AppColors.textHint, fontSize: 13)),
        ],
      ),
    );
  }

  List<Map<String, String>> _typesForRole(String role) {
    if (role == 'admin' || role == 'supervisor') {
      return [
        {'value': 'checkin', 'label': 'Check-In'},
        {'value': 'late', 'label': 'Late'},
        {'value': 'missing_checkout', 'label': 'Missing CO'},
        {'value': 'fake_gps', 'label': 'Fake GPS'},
        {'value': 'location_alert', 'label': 'Location'},
        {'value': 'task', 'label': 'Tasks'},
        {'value': 'leave', 'label': 'Leave'},
      ];
    }
    return [
      {'value': 'checkin', 'label': 'Attendance'},
      {'value': 'leave', 'label': 'Leave'},
      {'value': 'salary', 'label': 'Salary'},
      {'value': 'loan', 'label': 'Loan'},
      {'value': 'overtime', 'label': 'Overtime'},
      {'value': 'task', 'label': 'Tasks'},
    ];
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'checkin':
        return Icons.login;
      case 'checkout':
        return Icons.logout;
      case 'late':
        return Icons.alarm;
      case 'missing_checkout':
        return Icons.warning_amber;
      case 'leave':
        return Icons.event_available;
      case 'overtime':
        return Icons.more_time;
      case 'salary':
        return Icons.payments;
      case 'loan':
        return Icons.account_balance;
      case 'task':
        return Icons.assignment;
      case 'location_alert':
        return Icons.location_off;
      case 'fake_gps':
        return Icons.gps_off;
      default:
        return Icons.notifications;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'late':
      case 'missing_checkout':
        return AppColors.warning;
      case 'fake_gps':
      case 'location_alert':
        return AppColors.error;
      case 'salary':
      case 'overtime':
        return AppColors.success;
      case 'loan':
        return AppColors.accent;
      case 'task':
        return AppColors.primary;
      case 'leave':
        return AppColors.onLeave;
      default:
        return AppColors.primary;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}
