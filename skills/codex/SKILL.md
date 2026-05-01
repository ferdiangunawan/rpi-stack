# Codex RPI Skills

This directory contains Codex-native skills for the RPI workflow: Research, Plan, Implement, Audit, and Review.

## Principles

- General coding first: frontend, backend, mobile, scripts, infrastructure, tests, and documentation.
- Project conventions first: `AGENTS.md`, manifests, nearby tests, and existing implementations override generic guidance.
- Optional profiles: framework-specific rules live under `rpi/references/profiles/` and are loaded only when relevant.
- Codex-native operation: use `.codex/output`, `.codex/sessions`, `update_plan`, terminal inspection, and concise direct user questions.
- Other-agent commands and session scripts do not belong in the Codex skill set.

## Skills

| Skill | Purpose |
|-------|---------|
| `rpi` | Orchestrates the full workflow and chooses fast, standard, or strict mode. |
| `research` | Gathers requirements and codebase evidence. |
| `plan` | Produces decision-complete implementation plans. |
| `audit` | Checks hallucination, overengineering, underengineering, and traceability. |
| `implement` | Executes plans with progress tracking and validation. |
| `code-review` | Reviews changes using P0/P1/P2 severity. |
| `audit-security` | Performs focused security review. |
| `audit-performance` | Performs focused performance review. |

## Output

Formal artifacts go in `.codex/output`:

- `research-{feature}.md`
- `plan-{feature}.md`
- `audit-{feature}-{phase}.md`
- `review-{feature}.md`

Long-running session state may go in `.codex/sessions`.

## Mode Defaults

- Use `fast` for clear, low-risk changes.
- Use `standard` for normal feature work and multi-file changes.
- Use `strict` for high-risk or ambiguous work such as auth, payments, migrations, data loss, security, or broad architecture changes.
