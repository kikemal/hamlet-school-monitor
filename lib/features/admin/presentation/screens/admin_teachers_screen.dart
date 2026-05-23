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

class AdminTeachersScreen extends ConsumerWidget {
  const AdminTeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminTeachersProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'Teachers',
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
              onRetry: () => ref.invalidate(adminTeachersProvider),
            ),
            data: (items) => items.isEmpty
                ? AdminEmptyState(
                    message: 'No teachers yet.',
                    actionLabel: 'Add teacher',
                    onAction: () => _showForm(context, ref),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final t = items[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade100,
                            child: Text(t.firstName[0]),
                          ),
                          title: Text(t.fullName),
                          subtitle: Text(
                            [
                              t.teacher.specialization ?? '—',
                              if (t.className != null) 'Class: ${t.className}',
                            ].join(' · '),
                          ),
                          trailing: PopupMenuButton(
                            onSelected: (v) async {
                              if (v == 'edit') {
                                await _showForm(context, ref, item: t);
                              }
                              if (v == 'delete') {
                                await _delete(context, ref, t);
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
    TeacherListItem? item,
  }) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final email = TextEditingController();
    final pass = TextEditingController();
    final first = TextEditingController(text: item?.firstName ?? '');
    final last = TextEditingController(text: item?.lastName ?? '');
    final spec = TextEditingController(text: item?.teacher.specialization ?? '');
    final phone = TextEditingController();

    final fields = <Widget>[
      if (item == null) ...[
        AdminValidatedField.email(email),
        AdminValidatedField.password(pass),
      ],
      AdminValidatedField.firstName(first),
      AdminValidatedField.lastName(last),
      AdminValidatedField(
        controller: spec,
        label: 'Specialization',
        validator: (v) => AppValidator.validateRequired(v, 'Specialization'),
      ),
      AdminValidatedField.phoneOptional(phone),
    ];

    final ok = await showAdminFormDialog(
      context: context,
      title: item == null ? 'Add teacher' : 'Edit teacher',
      fields: fields,
    );

    if (ok != true) {
      for (final c in [email, pass, first, last, spec, phone]) {
        c.dispose();
      }
      return;
    }

    try {
      final repo = ref.read(adminRepositoryProvider);
      if (item == null) {
        await repo.createTeacher(
          schoolId: schoolId,
          email: email.text.trim(),
          password: pass.text,
          firstName: first.text.trim(),
          lastName: last.text.trim(),
          specialization: spec.text.trim(),
          phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        );
      } else {
        await repo.updateTeacher(
          teacher: item.teacher,
          firstName: first.text.trim(),
          lastName: last.text.trim(),
          specialization: spec.text.trim(),
          phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        );
      }
      adminInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher saved')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      for (final c in [email, pass, first, last, spec, phone]) {
        c.dispose();
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    TeacherListItem item,
  ) async {
    final ok = await showAdminConfirmDialog(
      context: context,
      title: 'Delete teacher?',
      message: 'Remove ${item.fullName} permanently?',
    );
    if (!ok) return;
    await ref.read(adminRepositoryProvider).deleteTeacher(item.teacher.id);
    adminInvalidateAll(ref);
  }
}
