# Claude Code/Codex CLI Skills - RPI Framework

## Overview

This directory contains custom skills for the RPI (Research, Plan, Implement) methodology - a structured approach to software development that ensures quality through systematic validation.

## Agent Compatibility

These skills are used by both Claude Code and Codex CLI.

- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.
- SKILLS_DIR: `~/.claude/skills` for Claude Code, `~/.codex/skills` for Codex CLI.
- Slash commands like `/rpi` are Claude Code syntax; in Codex CLI, invoke the skill by name in the prompt.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           RPI WORKFLOW                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   INPUT              RESEARCH           AUDIT            PLAN               │
│  ┌──────┐           ┌──────┐          ┌──────┐         ┌──────┐            │
│  │ Jira │──────────▶│      │─────────▶│      │────────▶│      │            │
│  │ PRD  │           │      │  PASS?   │      │  PASS?  │      │            │
│  │Prompt│           │      │          │      │         │      │            │
│  └──────┘           └──────┘          └──────┘         └──────┘            │
│                         │                                  │                │
│                         ▼                                  ▼                │
│                    research.md                         plan.md              │
│                                                                             │
│                     AUDIT             IMPLEMENT         REVIEW              │
│                    ┌──────┐          ┌──────┐         ┌──────┐             │
│               ────▶│      │─────────▶│      │────────▶│      │             │
│                    │      │  PASS?   │      │         │      │             │
│                    │      │          │      │         │      │             │
│                    └──────┘          └──────┘         └──────┘             │
│                                          │                │                 │
│                                          ▼                ▼                 │
│                                       CODE            APPROVED              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Available Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| **RPI** | `/rpi` | Full workflow orchestrator |
| **Research** | `/research` | Gather context and assess confidence |
| **Audit** | `/audit` | Validate against over/under/hallucination |
| **Plan** | `/plan` | Create detailed implementation plan |
| **Implement** | `/implement` | Execute plan with tracking |
| **Code Review** | `/code-review` | Review code with P0/P1/P2 severity |
| **Reimplement** | `/reimplement` | Reimplement commits/PRs between Kick Avenue and Kard Avenue repos |

---

## Quick Start

### Full RPI Workflow

Claude Code uses slash commands; Codex CLI uses the skill name in the prompt.

```bash
# From Jira issue
/rpi KB-1234

# From Confluence PRD
/rpi https://kickavenue.atlassian.net/wiki/spaces/DEV/pages/123456

# From direct requirements
/rpi Add feature to export user data as CSV
```

### Individual Skills

Claude Code uses slash commands; Codex CLI uses the skill name in the prompt.

```bash
# Research only
/research KB-1234

# Audit a document
/audit research
/audit plan

# Create plan from research
/plan

# Implement from plan
/implement

# Code review
/code-review
/code-review path/to/file.dart
```

---

## Output Files

All RPI outputs are saved to OUTPUT_DIR:

```
OUTPUT_DIR/
├── research-{feature}.md    # Research findings
├── plan-{feature}.md        # Implementation plan
├── audit-{feature}.md       # Audit reports
└── review-{feature}.md      # Code review reports
```

---

## Quality Gates

### Gate 1: Research Validation
- Confidence Score ≥ 60%
- Hallucination Score ≤ 20%
- Coverage ≥ 80%

### Gate 2: Plan Validation
- All requirements traced to tasks
- No architectural violations
- Plan Score ≥ 70%

### Gate 3: Implementation Validation
- All tasks completed
- flutter analyze passes
- Code review approved

---

## Severity Levels

### Audit Scores
- **Hallucination**: Inventing requirements (target: ≤20%)
- **Overengineering**: Adding unnecessary complexity (target: ≤15%)
- **Underengineering**: Missing requirements (target: ≤15%)
- **Balance**: Sweet spot between over/under (target: ≥70%)

### Code Review
- **P0 (Critical)**: Must fix - security, crashes, data loss
- **P1 (Important)**: Should fix - bugs, performance, patterns
- **P2 (Nice-to-have)**: Consider - style, docs, minor improvements

---

## File Structure

Each skill is organized in its own subfolder with a `SKILL.md` file:

```
SKILLS_DIR/
├── README.md               # This file
├── audit/
│   └── SKILL.md            # Audit skill definition
├── code-review/
│   └── SKILL.md            # Code review skill definition
├── implement/
│   └── SKILL.md            # Implementation skill definition
├── plan/
│   └── SKILL.md            # Planning skill definition
├── research/
│   └── SKILL.md            # Research skill definition
└── rpi/
    └── SKILL.md            # RPI orchestrator skill definition
```

---

## Integration with AGENTS.md

All skills are designed to work with project-specific `AGENTS.md`:

1. **Research** reads AGENTS.md to understand project patterns
2. **Audit** validates against AGENTS.md conventions
3. **Plan** uses AGENTS.md patterns for task templates
4. **Implement** follows AGENTS.md strictly
5. **Code Review** checks AGENTS.md compliance

---

## Best Practices

### When to Use Full RPI
- New features with unclear scope
- Complex multi-file changes
- Features from Jira/Confluence PRD

### When to Use Individual Skills
- `/research` - When exploring feasibility
- `/audit` - When validating existing plans
- `/plan` - When scope is already clear
- `/implement` - When plan exists
- `/code-review` - After any significant code changes

### Tips
1. Always run full RPI for Jira tickets
2. Use audit between research and plan
3. Don't skip audit gates
4. Review code before marking complete
5. Keep outputs for documentation

---

## Adding New Skills

To add a new skill:

1. Create a subfolder: `SKILLS_DIR/{skill-name}/`
2. Create `SKILL.md` inside the subfolder with:
   - Skill metadata (name, description, trigger)
   - Skill logic and instructions
   - Output format
3. Restart Claude Code or Codex CLI to load the new skill

Example structure:
```
SKILLS_DIR/my-skill/
└── SKILL.md
```

---

## Troubleshooting

### "Low Confidence Score"
- Missing information in PRD
- Run `/research` with more specific query
- Ask stakeholder for clarification

### "Audit Failed"
- Review specific findings
- Address P0/P1 issues
- Re-run audit after fixes

### "Pattern Violation"
- Check AGENTS.md for correct pattern
- Look at similar existing code
- Follow project conventions exactly

### "Skill Not Found"
- Ensure skill folder exists: `SKILLS_DIR/{skill-name}/`
- Ensure `SKILL.md` file exists inside the folder
- Restart Claude Code or Codex CLI to reload skills
