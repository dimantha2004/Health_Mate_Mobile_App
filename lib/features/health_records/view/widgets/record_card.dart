import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/health_record.dart';
import '../health_metric.dart';

class RecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onTap;

  const RecordCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _DateBadge(date: record.date),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatMediumDate(record.date),
                        style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        for (final metric in HealthMetric.values)
                          _MetricValue(
                              metric: metric, value: metric.ofRecord(record)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: theme.colorScheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final DateTime date;

  const _DateBadge({required this.date});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('${date.day}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onPrimaryContainer)),
          Text(DateFormat('MMM').format(date).toUpperCase(),
              style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer)),
        ],
      ),
    );
  }
}

class _MetricValue extends StatelessWidget {
  final HealthMetric metric;
  final int value;

  const _MetricValue({required this.metric, required this.value});

  @override
  Widget build(BuildContext context) => Semantics(
        label: '${metric.label}: ${metric.format(value)}',
        excludeSemantics: true,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(metric.icon, size: 16, color: metric.color),
            const SizedBox(width: 4),
            Text(metric.format(value),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
}
