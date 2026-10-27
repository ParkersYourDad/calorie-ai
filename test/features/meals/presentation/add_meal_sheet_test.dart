import 'package:calorie_ai/core/localization/app_strings.dart';
import 'package:calorie_ai/features/meals/presentation/add_meal_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps optional nutrition fields collapsed until requested', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: const [Locale('en'), Locale('ar')],
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () {
                  AddMealSheet.show(context);
                },
                child: const Text('Open meal form'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open meal form'));
    await tester.pumpAndSettle();

    expect(find.text('Nutrition details · Optional'), findsOneWidget);
    expect(find.text('Protein'), findsNothing);
    expect(find.text('Sodium'), findsNothing);

    await tester.tap(find.text('Nutrition details · Optional'));
    await tester.pumpAndSettle();

    expect(find.text('Protein'), findsOneWidget);
    expect(find.text('Carbohydrates'), findsOneWidget);
    expect(find.text('Fat'), findsOneWidget);
    expect(find.text('Sugar'), findsOneWidget);
    expect(find.text('Fiber'), findsOneWidget);
    expect(find.text('Sodium'), findsOneWidget);
  });
}
