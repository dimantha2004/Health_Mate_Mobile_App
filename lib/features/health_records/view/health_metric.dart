import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../goals/data/daily_goals.dart';
import '../data/daily_summary.dart';
import '../data/health_record.dart';

enum HealthMetric {
  steps(
    label: 'Steps',
    unit: 'steps',
    icon: Icons.directions_walk_rounded,
    color: Color(0xFF2E7D32),
    max: 100000,
  ),
  calories(
    label: 'Calories burned',
    unit: 'kcal',
    icon: Icons.local_fire_department_rounded,
    color: Color(0xFFD32F2F),
    max: 10000,
  ),
  water(
    label: 'Water intake',
    unit: 'ml',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF1976D2),
    max: 10000,
  );

  const HealthMetric({
    required this.label,
    required this.unit,
    required this.icon,
    required this.color,
    required this.max,
  });

  final String label;
  final String unit;
  final IconData icon;
  final Color color;

  final int max;

  int ofRecord(HealthRecord record) => switch (this) {
        steps => record.steps,
        calories => record.calories,
        water => record.water,
      };

  int ofSummary(DailySummary summary) => switch (this) {
        steps => summary.steps,
        calories => summary.calories,
        water => summary.water,
      };

  int ofGoals(DailyGoals goals) => switch (this) {
        steps => goals.steps,
        calories => goals.calories,
        water => goals.water,
      };

  String format(int value) => '${formatNumber(value)} $unit';
}
