---
name: plan
description: Transforms validated research into an actionable, decision-complete implementation plan with dependency ordering and verification steps.
---

# Plan Skill

Transforms research findings and user requirements into a decision-complete, sequentially ordered implementation plan.

## When to Use

- Creating an implementation plan after completing research.
- Breaking down a complex feature, refactor, or bugfix into atomic, verifiable steps.
- Updating or verifying an existing plan before code changes.

## Guiding Principles

1. **Stack-Agnostic Core**: Follow architecture patterns from the active repository's `AGENTS.md` and domain profile in `profiles/` (`flutter.md`, `frontend.md`, `backend.md`, `scripts.md`).
2. **Atomic & Sequential**: Structure tasks so each step leaves the codebase in a compilable, testable state.
3. **Verification-First**: Every task must define how it will be verified (compiler check, targeted test, or lint command).
4. **Decisions Included**: Don't leave edge cases or architecture branches ambiguous in the plan. Document confirmed decisions and safe defaults.

---

## Phase 1: Architectural Alignment

Before writing tasks, establish:
- **Component Boundaries**: Extend existing modules vs. create new isolated modules.
- **Data Flow**: Data Source / DB / API → Domain Logic / Services → State / Controller → UI / Consumer.
- **Stack Profile**: Load and apply guidelines from `profiles/<stack>.md`.

---

## Phase 2: Resolving Remaining Edge Cases

If minor UX or technical questions remain:
- Check existing codebase patterns first.
- Apply safe defaults for standard behaviors (e.g. empty lists show standard empty placeholder; network errors trigger standard toast/banner). Document under **Confirmed Decisions & Assumptions**.
- If a remaining question alters core product behavior or scope, ask the user concisely with a recommended default before finalizing the plan.

---

## Phase 3: Task Decomposition

Structure tasks in dependency order:

```text
T1: Foundation & Data Layer
  - Target: Models, schemas, DTOs, migrations, API clients
  - Verification: compilation / schema validation / model unit test

T2: Business Logic & Application Layer
  - Target: Services, use cases, state management, controllers
  - Verification: business logic unit tests / mock verification

T3: Presentation & Consumer Layer
  - Target: UI components, screens, CLI commands, route registration
  - Verification: visual inspection / widget or component tests

T4: Integration & Edge-case Hardening
  - Target: Error boundaries, empty states, permissions, end-to-end integration
  - Verification: full lint, end-to-end flow check
```

---

## Phase 4: Verification Strategy

Every plan must specify concrete verification commands:
- **Static Analysis**: Exact lint/typecheck command (e.g. `npm run lint`, `flutter analyze`, `golangci-lint run`).
- **Targeted Automated Tests**: Exact unit/integration test commands for the touched paths.
- **Manual Verification Steps**: Step-by-step instructions to verify the change visually or via API call.

---

## Output Template

Save to `OUTPUT_DIR/plan-{feature}.md` (or present inline for Fast-Path):

```markdown
# Implementation Plan: {Feature Name}

## Metadata
- Date: {YYYY-MM-DD}
- Complexity: {Low / Medium / High}
- Stack: {Flutter / Frontend / Backend / Tooling}

## Architectural Approach & Confirmed Decisions
- **Approach**: {Summary of architectural design and pattern alignment}
- **Assumptions & Defaults**: {List of defaults applied for edge cases}

## Tasks

### T1: {Title}
- **Layer / Area**: {Data / Domain / Application / Presentation / Tooling}
- **Files**:
  - `[NEW / MODIFY]` `{path/to/file}`
- **Dependencies**: None
- **Acceptance Criteria**:
  - [ ] {Specific verifiable criterion}
- **Verification**: `{command or manual check}`

### T2: {Title}
...

## File Inventory Summary
| File | Action | Purpose |
|------|--------|---------|
| `path/to/file` | New / Modify | {Description} |

## Verification Plan
- **Lint / Analyze**: `{exact command}`
- **Automated Tests**: `{exact test command}`
- **Manual Check**: {Step-by-step instructions}

## Rollback & Blast Radius
- {Rollback strategy if deployment fails or side-effects occur}
```
