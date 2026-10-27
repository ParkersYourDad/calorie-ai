import 'package:calorie_ai/features/meals/domain/logged_meal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggedMeal', () {
    test('round-trips a saved meal', () {
      final loggedAt = DateTime(2026, 10, 27, 12, 30);
      final meal = LoggedMeal(
        id: 42,
        name: 'Oatmeal',
        calories: 320,
        type: MealType.breakfast,
        loggedAt: DateTime(2026, 10, 27, 12, 30),
        proteinGrams: 25.5,
        carbohydratesGrams: 40,
        fatGrams: 8.25,
        sugarGrams: 0,
        fiberGrams: 4,
        sodiumMilligrams: 1200,
      );

      final restored = LoggedMeal.tryParse(meal.toJson());

      expect(restored, isNotNull);
      expect(restored!.id, 42);
      expect(restored.name, 'Oatmeal');
      expect(restored.calories, 320);
      expect(restored.type, MealType.breakfast);
      expect(restored.loggedAt, loggedAt);
      expect(restored.proteinGrams, 25.5);
      expect(restored.carbohydratesGrams, 40);
      expect(restored.fatGrams, 8.25);
      expect(restored.sugarGrams, 0);
      expect(restored.fiberGrams, 4);
      expect(restored.sodiumMilligrams, 1200);
    });

    test('reads the original integer meal type format', () {
      final restored = LoggedMeal.tryParse({
        'id': 7,
        'name': 'Soup',
        'calories': 180,
        'type': MealType.lunch.index,
      });

      expect(restored, isNotNull);
      expect(restored!.type, MealType.lunch);
      expect(restored.name, 'Soup');
      expect(restored.calories, 180);
      expect(restored.proteinGrams, isNull);
      expect(restored.sodiumMilligrams, isNull);
    });

    test('rejects invalid persisted records', () {
      expect(LoggedMeal.tryParse(null), isNull);
      expect(
        LoggedMeal.tryParse({
          'id': 'not-an-id',
          'name': 'Food',
          'calories': 100,
          'type': 'lunch',
        }),
        isNull,
      );
      expect(
        LoggedMeal.tryParse({
          'id': 1,
          'name': 'Food',
          'calories': -1,
          'type': 'lunch',
        }),
        isNull,
      );
    });
  });

  test('calendar day comparison ignores time of day', () {
    expect(
      isSameCalendarDay(DateTime(2026, 10, 27, 8), DateTime(2026, 10, 27, 22)),
      isTrue,
    );
    expect(
      isSameCalendarDay(DateTime(2026, 10, 27), DateTime(2026, 10, 28)),
      isFalse,
    );
  });
}
