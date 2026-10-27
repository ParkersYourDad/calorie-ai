import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../../meals/domain/logged_meal.dart';
import '../../meals/presentation/add_meal_sheet.dart';
import '../../settings/presentation/app_settings_sheet.dart';
import '../data/dashboard_storage.dart';
import 'dashboard_components.dart';
import 'goal_dialog.dart';

class CalorieHomePage extends StatefulWidget {
  const CalorieHomePage({
    required this.themeMode,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<CalorieHomePage> createState() => _CalorieHomePageState();
}

class _CalorieHomePageState extends State<CalorieHomePage> {
  final DashboardStorage _storage = DashboardStorage();
  final List<LoggedMeal> _meals = [];
  Future<void> _saveQueue = Future<void>.value();

  DateTime _selectedDate = calendarDay(DateTime.now());
  int? _dailyGoal;
  bool _isLoading = true;
  bool _loadFailed = false;
  bool _hasUnreadableData = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  List<LoggedMeal> get _selectedDayMeals {
    final dayMeals = _meals
        .where((meal) => isSameCalendarDay(meal.loggedAt, _selectedDate))
        .toList();
    dayMeals.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return dayMeals;
  }

  int get _totalCalories =>
      _selectedDayMeals.fold(0, (total, meal) => total + meal.calories);

  bool get _isShowingToday =>
      isSameCalendarDay(_selectedDate, calendarDay(DateTime.now()));

  Future<void> _loadSavedData() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final snapshot = await _storage.load();
      if (!mounted) return;
      setState(() {
        _meals
          ..clear()
          ..addAll(snapshot.meals);
        _dailyGoal = snapshot.dailyGoal;
        _hasUnreadableData = snapshot.hasUnreadableData;
      });
    } catch (_) {
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _persistMeals() async {
    final snapshot = List<LoggedMeal>.unmodifiable(_meals);
    _saveQueue = _saveQueue
        .catchError((Object _) {})
        .then((_) => _storage.saveMeals(snapshot));

    try {
      await _saveQueue;
      return true;
    } catch (_) {
      if (mounted) _showMessage(AppStrings.of(context).saveFailed);
      return false;
    }
  }

  Future<void> _openSettings() => AppSettingsSheet.show(
    context,
    themeMode: widget.themeMode,
    locale: widget.locale,
    onThemeModeChanged: widget.onThemeModeChanged,
    onLocaleChanged: widget.onLocaleChanged,
  );

  void _moveDay(int offset) {
    final candidate = _selectedDate.add(Duration(days: offset));
    if (candidate.isAfter(calendarDay(DateTime.now()))) return;
    setState(() => _selectedDate = candidate);
  }

  void _returnToToday() {
    setState(() => _selectedDate = calendarDay(DateTime.now()));
  }

  Future<void> _addMeal() async {
    final draft = await AddMealSheet.show(context);
    if (!mounted || draft == null) return;

    final now = DateTime.now();
    final loggedAt = _isShowingToday
        ? now
        : DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            now.hour,
            now.minute,
            now.second,
          );
    var id = now.microsecondsSinceEpoch;
    while (_meals.any((meal) => meal.id == id)) {
      id++;
    }

    final meal = LoggedMeal(
      id: id,
      name: draft.name,
      calories: draft.calories,
      type: draft.type,
      loggedAt: loggedAt,
    );

    setState(() => _meals.add(meal));
    final saved = await _persistMeals();
    if (!saved && mounted) {
      setState(() => _meals.removeWhere((item) => item.id == meal.id));
    }
  }

  Future<void> _setGoal() async {
    final goal = await showDialog<int>(
      context: context,
      builder: (_) => GoalDialog(initialGoal: _dailyGoal),
    );
    if (!mounted || goal == null || goal == _dailyGoal) return;

    final previousGoal = _dailyGoal;
    setState(() => _dailyGoal = goal);
    try {
      await _storage.saveDailyGoal(goal);
    } catch (_) {
      if (!mounted) return;
      setState(() => _dailyGoal = previousGoal);
      _showMessage(AppStrings.of(context).saveFailed);
    }
  }

  Future<void> _removeMeal(LoggedMeal meal) async {
    setState(() => _meals.removeWhere((item) => item.id == meal.id));
    final saved = await _persistMeals();
    if (!mounted) return;

    if (!saved) {
      setState(() => _meals.add(meal));
      return;
    }

    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${meal.name} · ${strings.mealRemoved}'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: strings.undo,
            onPressed: () => _undoRemoval(meal),
          ),
        ),
      );
  }

  Future<void> _undoRemoval(LoggedMeal meal) async {
    if (_meals.any((item) => item.id == meal.id)) return;
    setState(() => _meals.add(meal));
    final saved = await _persistMeals();
    if (!saved && mounted) {
      setState(() => _meals.removeWhere((item) => item.id == meal.id));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName),
        actions: [
          if (!_isShowingToday)
            TextButton(onPressed: _returnToToday, child: Text(strings.today)),
          IconButton(
            tooltip: strings.settings,
            onPressed: _openSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _isLoading
            ? Center(
                child: Semantics(
                  label: strings.loading,
                  child: const CircularProgressIndicator(),
                ),
              )
            : _loadFailed
            ? LoadFailure(onRetry: _loadSavedData)
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppSizes.contentMaxWidth,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pageHorizontalPadding,
                      AppSpacing.sm,
                      AppSizes.pageHorizontalPadding,
                      AppSpacing.xxl,
                    ),
                    children: [
                      DateSelector(
                        date: _selectedDate,
                        isToday: _isShowingToday,
                        onPrevious: () => _moveDay(-1),
                        onNext: () => _moveDay(1),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        strings.dailyOverview,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      DailyCaloriesSummary(
                        totalCalories: _totalCalories,
                        goal: _dailyGoal,
                        onSetGoal: _setGoal,
                      ),
                      if (_hasUnreadableData) ...[
                        const SizedBox(height: AppSpacing.md),
                        DataWarning(message: strings.storedDataWarning),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.meals,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addMeal,
                            icon: const Icon(
                              Icons.add_rounded,
                              size: AppSizes.iconSmall,
                            ),
                            label: Text(strings.addMeal),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_selectedDayMeals.isEmpty)
                        EmptyMealsState(onAddMeal: _addMeal)
                      else
                        ..._buildMealSections(strings),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildMealSections(AppStrings strings) {
    final children = <Widget>[];
    for (final type in MealType.values) {
      final meals =
          _selectedDayMeals.where((meal) => meal.type == type).toList()
            ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
      if (meals.isEmpty) continue;

      children.add(
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.md,
            bottom: AppSpacing.xs,
          ),
          child: Text(
            strings.mealTypeLabel(type.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );

      for (var index = 0; index < meals.length; index++) {
        final meal = meals[index];
        children.add(
          MealRow(
            meal: meal,
            onDelete: () => _removeMeal(meal),
            showDivider: index != meals.length - 1,
          ),
        );
      }
    }
    return children;
  }
}
