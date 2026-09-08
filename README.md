# RPI Stack

Adaptive Research-Plan-Implement workflow system for modern AI coding agents: **Claude Code**, **OpenAI Codex**, and **Google Antigravity / Gemini CLI**.

Quality-gated, context-preserving, and engineered to maximize LLM agency without process overhead or learned helplessness.

---

## Core Design Principles

1. **Adaptive Depth** — Fast-Path for single-file bugfixes; Deep-Path for multi-step architectural features.
2. **Smart Clarification** — Inspect first; apply safe documented defaults for internal choices; provide opinionated recommendations with trade-offs when asking material questions.
3. **Decoupled Architecture** — 6 universal core skills with pluggable domain profiles (`flutter.md`, `frontend.md`, `backend.md`, `scripts.md`).
4. **Adversarial Quality Gates** — Grounded evidence checks and qualitative PASS/WARN/FAIL verdicts.
5. **Universal Agent Support** — First-class integration for Claude Code, Codex, and Antigravity / Gemini CLI.

---

## Architecture & Workflows

### Tier 1: Fast-Path (Tactical)
For bugfixes, minor refactors, and isolated components (< 3 files):
```text
Input (Bug / Task) ──► Grounded Plan & Checks ──► Implement ──► Scoped Review
```

### Tier 2: Deep-Path (Strategic)
For complex features, new APIs, multi-file refactors, or Jira tickets:
```text
Input (Jira / PRD / Prompt)
         │
         ▼
   [RESEARCH]  ─── Smart clarification (recommendations + trade-offs)
         │          Output: research-{feature}.md
         ▼
  [AUDIT RESEARCH] ─── Optional check for high-risk / exploratory work
         │
         ▼
     [PLAN]  ─── Verification-first task breakdown with dependency ordering
         │       Output: plan-{feature}.md
         ▼
   [AUDIT PLAN]  ─── Quality gate: Evidence integrity + Scope balance + AGENTS.md
         │ FAIL → revise and re-audit
         ▼
  [USER APPROVAL]  ─── Concise plan summary; wait for explicit human confirmation
         │
         ▼
   [IMPLEMENT]  ─── Sequential execution with safety rails against remote test DBs
         │          Output: code modifications
         ▼
  [CODE REVIEW]  ─── Multi-vector review: Correctness + Security + Performance (P0/P1/P2)
                     Output: review-{feature}.md
```

---

## The 6 Core Skills

| Skill | Purpose | Key Innovations |
|-------|---------|-----------------|
| `rpi` | Workflow orchestrator | Adaptive depth (Fast-Path vs Deep-Path), subagent delegation, resumable artifacts |
| `research` | Evidence gathering | Smart clarification (safe defaults + opinionated options), tool-agnostic connectors |
| `audit` | Adversarial quality gate | Evidence integrity, scope balance, blast radius safety, PASS/WARN/FAIL verdicts |
| `plan` | Task decomposition | Verification-first planning, dependency ordering, rollback considerations |
| `implement` | Systematic execution | Safe test execution rules, universal progress tracking, targeted verification |
| `code-review` | Multi-vector review | P0/P1/P2 classification, OWASP security, performance hot-paths, pattern compliance |

---

## Pluggable Domain Profiles

Domain conventions and framework-specific checklists live under `profiles/` rather than cluttering core skills:

- **[`profiles/flutter.md`](profiles/flutter.md)**: StateNotifier/Bloc immutability, `const` constructors, widget splitting, controller disposal, `flutter analyze`/`flutter test`.
- **[`profiles/frontend.md`](profiles/frontend.md)**: Next.js 15 App Router, Server vs Client components, Tailwind/Shadcn, a11y, hydration.
- **[`profiles/backend.md`](profiles/backend.md)**: API architecture, database migrations, transaction boundaries, idempotency, N+1 query prevention, authorization.
- **[`profiles/scripts.md`](profiles/scripts.md)**: POSIX shell standards, `set -euo pipefail`, dry-run support, argument validation.

---

## Agent Platform Support

| Agent | Skills Destination | Integration Details |
|-------|--------------------|---------------------|
| **Claude Code** | `~/.claude/skills` | Slash commands (`/rpi`) + native tool use |
| **OpenAI Codex** | `~/.codex/skills` | Prompt phrasing (`Use rpi...`) + `.codex-plugin/plugin.json` metadata |
| **Antigravity / Gemini CLI** | `~/.gemini/config/skills` | Slash commands or prompts + Native subagent execution |
| **Project-Local** | `.agents/skills` or custom | Isolated to active repository via `./install.sh --project` |

---

## Installation

### Fast Install (Auto-detects active agents)
```bash
git clone https://github.com/ferdiangunawan/rpi-stack.git
cd rpi-stack
./install.sh
```

### Targeted Installs
```bash
# Install specific agent
./install.sh claude
./install.sh codex
./install.sh gemini

# Install to all supported agents
./install.sh all

# Install into current project
./install.sh --project

# Dry run / preview actions
./install.sh --dry-run

# Remove installed skills
./install.sh --clean
```

Or using Makefile:
```bash
make install     # Install to all detected agents
make claude      # Claude Code only
make codex       # Codex only
make gemini      # Antigravity / Gemini CLI only
make diff        # Compare repo skills with installed skills
make clean       # Remove installed skills
```

---

## Usage Guide

Run RPI in your agent's normal execution mode:

### Claude Code (Slash Commands)
```text
/rpi KB-1234              # Full workflow for Jira issue
/rpi "Fix payment total"  # Adaptive Fast-Path or Deep-Path
/research KB-1234         # Research only
/audit plan               # Audit plan
/code-review              # Review changed files
```

### Codex / Copilot CLI (Natural Language Prompts)
```text
Use rpi to implement KB-1234
Use research to inspect the authentication flow
Use plan to break down this refactor
Use code-review to review my git diff
```

### Antigravity / Gemini CLI
```text
/rpi KB-1234
Use rpi to implement this ticket
```

---

## Resumability

RPI artifacts in `OUTPUT_DIR` (`.claude/output`, `.codex/output`, or project artifacts) provide durable state:
- `research-{feature}.md`
- `audit-research-{feature}.md`
- `plan-{feature}.md`
- `audit-plan-{feature}.md`
- `review-{feature}.md`

To resume work after context compaction or across sessions, simply invoke `/rpi {feature}`. RPI will detect the existing documents and pick up seamlessly at the next unfinished phase.
