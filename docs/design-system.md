# Implemented design system

This guide documents the system that currently exists in the app. It is not a list of planned components.

## Visual principles

- Warm-neutral light and dark palettes, with charcoal as the primary action color.
- One primary summary surface; meal entries stay on open surfaces separated by subtle dividers.
- No decorative gradients, heavy shadows, or surface tint.
- Whitespace and typography do most of the hierarchy work.
- Native Flutter controls remain in use where they provide accessible, platform-appropriate behavior.

## Tokens and theme

Source of truth: `lib/core/design/app_tokens.dart` and `lib/core/design/app_theme.dart`.

| Role | Current value |
| --- | --- |
| Page background, light | `#FAFAF8` |
| Surface, light | `#FFFFFF` |
| Subtle surface, light | `#F2F2EE` |
| Page background, dark | `#111110` |
| Surface, dark | `#1B1B19` |
| Subtle surface, dark | `#242521` |
| Body text | 14 logical pixels |
| Standard title | 16 logical pixels |
| Section title | 20 logical pixels |
| Page heading | 24 logical pixels |
| Spacing scale | 4, 8, 12, 16, 24, 32, 48 |
| Shape radii | 8, 12, 16, 24, full |
| Standard touch target | 48 logical pixels |
| Maximum content width | 640 logical pixels |

The calorie total uses a larger display treatment because it is the primary value on this screen. Surfaces use zero elevation and transparent surface tint. Light, Dark, and System appearance are selectable and saved on-device.

No custom font files are bundled yet. The UI uses the platform's available font fallback; IBM Plex Sans Arabic should only be introduced after font coverage and redistribution licensing are verified.

## Localization and direction

- User-facing copy is centralized in `lib/core/localization/app_strings.dart`.
- English and Arabic are supported; Device follows the operating-system locale.
- Flutter's localization delegates provide directionality for Arabic. Directional date controls explicitly select the appropriate chevron.
- New visible copy must be added to `AppStrings`; do not insert screen-specific user-facing literals in widgets.
- Test long Arabic and English strings and large text scaling before adding dense layouts.

## Shared behavior

- Buttons, icon controls, inputs, dialogs, bottom sheets, dividers, and snackbars inherit from the central theme.
- The goal dialog and meal-entry sheet share field styling and validation presentation.
- Meal deletion offers Undo. Persistence failures are shown instead of being reported as successful.
- Loading, storage failure, unreadable saved records, empty meals, and disabled next-day navigation have explicit states.

## Structure

- `lib/app/`: app bootstrap and app-level settings state.
- `lib/core/design/`: theme and visual tokens.
- `lib/core/localization/`: centralized English/Arabic strings.
- `lib/features/meals/domain/`: meal model and date helpers.
- `lib/features/meals/presentation/`: meal-entry sheet.
- `lib/features/home/data/`: local persistence boundary.
- `lib/features/home/presentation/`: dashboard state and focused UI components.
- `lib/features/settings/presentation/`: appearance and language controls.

Riverpod and go_router are not installed. This app currently has one primary screen, so adding global state-management or multi-tab routing infrastructure would add complexity without solving a current problem. Reconsider those dependencies when multiple features or navigation stacks make them useful.

## Extension rules

1. Reuse tokens and shared theme defaults before adding one-off styling.
2. Keep feature-specific behavior in its feature; keep app-wide rules in `core`.
3. Keep AI, barcode, camera, voice, and nutrition database capabilities disabled until real integrations and error states are implemented.
4. Add tests for domain transformations and critical UI behavior. Use golden tests only for selected shared components and themes.
