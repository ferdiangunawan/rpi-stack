---
name: rpi
description: Use for coding work that benefits from a Research-Plan-Implement workflow in Codex. Orchestrates research, planning, audits, implementation, validation, and review for general software projects across frontend, backend, mobile, scripts, infrastructure, and tests.
---

# RPI - Research, Plan, Implement for Codex

RPI is the full workflow for feature work, refactors, bug fixes with uncertain scope, Jira/PRD implementation, and high-risk changes. It is Codex-native and general coding first. Framework-specific rules are loaded from project files or optional profiles, not hardcoded in the core workflow.

## Codex Contract

- Output directory: `.codex/output` in the active project.
- Optional session directory: `.codex/sessions` in the active project.
- Progress tracking: use `update_plan` for task state when implementation begins.
- User questions: ask concise direct questions only when repo inspection cannot resolve a high-impact ambiguity.
- Project conventions: prefer `AGENTS.md`, README files, manifests, nearby tests, and existing implementations over generic advice.
- Do not use slash-command syntax or proprietary todo/question tool names from other agents in Codex skills.

## Modes

Choose the lightest mode that protects correctness.

| Mode | Use When | Flow |
|------|----------|------|
| `fast` | Small bug fixes, obvious refactors, low-risk UI/content changes | inspect -> mini-plan -> implement -> validate -> review summary |
| `standard` | Default for normal feature work and multi-file changes | research -> plan -> implement -> validate -> review |
| `strict` | Auth, payments, migrations, data loss risk, security, large architecture changes, unclear PRD/Jira | research artifact -> audit -> detailed plan -> audit -> approval checkpoint -> implement -> review |

Default to `standard`. Downgrade to `fast` only when the change is low risk and requirements are clear. Upgrade to `strict` when failure impact is high or requirements are ambiguous.

## Profile Selection

Before planning implementation, identify the project shape from files and existing code:

- Flutter/Dart: `pubspec.yaml`, `lib/`, `test/`, Flutter imports. Load `references/profiles/flutter.md`.
- Frontend web: `package.json`, React/Vue/Svelte/Next/Vite files, browser UI. Load `references/profiles/frontend.md`.
- Backend/API: server entrypoints, routers/controllers, database/schema files, API tests. Load `references/profiles/backend.md`.
- Scripts/tooling: CLI entrypoints, shell/Python/Node scripts, automation folders. Load `references/profiles/scripts.md`.

Load only relevant profiles. If `AGENTS.md` conflicts with a profile, `AGENTS.md` wins.

## Workflow

### 1. Input Detection

Classify the source:

- Jira issue key: fetch via Atlassian tools if available, otherwise use the prompt details.
- Confluence/PRD URL: fetch via Atlassian tools if available, otherwise ask for the missing document content.
- Direct prompt: extract goal, constraints, acceptance criteria, and risk level.
- Existing plan/research: resume from the most advanced reliable artifact.

Derive a short feature slug for artifact names.

### 2. Research

Use the `research` skill instructions. Gather only enough context for the selected mode.

Minimum research:

- Requirements and acceptance criteria.
- Similar existing implementations.
- Affected subsystems and boundaries.
- Validation commands and test patterns.
- Risks, unknowns, and assumptions.

Strict mode must write `.codex/output/research-{feature}.md` and audit it before planning.

### 3. Audit Research

Use the `audit` skill in strict mode, or when research contains important assumptions.

Gate targets:

- Confidence >= 60%.
- Hallucination <= 20%.
- Coverage >= 80% for must-have requirements.

If the gate fails, fix the research or ask the specific missing question before planning.

### 4. Plan

Use the `plan` skill instructions. The plan must be decision complete for the chosen mode.

Minimum plan contents:

- Implementation approach and boundaries.
- Task sequence with dependencies.
- Public interface/API/schema changes, if any.
- Edge cases and failure behavior.
- Test and validation commands.

Strict mode must write `.codex/output/plan-{feature}.md` and audit it before implementation.

### 5. Audit Plan

Use the `audit` skill in strict mode, or whenever scope, architecture, or generated tasks are uncertain.

Gate targets:

- Must-have requirements trace to implementation tasks.
- No unnecessary architecture or speculative future-proofing.
- No missing critical error handling, validation, security, or compatibility behavior.
- Project conventions from `AGENTS.md` and existing code are represented.

Revise the plan until it passes.

### 6. Approval Checkpoint

Only stop for explicit approval when:

- The user requested planning before implementation.
- The workflow is in strict mode and implementation would be high risk.
- The plan requires a product decision that cannot be derived from source material.

Otherwise continue implementation once the plan is sufficient.

### 7. Implement

Use the `implement` skill instructions.

Implementation rules:

- Track tasks with `update_plan` for multi-step work.
- Work in dependency order.
- Follow existing code style and architecture.
- Keep changes scoped to requirements.
- Validate before marking tasks complete.
- Do not use destructive commands unless explicitly requested or approved.

### 8. Review

Use the `code-review` skill after implementation.

- Fix all P0 findings.
- Fix P1 findings unless there is a clear reason to defer and the user is told.
- Include P2 findings only if useful.

## Artifacts

Use `.codex/output` for generated artifacts:

- `research-{feature}.md`
- `plan-{feature}.md`
- `audit-{feature}-{phase}.md`
- `review-{feature}.md`

Use `.codex/sessions/{session-id}.json` only for long-running or resumable work. Session tracking is optional for `fast` mode.

## Completion Criteria

A completed RPI run must provide:

- What changed.
- Files or subsystems touched.
- Validation run and result.
- Remaining risks or skipped validation.
- Review findings fixed or intentionally deferred.
