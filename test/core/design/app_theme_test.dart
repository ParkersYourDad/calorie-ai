import 'package:calorie_ai/core/design/app_theme.dart';
import 'package:calorie_ai/core/design/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme', () {
    test('uses the centralized neutral palette in both modes', () {
      final light = AppTheme.light();
      final dark = AppTheme.dark();

      expect(light.scaffoldBackgroundColor, AppColors.lightBackground);
      expect(dark.scaffoldBackgroundColor, AppColors.darkBackground);
      expect(light.colorScheme.onSurfaceVariant, AppColors.lightTextSecondary);
      expect(dark.colorScheme.onSurfaceVariant, AppColors.darkTextSecondary);
      expect(light.colorScheme.surfaceTint, Colors.transparent);
      expect(dark.colorScheme.surfaceTint, Colors.transparent);
      expect(light.cardTheme.elevation, 0);
      expect(dark.cardTheme.elevation, 0);
    });
  });
}
