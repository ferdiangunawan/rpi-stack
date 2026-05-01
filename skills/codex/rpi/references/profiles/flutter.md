# Flutter/Dart RPI Profile

Load this profile only for Flutter or Dart projects. `AGENTS.md` and existing code override these defaults.

## Detection

Common signals:

- `pubspec.yaml` with Flutter SDK.
- `lib/`, `test/`, `integration_test/`.
- Imports from `package:flutter`, Riverpod, Bloc, GetX, or project UI packages.

## Implementation Guidance

- Follow the state management pattern already used in the feature area.
- If the project uses Riverpod StateNotifier, keep state immutable and update through `copyWith` or existing project conventions.
- If the project uses Equatable or custom JSON helpers such as `ReturnValue`, follow the existing model pattern.
- Use existing design tokens, spacing helpers, localization keys, routing, and error widgets.
- Prefer small reusable widgets when that is the established pattern; avoid large build methods with repeated logic.
- Keep async work cancellable or safely ignored after disposal where relevant.

## Validation

Prefer targeted commands first:

- `dart format --set-exit-if-changed {changed dart files}` when supported.
- `flutter analyze {target paths}` or project analyze command.
- `flutter test {target tests}`.
- Broader `flutter test` when the change is cross-cutting.

## Review Focus

- Loading, empty, error, success, disabled, and permission states.
- Widget rebuild hot paths and missing disposal of controllers, streams, timers, focus nodes, and subscriptions.
- Route arguments, localization keys, theming, and responsive behavior.
- Platform-specific configuration for iOS/Android/web when touched.
