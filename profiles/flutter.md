# Flutter and Dart profile

Use for Flutter UI, state, navigation, and platform integration. Follow the active repository's instructions, state-management pattern, and design system first. Apply only checks relevant to the changed flow.

## Trace the behavior

- Follow state ownership, async completion, navigation, and lifecycle across the affected widgets and controllers.
- Reuse existing UI components, layout and typography tokens, localization, and error presentation. Use const constructors where valid and split a widget when its size or rebuild behavior warrants it.
- Check disposal and cancellation for resources the changed code owns. Check mounted or equivalent lifecycle guards before using context or state after an await.
- For long dynamic lists or expensive build paths, consider lazy construction and avoiding repeated work. Preserve item identity when state or focus depends on it.
- Inspect platform-specific behavior only where the change touches permissions, plugins, deep links, or native configuration.

## Verification

Use documented, authorized file-scoped format and analysis commands where practical. Run widget, integration, device, or visual checks only when appropriate and allowed. Distinguish analyzer results from actual device or user-flow evidence.
