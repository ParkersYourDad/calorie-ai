import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class AppSizes {
  static const double contentMaxWidth = 640;
  static const double pageHorizontalPadding = 24;
  static const double iconSmall = 18;
  static const double iconMedium = 22;
  static const double iconLarge = 28;
  static const double tapTarget = 48;
  static const double progressHeight = 5;
}

abstract final class AppColors {
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF2F2EE);
  static const Color lightText = Color(0xFF20211E);
  static const Color lightTextSecondary = Color(0xFF6E7069);
  static const Color lightOutline = Color(0xFFE3E4DE);

  static const Color darkBackground = Color(0xFF111110);
  static const Color darkSurface = Color(0xFF1B1B19);
  static const Color darkSurfaceSubtle = Color(0xFF242521);
  static const Color darkText = Color(0xFFF2F2ED);
  static const Color darkTextSecondary = Color(0xFFB2B3AB);
  static const Color darkOutline = Color(0xFF393A34);

  static const Color lightError = Color(0xFFB3261E);
  static const Color darkError = Color(0xFFFFB4AB);
}

abstract final class AppMotion {
  static const Duration quick = Duration(milliseconds: 140);
  static const Duration standard = Duration(milliseconds: 220);
  static const Curve standardCurve = Curves.easeOutCubic;
}
