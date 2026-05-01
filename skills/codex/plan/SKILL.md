---
name: plan
description: Creates a decision-complete implementation plan from requirements and research for general coding tasks in Codex.
---

# Plan Skill for Codex

Planning turns evidence into an implementation-ready sequence. The plan should remove decisions from the implementer without over-specifying obvious code details.

## Inputs

Use the best available context:

- Research artifact or conversation research.
- Requirements, Jira, PRD, or bug report.
- `AGENTS.md`, existing architecture, tests, and relevant profiles.

## Planning Rules

- Follow existing project patterns before introducing new patterns.
- Prefer minimal sufficient changes over speculative abstractions.
- Make public API, schema, CLI, config, or UX behavior explicit.
- Define failure behavior for realistic error paths.
- Ask only for high-impact product or architecture decisions that cannot be inferred.
- Record safe defaults as assumptions when asking would not materially change implementation.

## Task Model

Use compact task entries:

```markdown
### T{n}: {title}
- Type: {code|test|schema|config|docs|migration|cleanup}
- Area: {subsystem or component}
- Depends on: {task ids or none}
- Work: {specific behavior to implement}
- Acceptance: {observable completion criteria}
- Validation: {test/check/scenario}
```

Task ordering rules:

- Interfaces and contracts before consumers.
- Data/schema/migration before code that depends on it.
- Core logic before UI/CLI wrappers.
- Tests adjacent to the code they validate.
- Cleanup after behavior is proven.

## Required Decisions

Include these only when relevant:

- API/CLI/config contract: names, inputs, outputs, status codes, flags, environment variables.
- Data shape: schema fields, migrations, defaults, compatibility rules.
- UI behavior: loading, empty, error, success, disabled, and permission states.
- Backend behavior: validation, auth/authz, idempotency, transactions, retries, error mapping.
- Rollout behavior: feature flags, backwards compatibility, migration order, monitoring.

## Output

For standard/strict RPI, write `.codex/output/plan-{feature}.md`:

```markdown
# Implementation Plan: {Feature}

## Summary
- Goal: {goal}
- Mode: {fast|standard|strict}
- Risk: {low|normal|high}

## Key Changes
- {behavior-level change}

## Interfaces and Contracts
- {API/schema/CLI/config/public type changes, or "None"}

## Tasks
### T1: {title}
- Type: {type}
- Area: {area}
- Depends on: none
- Work: {work}
- Acceptance: {criteria}
- Validation: {command/scenario}

## Test Plan
- {unit/integration/e2e/manual scenario}

## Assumptions
- {safe default or confirmed decision}
```

For fast mode, provide a short implementation checklist in the conversation or `update_plan` instead of writing a full artifact.
