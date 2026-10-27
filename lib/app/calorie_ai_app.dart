import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/design/app_theme.dart';
import '../core/localization/app_strings.dart';
import '../features/home/presentation/home_page.dart';

class CalorieAiApp extends StatefulWidget {
  const CalorieAiApp({super.key});

  @override
  State<CalorieAiApp> createState() => _CalorieAiAppState();
}

class _CalorieAiAppState extends State<CalorieAiApp> {
  static const _themeKey = 'appearance.themeMode';
  static const _localeKey = 'appearance.locale';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  ThemeMode _themeMode = ThemeMode.system;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    try {
      final themeName = await _preferences.getString(_themeKey);
      final localeCode = await _preferences.getString(_localeKey);
      if (!mounted) return;

      final savedTheme = ThemeMode.values.where(
        (mode) => mode.name == themeName,
      );
      final savedLocale = localeCode == 'en' || localeCode == 'ar'
          ? Locale(localeCode!)
          : null;

      setState(() {
        if (savedTheme.isNotEmpty) _themeMode = savedTheme.first;
        _locale = savedLocale;
      });
    } catch (_) {
      // Preferences are optional; the app can use system defaults.
    }
  }

  Future<void> _changeThemeMode(ThemeMode value) async {
    setState(() => _themeMode = value);
    try {
      await _preferences.setString(_themeKey, value.name);
    } catch (_) {
      // Keep the in-memory selection active if persistence is unavailable.
    }
  }

  Future<void> _changeLocale(Locale? value) async {
    setState(() => _locale = value);
    try {
      if (value == null) {
        await _preferences.remove(_localeKey);
      } else {
        await _preferences.setString(_localeKey, value.languageCode);
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
