# Web frontend profile

Use for browser UI and client-facing web applications. Follow the active repository's instructions, framework version, and design system first. Apply only checks relevant to the changed surface.

## Trace the user flow

- Confirm the requested behavior across loading, empty, error, and success states when those states exist.
- Follow data fetching, cache invalidation, URL state, and server/client boundaries where the framework uses them. Do not assume one rendering model fits every route.
- Use existing components, tokens, copy, and responsive conventions. Check keyboard access, focus, labels, and semantics for changed interactive elements.
- Inspect escaping or sanitization when rendering user-controlled HTML or URLs. Consider bundle size and layout shift for changed media or dependencies.

## Verification

Use the repository's documented, authorized format, lint, typecheck, or targeted UI checks. Match the check to the change and report whether visual or browser behavior was actually observed. Do not assume a package manager, test runner, or command from the framework name alone.
