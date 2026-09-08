# RPI Stack Skill Distribution

Adaptive Research-Plan-Implement workflow skills for modern AI coding agents (Claude Code, OpenAI Codex, and Antigravity / Gemini CLI).

## Agent Compatibility & Discovery

| Agent | Skills Directory | Output Directory | Invoke Method | Integration Features |
|-------|------------------|------------------|---------------|----------------------|
| **Claude Code** | `~/.claude/skills` | `.claude/output` | Slash commands, e.g. `/rpi` | Native tool use & subagents |
| **OpenAI Codex** | `~/.codex/skills` | `.codex/output` | Prompt phrasing, e.g. `Use rpi...` | `.codex-plugin/plugin.json` metadata |
| **Antigravity / Gemini CLI** | `~/.gemini/config/skills` | `.gemini/output` or artifacts | Slash commands or prompt | Native subagent & tool execution |

## Adaptive Workflow Tiers

```text
Tier 1 (Fast-Path):  Grounded Plan & Verification ───────────► Implement ──► Scoped Review
Tier 2 (Deep-Path):  Research ──► Audit ──► Plan ──► Audit ──► User Gate ──► Implement ──► Code Review
```

## The 6 Core Skills

| Skill | Purpose | Key Innovations |
|-------|---------|-----------------|
| `rpi` | Full workflow orchestrator | Adaptive depth (Fast-Path vs Deep-Path), subagent delegation, resumability |
| `research` | Evidence gathering & mapping | Smart clarification (safe defaults + opinionated recommendations), tool-agnostic |
| `audit` | Adversarial quality gate | Evidence integrity, scope balance, blast radius safety, PASS/WARN/FAIL verdicts |
| `plan` | Actionable task breakdown | Verification-first planning, dependency ordering, rollback considerations |
| `implement` | Systematic execution | Safe test execution rules, universal progress tracking, targeted verification |
| `code-review` | Multi-vector inspection | P0/P1/P2 classification, OWASP security, performance hot-paths, pattern compliance |

## Pluggable Domain Profiles (`profiles/`)

Domain-specific conventions and checks are decoupled into modular reference profiles:
- `profiles/flutter.md`: Flutter SDK, Riverpod/Bloc immutability, controller disposal, widget rebuilding.
- `profiles/frontend.md`: Next.js 15, React Server Components vs Client Components, Tailwind/Shadcn, a11y.
- `profiles/backend.md`: APIs, transactions, database migrations, N+1 query prevention, authorization.
- `profiles/scripts.md`: Shell scripting, POSIX standards, command injection guards, dry-run flags.
