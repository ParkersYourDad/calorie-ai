enum MealType { breakfast, lunch, dinner, snack }

class LoggedMeal {
  const LoggedMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.type,
    required this.loggedAt,
  });

  final int id;
  final String name;
  final int calories;
  final MealType type;
  final DateTime loggedAt;

  Map<String, Object> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'type': type.name,
    'loggedAt': loggedAt.toIso8601String(),
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
    );
  }
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
