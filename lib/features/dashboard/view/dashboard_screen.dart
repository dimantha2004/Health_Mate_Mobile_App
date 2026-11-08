import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../health_records/view/health_metric.dart';
import '../../health_records/viewmodel/health_records_provider.dart';

/// Summary of today's activity: the totals of every record dated today.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HealthRecordsProvider>();
    final summary = provider.todaySummary;
    final theme = Theme.of(context);

    if (summary == null) {
      return provider.loadError != null
          ? ErrorView(message: provider.loadError!, onRetry: provider.load)
          : const LoadingView();
    }

    final cards = [
      for (final metric in HealthMetric.values)
        MetricCard(
          icon: metric.icon,
          color: metric.color,
          label: metric.label,
          value: metric.format(metric.ofSummary(summary)),
        ),
    ];

    return RefreshIndicator.adaptive(
      onRefresh: provider.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
        children: [
          Text(_greeting(), style: theme.textTheme.titleMedium),
          Text('Today – ${formatLongDate(summary.date)}',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // One column on phones; three side by side on wide screens.
          LayoutBuilder(
            builder: (context, constraints) => constraints.maxWidth >= 600
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final card in cards) ...[
                        Expanded(child: card),
                        if (card != cards.last) const SizedBox(width: 12),
                      ],
                    ],
                  )
                : Column(
                    children: [
                      for (final card in cards) ...[
                        card,
                        if (card != cards.last) const SizedBox(height: 12),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Card(
            color: theme.colorScheme.secondaryContainer,
            child: ListTile(
              leading: Icon(
                summary.isEmpty
                    ? Icons.info_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              title: Text(
                summary.isEmpty
                    ? 'Nothing logged yet today'
                    : '${summary.entryCount} '
                        '${summary.entryCount == 1 ? 'entry' : 'entries'} '
                        'logged today',
              ),
              subtitle: Text(summary.isEmpty
                  ? 'Tap "Add record" to log your first activity.'
                  : 'Totals include every record dated today.'),
            ),
          ),
        ],
      ),
    );
  }
}
