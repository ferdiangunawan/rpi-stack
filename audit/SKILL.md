---
name: audit
description: Validates research or plan against hallucination, overscoping, and traceability. Produces a clear PASS/WARN/FAIL verdict.
---

# Audit Skill

Quality gate that validates a research document or plan before the next phase begins.

---

## Agent Compatibility

- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.
- If an assumption needs user confirmation, ask directly — don't auto-fail.

## Audit Types

- `/audit research` — Validates research output before planning.
- `/audit plan` — Validates plan output before implementation.

---

## How to Run an Audit

### 1. Load Context

```
Required:
├── Artifact to audit (research-{feature}.md or plan-{feature}.md)
├── Original requirements (Jira description, PRD, or original prompt)
└── AGENTS.md (project conventions)
```

### 2. Run the Three Checks

For each check: list findings, then give a verdict.

---

## Check 1: Hallucination — Is anything invented?

Hallucination = a claim, requirement, or decision that is **not traceable** to the original requirements and is **not a reasonable technical necessity**.

### How to Check

For each requirement, decision, or task in the artifact:
- Can it be traced to the PRD / Jira / prompt? → **Traceable**
- Is it a reasonable inference from context or technical necessity? → **Justified**
- Is it invented with no basis? → **Hallucination**

**Important:** If something looks like an assumption, **ask the user first** before marking it as a hallucination. If the user confirms it → "User-confirmed assumption" (not a hallucination).

### Verdicts

| Finding | Verdict |
|---------|---------|
| No hallucinations found | ✅ PASS |
| Minor assumptions (user-confirmed or clearly justified) | ⚠️ WARN |
| Invented requirements with no basis | ❌ FAIL |

---

## Check 2: Scope Balance — Is it the right amount of work?

Overengineering = adding things not required (abstractions, configs, future-proofing).
Underengineering = missing requirements, missing error handling, missing edge cases.

### How to Check

**Overengineering signals:**
- Abstractions or layers that serve no current requirement
- Configuration options not asked for
- "Future-proofing" without specification
- New patterns when existing patterns suffice

**Underengineering signals:**
- PRD requirements with no corresponding task or coverage
- Happy-path-only implementation (missing error/empty/loading states)
- Missing input validation or auth checks
- Acceptance criteria with no task addressing them

### Verdicts

| Finding | Verdict |
|---------|---------|
| Nothing extraneous, nothing missing | ✅ PASS |
| Minor scope issues that don't block | ⚠️ WARN |
| Significant scope creep or requirement gaps | ❌ FAIL |

---

## Check 3: Traceability — Does every requirement have coverage?

Build a simple matrix: each requirement → covered by task(s) or explained why not.

| Requirement | Covered by | Status |
|-------------|------------|--------|
| R1: {desc} | T1, T3 | ✅ Full |
| R2: {desc} | T2 | ✅ Full |
| R3: {desc} | — | ❌ Missing |

### Verdicts

| Finding | Verdict |
|---------|---------|
| All requirements covered | ✅ PASS |
| Some partial coverage with clear reason | ⚠️ WARN |
| Requirements with no coverage | ❌ FAIL |

---

## Overall Verdict

| Result | Meaning | Action |
|--------|---------|--------|
| **PASS** | All checks green or warn-level | Proceed to next phase |
| **WARN** | Minor issues noted, nothing blocking | Proceed with caution; note items for review |
| **FAIL** | At least one check failed | Stop; fix issues; re-audit |

---

## Output Template

Save to `OUTPUT_DIR/audit-{type}-{feature}.md`:

```markdown
# Audit Report: {Feature} ({Research / Plan})

## Check 1: Hallucination
**Verdict: {PASS / WARN / FAIL}**

Findings:
- {item}: {Traceable / Justified / Hallucination — reason}

{If hallucination: List what must be removed or confirmed}

---

## Check 2: Scope Balance
**Verdict: {PASS / WARN / FAIL}**

Overengineering findings:
- {item or "None"}

Underengineering findings:
- {item or "None"}

{Recommended additions or removals}

---

## Check 3: Traceability

| Requirement | Covered by | Status |
|-------------|------------|--------|
| R1: {desc} | {tasks} | ✅ / ⚠️ / ❌ |

**Verdict: {PASS / WARN / FAIL}**

---

## Pattern Compliance (Plan Audit Only)

| Pattern | Status | Notes |
|---------|--------|-------|
| {pattern from AGENTS.md} | ✅ / ❌ | {notes} |

---

## Overall: {PASS / WARN / FAIL}

### Blocking Issues (must fix before proceeding)
{List or "None"}

### Non-Blocking Issues (noted for awareness)
{List or "None"}

### Next Steps
1. {action}
```

---

## Quick Commands

```
/audit research  — Audit the research output
/audit plan      — Audit the plan output
```
