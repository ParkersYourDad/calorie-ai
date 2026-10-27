import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/app_theme.dart';
import '../core/localization/app_strings.dart';
import '../features/home/presentation/home_page.dart';

abstract final class AppPreferenceKeys {
  static const themeMode = 'appearance.themeMode';
  static const locale = 'appearance.locale';
}

class CalorieAiApp extends StatefulWidget {
  const CalorieAiApp({
    this.initialThemeMode = ThemeMode.system,
    this.initialLocale,
    super.key,
  });

  final ThemeMode initialThemeMode;
  final Locale? initialLocale;

  @override
  State<CalorieAiApp> createState() => _CalorieAiAppState();
}

class _CalorieAiAppState extends State<CalorieAiApp> {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  late ThemeMode _themeMode;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    _locale = widget.initialLocale;
  }

  Future<void> _changeThemeMode(ThemeMode value) async {
    setState(() => _themeMode = value);
    try {
      await _preferences.setString(AppPreferenceKeys.themeMode, value.name);
    } catch (_) {
      // Keep the in-memory selection active if persistence is unavailable.
    }
  }

  Future<void> _changeLocale(Locale? value) async {
    setState(() => _locale = value);
    try {
      if (value == null) {
        await _preferences.remove(AppPreferenceKeys.locale);
      } else {
        await _preferences.setString(
          AppPreferenceKeys.locale,
          value.languageCode,
        );
      }
    } catch (_) {
      // Keep the in-memory selection active if persistence is unavailable.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppStrings.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: CalorieHomePage(
        themeMode: _themeMode,
        locale: _locale,
        onThemeModeChanged: _changeThemeMode,
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}
