import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../../meals/domain/logged_meal.dart';
import '../../meals/presentation/add_meal_sheet.dart';
import '../../settings/presentation/app_settings_sheet.dart';
import '../data/dashboard_storage.dart';

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
      builder: (_) => _GoalDialog(initialGoal: _dailyGoal),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appName),
        actions: [
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
                ? _LoadFailure(onRetry: _loadSavedData)
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
                          _DateSelector(
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
                          _DailyCaloriesSummary(
                            totalCalories: _totalCalories,
                            goal: _dailyGoal,
                            onSetGoal: _setGoal,
                          ),
                          if (_hasUnreadableData) ...[
                            const SizedBox(height: AppSpacing.md),
                            _DataWarning(message: strings.storedDataWarning),
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
                            _EmptyMealsState(onAddMeal: _addMeal)
                          else
                            ..._buildMealSections(strings),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            strings.manualEntryNote,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                          ),
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
      final meals = _selectedDayMeals
          .where((meal) => meal.type == type)
          .toList()
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
          _MealRow(
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

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.date,
    required this.isToday,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime date;
  final bool isToday;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Row(
      children: [
        IconButton(
          tooltip: strings.previousDay,
          onPressed: onPrevious,
          icon: Icon(
            isRtl ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
          ),
        ),
        Expanded(
          child: Text(
            strings.dateLabel(date, DateTime.now()),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: strings.nextDay,
          onPressed: isToday ? null : onNext,
          icon: Icon(
            isRtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
          ),
        ),
      ],
    );
  }
}

class _DailyCaloriesSummary extends StatelessWidget {
  const _DailyCaloriesSummary({
    required this.totalCalories,
    required this.goal,
    required this.onSetGoal,
  });

  final int totalCalories;
  final int? goal;
  final VoidCallback onSetGoal;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final remaining = goal == null ? null : goal! - totalCalories;
    final progress = goal == null
        ? 0.0
        : (totalCalories / goal!).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.caloriesConsumed,
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    strings.number(totalCalories),
                    style: textTheme.headlineSmall?.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -1.1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                strings.kcal,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (goal != null) ...[
            const SizedBox(height: AppSpacing.lg),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: AppSizes.progressHeight,
                backgroundColor: colors.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ] else
            const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  goal == null
                      ? strings.goalNotSet
                      : strings.remainingLabel(
                          remaining!,
                          exceeded: remaining < 0,
                        ),
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: onSetGoal,
                child: Text(goal == null ? strings.setGoal : strings.editGoal),
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
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: AppSizes.iconLarge,
            color: colors.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(strings.noMealsYet, style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.emptyMealsHint,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onAddMeal,
            icon: const Icon(Icons.add_rounded, size: AppSizes.iconSmall),
            label: Text(strings.addFirstMeal),
          ),
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.meal,
    required this.onDelete,
    required this.showDivider,
  });

  final LoggedMeal meal;
  final VoidCallback onDelete;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  _mealIcon(meal.type),
                  size: AppSizes.iconMedium,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      strings.caloriesValue(meal.calories),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                tooltip: strings.removeMeal,
                onPressed: onDelete,
                icon: const Icon(Icons.close_rounded),
                iconSize: AppSizes.iconSmall,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            indent: AppSpacing.xl + AppSpacing.sm,
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
      ],
    );
  }

  IconData _mealIcon(MealType type) => switch (type) {
        MealType.breakfast => Icons.wb_sunny_outlined,
        MealType.lunch => Icons.lunch_dining_outlined,
        MealType.dinner => Icons.dinner_dining_outlined,
        MealType.snack => Icons.local_cafe_outlined,
      };
}

class _DataWarning extends StatelessWidget {
  const _DataWarning({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline_rounded, size: AppSizes.iconSmall, color: colors.error),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.error,
                ),
          ),
        ),
      ],
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.storage_outlined,
              color: colors.onSurfaceVariant,
              size: AppSizes.iconLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              strings.loadFailed,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalDialog extends StatefulWidget {
  const _GoalDialog({required this.initialGoal});

  final int? initialGoal;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialGoal?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return AlertDialog(
      title: Text(strings.dailyGoal),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: strings.caloriesPerDay,
            hintText: strings.goalHint,
          ),
          validator: (value) {
            final goal = int.tryParse(value?.trim() ?? '');
            if (goal == null || goal < 1 || goal > 100000) {
              return strings.enterValidGoal;
            }
            return null;
          },
          onFieldSubmitted: (_) => _save(strings),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () => _save(strings),
          child: Text(strings.save),
        ),
      ],
    );
  }

  void _save(AppStrings strings) {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }
}
