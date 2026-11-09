import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/database/database_helper.dart';
import 'package:healthmate/features/health_records/data/health_record_repository.dart';
import 'package:healthmate/features/health_records/view/record_form_screen.dart';
import 'package:healthmate/features/health_records/viewmodel/health_records_provider.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpForm(WidgetTester tester) async {
    final provider =
        HealthRecordsProvider(HealthRecordRepository(DatabaseHelper()));
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: provider,
      child: const MaterialApp(home: RecordFormScreen()),
    ));
  }

  testWidgets('saving an empty form shows a required error for each metric',
      (tester) async {
    await pumpForm(tester);

    await tester.tap(find.text('Save record'));
    await tester.pump();

    expect(find.text('Steps is required'), findsOneWidget);
    expect(find.text('Calories burned is required'), findsOneWidget);
    expect(find.text('Water intake is required'), findsOneWidget);
  });

  testWidgets('all-zero values are rejected with a form-level message',
      (tester) async {
    await pumpForm(tester);

    for (final field in find.byType(TextFormField).evaluate().skip(1)) {
      await tester.enterText(find.byWidget(field.widget), '0');
    }
    await tester.tap(find.text('Save record'));
    await tester.pump();

    expect(find.text('Enter at least one activity value greater than 0.'),
        findsOneWidget);
  });

  testWidgets('a value above the maximum shows a range error', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextFormField).at(1), '200000');
    await tester.tap(find.text('Save record'));
    await tester.pump();

    expect(find.text('Steps must be 100,000 or less'), findsOneWidget);
  });
}
