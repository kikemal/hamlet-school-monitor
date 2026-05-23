import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/app_validator.dart';
import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminFeesScreen extends ConsumerWidget {
  const AdminFeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feesAsync = ref.watch(adminFeesProvider);
    final paymentsAsync = ref.watch(adminFeePaymentsProvider);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          AdminPageHeader(
            title: 'School fees',
            subtitle: 'Fee structures and payment tracking',
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _recordPayment(context, ref),
                  icon: const Icon(Icons.payment),
                  label: const Text('Record payment'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _createFee(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('New fee'),
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Fee structures'),
              Tab(text: 'Payments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                feesAsync.when(
                  loading: () => const AdminLoadingView(),
                  error: (e, _) => AdminErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(adminFeesProvider),
                  ),
                  data: (fees) => fees.isEmpty
                      ? const Center(child: Text('No fee structures yet.'))
                      : ListView.builder(
                          itemCount: fees.length,
                          itemBuilder: (_, i) {
                            final f = fees[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(f.fee.description),
                                subtitle: Text(
                                  'Due ${DateFormat.yMMMd().format(f.fee.dueDate)} · '
                                  'Paid ${f.totalPaid.toStringAsFixed(0)} / ${f.fee.amount.toStringAsFixed(0)}',
                                ),
                                trailing: Chip(
                                  label: Text(f.isPaid ? 'Paid' : f.latestStatus),
                                  backgroundColor:
                                      f.isPaid ? Colors.green.shade100 : null,
                                ),
                                onTap: () => _editFee(context, ref, f),
                                onLongPress: () => _deleteFee(context, ref, f),
                              ),
                            );
                          },
                        ),
                ),
                paymentsAsync.when(
                  loading: () => const AdminLoadingView(),
                  error: (e, _) => AdminErrorView(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(adminFeePaymentsProvider),
                  ),
                  data: (payments) => payments.isEmpty
                      ? const Center(child: Text('No payments recorded yet.'))
                      : ListView.builder(
                          itemCount: payments.length,
                          itemBuilder: (_, i) {
                            final p = payments[i];
                            return ListTile(
                              leading: Icon(
                                p.payment.status == 'completed'
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: p.payment.status == 'completed'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text(p.feeDescription),
                              subtitle: Text(p.parentName),
                              trailing: Text(
                                '${p.payment.amountPaid.toStringAsFixed(0)} (${p.payment.status})',
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createFee(BuildContext context, WidgetRef ref) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final desc = TextEditingController();
    final amount = TextEditingController();
    var dueDate = DateTime.now().add(const Duration(days: 30));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Create fee structure'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminValidatedField.required(desc, 'Description'),
                    AdminValidatedField.amount(amount),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Due: ${DateFormat.yMMMd().format(dueDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 2)),
                          initialDate: dueDate,
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Create'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) {
      desc.dispose();
      amount.dispose();
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).createFee(
            schoolId: schoolId,
            amount: double.parse(amount.text.trim()),
            description: desc.text.trim(),
            dueDate: dueDate,
          );
      adminInvalidateAll(ref);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      desc.dispose();
      amount.dispose();
    }
  }

  Future<void> _editFee(
    BuildContext context,
    WidgetRef ref,
    FeeWithStatus feeWithStatus,
  ) async {
    final fee = feeWithStatus.fee;
    final desc = TextEditingController(text: fee.description);
    final amount = TextEditingController(text: fee.amount.toString());
    var dueDate = fee.dueDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Edit fee structure'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminValidatedField.required(desc, 'Description'),
                    AdminValidatedField.amount(amount),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Due: ${DateFormat.yMMMd().format(dueDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365 * 2)),
                          initialDate: dueDate,
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(ctx, true);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );

    if (ok != true) {
      desc.dispose();
      amount.dispose();
      return;
    }

    await ref.read(adminRepositoryProvider).updateFee(
          id: fee.id,
          amount: double.parse(amount.text.trim()),
          description: desc.text.trim(),
          dueDate: dueDate,
        );
    adminInvalidateAll(ref);
    desc.dispose();
    amount.dispose();
  }

  Future<void> _deleteFee(
    BuildContext context,
    WidgetRef ref,
    FeeWithStatus f,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete fee?',
      message: 'Remove "${f.fee.description}"?',
    );
    if (!ok) return;
    await ref.read(adminRepositoryProvider).deleteFee(f.fee.id);
    adminInvalidateAll(ref);
  }

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final fees = await ref.read(adminFeesProvider.future);
    final parents = await ref.read(adminParentsProvider.future);
    if (fees.isEmpty || parents.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Create at least one fee and one parent first.'),
          ),
        );
      }
      return;
    }

    String? feeId = fees.first.fee.id;
    String? parentId = parents.first.id;
    var status = 'completed';
    final amount = TextEditingController();
    final method = TextEditingController();

    final ok = await showAdminFormDialog(
      context: context,
      title: 'Record payment',
      confirmLabel: 'Record',
      fields: [
        DropdownButtonFormField<String>(
          value: feeId,
          decoration: const InputDecoration(
            labelText: 'Fee',
            border: OutlineInputBorder(),
          ),
          items: fees
              .map(
                (f) => DropdownMenuItem(
                  value: f.fee.id,
                  child: Text(
                    '${f.fee.description} (${f.fee.amount.toStringAsFixed(0)})',
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => feeId = v,
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: parentId,
          decoration: const InputDecoration(
            labelText: 'Parent',
            border: OutlineInputBorder(),
          ),
          items: parents
              .map(
                (p) => DropdownMenuItem(
                  value: p.id,
                  child: Text(p.fullName),
                ),
              )
              .toList(),
          onChanged: (v) => parentId = v,
        ),
        const SizedBox(height: 12),
        AdminValidatedField.amount(amount),
        AdminValidatedField(
          controller: method,
          label: 'Payment method',
          validator: (v) => AppValidator.validateRequired(v, 'Payment method'),
        ),
        DropdownButtonFormField<String>(
          value: status,
          decoration: const InputDecoration(
            labelText: 'Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'failed', child: Text('Failed')),
          ],
          onChanged: (v) {
            if (v != null) status = v;
          },
        ),
      ],
    );

    if (ok != true || feeId == null || parentId == null) {
      amount.dispose();
      method.dispose();
      return;
    }

    try {
      await ref.read(adminRepositoryProvider).recordPayment(
            feeId: feeId!,
            parentId: parentId!,
            amountPaid: double.parse(amount.text.trim()),
            status: status,
            paymentMethod: method.text.trim(),
          );
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      amount.dispose();
      method.dispose();
    }
  }
}
