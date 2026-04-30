# RPI Stack

Lean Research-Plan-Implement workflow system for Claude Code, Codex CLI, and GitHub Copilot CLI. Quality-gated, context-preserving, and focused on keeping the LLM productive — not on ceremony.

---

## Design Principles

1. **Linear and clear** — the workflow is a straight line; no branching machinery
2. **Low ceremony** — skills are focused instructions, not process frameworks
3. **Qualitative over numeric** — quality gates use clear pass/fail criteria, not invented percentages
4. **Outputs as state** — output files are the source of truth; no separate session JSON
5. **Ask once** — clarification questions are batched and asked in a single step

---

## Architecture

```
Input (Jira / PRD / Prompt)
         │
         ▼
   [RESEARCH]  ─── Ask all clarifying questions at once (if any)
         │          Output: research-{feature}.md
         ▼
  [AUDIT RESEARCH]  ─── PASS / WARN / FAIL (qualitative)
         │ FAIL → revise and re-run
         ▼
    [PLAN]  ─── Ask all open questions at once (if any)
         │       Output: plan-{feature}.md
         ▼
  [AUDIT PLAN]  ─── All requirements traced? Balanced? Pattern-compliant?
         │ FAIL → revise and re-run
         ▼
 [USER APPROVAL]  ─── Present plan summary, wait for explicit yes
         │
         ▼
  [IMPLEMENT]  ─── Task by task, verify each, lint after each
         │          Output: code changes
         ▼
 [CODE REVIEW]  ─── Correctness + Security + Performance (P0/P1/P2)
                    Output: review-{feature}.md
```

---

## Skills

| Skill | Purpose |
|-------|---------|
| `/rpi` | Full orchestrator — runs all skills in sequence |
| `/research` | Gather context; ask clarifying questions as a batch |
| `/audit` | Qualitative gate: PASS/WARN/FAIL for hallucination, scope, traceability |
| `/plan` | Task breakdown with dependencies; ask open questions as a batch |
| `/implement` | Task-by-task execution following AGENTS.md |
| `/code-review` | Final review: correctness, security, performance, patterns |

---

## Hooks (Behavioral Guards)

| Hook | Trigger | Purpose |
|------|---------|---------|
| `rpi-audit-before-implement` | `/implement` without passing plan audit | Enforces plan audit gate |
| `rpi-p0-blocker` | Marking complete with P0 findings | Prevents merging critical issues |

---

## Usage

```bash
# Full workflow
/rpi KB-1234
/rpi https://confluence.example.com/pages/123
/rpi "Add CSV export for user orders"

# Individual skills
/research KB-1234     # Research only
/audit research       # Audit the research output
/audit plan           # Audit the plan output
/plan                 # Create plan from research
/implement            # Execute plan
/code-review          # Review all changes
```

---

## Output Files

All outputs land in OUTPUT_DIR (`.claude/output`, `.codex/output`, or `.copilot/output`):

```
OUTPUT_DIR/
├── research-{feature}.md         # Research findings + confidence
├── audit-research-{feature}.md   # Research quality gate report
├── plan-{feature}.md             # Task breakdown + file inventory
├── audit-plan-{feature}.md       # Plan quality gate report
└── review-{feature}.md           # Code review report (P0/P1/P2)
```

These files serve as the session state. To resume after context loss: read the output files and pick up at the right step.

---

## Quality Gates

### Audit: Research
- **Hallucination check**: No claims invented without basis in requirements
- **Scope check**: Nothing excessive added, nothing critical missing
- **Confidence check**: Enough is known to plan without major unknowns

### Audit: Plan
- **Traceability**: Every requirement maps to at least one task
- **Scope balance**: No overengineering, no underengineering
- **Pattern compliance**: Tasks follow AGENTS.md conventions

### Code Review
- **P0** (critical): Must fix before merge — security vulns, memory leaks, blocking I/O, crashes
- **P1** (important): Should fix — logic errors, missing validation, pattern violations
- **P2** (nice-to-have): Consider — style, minor perf, refactoring

---

## Installation

```bash
# Copy skills to your agent's skills directory
cp -r rpi research audit plan implement code-review ~/.claude/skills/
cp -r hooks/* ~/.claude/hooks/

# For Codex CLI
cp -r rpi research audit plan implement code-review ~/.codex/skills/

# For Copilot CLI
cp -r rpi research audit plan implement code-review ~/.copilot/skills/
```

---

## Integration with AGENTS.md

All skills reference the project's `AGENTS.md`:
1. **Research** reads AGENTS.md to understand existing patterns
2. **Audit** checks plan compliance against AGENTS.md conventions
3. **Implement** follows AGENTS.md patterns exactly — read before every new file
4. **Code Review** checks AGENTS.md adherence in all changed files
