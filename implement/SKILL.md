---
name: implement
description: Executes implementation plan with quality checks and progress tracking. Follows AGENTS.md patterns strictly.
---

# Implement Skill

Executes the validated plan systematically, task by task, with verification at each step.

---

## Agent Compatibility

- TodoWrite: use the tool in Claude Code; in Codex CLI, use `update_plan` or a simple checklist.
- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.

---

## Phase 1: Preparation

### 1.1 Load Context

Before writing any code:

```
Required Reading (in order):
├── AGENTS.md                    ← Project patterns & conventions (read first, always)
├── plan-{feature}.md            ← Implementation plan
├── research-{feature}.md        ← Research context
└── Reference files from plan    ← Similar existing implementations
```

### 1.2 Context Checklist

```
□ AGENTS.md fully read — understand state management, models, styling, widget structure
□ Plan fully loaded — all tasks, dependencies, and acceptance criteria known
□ Reference code reviewed — similar existing implementations identified
```

### 1.3 Initialize Task Tracking

Set up progress tracking before starting:

```
TodoWrite (Claude Code) or update_plan (Codex CLI):
  T1: {title} — pending
  T2: {title} — pending
  ...all tasks from plan
```

---

## Phase 2: Execution

### 2.1 Task Execution Order

For each task in dependency order:
1. Mark task **in_progress**
2. Read related existing code (don't assume — verify)
3. Implement following AGENTS.md patterns exactly
4. Verify acceptance criteria
5. Run lint / analyze
6. Mark task **completed**
7. Move to next task

**One task at a time. Never skip ahead.**

### 2.2 Implementation Rules

```
1. Follow AGENTS.md patterns EXACTLY — check before writing every new file
2. Use existing components — don't rebuild what already exists
3. No scope creep — only implement what's in the plan
4. No hardcoded values — use project constants (check AGENTS.md for names)
5. Define constants ONCE, reference everywhere
6. Verify library behavior from docs or source — never assume
```

### 2.3 Per-Task Verification

After each task, confirm:
```
□ Code compiles (no errors)
□ Lint passes
□ Follows AGENTS.md patterns
□ All acceptance criteria for this task met
□ No unplanned code added
```

### 2.4 If Implementation Hits a Problem

```
Minor issue (typo, wrong import):
  → Fix and continue

Design issue (plan is wrong for this layer):
  → Stop, revise plan, re-audit if significant

Fundamental issue (research was incomplete):
  → Stop, return to research phase
```

---

## Phase 3: Verification

After all tasks complete:

```
□ All tasks marked completed
□ Full lint / analyze passes
□ Feature works as specified (review acceptance criteria)
□ No regressions in existing functionality
□ No hardcoded values
```

---

## Phase 4: Code Review (Auto-Triggered)

After verification, trigger code review:

```
Claude Code: Use Task tool with subagent_type: "code-reviewer"
Other agents: Invoke /code-review skill

Scope: all new and modified files from the plan's file inventory
```

The code review covers correctness, security, performance, and pattern compliance.

---

## Output Summary

After implementation complete:

```markdown
# Implementation Summary: {Feature Name}

## Status
- Tasks Completed: {X}/{Total}
- Lint: {PASS/FAIL}
- Pattern compliance: {PASS/FAIL}

## Files Changed

### Created
| File | Purpose |
|------|---------|
| `path` | {purpose} |

### Modified
| File | Changes |
|------|---------|
| `path` | {changes} |

## Deviations from Plan
{Any deviations and reasons, or "None"}

## Next Steps
1. Code review (triggered)
2. {other items}
```

---

## Quick Commands

```
/implement           — Start implementation from plan
/implement continue  — Continue from last checkpoint
/implement task T5   — Start from specific task
/implement verify    — Run verification only
```
