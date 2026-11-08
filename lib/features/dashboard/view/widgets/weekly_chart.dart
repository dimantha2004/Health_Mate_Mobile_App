import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../goals/data/daily_goals.dart';
import '../../../health_records/data/daily_summary.dart';
import '../../../health_records/view/health_metric.dart';

/// Bar chart of daily totals for the last 7 days, one metric at a time, with
/// a dashed line at the daily goal. Tap a bar to see its exact value.
class WeeklyChart extends StatefulWidget {
  final List<DailySummary> days;
  final DailyGoals? goals;

  const WeeklyChart({super.key, required this.days, this.goals});

  @override
  State<WeeklyChart> createState() => _WeeklyChartState();
}

class _WeeklyChartState extends State<WeeklyChart> {
  // Which metric is shown is purely visual, so it stays local widget state
  // rather than going into a provider.
  HealthMetric _metric = HealthMetric.steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metric = _metric;
    final values = [for (final day in widget.days) metric.ofSummary(day)];
    final goal = widget.goals == null ? null : metric.ofGoals(widget.goals!);
    final average = values.isEmpty
        ? 0
        : (values.reduce((a, b) => a + b) / values.length).round();
    final maxY = math.max(values.fold(0, math.max), goal ?? 0) * 1.15;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last 7 days', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<HealthMetric>(
                segments: [
                  for (final m in HealthMetric.values)
                    ButtonSegment(
                      value: m,
                      icon: Icon(m.icon),
                      label: Text(m.label.split(' ').first),
                    ),
                ],
                selected: {metric},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _metric = s.first),
              ),
            ),
            const SizedBox(height: 20),
            Semantics(
              label: '${metric.label} for the last 7 days: '
                  '${values.map(metric.format).join(', ')}',
              excludeSemantics: true,
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    maxY: maxY == 0 ? 1 : maxY,
                    barGroups: [
                      for (var i = 0; i < values.length; i++)
                        BarChartGroupData(x: i, barRods: [
                          BarChartRodData(
                            toY: values[i].toDouble(),
                            color: metric.color,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                          ),
                        ]),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(),
                      rightTitles: const AxisTitles(),
                      topTitles: const AxisTitles(),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              value.toInt() == widget.days.length - 1
                                  ? 'Today'
                                  : DateFormat('E')
                                      .format(widget.days[value.toInt()].date),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    extraLinesData: ExtraLinesData(horizontalLines: [
                      if (goal != null)
                        HorizontalLine(
                          y: goal.toDouble(),
                          color: metric.color.withValues(alpha: 0.6),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: metric.color),
                            labelResolver: (_) => 'Goal',
                          ),
                        ),
                    ]),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) =>
                            theme.colorScheme.inverseSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                            BarTooltipItem(
                          metric.format(rod.toY.round()),
                          TextStyle(color: theme.colorScheme.onInverseSurface),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Daily average: ${metric.format(average)}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
