import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../../meals/domain/logged_meal.dart';
import '../domain/nutrition_totals.dart';

class NutritionSummarySheet extends StatelessWidget {
  const NutritionSummarySheet({required this.meals, super.key});

  final List<LoggedMeal> meals;

  static Future<void> show(
    BuildContext context, {
    required List<LoggedMeal> meals,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => NutritionSummarySheet(meals: List.unmodifiable(meals)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final totals = NutritionTotals.fromMeals(meals);
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            strings.nutritionDetails,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.recordedOnlyNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _NutrientRow(
            label: strings.protein,
            total: totals.protein,
            unit: strings.grams,
          ),
          _NutrientRow(
            label: strings.carbohydrates,
            total: totals.carbohydrates,
            unit: strings.grams,
          ),
          _NutrientRow(
            label: strings.fat,
            total: totals.fat,
            unit: strings.grams,
          ),
          _NutrientRow(
            label: strings.sugar,
            total: totals.sugar,
            unit: strings.grams,
          ),
          _NutrientRow(
            label: strings.fiber,
            total: totals.fiber,
            unit: strings.grams,
          ),
          _NutrientRow(
            label: strings.sodium,
            total: totals.sodium,
            unit: strings.milligrams,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.label,
    required this.total,
    required this.unit,
    this.isLast = false,
  });

  final String label;
  final NutrientTotal total;
  final String unit;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Text(label, style: textTheme.bodyLarge)),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    total.value == null
                        ? '—'
                        : '${strings.decimal(total.value!)} $unit',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.end,
                  ),
                  if (total.isPartial) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      strings.recordedInMeals(
                        total.recordedMeals,
                        total.totalMeals,
                      ),
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: colors.outlineVariant.withValues(alpha: 0.65)),
      ],
    );
  }
}
