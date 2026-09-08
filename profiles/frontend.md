# Web Frontend Profile

Load this profile when working with web frontends (Next.js, React, Vue, Svelte, Astro, Vite, etc.). Project-level `AGENTS.md` and existing repository conventions override these defaults.

## Detection Signals

- `package.json`, `pnpm-workspace.yaml`, or `bun.lockb` with frontend dependencies (`react`, `next`, `vue`, `svelte`).
- Directory structure with `app/`, `pages/`, `components/`, `src/`, `styles/`.
- Styling libraries like Tailwind CSS, CSS Modules, Styled Components, or UI toolkits (Radix, Shadcn UI).

## Architecture & Boundaries

- **Server vs. Client boundaries**: In React Server Components (Next.js App Router), keep components Server Components by default. Use `'use client'` only when needing browser APIs, state hooks (`useState`), or user interaction listeners (`onClick`).
- **Data fetching & Caching**: Prefer server-side data fetching. Use framework caching primitives (`cache`, `revalidateTag`, `revalidatePath`) deliberately; avoid unintended stale UI.
- **Design system & Tokens**: Follow project component libraries and Tailwind design tokens. Avoid ad-hoc arbitrary Tailwind values (`w-[347px]`) when design system tokens exist.
- **State Management**: Prefer localized state or URL query state (`useSearchParams`) for shareable UI filters. Avoid global stores for ephemeral component state.

## Accessibility (a11y) & UX Standards

- Use semantic HTML tags (`<main>`, `<nav>`, `<article>`, `<button>`, `<header>`, `<footer>`).
- Ensure interactive elements are keyboard-navigable (`Tab`, `Enter`, `Space`) with visible focus indicators.
- Provide accessible labels (`aria-label`, `aria-describedby`, `<label htmlFor="...">`) for icon-only buttons, form fields, and modal dialogs.
- Always implement loading (skeleton/spinner), error (error boundaries), and empty states for asynchronous UI.

## Performance & Security

- **Image & Font optimization**: Use `next/image` or framework image loaders to prevent layout shifts (CLS) and optimize formats.
- **Bundle size**: Avoid importing entire massive utility libraries when tree-shaken named imports exist.
- **XSS prevention**: Never use `dangerouslySetInnerHTML` or `v-html` with untrusted user input without sanitization (`DOMPurify`).

## Validation Commands

```bash
# Typecheck
npm run typecheck # or pnpm / yarn / bun

# Lint
npm run lint

# Unit & component tests
npm run test # or vitest / jest

# E2E test (targeted)
npx playwright test <target-spec>
```

## Review Focus

- Client/Server component boundary leaks (unnecessary `'use client'`).
- Missing error boundary or empty state handling.
- XSS risks or insecure direct iframe/HTML rendering.
- Layout shift (CLS) or unoptimized image loading.
- Accessibility omissions on interactive controls.
