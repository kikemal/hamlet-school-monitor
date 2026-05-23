import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../core/utils/app_validator.dart';
import '../../domain/models/admin_models.dart';
import '../providers/admin_providers.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';
import '../widgets/admin_validated_field.dart';

class AdminEventsScreen extends ConsumerStatefulWidget {
  const AdminEventsScreen({super.key});

  @override
  ConsumerState<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends ConsumerState<AdminEventsScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(adminEventsProvider);

    return Column(
      children: [
        AdminPageHeader(
          title: 'School calendar',
          subtitle: 'Holidays, exams, parent meetings',
          action: FilledButton.icon(
            onPressed: () => _addEvent(context),
            icon: const Icon(Icons.add),
            label: const Text('Add event'),
          ),
        ),
        Expanded(
          child: eventsAsync.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(adminEventsProvider),
            ),
            data: (items) {
              final map = <DateTime, List<String>>{};
              for (final e in items) {
                final day = DateTime(
                  e.event.eventDate.year,
                  e.event.eventDate.month,
                  e.event.eventDate.day,
                );
                map.putIfAbsent(day, () => []).add(e.event.title);
              }

              final filtered = _selected == null
                  ? items
                  : items.where((e) {
                      final d = e.event.eventDate;
                      return isSameDay(
                        DateTime(d.year, d.month, d.day),
                        _selected,
                      );
                    }).toList();

              return LayoutBuilder(
                builder: (context, constraints) {
                  final useRow = constraints.maxWidth > 700;
                  final calendar = TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2035),
                    focusedDay: _focused,
                    selectedDayPredicate: (d) => isSameDay(_selected, d),
                    onDaySelected: (s, f) => setState(() {
                      _selected = s;
                      _focused = f;
                    }),
                    eventLoader: (day) =>
                        map[DateTime(day.year, day.month, day.day)] ?? [],
                  );

                  final list = ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_selected != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Events on ${DateFormat.yMMMd().format(_selected!)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ...filtered.map((e) {
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              _eventIcon(e.event.title),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(e.event.title),
                            subtitle: Text(
                              DateFormat.yMMMd()
                                  .add_jm()
                                  .format(e.event.eventDate),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _editEvent(context, e),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    await ref
                                        .read(adminRepositoryProvider)
                                        .deleteEvent(e.event.id);
                                    adminInvalidateAll(ref);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );

                  if (useRow) {
                    return Row(
                      children: [
                        Expanded(flex: 2, child: calendar),
                        Expanded(flex: 3, child: list),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(height: 320, child: calendar),
                      Expanded(child: list),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _eventIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('holiday')) return Icons.beach_access;
    if (lower.contains('exam')) return Icons.quiz;
    if (lower.contains('parent')) return Icons.groups;
    return Icons.event;
  }

  Future<void> _addEvent(BuildContext context) async {
    final schoolId = ref.read(adminSchoolIdProvider);
    if (schoolId == null) return;

    final title = TextEditingController();
    final desc = TextEditingController();
    var date = DateTime.now().add(const Duration(hours: 9));

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Add calendar event'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminValidatedField.required(title, 'Title'),
                    AdminValidatedField(
                      controller: desc,
                      label: 'Description',
                      maxLines: 3,
                      validator: (v) => AppValidator.validateOptionalMaxLength(
                        v,
                        500,
                        fieldName: 'Description',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        DateFormat.yMMMd().add_jm().format(date),
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          initialDate: date,
                        );
                        if (pickedDate == null || !ctx.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(date),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            date = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
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
      title.dispose();
      desc.dispose();
      return;
    }

    await ref.read(adminRepositoryProvider).createEvent(
          schoolId: schoolId,
          title: title.text.trim(),
          description: desc.text.trim().isEmpty ? null : desc.text.trim(),
          eventDate: date,
        );
    adminInvalidateAll(ref);
    title.dispose();
    desc.dispose();
  }

  Future<void> _editEvent(BuildContext context, EventListItem item) async {
    final event = item.event;
    final title = TextEditingController(text: event.title);
    final desc = TextEditingController(text: event.description ?? '');
    var date = event.eventDate;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final formKey = GlobalKey<FormState>();
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Edit event'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AdminValidatedField.required(title, 'Title'),
                    AdminValidatedField(
                      controller: desc,
                      label: 'Description',
                      maxLines: 3,
                      validator: (v) => AppValidator.validateOptionalMaxLength(
                        v,
                        500,
                        fieldName: 'Description',
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        DateFormat.yMMMd().add_jm().format(date),
                      ),
                      trailing: const Icon(Icons.schedule),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          initialDate: date,
                        );
                        if (pickedDate == null || !ctx.mounted) return;
                        final pickedTime = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay.fromDateTime(date),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            date = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
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
      title.dispose();
      desc.dispose();
      return;
    }

    await ref.read(adminRepositoryProvider).updateEvent(
          id: event.id,
          title: title.text.trim(),
          description: desc.text.trim().isEmpty ? null : desc.text.trim(),
          eventDate: date,
        );
    adminInvalidateAll(ref);
    title.dispose();
    desc.dispose();
  }
}
