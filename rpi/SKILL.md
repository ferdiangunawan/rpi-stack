---
name: rpi
description: Orchestrates adaptive Research-Plan-Implement workflows with quality gates. Supports Fast-Path for bugfixes and Deep-Path for multi-step features.
---

# RPI — Research, Plan, Implement (Orchestrator)

The core workflow orchestrator that coordinates research, planning, implementation, quality gates, and code review with adaptive depth.

```text
Tier 1 (Fast-Path):  Grounded Plan & Verification ───────────► Implement ──► Scoped Review
Tier 2 (Deep-Path):  Research ──► Audit ──► Plan ──► Audit ──► User Gate ──► Implement ──► Code Review
```

---

## Agent Compatibility & Ecosystem

- **Output Directory**: Writes artifacts to `OUTPUT_DIR` (`.claude/output`, `.codex/output`, or project artifacts directory) when requested or in multi-session mode; supports inline conversational handoffs for fast iteration.
- **Subagent Parallelism**: When subagent tools are present (`invoke_subagent` in Antigravity, `Task` in Claude Code), delegates read-only research and adversarial review to subagents to preserve main agent context.
- **Sub-skill Invocation**: Uses the `Skill` tool (Claude Code), prompts (Codex), or native skill/tool dispatch (Antigravity).

---

## Workflow Tiers (Adaptive Depth)

Determine the appropriate workflow tier based on the task complexity:

### Tier 1: Fast-Path (Tactical)
**Criteria**: Localized bugfixes, small UI adjustments, single-component tweaks, or minor refactors (< 3 files, low architectural risk).
1. **Grounded Plan**: Inspect the codebase, read `AGENTS.md`, and formulate a compact task breakdown with verification steps in one step.
2. **Execute & Verify**: Implement the changes, run targeted lint/tests.
3. **Scoped Review**: Inspect git diff for correctness, security, and pattern compliance.

### Tier 2: Deep-Path (Strategic)
**Criteria**: New features, multi-file architectural changes, database migrations, authentication, public API changes, or Jira tickets/PRDs.
Follow the full 7-step quality-gated workflow below.

---

## Deep-Path Execution Protocol

### Step 1: Input Analysis & Naming
- Derive a canonical feature slug: Jira key (e.g. `KB-1234` → `kb-1234`), issue title, or prompt slug (e.g. `csv-export`).
- **Resumability Check**: If `OUTPUT_DIR/plan-{feature}.md` or `OUTPUT_DIR/research-{feature}.md` exists, read the existing state and resume at the first unfinished phase.

### Step 2: Research (`/research`)
- Gather requirements from Jira, PRD, or prompt.
- Inspect codebase patterns and relevant profile in `profiles/`.
- Apply **Smart Clarification**: use safe defaults for trivial UI/internal choices; batch material questions with opinionated recommendations.
- Produces: `research-{feature}.md` (or structured research handoff).

### Step 3: Research Audit (`/audit research`)
*Optional for medium tasks; recommended for high-risk, exploratory, or unfamiliar areas.*
- Quality check for evidence grounding and scope definition.
- If **FAIL**: Resolve blockers or ask for missing specifications before planning.

### Step 4: Plan (`/plan`)
- Break down implementation into atomic, dependency-ordered tasks.
- Specify exact verification commands for each task.
- Document architectural approach, assumptions, and blast radius.
- Produces: `plan-{feature}.md`.

### Step 5: Plan Audit (`/audit plan`)
- Mandatory quality gate before writing code:
  - **Evidence Integrity**: No fabricated APIs or hallucinated libraries.
  - **Scope Balance**: No unrequested overengineering; no missing edge cases.
  - **Feasibility & Safety**: Rollback considered, database safety verified.
  - **Pattern Compliance**: Follows `AGENTS.md` and domain profile.
- If **FAIL**: Revise plan and re-audit until **PASS** or acceptable **WARN**.

### Step 6: Human Gate (Approval)
Present a concise plan summary to the user before writing any code:

```text
Feature: {feature-name} ({complexity})
Tasks: {count} | New files: {n} | Modified: {n}

Tasks:
  T1: {title} (Verify: {command})
  T2: {title} (Verify: {command})

Quality Gate: Plan Audit: PASS ✓
Proceed with implementation?
```
Wait for explicit confirmation before proceeding.

### Step 7: Implement (`/implement`)
- Execute tasks in dependency order.
- Verify each task with targeted compilation/tests.
- Never run unauthorized destructive tests against non-local databases.

### Step 8: Code Review (`/code-review`)
- Review changed files for Correctness, Security (OWASP), Performance, and Pattern Compliance.
- Classify findings into P0 (Critical/Blocking), P1 (Important), and P2 (Minor).
- **Rule**: If P0 issues exist, resolve them immediately and re-verify before marking work complete.

---

## Quick Reference Commands

```bash
/rpi KB-1234               # Deep-Path feature from Jira
/rpi https://docs/.../prd  # Deep-Path feature from PRD
/rpi "Fix checkout total"  # Fast-Path or Deep-Path based on scope

# Individual skills for targeted execution:
/research <topic>
/plan
/audit plan
/implement
/code-review
```
