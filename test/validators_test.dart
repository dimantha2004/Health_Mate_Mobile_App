import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/utils/formatters.dart';
import 'package:healthmate/core/utils/validators.dart';

void main() {
  group('validateWholeNumber', () {
    String? check(String? v) =>
        validateWholeNumber(v, label: 'Steps', max: 100000);

    test('accepts 0, the maximum and surrounding spaces', () {
      expect(check('0'), isNull);
      expect(check('100000'), isNull);
      expect(check(' 7850 '), isNull);
    });

    test('rejects empty input', () {
      expect(check(null), 'Steps is required');
      expect(check('   '), 'Steps is required');
    });

    test('rejects text and decimals', () {
      expect(check('abc'), 'Enter a whole number');
      expect(check('12.5'), 'Enter a whole number');
    });

    test('rejects negative and too-large values', () {
      expect(check('-1'), 'Steps cannot be negative');
      expect(check('100001'), 'Steps must be 100,000 or less');
    });
  });

  group('validateRecordDate', () {
    test('accepts today and past dates', () {
      expect(validateRecordDate(today()), isNull);
      expect(validateRecordDate(DateTime(2026, 1, 1)), isNull);
    });

    test('rejects missing and future dates', () {
      expect(validateRecordDate(null), 'Select a date');
      expect(validateRecordDate(today().add(const Duration(days: 1))),
          'Date cannot be in the future');
    });
  });
}
