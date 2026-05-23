import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../homework/presentation/widgets/homework_card.dart';
import '../../domain/models/student_models.dart';
import '../providers/student_providers.dart';
import '../widgets/student_error_view.dart';
import '../widgets/student_loading_view.dart';
import '../widgets/student_page_header.dart';

class StudentHomeworkScreen extends ConsumerWidget {
  const StudentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeworkAsync = ref.watch(studentHomeworkProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StudentPageHeader(
            title: 'Homework',
            subtitle: 'View assignments and submit your work',
          ),
        ),
        homeworkAsync.when(
          loading: () => const SliverToBoxAdapter(child: StudentLoadingView()),
          error: (e, _) => SliverToBoxAdapter(
            child: StudentErrorView(
              message: e.toString(),
              onRetry: () => ref.invalidate(studentHomeworkProvider),
            ),
          ),
          data: (homeworkList) {
            if (homeworkList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Center(
                    child: Text(
                      'No homework assigned',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            final pendingCount =
                homeworkList.where((h) => !h.isSubmitted).length;

            return SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatColumn(
                              label: 'Pending',
                              value: '$pendingCount',
                            ),
                            _StatColumn(
                              label: 'Submitted',
                              value: '${homeworkList.length - pendingCount}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: homeworkList.length,
                      itemBuilder: (context, index) {
                        final hw = homeworkList[index];
                        return HomeworkCard.fromStudent(
                          hw,
                          onTap: () => _openDetail(context, ref, hw),
                          trailing: hw.isSubmitted
                              ? null
                              : FilledButton.tonal(
                                  onPressed: () =>
                                      _showSubmitDialog(context, ref, hw),
                                  child: const Text('Submit'),
                                ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _openDetail(
    BuildContext context,
    WidgetRef ref,
    StudentHomeworkWithSubmission hw,
  ) {
    if (!hw.isSubmitted) {
      _showSubmitDialog(context, ref, hw);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: HomeworkCard.fromStudent(hw),
      ),
    );
  }

  Future<void> _showSubmitDialog(
    BuildContext context,
    WidgetRef ref,
    StudentHomeworkWithSubmission hw,
  ) async {
    final auth = ref.read(authProvider);
    final studentId = auth.profile?.id;
    if (studentId == null) return;

    final textCtrl = TextEditingController();
    Uint8List? fileBytes;
    String? fileName;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Submit — ${hw.homework.title}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Your answer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.upload_file),
                  title: Text(fileName ?? 'Attach file (optional)'),
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      withData: true,
                    );
                    if (result != null && result.files.single.bytes != null) {
                      setState(() {
                        fileBytes = result.files.single.bytes;
                        fileName = result.files.single.name;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );

    if (ok != true) {
      textCtrl.dispose();
      return;
    }

    try {
      await ref.read(studentRepositoryProvider).submitHomework(
            homeworkId: hw.homework.id,
            studentId: studentId,
            submissionText: textCtrl.text.trim().isEmpty ? null : textCtrl.text.trim(),
            fileBytes: fileBytes,
            fileName: fileName,
          );
      ref.invalidate(studentHomeworkProvider);
      studentInvalidateAll(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Homework submitted')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      textCtrl.dispose();
    }
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 24.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
