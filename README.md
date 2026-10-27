# Calorie AI

A Flutter mobile app focused on calm, clear daily food logging. The app is intentionally being built in small, verifiable stages rather than presenting unfinished integrations as working features.

## Current capabilities

- Add meals manually with a name, calorie amount, and meal category.
- Track daily calories and set an optional calorie goal.
- Move between dates to view logged meals for a day.
- Remove a meal and undo the removal.
- Persist meal entries and the daily goal on-device.
- Choose Light, Dark, or System appearance.
- Choose English, Arabic, or the device language.
- Use localized copy and direction-aware day navigation.

AI food recognition, barcode scanning, label scanning, voice input, a food database, macro tracking, hydration, activity, fasting, and health integrations are **not implemented yet**. The app does not upload photos or fabricate results. Those capabilities will only be enabled when their data sources, permissions, error states, and required services are implemented.

## Toolchain

- Flutter **3.47.0 or newer**
- Dart **3.13.5 or newer**

## Run locally

```sh
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter run
```

GitHub Actions runs formatting, static analysis, and tests on pushes to `main`, pull requests, and manual workflow dispatches. A workflow being configured does not imply that its latest run has passed.

## Project structure

- `lib/app/`: app bootstrap and persisted global preferences.
- `lib/core/design/`: centralized design tokens and theme.
- `lib/core/localization/`: English and Arabic UI strings.
- `lib/features/home/`: dashboard state, presentation, and local persistence.
- `lib/features/meals/`: meal model and manual-entry UI.
- `lib/features/settings/`: appearance and language settings.
- `test/`: focused automated tests.

See [the implemented design system](docs/design-system.md) for the palette, spacing, typography, layout rules, and extension guidance.

## Product and privacy principles

- Android and iOS first; no web or desktop scope.
- Never display placeholder AI output as a real estimate.
- Keep provider credentials on a secure backend, never in the mobile app.
- Request device permissions only when a real feature needs them.
- Label estimates clearly and allow users to correct them.
- Health-related estimates are informational, not medical advice.
