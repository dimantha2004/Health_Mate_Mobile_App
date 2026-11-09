import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/formatters.dart';
import '../../viewmodel/health_records_provider.dart';

class DateFilterBar extends StatelessWidget {
  const DateFilterBar({super.key});

  Future<void> _pickDate(BuildContext context) async {
    final provider = context.read<HealthRecordsProvider>();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.filterFrom ?? today(),
      firstDate: DateTime(2000),
      lastDate: today(),
      helpText: 'Show records for',
    );
    if (picked != null) await provider.setDateFilter(picked, picked);
  }

  Future<void> _pickRange(BuildContext context) async {
    final provider = context.read<HealthRecordsProvider>();
    final from = provider.filterFrom;
    final to = provider.filterTo;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: today(),
      initialDateRange: from != null && to != null
          ? DateTimeRange(start: from, end: to)
          : null,
      helpText: 'Show records between',
    );
    if (picked != null) await provider.setDateFilter(picked.start, picked.end);
  }

  static String _label(DateTime from, DateTime to) => from == to
      ? formatMediumDate(from)
      : '${formatShortDate(from)} – ${formatLongDate(to)}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordsProvider>();
    final from = provider.filterFrom;
    final to = provider.filterTo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.event_rounded),
                  label: const Text('Pick date'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickRange(context),
                  icon: const Icon(Icons.date_range_rounded),
                  label: const Text('Date range'),
                ),
              ),
            ],
          ),
          if (from != null && to != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InputChip(
                avatar: const Icon(Icons.filter_alt_rounded, size: 18),
                label: Text(_label(from, to)),
                onDeleted: provider.clearDateFilter,
                deleteButtonTooltipMessage: 'Clear filter',
              ),
            ),
        ],
      ),
    );
  }
}
