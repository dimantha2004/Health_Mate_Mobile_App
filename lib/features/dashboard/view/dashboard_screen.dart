import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/metric_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../goals/viewmodel/goals_provider.dart';
import '../../health_records/view/health_metric.dart';
import '../../health_records/viewmodel/health_records_provider.dart';
import 'widgets/weekly_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  static MetricCard _metricCard(HealthMetric metric, int value, int? goal) {
    final String? caption;
    if (goal == null) {
      caption = null;
    } else if (value >= goal) {
      caption = 'Goal of ${metric.format(goal)} reached!';
    } else {
      caption = '${(value * 100 / goal).floor()}% of ${metric.format(goal)} '
          'goal';
    }
    return MetricCard(
      icon: metric.icon,
      color: metric.color,
      label: metric.label,
      value: metric.format(value),
      progress: goal == null ? null : value / goal,
      caption: caption,
    );
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

    final goals = context.watch<GoalsProvider>().goals;
    final cards = [
      for (final metric in HealthMetric.values)
        _metricCard(metric, metric.ofSummary(summary),
            goals == null ? null : metric.ofGoals(goals)),
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
          const SizedBox(height: 16),
          WeeklyChart(days: provider.lastSevenDays, goals: goals),
        ],
      ),
    );
  }
}
