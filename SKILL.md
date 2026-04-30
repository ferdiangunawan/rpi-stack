# Claude Code/Codex CLI/Copilot CLI Skills - RPI Framework

## Overview

Lean Research-Plan-Implement methodology for structured, quality-gated software development.

## Agent Compatibility

| Agent | Skills Directory | Output Directory | Invoke Method |
|-------|------------------|------------------|---------------|
| Claude Code | `~/.claude/skills` | `.claude/output` | `/skill-name` |
| Codex CLI | `~/.codex/skills` | `.codex/output` | Skill name in prompt |
| Copilot CLI | `~/.copilot/skills` | `.copilot/output` | `/skills` command |

---

## Workflow

```
Input → Research → Audit → Plan → Audit → Approve → Implement → Code Review
```

---

## Available Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| **RPI** | `/rpi` | Full workflow orchestrator |
| **Research** | `/research` | Gather context and assess confidence |
| **Audit** | `/audit` | Validate research or plan (qualitative PASS/WARN/FAIL) |
| **Plan** | `/plan` | Create detailed implementation plan |
| **Implement** | `/implement` | Execute plan task by task |
| **Code Review** | `/code-review` | Review code: correctness, security, performance, patterns |

---

## Quick Start

```bash
# Full RPI workflow from Jira ticket
/rpi KB-1234

# Full RPI workflow from PRD URL
/rpi https://kickavenue.atlassian.net/wiki/spaces/DEV/pages/123456

# Full RPI workflow from direct requirements
/rpi Add feature to export user data as CSV

# Individual skills
/research KB-1234
/audit research
/audit plan
/plan
/implement
/code-review
```

---

## Output Files

```
OUTPUT_DIR/
├── research-{feature}.md         # Research findings
├── audit-research-{feature}.md   # Research audit report
├── plan-{feature}.md             # Implementation plan
├── audit-plan-{feature}.md       # Plan audit report
└── review-{feature}.md           # Code review report
```

---

## Quality Gates

### Gate 1: Research Audit
- No phantom requirements (invented without basis)
- No major unresolved open questions
- Confidence high enough to plan

### Gate 2: Plan Audit
- Every requirement traced to a task
- No overengineering or underengineering
- Follows AGENTS.md patterns

### Gate 3: Code Review
- P0 issues: **must be zero** before completion
- P1 issues: should fix before merge
- P2 issues: optional improvements

---

## Hooks (Behavioral Guards)

| Hook | Purpose |
|------|---------|
| `rpi-audit-before-implement` | Blocks `/implement` if plan audit hasn't passed |
| `rpi-p0-blocker` | Blocks completion when P0 issues are unresolved |

---

## File Structure

```
SKILLS_DIR/
├── SKILL.md              # This file
├── README.md             # Full documentation
├── rpi/SKILL.md          # Orchestrator
├── research/SKILL.md     # Research skill
├── audit/SKILL.md        # Audit skill
├── plan/SKILL.md         # Plan skill
├── implement/SKILL.md    # Implement skill
├── code-review/SKILL.md  # Code review skill (includes security + performance)
└── hooks/
    ├── hookify.rpi-audit-before-implement.local.md
    └── hookify.rpi-p0-blocker.local.md
```

---

## Best Practices

- Always run full `/rpi` for Jira tickets or complex features
- Use `/audit` between research and plan, and between plan and implement
- Never skip the audit gates
- `/code-review` runs automatically at end of `/implement` — check P0s before merging
- Output files serve as the resume state — if context is lost, re-read output files

---

## Adding New Skills

1. Create `SKILLS_DIR/{skill-name}/SKILL.md`
2. Add skill metadata (name, description), logic, and output format
3. Restart the agent to load the new skill
