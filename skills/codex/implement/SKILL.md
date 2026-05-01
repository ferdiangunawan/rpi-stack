---
name: implement
description: Executes an implementation plan in Codex with progress tracking, validation, and review. General-purpose across languages and frameworks.
---

# Implement Skill for Codex

Implement executes the plan with minimal scope creep and continuous validation.

## Preparation

Before editing code:

- Read the plan or derive a compact checklist from the request.
- Read `AGENTS.md` and relevant project docs.
- Inspect similar existing code and nearby tests.
- Detect relevant validation commands from manifests and scripts.
- Load relevant RPI profile references only when useful.

Use `update_plan` for multi-step work. One task may be `in_progress` at a time.

## Execution Rules

- Work in dependency order.
- Keep changes scoped to stated requirements and plan assumptions.
- Prefer existing utilities, architecture, naming, and error patterns.
- Do not rewrite unrelated code.
- Do not introduce new dependencies unless required or explicitly justified.
- Validate each meaningful task before marking it complete.
- If implementation reveals a plan flaw, pause, revise the plan, then continue.
- Preserve user changes and never revert unrelated edits.

## Validation Selection

Choose the most specific validation available:

| Project Signal | Common Validation |
|----------------|-------------------|
| `package.json` | `npm test`, `npm run lint`, `npm run typecheck`, project scripts |
| `pyproject.toml` / `requirements.txt` | `pytest`, `ruff`, `mypy`, project scripts |
| `go.mod` | `go test ./...`, `go vet ./...` |
| `Cargo.toml` | `cargo test`, `cargo clippy`, `cargo fmt --check` |
| `pubspec.yaml` | `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test` |
| build files / CI config | Matching targeted build or check command |

Run targeted tests first, then broader checks when the change scope justifies it. If a command cannot be run, report why.

## Security and Performance Checks

For high-risk or relevant changes:

- Run the `audit-security` skill for auth, permissions, secrets, input validation, external calls, or sensitive data.
- Run the `audit-performance` skill for hot paths, large data, UI rendering, concurrency, memory, or I/O changes.
- Fix all P0 issues before completing.

Use subagents only when the user explicitly requested parallel agent work or the environment policy allows it for the current task.

## Review

After implementation:

- Run the `code-review` skill on modified areas.
- Fix all P0 findings.
- Fix P1 findings unless explicitly deferred with rationale.
- Summarize P2 findings only when useful.

## Final Summary

Report:

- What changed.
- Important files or subsystems touched.
- Validation commands and results.
- Review status and remaining risks.
- Any tests not run and why.
