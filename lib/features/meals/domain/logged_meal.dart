enum MealType { breakfast, lunch, dinner, snack }

class LoggedMeal {
  const LoggedMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.type,
    required this.loggedAt,
    this.proteinGrams,
    this.carbohydratesGrams,
    this.fatGrams,
    this.sugarGrams,
    this.fiberGrams,
    this.sodiumMilligrams,
  });

  final int id;
  final String name;
  final int calories;
  final MealType type;
  final DateTime loggedAt;

  /// Null means the user has not entered a value; zero is a real value.
  final double? proteinGrams;
  final double? carbohydratesGrams;
  final double? fatGrams;
  final double? sugarGrams;
  final double? fiberGrams;
  final double? sodiumMilligrams;

  bool get hasNutritionDetails =>
      proteinGrams != null ||
      carbohydratesGrams != null ||
      fatGrams != null ||
      sugarGrams != null ||
      fiberGrams != null ||
      sodiumMilligrams != null;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'type': type.name,
    'loggedAt': loggedAt.toIso8601String(),
    if (proteinGrams != null) 'proteinGrams': proteinGrams!,
    if (carbohydratesGrams != null) 'carbohydratesGrams': carbohydratesGrams!,
    if (fatGrams != null) 'fatGrams': fatGrams!,
    if (sugarGrams != null) 'sugarGrams': sugarGrams!,
    if (fiberGrams != null) 'fiberGrams': fiberGrams!,
    if (sodiumMilligrams != null) 'sodiumMilligrams': sodiumMilligrams!,
  };

  static LoggedMeal? tryParse(Object? value) {
    if (value is! Map) return null;

    final idValue = value['id'];
    final nameValue = value['name'];
    final caloriesValue = value['calories'];
    final typeValue = value['type'];

    if (idValue is! num ||
        nameValue is! String ||
        nameValue.trim().isEmpty ||
        caloriesValue is! num ||
        caloriesValue < 0 ||
        caloriesValue > 100000) {
      return null;
    }

    final MealType? parsedType;
    if (typeValue is String) {
      parsedType = MealType.values
          .where((type) => type.name == typeValue)
          .firstOrNull;
    } else if (typeValue is int &&
        typeValue >= 0 &&
        typeValue < MealType.values.length) {
      parsedType = MealType.values[typeValue];
    } else {
      parsedType = null;
    }
    if (parsedType == null) return null;

    final rawDate = value['loggedAt'];
    final parsedDate = rawDate is String ? DateTime.tryParse(rawDate) : null;

    return LoggedMeal(
      id: idValue.toInt(),
      name: nameValue.trim(),
      calories: caloriesValue.toInt(),
      type: parsedType,
      // Older saved entries did not include a timestamp.
      loggedAt: parsedDate ?? DateTime.now(),
      proteinGrams: _optionalMeasure(value['proteinGrams'], maximum: 100000),
      carbohydratesGrams: _optionalMeasure(
        value['carbohydratesGrams'],
        maximum: 100000,
      ),
      fatGrams: _optionalMeasure(value['fatGrams'], maximum: 100000),
      sugarGrams: _optionalMeasure(value['sugarGrams'], maximum: 100000),
      fiberGrams: _optionalMeasure(value['fiberGrams'], maximum: 100000),
      sodiumMilligrams: _optionalMeasure(
        value['sodiumMilligrams'],
        maximum: 10000000,
      ),
    );
  }
}

double? _optionalMeasure(Object? value, {required double maximum}) {
  if (value == null || value is! num) return null;
  if (!value.isFinite || value < 0 || value > maximum) return null;
  return value.toDouble();
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}

bool isSameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime calendarDay(DateTime date) =>
    DateTime(date.year, date.month, date.day);
