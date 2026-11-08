import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/database_helper.dart';
import 'features/goals/data/goals_repository.dart';
import 'features/goals/viewmodel/goals_provider.dart';
import 'features/health_records/data/health_record_repository.dart';
import 'features/health_records/viewmodel/health_records_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependencies are created once here and passed down (View -> ViewModel ->
  // Repository -> DatabaseHelper), so each layer only knows the one below it.
  // Both repositories share one database connection.
  final database = DatabaseHelper();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              HealthRecordsProvider(HealthRecordRepository(database))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalsProvider(GoalsRepository(database))..load(),
        ),
      ],
      child: const HealthMateApp(),
    ),
  );
}
