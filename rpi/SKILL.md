---
name: rpi
description: Use when implementing features from Jira tickets, PRDs, or user requirements. Orchestrates Research-Plan-Implement workflow with quality gates.
---

# RPI - Research, Plan, Implement (Orchestrator)

Full workflow orchestrator that invokes individual skills in sequence with quality gates.

```
Input → Research → Audit → Plan → Audit → Approve → Implement → Code Review
```

---

## Agent Compatibility

- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.
- Invoke sub-skills with the Skill tool (Claude Code) or by naming the skill in the prompt (Codex CLI / Copilot CLI).

## When to Use

- User provides a Jira issue key (e.g., KB-1234)
- User provides a Confluence PRD URL
- User describes a feature to implement

---

## Step 1: Input & Feature Naming

Derive **feature name** from input (used for all output files):
- Jira key `KB-1234` → `kb-1234`
- Confluence URL → sanitized page title slug
- Direct prompt → short slug, max 30 chars (e.g., `export-csv`)

**Resume:** If output files for this feature already exist in OUTPUT_DIR (e.g., `research-{feature}.md`), read them and skip to the appropriate step.

---

## Step 2: Research

Invoke `/research {input}`. Produces `OUTPUT_DIR/research-{feature}.md`.

---

## Step 3: Research Audit

Invoke `/audit research`. Quality gate:

| Check | Gate |
|-------|------|
| All requirements traceable | No phantom requirements |
| Confidence high enough to plan | No major open unknowns |

**FAIL** → Stop, report findings, ask user for clarification, re-run `/research`.
**PASS** → Proceed.

---

## Step 4: Plan

Invoke `/plan`. Produces `OUTPUT_DIR/plan-{feature}.md`.

---

## Step 5: Plan Audit

Invoke `/audit plan`. Quality gate:

| Check | Gate |
|-------|------|
| Every requirement has a task | Full traceability |
| No unnecessary scope added | No overengineering |
| No requirements missed | No underengineering |
| Follows AGENTS.md patterns | Pattern compliance |

**FAIL** → Revise plan, re-run `/audit plan`.
**PASS** → Proceed.

---

## Step 6: User Approval

Present a concise plan summary:

```
Feature: {feature name}
Tasks: {count} | New files: {n} | Modified: {n}

Tasks:
  T1: {title}
  T2: {title}
  ...

Quality Gates: Research Audit ✓ | Plan Audit ✓

Proceed with implementation? (yes/no)
```

Wait for explicit approval. If user requests changes, revise and re-audit before re-presenting.

---

## Step 7: Implement

Invoke `/implement`. Executes tasks in dependency order, verifies each, runs lint.

---

## Step 8: Code Review

Invoke `/code-review`. Reviews all new and modified files for correctness, security, and performance with P0/P1/P2 findings.

| Severity | Action |
|----------|--------|
| P0 (Critical) | Must fix before completing |
| P1 (Important) | Should fix, discuss with user |
| P2 (Nice-to-have) | Note for future |

If P0 found: fix all P0 issues, re-run `/code-review`.

---

## Output Files

| File | Phase |
|------|-------|
| `research-{feature}.md` | Research |
| `audit-research-{feature}.md` | Research Audit |
| `plan-{feature}.md` | Plan |
| `audit-plan-{feature}.md` | Plan Audit |
| `review-{feature}.md` | Code Review |

## Quick Reference

```bash
/rpi KB-1234              # From Jira
/rpi {confluence-url}     # From Confluence
/rpi "Add export feature" # From direct prompt
```

**Resume after context loss:** Output files in OUTPUT_DIR are the source of truth. Read `research-{feature}.md` and `plan-{feature}.md` to resume at the right step.

**Individual skills (standalone):**
- Use `/rpi` for complete feature implementation
- Use individual skills for targeted tasks or exploration
