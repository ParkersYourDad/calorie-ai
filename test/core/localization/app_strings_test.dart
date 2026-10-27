import 'package:calorie_ai/core/localization/app_strings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppStrings', () {
    test('formats the selected date in English', () {
      const strings = AppStrings(Locale('en'));

      expect(
        strings.dateLabel(DateTime(2026, 10, 27), DateTime(2026, 10, 27)),
        'Today',
      );
      expect(
        strings.dateLabel(DateTime(2026, 10, 26), DateTime(2026, 10, 27)),
        'Yesterday',
      );
    });

    test('uses Arabic copy and digits for Arabic locale', () {
      const strings = AppStrings(Locale('ar'));

      expect(strings.number(1200), '١٢٠٠');
      expect(strings.parseInteger('١٢٠٠'), 1200);
      expect(strings.parseDecimal('١٢٫٥'), 12.5);
      expect(strings.parseDecimal('Infinity'), isNull);
      expect(strings.mealTypeLabel('breakfast'), 'الإفطار');
      expect(
        strings.dateLabel(DateTime(2026, 10, 27), DateTime(2026, 10, 27)),
        'اليوم',
      );
    });
  });
}
