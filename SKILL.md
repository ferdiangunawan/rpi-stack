# RPI Stack Skill Distribution

Lean Research-Plan-Implement workflow skills for Claude Code and Codex.

## Agent Compatibility

| Agent | Skills Directory | Output Directory | Invoke Method | Extra Tools |
|-------|------------------|------------------|---------------|-------------|
| Claude Code | `~/.claude/skills` | `.claude/output` | Slash commands, e.g. `/rpi` | Hookify guard files |
| Codex | `~/.codex/skills` | `.codex/output` | Skill name in prompt, e.g. `Use rpi...` | `.codex-plugin/plugin.json` metadata |

## Workflow

```
Input -> Research -> Audit -> Plan -> Audit -> Approve -> Implement -> Code Review
```

## Skills

| Skill | Purpose |
|-------|---------|
| `rpi` | Full workflow orchestrator |
| `research` | Gather context and batch clarifying questions |
| `audit` | PASS/WARN/FAIL gate for hallucination, scope, and traceability |
| `plan` | Create implementation-ready task breakdown |
| `implement` | Execute the approved plan |
| `code-review` | Review correctness, security, performance, and patterns |

The stack intentionally stays at 6 skills. Security and performance are review categories inside `code-review`, not separate skills.
