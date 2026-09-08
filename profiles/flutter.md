# Flutter / Dart Profile

Load this profile when working in a Flutter or Dart codebase. Project-level `AGENTS.md` and existing repository conventions override these defaults.

## Detection Signals

- `pubspec.yaml` with Flutter SDK or Dart packages.
- Directory structure containing `lib/`, `test/`, `integration_test/`, `android/`, `ios/`.
- Imports from `package:flutter/...`, `flutter_riverpod`, `bloc`, `provider`, or internal UI packages.

## Architecture & Conventions

- Follow the state management pattern established in the feature area (e.g. Riverpod `Notifier`/`AsyncNotifier`, Bloc, or project-specific controllers).
- Keep state immutable; update state via `copyWith` or pattern-matching helpers.
- Use existing design tokens, typography, colors, padding helpers, localization keys, and shared widgets. Never hardcode magic numbers or hex colors.
- Follow the clean architecture layering if present: `data/` (data sources, DTO models) → `domain/` (entities, use cases) → `application/` (state/controllers) → `presentation/` (widgets, screens).

## Performance & Widget Structure

- **Const constructors**: Use `const` constructors wherever the compiler allows.
- **Widget extraction**: Split large widgets into separate `StatelessWidget` classes in their own files. Avoid `_buildXxx()` helper methods inside widget build methods to prevent unnecessary rebuild subtrees.
- **List virtualization**: Use `ListView.builder` or `SliverList` for long or dynamic lists. Never use unbounded `ListView(children: ...)` with dynamic data.
- **List item identity**: Provide explicit keys (`ValueKey` or `ObjectKey`) for dynamic list items to preserve state and focus correctly.
- **No heavy computation in `build()`**: Defer sorting, filtering, JSON parsing, or date formatting to controllers, selectors, or compute isolates.

## Lifecycle & Memory Safety (P0 Guards)

- Always dispose resources in `dispose()`:
  - `TextEditingController`
  - `ScrollController`
  - `AnimationController`
  - `FocusNode`
  - `StreamSubscription`
  - `Timer`
- Guard asynchronous callbacks with `mounted` checks before referencing `BuildContext`, `setState`, or Riverpod `ref`.

## Validation Commands

Run targeted commands before wider checks:

```bash
# Format check
dart format --set-exit-if-changed <changed-files>

# Static analysis
flutter analyze <target-paths>

# Targeted unit/widget tests
flutter test <target-test-files>
```

## Review Focus

- Missing resource disposal (P0 memory leak).
- Unbounded rebuild hot paths or missing `const` (P1 performance).
- Missing error, loading, empty, and offline states (P1 user experience).
- Hardcoded styles or strings bypassing localization (P2 pattern compliance).
