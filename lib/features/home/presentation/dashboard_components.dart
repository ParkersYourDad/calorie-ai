import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../../meals/domain/logged_meal.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
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

class DailyCaloriesSummary extends StatelessWidget {
  const DailyCaloriesSummary({
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

class EmptyMealsState extends StatelessWidget {
  const EmptyMealsState({required this.onAddMeal});

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

class MealRow extends StatelessWidget {
  const MealRow({
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

class DataWarning extends StatelessWidget {
  const DataWarning({required this.message});

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

class LoadFailure extends StatelessWidget {
  const LoadFailure({required this.onRetry});

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
