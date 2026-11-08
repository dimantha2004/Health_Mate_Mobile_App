import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/database/database_helper.dart';
import 'features/health_records/data/health_record_repository.dart';
import 'features/health_records/viewmodel/health_records_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependencies are created once here and passed down (View -> ViewModel ->
  // Repository -> DatabaseHelper), so each layer only knows the one below it.
  final repository = HealthRecordRepository(DatabaseHelper());

  runApp(
    ChangeNotifierProvider(
      create: (_) => HealthRecordsProvider(repository)..load(),
      child: const HealthMateApp(),
    ),
  );
}
