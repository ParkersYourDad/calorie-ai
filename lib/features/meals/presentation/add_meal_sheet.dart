import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';
import '../domain/logged_meal.dart';

class MealDraft {
  const MealDraft({
    required this.name,
    required this.calories,
    required this.type,
  });

  final String name;
  final int calories;
  final MealType type;
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
  MealType _type = MealType.breakfast;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _save(AppStrings strings) {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      MealDraft(
        name: _nameController.text.trim(),
        calories: strings.parseInteger(_caloriesController.text)!,
        type: _type,
      ),
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(strings),
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
