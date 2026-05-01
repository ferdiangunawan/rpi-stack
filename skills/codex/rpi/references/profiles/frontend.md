# Frontend Web RPI Profile

Load this profile for browser UI work using React, Next.js, Vue, Svelte, Astro, Vite, or similar stacks. `AGENTS.md` and existing code override these defaults.

## Detection

Common signals:

- `package.json` with frontend framework dependencies.
- `src/`, `app/`, `pages/`, `components/`, `routes/`.
- CSS, design tokens, Storybook, Playwright, Cypress, or Testing Library.

## Implementation Guidance

- Follow existing component, state, data fetching, routing, and styling patterns.
- Preserve accessibility: semantic elements, labels, keyboard behavior, focus management, and color contrast.
- Keep server/client boundaries explicit for frameworks that distinguish them.
- Avoid introducing global state or new dependencies unless required.
- Handle loading, empty, error, optimistic, and permission states when user-visible behavior changes.

## Validation

Prefer project scripts from `package.json`:

- Unit/component tests.
- Typecheck.
- Lint.
- E2E tests for user flows when relevant.
- Build only when the change touches bundling, routing, server/client boundaries, or deployment behavior.

## Review Focus

- Accessibility regressions.
- Race conditions in async fetch/mutation flows.
- Cache invalidation and stale UI.
- XSS risks from HTML rendering or unsafe URLs.
- Hydration, routing, and environment variable boundaries.
