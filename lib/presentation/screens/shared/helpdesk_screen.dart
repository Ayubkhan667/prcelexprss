import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_utils.dart';
import '../../../data/models/helpdesk_ticket_model.dart';
import '../../../data/providers/app_providers.dart';
import '../../../data/providers/auth_provider.dart';
import '../../widgets/common/status_badge.dart';

class HelpdeskScreen extends ConsumerStatefulWidget {
  final bool adminMode;
  const HelpdeskScreen({
    super.key,
    this.adminMode = false,
  });

  @override
  ConsumerState<HelpdeskScreen> createState() => _HelpdeskScreenState();
}

class _HelpdeskScreenState extends ConsumerState<HelpdeskScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = 'General';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.adminMode ? 2 : 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(currentStaffProvider);
    final tickets = ref.watch(
      helpdeskTicketsProvider(widget.adminMode ? null : staff?.id),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.adminMode ? 'Helpdesk Queue' : 'Helpdesk'),
        bottom: TabBar(
          controller: _tabController,
          tabs: widget.adminMode
              ? const [
                  Tab(text: 'Open'),
                  Tab(text: 'Resolved'),
                ]
              : const [
                  Tab(text: 'My Tickets'),
                  Tab(text: 'New Ticket'),
                ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.adminMode
            ? [
                _ticketList(
                  tickets
                      .where((item) =>
                          item.status != 'Resolved' && item.status != 'Closed')
                      .toList(),
                ),
                _ticketList(
                  tickets
                      .where((item) =>
                          item.status == 'Resolved' || item.status == 'Closed')
                      .toList(),
                ),
              ]
            : [
                _ticketList(tickets),
                _newTicketTab(),
              ],
      ),
    );
  }

  Widget _newTicketTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'General', child: Text('General')),
            DropdownMenuItem(value: 'Attendance', child: Text('Attendance')),
            DropdownMenuItem(value: 'Payroll', child: Text('Payroll')),
            DropdownMenuItem(value: 'App Support', child: Text('App Support')),
            DropdownMenuItem(value: 'HR', child: Text('HR')),
          ],
          onChanged: (value) => setState(() => _category = value ?? 'General'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _subjectCtrl,
          decoration: const InputDecoration(
            labelText: 'Subject',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageCtrl,
          minLines: 5,
          maxLines: 7,
          decoration: const InputDecoration(
            labelText: 'Describe the issue',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _isSubmitting ? null : _submitTicket,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.support_agent_outlined),
          label: Text(_isSubmitting ? 'Submitting...' : 'Submit Ticket'),
        ),
      ],
    );
  }

  Widget _ticketList(List<HelpdeskTicketModel> tickets) {
    if (tickets.isEmpty) {
      return const Center(child: Text('No tickets found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: tickets.length,
      itemBuilder: (_, index) => _ticketCard(tickets[index]),
    );
  }

  Widget _ticketCard(HelpdeskTicketModel ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.subject,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${ticket.staffName} • ${ticket.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(ticket.message),
            if (ticket.response != null && ticket.response!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Response: ${ticket.response}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Created: ${AppUtils.formatDate(ticket.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (widget.adminMode) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _adminAction(ticket, 'In Progress'),
                  _adminAction(ticket, 'Resolved'),
                  _adminAction(ticket, 'Closed'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _adminAction(HelpdeskTicketModel ticket, String status) {
    return OutlinedButton(
      onPressed: () => _respondToTicket(ticket, status),
      child: Text(status),
    );
  }

  Future<void> _submitTicket() async {
    final staff = ref.read(currentStaffProvider);
    if (staff == null) {
      return;
    }

    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    if (subject.isEmpty || message.isEmpty) {
      AppUtils.showSnackBar(
        context,
        'Subject and message are required.',
        isError: true,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ticket = HelpdeskTicketModel(
      id: 'helpdesk_${DateTime.now().millisecondsSinceEpoch}',
      staffId: staff.id,
      staffName: staff.name,
      staffCode: staff.staffCode,
      subject: subject,
      category: _category,
      message: message,
      status: 'Open',
      createdAt: DateTime.now(),
    );

    try {
      await ref.read(hrOperationsRepositoryProvider).addHelpdeskTicket(ticket);
      ref.read(mockDataRevisionProvider.notifier).state++;
      _subjectCtrl.clear();
      _messageCtrl.clear();
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      _tabController.animateTo(0);
      AppUtils.showSnackBar(context, 'Ticket submitted');
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _isSubmitting = false);
      AppUtils.showSnackBar(
        context,
        'Unable to submit ticket right now.',
        isError: true,
      );
    }
  }

  Future<void> _respondToTicket(
    HelpdeskTicketModel ticket,
    String status,
  ) async {
    final controller = TextEditingController(text: ticket.response ?? '');
    final response = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Ticket: $status'),
        content: TextField(
          controller: controller,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Add a response for the staff member',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (response == null) {
      return;
    }

    try {
      await ref.read(hrOperationsRepositoryProvider).updateHelpdeskTicketStatus(
            ticketId: ticket.id,
            status: status,
            response: response,
          );
      ref.read(mockDataRevisionProvider.notifier).state++;
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(context, 'Ticket updated');
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppUtils.showSnackBar(
        context,
        'Unable to update ticket right now.',
        isError: true,
      );
    }
  }
}
