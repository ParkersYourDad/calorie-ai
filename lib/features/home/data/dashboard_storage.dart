import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../meals/domain/logged_meal.dart';

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.meals,
    required this.dailyGoal,
    required this.hasUnreadableData,
  });

  final List<LoggedMeal> meals;
  final int? dailyGoal;
  final bool hasUnreadableData;
}

class DashboardStorage {
  DashboardStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _mealsKey = 'calorie_ai.meals';
  static const _goalKey = 'calorie_ai.daily_goal';

  final SharedPreferencesAsync _preferences;

  Future<DashboardSnapshot> load() async {
    var hasUnreadableData = false;
    final savedGoal = await _preferences.getInt(_goalKey);
    final rawMeals = await _preferences.getString(_mealsKey);
    final meals = <LoggedMeal>[];
    var requiresMigration = false;

    if (rawMeals != null) {
      try {
        final decoded = jsonDecode(rawMeals);
        if (decoded is! List) {
          hasUnreadableData = true;
        } else {
          for (final item in decoded) {
            if (item is Map &&
                (item['loggedAt'] == null || item['type'] is int)) {
              requiresMigration = true;
            }
            final meal = LoggedMeal.tryParse(item);
            if (meal == null) {
              hasUnreadableData = true;
            } else {
              meals.add(meal);
            }
          }
        }
      } on FormatException {
        hasUnreadableData = true;
      }
    }

    if (requiresMigration && !hasUnreadableData) {
      await saveMeals(meals);
    }

    return DashboardSnapshot(
      meals: List.unmodifiable(meals),
      dailyGoal: savedGoal != null && savedGoal > 0 ? savedGoal : null,
      hasUnreadableData: hasUnreadableData,
    );
  }

  Future<void> saveMeals(List<LoggedMeal> meals) async {
    final payload = jsonEncode(meals.map((meal) => meal.toJson()).toList());
    await _preferences.setString(_mealsKey, payload);
  }

  Future<void> saveDailyGoal(int goal) => _preferences.setInt(_goalKey, goal);
}
