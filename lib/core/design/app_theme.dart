import 'package:flutter/material.dart';

import 'app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceSubtle =
        isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle;
    final primaryText = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final outline = isDark ? AppColors.darkOutline : AppColors.lightOutline;
    final error = isDark ? AppColors.darkError : AppColors.lightError;

    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF55584F),
      brightness: brightness,
      surface: surface,
      primary: primaryText,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      secondary: secondaryText,
      onSecondary: isDark ? AppColors.darkBackground : Colors.white,
      error: error,
      onError: isDark ? AppColors.darkBackground : Colors.white,
      outline: outline,
      outlineVariant: outline,
    ).copyWith(
      primaryContainer: surfaceSubtle,
      onPrimaryContainer: primaryText,
      secondaryContainer: surfaceSubtle,
      onSecondaryContainer: primaryText,
      tertiary: secondaryText,
      onTertiary: isDark ? AppColors.darkBackground : Colors.white,
      tertiaryContainer: surfaceSubtle,
      onTertiaryContainer: primaryText,
      onSurface: primaryText,
      onSurfaceVariant: secondaryText,
      errorContainer: surfaceSubtle,
      onErrorContainer: error,
      inverseSurface: isDark ? AppColors.lightSurface : AppColors.darkSurface,
      onInverseSurface: isDark ? AppColors.lightText : AppColors.darkText,
      inversePrimary: isDark ? AppColors.lightText : AppColors.darkText,
      surfaceDim: background,
      surfaceBright: surface,
      shadow: Colors.transparent,
      surfaceTint: Colors.transparent,
      surfaceContainerLowest: surface,
      surfaceContainerLow: surfaceSubtle,
      surfaceContainer: surfaceSubtle,
      surfaceContainerHigh: surfaceSubtle,
      surfaceContainerHighest: surfaceSubtle,
    );

    final textTheme = const TextTheme(
      bodySmall: TextStyle(
        fontSize: AppTypography.caption,
        height: AppTypography.titleLineHeight,
      ),
      bodyMedium: TextStyle(
        fontSize: AppTypography.body,
        height: AppTypography.bodyLineHeight,
      ),
      bodyLarge: TextStyle(
        fontSize: AppTypography.title,
        height: AppTypography.titleLineHeight,
      ),
      titleSmall: TextStyle(
        fontSize: AppTypography.body,
        fontWeight: AppTypography.semibold,
      ),
      titleMedium: TextStyle(
        fontSize: AppTypography.title,
        fontWeight: AppTypography.semibold,
      ),
      titleLarge: TextStyle(
        fontSize: AppTypography.sectionHeading,
        fontWeight: AppTypography.semibold,
      ),
      headlineSmall: TextStyle(
        fontSize: AppTypography.pageHeading,
        height: AppTypography.pageLineHeight,
        fontWeight: AppTypography.semibold,
      ),
    ).apply(
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: outline,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: outline.withValues(alpha: 0.65)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceSubtle.withValues(alpha: isDark ? 0.72 : 0.68),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primaryText, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: error, width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, AppSizes.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: AppTypography.body,
            fontWeight: AppTypography.semibold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, AppSizes.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          side: BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, AppSizes.tapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppSizes.tapTarget, AppSizes.tapTarget),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: outline),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.darkSurfaceSubtle : primaryText,
        contentTextStyle: TextStyle(color: isDark ? primaryText : Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryText,
        linearTrackColor: outline.withValues(alpha: 0.55),
        circularTrackColor: outline.withValues(alpha: 0.55),
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.75),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
