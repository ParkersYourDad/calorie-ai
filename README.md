# Calorie AI

A Flutter mobile app for calorie tracking and planned AI-assisted food analysis.

## Current status

The starter app currently supports:
- Manual meal logging with calorie amounts and meal categories.
- A daily calorie total and configurable daily goal.
- Removing logged meals.
- Local persistence of meals and the daily goal on the device.
- System-aware light and dark themes.

AI photo analysis is **not connected yet**. The app does not upload photos or invent AI estimates. A secure backend and a real model integration are required before this feature can be enabled.

## Run locally

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Product principles

- Android and iOS first.
- English and Arabic locale foundations with correct directional layout as localization is implemented.
- Light, dark, and system themes.
- Food estimates must be clearly labeled as estimates and remain editable.
- Provider credentials must stay on a secure backend, never in the mobile app.
- Health-related estimates should not be presented as medical advice.
