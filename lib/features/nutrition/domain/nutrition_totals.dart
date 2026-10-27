import '../../meals/domain/logged_meal.dart';

class NutrientTotal {
  const NutrientTotal({
    required this.value,
    required this.recordedMeals,
    required this.totalMeals,
  });

  /// Null means no meal contains a recorded value for this nutrient.
  final double? value;
  final int recordedMeals;
  final int totalMeals;

  bool get hasValue => value != null;
  bool get isPartial => hasValue && recordedMeals < totalMeals;
}

class NutritionTotals {
  const NutritionTotals({
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.sugar,
    required this.fiber,
    required this.sodium,
  });

  final NutrientTotal protein;
  final NutrientTotal carbohydrates;
  final NutrientTotal fat;
  final NutrientTotal sugar;
  final NutrientTotal fiber;
  final NutrientTotal sodium;

  bool get hasValues => [
    protein,
    carbohydrates,
    fat,
    sugar,
    fiber,
    sodium,
  ].any((total) => total.hasValue);

  factory NutritionTotals.fromMeals(List<LoggedMeal> meals) {
    return NutritionTotals(
      protein: _total(meals, (meal) => meal.proteinGrams),
      carbohydrates: _total(meals, (meal) => meal.carbohydratesGrams),
      fat: _total(meals, (meal) => meal.fatGrams),
      sugar: _total(meals, (meal) => meal.sugarGrams),
      fiber: _total(meals, (meal) => meal.fiberGrams),
      sodium: _total(meals, (meal) => meal.sodiumMilligrams),
    );
  }
}

NutrientTotal _total(
  List<LoggedMeal> meals,
  double? Function(LoggedMeal meal) select,
) {
  var sum = 0.0;
  var recorded = 0;

  for (final meal in meals) {
    final value = select(meal);
    if (value == null) continue;
    sum += value;
    recorded++;
  }

  return NutrientTotal(
    value: recorded == 0 ? null : sum,
    recordedMeals: recorded,
    totalMeals: meals.length,
  );
}
