---
name: plan
description: Creates detailed implementation plan from validated research. Produces task breakdown with dependencies and file inventory.
---

# Plan Skill

Transforms validated research into an actionable implementation plan.

---

## Agent Compatibility

- AskUserQuestion: use the tool in Claude Code; in Codex CLI, ask the user directly.
- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.

---

## Phase 1: Architectural Decisions

Before task breakdown, decide:
- Which existing patterns and components to reuse (from research + AGENTS.md)
- New vs. extend: create new files or modify existing?
- Data flow: API → Repository → Service → Controller → UI (follow project layers)
- State management approach (follow AGENTS.md)

---

## Phase 2: Open Questions

Before writing the plan, identify any open edge cases or scope questions:
- Empty states, error states, boundary conditions with no specified behavior
- Scope ambiguity: "should X be included?"
- Conflicting requirements

**If there are ANY open questions, list them ALL and ask in a single batch before writing the plan.**

> Do NOT silently assume edge case behavior — ask.
> Document the user's answer in the plan under "Confirmed Decisions".

Example:
```
Before I write the plan, I need to clarify a few things:

1. [Edge case] When the list is empty, should we show "No results" or hide the section?
2. [Scope] Should {feature X} be included in this sprint or deferred?
3. [Architecture] Should we extend {ExistingController} or create a new one?
```

---

## Phase 3: Task Decomposition

Break implementation into atomic, sequential tasks. Each task:

```
T{n}: {Short title}
  Layer: data / domain / application / presentation
  Files: {list of files to create or modify}
  Requires: {R1, R2...} (requirement IDs it fulfills)
  Depends on: {T1, T2...} (tasks that must complete first)
  Acceptance criteria:
    - [ ] {specific verifiable criterion}
```

### Task Ordering Rules

1. **Foundation first:** Models → Services → Controllers → Screens
2. **Layer order:** Data → Domain → Application → Presentation
3. **No circular dependencies**
4. **Tests adjacent to related code**

---

## Phase 4: File Inventory

List every file to create or modify:

```
Create:
  lib/src/features/{feature}/data/{name}_response.dart
  lib/src/features/{feature}/presentation/{screen}_screen.dart
  ...

Modify:
  lib/src/routes/app_router.dart  (add route)
  ...
```

---

## Phase 5: Risk Assessment

Brief notes on:
- Technical unknowns remaining
- External dependencies (new API endpoints, third-party libs)
- Rollback considerations

---

## Output Template

Save to `OUTPUT_DIR/plan-{feature}.md`:

```markdown
# Implementation Plan: {Feature Name}

## Metadata
- Date: {date}
- Source: research-{feature}.md
- Complexity: {Low / Medium / High}

## Confirmed Decisions
| Question | Decision |
|----------|----------|
| {edge case} | {answer} |

## Architectural Approach
{Brief description of approach and patterns used}

## Tasks

### T1: {Title}
- **Layer**: {layer}
- **Files**: `{path}`
- **Requires**: R1, R2
- **Depends on**: —
- **Acceptance criteria**:
  - [ ] {criterion}

### T2: {Title}
...

## File Inventory

### Created
| File | Purpose |
|------|---------|
| `path` | {purpose} |

### Modified
| File | Changes |
|------|---------|
| `path` | {changes} |

## Requirement Traceability
| Requirement | Addressed by |
|-------------|--------------|
| R1: {desc} | T1, T3 |
| R2: {desc} | T2 |

## Risks
{List or "None identified"}
```

---

## Quick Commands

```
/plan        — Create plan from validated research
/plan verify — Verify existing plan against requirements
```
