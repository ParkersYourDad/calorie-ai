import 'package:calorie_ai/features/meals/domain/logged_meal.dart';
import 'package:calorie_ai/features/nutrition/domain/nutrition_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sums entered values and exposes incomplete coverage', () {
    final meals = [
      LoggedMeal(
        id: 1,
        name: 'Breakfast',
        calories: 350,
        type: MealType.breakfast,
        loggedAt: DateTime(2026, 10, 27, 8),
        proteinGrams: 20,
        fatGrams: 0,
      ),
      LoggedMeal(
        id: 2,
        name: 'Lunch',
        calories: 600,
        type: MealType.lunch,
        loggedAt: DateTime(2026, 10, 27, 13),
        proteinGrams: 35.5,
        fatGrams: 12,
      ),
      LoggedMeal(
        id: 3,
        name: 'Snack',
        calories: 150,
        type: MealType.snack,
        loggedAt: DateTime(2026, 10, 27, 16),
      ),
    ];

    final totals = NutritionTotals.fromMeals(meals);

    expect(totals.protein.value, 55.5);
    expect(totals.protein.recordedMeals, 2);
    expect(totals.protein.totalMeals, 3);
    expect(totals.protein.isPartial, isTrue);
    expect(totals.fat.value, 12);
    expect(totals.fat.isPartial, isTrue);
    expect(totals.carbohydrates.value, isNull);
    expect(totals.hasValues, isTrue);
  });

  test('preserves real zero and handles an empty day', () {
    final meal = LoggedMeal(
      id: 1,
      name: 'Water',
      calories: 0,
      type: MealType.snack,
      loggedAt: DateTime(2026, 10, 27),
      sugarGrams: 0,
    );

    final totals = NutritionTotals.fromMeals([meal]);
    expect(totals.sugar.value, 0);
    expect(totals.sugar.hasValue, isTrue);
    expect(totals.sugar.isPartial, isFalse);

    final empty = NutritionTotals.fromMeals(const []);
    expect(empty.hasValues, isFalse);
    expect(empty.protein.value, isNull);
  });
}
