import 'package:flutter/material.dart';

import '../../../core/design/app_tokens.dart';
import '../../../core/localization/app_strings.dart';

class AppSettingsSheet extends StatefulWidget {
  const AppSettingsSheet({
    required this.themeMode,
    required this.locale,
    required this.onThemeModeChanged,
    required this.onLocaleChanged,
    super.key,
  });

  final ThemeMode themeMode;
  final Locale? locale;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<Locale?> onLocaleChanged;

  static Future<void> show(
    BuildContext context, {
    required ThemeMode themeMode,
    required Locale? locale,
    required ValueChanged<ThemeMode> onThemeModeChanged,
    required ValueChanged<Locale?> onLocaleChanged,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => AppSettingsSheet(
        themeMode: themeMode,
        locale: locale,
        onThemeModeChanged: onThemeModeChanged,
        onLocaleChanged: onLocaleChanged,
      ),
    );
  }

  @override
  State<AppSettingsSheet> createState() => _AppSettingsSheetState();
}

class _AppSettingsSheetState extends State<AppSettingsSheet> {
  late ThemeMode _themeMode;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.themeMode;
    _locale = widget.locale;
  }

  void _selectTheme(ThemeMode value) {
    setState(() => _themeMode = value);
    widget.onThemeModeChanged(value);
  }

  void _selectLocale(Locale? value) {
    setState(() => _locale = value);
    widget.onLocaleChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final selectedLocale = _locale?.languageCode ?? 'system';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.settings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings.appearance,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(strings.system),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(strings.light),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(strings.dark),
                ),
              ],
              selected: {_themeMode},
              onSelectionChanged: (value) => _selectTheme(value.first),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            strings.language,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: 'system',
                  label: Text(strings.deviceLanguage),
                ),
                const ButtonSegment(value: 'en', label: Text('English')),
                const ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {selectedLocale},
              onSelectionChanged: (value) {
                final selected = value.first;
                _selectLocale(
                  selected == 'system' ? null : Locale(selected),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            strings.settingsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
