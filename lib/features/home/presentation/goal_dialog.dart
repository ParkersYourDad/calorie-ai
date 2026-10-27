import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';

class GoalDialog extends StatefulWidget {
  const GoalDialog({required this.initialGoal});

  final int? initialGoal;

  @override
  State<GoalDialog> createState() => GoalDialogState();
}

class GoalDialogState extends State<_GoalDialog> {
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
