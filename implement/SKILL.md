---
name: implement
description: Executes validated implementation plans systematically with progress tracking, safety rails, and per-task verification.
---

# Implement Skill

Executes an approved implementation plan step by step, applying code edits, running targeted validations, and respecting project safety boundaries.

## When to Use

- Executing an approved plan from the Plan phase.
- Applying targeted changes in code with verified checkpoints.
- Note: Do NOT make code modifications while the agent is in a read-only or planning-only mode.

## Agent Compatibility & Task Tracking

- **Task Tracking**: Use available tracking mechanisms:
  - Claude Code: `TodoWrite`
  - Codex / Copilot CLI: `update_plan` or checklist
  - Antigravity / Gemini CLI: checklist or `manage_task`
- **Context Maintenance**: Keep one active task `in_progress` at a time; mark `completed` before moving to the next.

---

## Phase 1: Pre-Execution Safety & Context

1. **Read Instructions**: Always read `AGENTS.md` and the relevant profile in `profiles/` before modifying code.
2. **Review Current Plan**: Verify that all tasks, file paths, and acceptance criteria are loaded.
3. **Safety Guardrails**:
   - **Never run destructive tests against remote/shared databases**: Never execute database reset, wipe, or heavy migration commands against staging or production environments. Verify local isolation before running backend database tests.
   - **Respect test restrictions**: If `AGENTS.md` restricts test execution (e.g. "Do not run Flutter tests"), honor it strictly.

---

## Phase 2: Execution Protocol

### Step-by-Step Execution:
1. **Focus**: Take the next uncompleted task in dependency order.
2. **Inspect**: Read existing target files and surrounding code. Never make blind edits.
3. **Implement**: Write code conforming strictly to `AGENTS.md` patterns, naming conventions, and style rules.
4. **Targeted Verification**:
   - Run compilation / typecheck (e.g. `tsc --noEmit`, `dart analyze`, `go build`).
   - Run targeted unit tests for the specific touched module.
   - Confirm acceptance criteria for this specific task.
5. **Mark Done**: Update task status to `completed` and proceed.

### Managing Unplanned Obstacles:
- **Minor issue** (syntax fix, missing import): Resolve and continue.
- **Design flaw / Plan divergence**: If actual codebase structure contradicts the plan, pause, update the plan notes, and adjust.
- **Scope expansion / Blocker**: If completing a task requires major out-of-scope work, stop and consult the user.

---

## Phase 3: Final Verification & Review Handoff

Once all tasks are marked complete:
1. **Full Static Check**: Run the repository's main lint or typecheck command.
2. **Diff Inspection**: Inspect git status and diff to confirm no stray files, unintended formatting changes, or commented-out debris remain.
3. **Trigger Code Review**:
   - If a code review subagent is supported, invoke it on the changed files.
   - Otherwise, run `/code-review` on the modified files to verify correctness, security, performance, and pattern compliance.

---

## Output Summary

Provide a concise completion summary:

```markdown
# Implementation Summary: {Feature Name}

## Status
- Tasks Completed: {X}/{Total}
- Static Analysis / Lint: {PASS / FAIL}
- Target Tests: {PASS / SKIPPED / NOT APPLICABLE}

## Files Modified
| File | Action | Summary of Changes |
|------|--------|--------------------|
| `path/to/file` | Created / Modified | {Brief description} |

## Deviations from Plan
{List any minor deviations and reasons, or "None"}

## Verification Performed
- `{lint command}`: PASSED
- `{test command}`: PASSED (or skipped per project rules)

## Next Step
Proceed to **Code Review** (`/code-review`).
```
