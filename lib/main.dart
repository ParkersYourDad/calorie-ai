import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CalorieAiApp());
}

class CalorieAiApp extends StatelessWidget {
  const CalorieAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    const neutralSeed = Color(0xFF5D6258);
    return MaterialApp(
      title: 'Calorie AI',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light, neutralSeed),
      darkTheme: _theme(Brightness.dark, neutralSeed),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const CalorieHomePage(),
    );
  }

  ThemeData _theme(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      surface: brightness == Brightness.light
          ? const Color(0xFFFAFAF8)
          : const Color(0xFF151614),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant.withValues(alpha: 0.55),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, height: 1.45),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum MealType { breakfast, lunch, dinner, snack }

class LoggedMeal {
  const LoggedMeal({
    required this.id,
    required this.name,
    required this.calories,
    required this.type,
  });

  final int id;
  final String name;
  final int calories;
  final MealType type;
}

class CalorieHomePage extends StatefulWidget {
  const CalorieHomePage({super.key});

  @override
  State<CalorieHomePage> createState() => _CalorieHomePageState();
}

class _CalorieHomePageState extends State<CalorieHomePage> {
  final List<LoggedMeal> _meals = [];
  int? _dailyGoal;
  int _nextId = 0;
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  static const _mealsKey = 'calorie_ai.meals';
  static const _goalKey = 'calorie_ai.daily_goal';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    try {
      final rawMeals = await _preferences.getString(_mealsKey);
      final savedGoal = await _preferences.getInt(_goalKey);
      final restoredMeals = rawMeals == null
          ? <LoggedMeal>[]
          : (jsonDecode(rawMeals) as List<dynamic>).map((item) {
              final map = item as Map<String, dynamic>;
              final typeIndex = map['type'] as int;
              return LoggedMeal(
                id: map['id'] as int,
                name: map['name'] as String,
                calories: map['calories'] as int,
                type: MealType.values[typeIndex.clamp(0, MealType.values.length - 1)],
              );
            }).toList();
      if (!mounted) return;
      setState(() {
        _meals
          ..clear()
          ..addAll(restoredMeals);
        _dailyGoal = savedGoal;
        _nextId = restoredMeals.fold<int>(
              0,
              (highest, meal) => meal.id >= highest ? meal.id + 1 : highest,
            );
      });
    } catch (_) {
      // Keep the app usable if stored data is missing or malformed.
    }
  }

  Future<void> _saveMeals() async {
    final payload = jsonEncode(_meals.map((meal) => {
          'id': meal.id,
          'name': meal.name,
          'calories': meal.calories,
          'type': meal.type.index,
        }).toList());
    await _preferences.setString(_mealsKey, payload);
  }

  int get _totalCalories =>
      _meals.fold(0, (total, meal) => total + meal.calories);

  Future<void> _addMeal() async {
    final meal = await showDialog<LoggedMeal>(
      context: context,
      builder: (context) => const _AddMealDialog(),
    );
    if (!mounted || meal == null) return;
    setState(() => _meals.add(LoggedMeal(
          id: _nextId++,
          name: meal.name,
          calories: meal.calories,
          type: meal.type,
        )));
    await _saveMeals();
  }

  Future<void> _setGoal() async {
    final controller = TextEditingController(
      text: _dailyGoal?.toString() ?? '',
    );
    final goal = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Daily calorie goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Calories per day',
            hintText: 'e.g. 2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 1 || value > 100000) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Save goal'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || goal == null) return;
    setState(() => _dailyGoal = goal);
    await _preferences.setInt(_goalKey, goal);
  }

  Future<void> _showAiStatus() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI food analysis'),
        content: const Text(
          'AI analysis is not connected yet. No photo is uploaded and no '
          'calorie estimate is generated. This feature will be enabled after '
          'a secure backend is configured.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMeal(LoggedMeal meal) async {
    setState(() => _meals.removeWhere((item) => item.id == meal.id));
    await _saveMeals();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${meal.name} removed'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final goal = _dailyGoal;
    final progress = goal == null ? 0.0 : (_totalCalories / goal).clamp(0.0, 1.0).toDouble();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            tooltip: 'Set daily goal',
            onPressed: _setGoal,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Your daily balance',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              'A clearer picture of what you eat.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            _DailyCaloriesCard(
              totalCalories: _totalCalories,
              goal: goal,
              progress: progress,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Today’s meals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addMeal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add meal'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_meals.isEmpty)
              _EmptyMealsState(onAddMeal: _addMeal)
            else
              ...MealType.values.map((type) {
                final meals = _meals.where((meal) => meal.type == type).toList();
                if (meals.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mealTypeLabel(type),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...meals.map((meal) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _MealRow(
                              meal: meal,
                              onDelete: () => _removeMeal(meal),
                            ),
                          )),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showAiStatus,
              icon: const Icon(Icons.center_focus_weak_rounded),
              label: const Text('Analyze food with AI'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Calories entered manually are estimates. AI photo analysis is '
              'not available yet.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _mealTypeLabel(MealType type) => switch (type) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snacks',
      };
}

class _DailyCaloriesCard extends StatelessWidget {
  const _DailyCaloriesCard({
    required this.totalCalories,
    required this.goal,
    required this.progress,
  });

  final int totalCalories;
  final int? goal;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final remaining = goal == null ? null : goal! - totalCalories;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Calories consumed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totalCalories.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 7, bottom: 5),
                child: Text(
                  'kcal',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(value: progress, minHeight: 6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  goal == null
                      ? 'Daily goal not set'
                      : remaining! >= 0
                          ? '$remaining kcal remaining'
                          : '${remaining.abs()} kcal over goal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ),
              Text(
                goal == null
                    ? '—'
                    : '${(totalCalories / goal! * 100).round()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyMealsState extends StatelessWidget {
  const _EmptyMealsState({required this.onAddMeal});

  final VoidCallback onAddMeal;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.restaurant_outlined, size: 28, color: colors.onSurfaceVariant),
          const SizedBox(height: 10),
          Text('No meals logged', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Add your first meal to start tracking today.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 14),
          TextButton(onPressed: onAddMeal, child: const Text('Add first meal')),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal, required this.onDelete});

  final LoggedMeal meal;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_mealIcon(meal.type), color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  '${meal.calories} kcal',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove meal',
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }

  IconData _mealIcon(MealType type) => switch (type) {
        MealType.breakfast => Icons.wb_sunny_outlined,
        MealType.lunch => Icons.lunch_dining_outlined,
        MealType.dinner => Icons.dinner_dining_outlined,
        MealType.snack => Icons.local_cafe_outlined,
      };
}

class _AddMealDialog extends StatefulWidget {
  const _AddMealDialog();

  @override
  State<_AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<_AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  MealType _type = MealType.breakfast;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      LoggedMeal(
        id: -1,
        name: _nameController.text.trim(),
        calories: int.parse(_caloriesController.text.trim()),
        type: _type,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add meal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Food name',
                  hintText: 'e.g. Oatmeal',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Enter a food name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories (kcal)',
                  hintText: 'e.g. 320',
                ),
                validator: (value) {
                  final calories = int.tryParse(value?.trim() ?? '');
                  if (calories == null || calories < 0 || calories > 100000) {
                    return 'Enter a valid calorie amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<MealType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Meal type'),
                items: MealType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(switch (type) {
                            MealType.breakfast => 'Breakfast',
                            MealType.lunch => 'Lunch',
                            MealType.dinner => 'Dinner',
                            MealType.snack => 'Snack',
                          }),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Add meal')),
      ],
    );
  }
}
