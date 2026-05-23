import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_validator.dart';
import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_empty_state.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_form_dialog.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminParentsScreen extends ConsumerWidget {
  const AdminParentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminParentsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Parents',
          action: FilledButton.icon(
            onPressed: () => _showForm(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminParentsProvider),
            ),
            data: (items) => items.isEmpty
                ? AdminEmptyState(
                    message: 'No parents yet.',
                    actionLabel: 'Add parent',
                    onAction: () => _showForm(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final p = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange.shade100,
                            child: const Icon(Icons.family_restroom, size: 20),
                          ),
                          title: Text(p.fullName),
                          subtitle: Text(
                            '${p.childrenCount} children · ${p.phone ?? 'No phone'}',
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _showForm(context, ref, item: p);
                              }
                              if (v == 'delete') {
                                await _delete(context, ref, p);
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _showForm(
    BuildContext context,
    WidgetRef ref, {
    ParentListItem? item,
  }) async {
    final email = TextEditingController();
    final pass = TextEditingController();
    final first = TextEditingController(text: item?.firstName ?? '');
    final last = TextEditingController(text: item?.lastName ?? '');
    final address = TextEditingController(text: item?.address ?? '');
    final emergency = TextEditingController(text: item?.emergencyContact ?? '');
    final phone = TextEditingController(text: item?.phone ?? '');

    final fields = <Widget>[
      if (item == null) ...[
        AdminValidatedField.email(email),
        AdminValidatedField.password(pass),
      ],
      AdminValidatedField.firstName(first),
      AdminValidatedField.lastName(last),
      AdminValidatedField.phoneOptional(phone),
      AdminValidatedField(
        controller: address,
        label: 'Address',
        validator: (v) =>
            AppValidator.validateOptionalMaxLength(v, 200, fieldName: 'Address'),
      ),
      AdminValidatedField(
        controller: emergency,
        label: 'Emergency contact',
        validator: (v) => AppValidator.validateOptionalMaxLength(
          v,
          100,
          fieldName: 'Emergency contact',
        ),
      ),
    ];

    final ok = await showAdminFormDialog(
      context: context,
      title: item == null ? 'Add parent' : 'Edit parent',
      fields: fields,
    );

    if (ok != true) {
      for (final c in [email, pass, first, last, address, emergency, phone]) {
        c.dispose();
      }
      return;
    }

    try {
      final repo = ref.read(adminRepositoryProvider);
      if (item == null) {
        await repo.createParent(
          email: email.text.trim(),
          password: pass.text,
          firstName: first.text.trim(),
          lastName: last.text.trim(),
          address: address.text.trim().isEmpty ? null : address.text.trim(),
          emergencyContact:
              emergency.text.trim().isEmpty ? null : emergency.text.trim(),
          phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        );
      } else {
        await repo.updateParent(
          id: item.id,
          firstName: first.text.trim(),
          lastName: last.text.trim(),
          address: address.text.trim().isEmpty ? null : address.text.trim(),
          emergencyContact:
              emergency.text.trim().isEmpty ? null : emergency.text.trim(),
          phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        );
      }
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      for (final c in [email, pass, first, last, address, emergency, phone]) {
        c.dispose();
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ParentListItem item,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete parent?',
      message: 'Remove ${item.fullName}? Students linked to this parent will be unlinked.',
    );
    if (!ok) return;
    await ref.read(adminRepositoryProvider).deleteParent(item.id);
    adminInvalidateAll(ref);
  }
}
