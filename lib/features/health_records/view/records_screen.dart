import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/state_views.dart';
import '../data/health_record.dart';
import '../viewmodel/health_records_provider.dart';
import 'record_form_screen.dart';
import 'widgets/date_filter_bar.dart';
import 'widgets/record_card.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  void _openEditor(BuildContext context, HealthRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecordFormScreen(record: record)),
    );
  }

  Future<bool> _confirmSwipeDelete(
      BuildContext context, HealthRecord record) async {
    if (!await confirmDelete(context) || !context.mounted) return false;
    final error =
        await context.read<HealthRecordsProvider>().deleteRecord(record.id!);
    if (context.mounted) {
      showMessage(context, error ?? 'Record deleted', isError: error != null);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordsProvider>();
    final records = provider.records;

    final Widget body;
    if (provider.loadError != null) {
      body = ErrorView(message: provider.loadError!, onRetry: provider.load);
    } else if (provider.isLoading && records.isEmpty) {
      body = const LoadingView();
    } else if (records.isEmpty) {
      body = provider.isFiltered
          ? EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No records for this date',
              message: 'Try another date, or clear the filter to see all '
                  'records.',
              action: TextButton(
                onPressed: provider.clearDateFilter,
                child: const Text('Clear filter'),
              ),
            )
          : const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'No health records yet',
              message: 'Tap "Add record" to log your steps, calories and '
                  'water intake.',
            );
    } else {
      body = RefreshIndicator.adaptive(
        onRefresh: provider.load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
          itemCount: records.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            if (index == 0) return _RecordCount(records.length);
            final record = records[index - 1];
            return Dismissible(
              key: ValueKey(record.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) => _confirmSwipeDelete(context, record),
              background: _DeleteBackground(),
              child: RecordCard(
                record: record,
                onTap: () => _openEditor(context, record),
              ),
            );
          },
        ),
      );
    }

    return Column(
      children: [
        const DateFilterBar(),
        Expanded(child: body),
      ],
    );
  }
}

class _RecordCount extends StatelessWidget {
  final int count;

  const _RecordCount(this.count);

  @override
  Widget build(BuildContext context) => Text(
        '$count ${count == 1 ? 'record' : 'records'}',
        style: Theme.of(context).textTheme.labelLarge,
      );
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(Icons.delete_outline_rounded, color: colors.onErrorContainer),
    );
  }
}
