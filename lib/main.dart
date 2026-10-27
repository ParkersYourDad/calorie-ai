import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/calorie_ai_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var themeMode = ThemeMode.system;
  Locale? locale;
  final preferences = SharedPreferencesAsync();

  try {
    final savedThemeName = await preferences.getString(
      AppPreferenceKeys.themeMode,
    );
    for (final mode in ThemeMode.values) {
      if (mode.name == savedThemeName) {
        themeMode = mode;
        break;
      }
    }

    final savedLocale = await preferences.getString(AppPreferenceKeys.locale);
    if (savedLocale == 'en' || savedLocale == 'ar') {
      locale = Locale(savedLocale!);
    }
  } catch (_) {
    // Defaults are safe when preferences are unavailable.
  }

  runApp(CalorieAiApp(initialThemeMode: themeMode, initialLocale: locale));
}
