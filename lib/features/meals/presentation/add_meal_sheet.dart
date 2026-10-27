import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../domain/logged_meal.dart';

class MealDraft {
  const MealDraft({
    required this.name,
    required this.calories,
    required this.type,
    this.proteinGrams,
    this.carbohydratesGrams,
    this.fatGrams,
    this.sugarGrams,
    this.fiberGrams,
    this.sodiumMilligrams,
  });

  final String name;
  final int calories;
  final MealType type;
  final double? proteinGrams;
  final double? carbohydratesGrams;
  final double? fatGrams;
  final double? sugarGrams;
  final double? fiberGrams;
  final double? sodiumMilligrams;
}

class AddMealSheet extends StatefulWidget {
  const AddMealSheet({super.key});

  static Future<MealDraft?> show(BuildContext context) {
    return showModalBottomSheet<MealDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: const AddMealSheet(),
      ),
    );
  }

  @override
  State<AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<AddMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _fatController = TextEditingController();
  final _sugarController = TextEditingController();
  final _fiberController = TextEditingController();
  final _sodiumController = TextEditingController();

  MealType _type = MealType.breakfast;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbohydratesController.dispose();
    _fatController.dispose();
    _sugarController.dispose();
    _fiberController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  double? _optionalValue(TextEditingController controller, AppStrings strings) {
    if (controller.text.trim().isEmpty) return null;
    return strings.parseDecimal(controller.text);
  }

  void _save(AppStrings strings) {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      MealDraft(
        name: _nameController.text.trim(),
        calories: strings.parseInteger(_caloriesController.text)!,
        type: _type,
        proteinGrams: _optionalValue(_proteinController, strings),
        carbohydratesGrams: _optionalValue(_carbohydratesController, strings),
        fatGrams: _optionalValue(_fatController, strings),
        sugarGrams: _optionalValue(_sugarController, strings),
        fiberGrams: _optionalValue(_fiberController, strings),
        sodiumMilligrams: _optionalValue(_sodiumController, strings),
      ),
    );
  }

  Widget _nutritionField({
    required TextEditingController controller,
    required String label,
    required String unit,
    required AppStrings strings,
  }) {
    final maximum = unit == strings.milligrams ? 10000000.0 : 100000.0;
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final amount = strings.parseDecimal(value);
        if (amount == null || amount < 0 || amount > maximum) {
          return strings.enterValidNutrition;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(strings.addMeal, style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.foodName,
                hintText: strings.foodNameHint,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? strings.enterFoodName
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: strings.calories,
                hintText: strings.caloriesHint,
              ),
              validator: (value) {
                final calories = strings.parseInteger(value);
                if (calories == null || calories < 0 || calories > 100000) {
                  return strings.enterValidCalories;
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<MealType>(
              initialValue: _type,
              isExpanded: true,
              decoration: InputDecoration(labelText: strings.mealType),
              items: MealType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(strings.mealTypeLabel(type.name)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            ExpansionTile(
              key: const PageStorageKey<String>('optional-nutrition-fields'),
              maintainState: true,
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              title: Text(
                '${strings.nutritionDetails} · ${strings.optional}',
                style: textTheme.titleMedium,
              ),
              subtitle: Text(
                strings.nutritionHint,
                style: textTheme.bodySmall,
              ),
              children: [
                const SizedBox(height: AppSpacing.sm),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fieldWidth =
                        (constraints.maxWidth - AppSpacing.sm) / 2;
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.md,
                      children: [
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _proteinController,
                            label: strings.protein,
                            unit: strings.grams,
                            strings: strings,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _carbohydratesController,
                            label: strings.carbohydrates,
                            unit: strings.grams,
                            strings: strings,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _fatController,
                            label: strings.fat,
                            unit: strings.grams,
                            strings: strings,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _sugarController,
                            label: strings.sugar,
                            unit: strings.grams,
                            strings: strings,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _fiberController,
                            label: strings.fiber,
                            unit: strings.grams,
                            strings: strings,
                          ),
                        ),
                        SizedBox(
                          width: fieldWidth,
                          child: _nutritionField(
                            controller: _sodiumController,
                            label: strings.sodium,
                            unit: strings.milligrams,
                            strings: strings,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.cancel),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _save(strings),
                    child: Text(strings.addMeal),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
