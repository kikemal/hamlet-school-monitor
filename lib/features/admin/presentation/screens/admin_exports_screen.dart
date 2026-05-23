import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_providers.dart';
import '../widgets/admin_error_view.dart';
import '../widgets/admin_loading_view.dart';
import '../widgets/admin_page_header.dart';

class AdminExportsScreen extends ConsumerWidget {
  const AdminExportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportAsync = ref.watch(adminExportDataProvider);

    return Column(
      children: [
        const AdminPageHeader(
          title: 'Export data',
          subtitle: 'Download attendance and results as CSV',
        ),
        Expanded(
          child: exportAsync.when(
            loading: () => const AdminLoadingView(),
            error: (e, _) => AdminErrorView(message: e.toString()),
            data: (data) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ExportCard(
                    title: 'Attendance',
                    count: data.attendance.length,
                    onExport: () {
                      final csv = ref
                          .read(adminRepositoryProvider)
                          .attendanceToCsv(data.attendance);
                      _copyCsv(context, csv, 'Attendance CSV copied to clipboard');
                    },
                  ),
                  const SizedBox(height: 16),
                  _ExportCard(
                    title: 'Results',
                    count: data.results.length,
                    onExport: () {
                      final csv =
                          ref.read(adminRepositoryProvider).resultsToCsv(data.results);
                      _copyCsv(context, csv, 'Results CSV copied to clipboard');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _copyCsv(BuildContext context, String csv, String message) {
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ExportCard extends StatelessWidget {
  const _ExportCard({
    required this.title,
    required this.count,
    required this.onExport,
  });

  final String title;
  final int count;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text('$count records'),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: onExport,
              icon: const Icon(Icons.download),
              label: const Text('Export CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
