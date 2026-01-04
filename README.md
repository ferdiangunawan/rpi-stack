# RPI Stack

Research-Plan-Implement workflow system for Claude Code with session tracking, quality gates, and automatic context preservation.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              RPI STACK ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌───────────┐ │
│   │   RESEARCH   │────▶│    AUDIT     │────▶│     PLAN     │────▶│   AUDIT   │ │
│   │  R1/R2/R3    │     │  (research)  │     │  P1/P2/P3    │     │  (plan)   │ │
│   │  checkpoints │     │              │     │  checkpoints │     │           │ │
│   └──────────────┘     └──────────────┘     └──────────────┘     └─────┬─────┘ │
│                                                                         │       │
│                                                                         ▼       │
│   ┌──────────────┐     ┌──────────────┐     ┌──────────────────────────────┐   │
│   │ CODE REVIEW  │◀────│  IMPLEMENT   │◀────│      USER APPROVAL           │   │
│   │              │     │  + bg audits │     │                              │   │
│   └──────────────┘     └──────┬───────┘     └──────────────────────────────┘   │
│                               │                                                  │
│                               ▼                                                  │
│   ┌─────────────────────────────────────────────────────────────────────────┐   │
│   │                     BACKGROUND AUDITS (parallel)                         │   │
│   │    ┌─────────────────┐              ┌──────────────────┐                │   │
│   │    │ audit-security  │              │ audit-performance │                │   │
│   │    │ P0: credentials │              │ P0: memory leaks  │                │   │
│   │    │ P0: injection   │              │ P0: infinite loop │                │   │
│   │    └─────────────────┘              └──────────────────┘                │   │
│   └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                              HOOK SYSTEMS                                        │
│                                                                                  │
│   ┌─────────────────────────────┐     ┌─────────────────────────────────────┐   │
│   │      HOOKIFY (behavior)     │     │      NATIVE HOOKS (events)          │   │
│   │  ┌───────────────────────┐  │     │  ┌─────────────────────────────┐    │   │
│   │  │ Block impl w/o audit  │  │     │  │ PreCompact → save session   │    │   │
│   │  │ Block complete w/ P0  │  │     │  │ SessionEnd → save session   │    │   │
│   │  │ Auto-save on progress │  │     │  └─────────────────────────────┘    │   │
│   │  │ Track phase changes   │  │     │                                     │   │
│   │  └───────────────────────┘  │     │  Prevents context loss!             │   │
│   └─────────────────────────────┘     └─────────────────────────────────────┘   │
│                                                                                  │
├─────────────────────────────────────────────────────────────────────────────────┤
│                              SESSION TRACKING                                    │
│                                                                                  │
│   ~/.claude/sessions/                    CLI Tracker                            │
│   ├── index.json                         ┌────────────────────────────────┐     │
│   └── rpi-{feature}-{date}-{hash}/       │ rpi-tracker      (detailed)   │     │
│       ├── session.json                   │ rpi-tracker-list (all)        │     │
│       └── context-summary.md             │ rpi-status       (one-liner)  │     │
│                                          └────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## How It Works

### 1. RPI Workflow
```
/rpi KB-1234
    │
    ├─▶ /research      Gather context (Jira, Confluence, codebase)
    │   └─ R1/R2/R3    Mandatory question checkpoints
    │
    ├─▶ /audit         Validate research (≥60% confidence)
    │
    ├─▶ /plan          Create implementation plan
    │   └─ P1/P2/P3    Mandatory question checkpoints
    │
    ├─▶ /audit         Validate plan (100% traceability)
    │
    ├─▶ User Approval  Present plan, wait for approval
    │
    ├─▶ /implement     Execute with background audits
    │   └─ P0 found?   Inject finding, fix immediately
    │
    └─▶ /code-review   Final review
```

### 2. Session Tracking
Sessions persist across Claude Code restarts, context compactions, and crashes.

```bash
# Any /rpi command auto-creates a tracked session
/rpi KB-1234

# Resume later (even after context loss)
/rpi --session resume

# Check progress from terminal
rpi-tracker-list
```

### 3. Two Hook Systems

| System | Purpose | How It Works |
|--------|---------|--------------|
| **Hookify** | Control Claude's behavior | Pattern-matches on actions, can block/modify |
| **Native Hooks** | Preserve session state | Runs scripts on events (PreCompact, SessionEnd) |

**Why both?**
- Hookify can't run when context compacts (it's gone!)
- Native hooks run external scripts that survive context loss
- Together: behavior control + data preservation

---

## CLI Tracker Preview

### Detailed View (`rpi-tracker`)
```
╔════════════════════════════════════════════════════════════════════════════════╗
║                              RPI SESSION TRACKER                                ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  Session: rpi-kb-4149-20260103-a1b2c3                                          ║
║  Feature: KB-4149 Add user authentication                                       ║
║  Started: 2026-01-03 14:30:00                                                   ║
╠════════════════════════════════════════════════════════════════════════════════╣
║                                                                                 ║
║  Phase Progress:                                                                ║
║  [●] RESEARCH ──▶ [●] PLAN ──▶ [◐] IMPLEMENT ──▶ [ ] REVIEW                    ║
║                                                                                 ║
║  [███████████████████░░░░░░░░░░] 65%                                           ║
║                                                                                 ║
║  Tasks: 6/10 completed                                                          ║
║  Current: T7 - Implement login API endpoint                                     ║
║                                                                                 ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  Quality Gates:                                                                 ║
║    ✓ Research Audit    PASS  (92%)                                             ║
║    ✓ Plan Audit        PASS  (88%)                                             ║
║    ✓ Security Audit    PASS  (no P0)                                           ║
║    ○ Performance Audit RUNNING...                                               ║
║    ○ Code Review       PENDING                                                  ║
╠════════════════════════════════════════════════════════════════════════════════╣
║  Resume: /rpi --session resume rpi-kb-4149-20260103-a1b2c3                     ║
╚════════════════════════════════════════════════════════════════════════════════╝
```

### List View (`rpi-tracker-list`)
```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                                    RPI SESSIONS                                       ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                       ║
║  ▶ rpi-kb-4149-20260103-a1b2c3                                                       ║
║    KB-4149 Add user authentication                                                    ║
║    ◐ IMPLEMENT [███████████████░░░░░] 65%  Tasks: 6/10                               ║
║                                                                                       ║
║    rpi-kb-4102-20260102-x9y8z7                                                       ║
║    KB-4102 Fix payment validation                                                     ║
║    ● COMPLETE  [████████████████████] 100% Tasks: 4/4                                ║
║                                                                                       ║
║    rpi-kb-4088-20260101-m3n4o5                                                       ║
║    KB-4088 Refactor cart module                                                       ║
║    ◑ PLAN      [████████░░░░░░░░░░░░] 40%  Tasks: 2/5                                ║
║                                                                                       ║
╟──────────────────────────────────────────────────────────────────────────────────────╢
║  Total: 3 session(s)  │  ▶ = active  │  Commands: --help for options                 ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

### Quick Status (`rpi-status`)
```
RPI: kb-4149 | IMP | [███████░░░] 65% | T:6/10
```

---

## Prerequisites

### Required: jq
The install script uses `jq` for JSON processing:

```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt install jq
```

### For Claude Code Users

**Recommended: Use Edit Mode**

Run Claude Code in **Edit Mode** (not Plan Mode) when using RPI Stack:
- RPI Stack has its own `/plan` skill with P1/P2/P3 checkpoints
- Claude's Plan Mode conflicts with RPI's planning workflow
- Edit Mode allows full editing capabilities needed by `/implement`

> **Note:** RPI Stack still verifies before acting. The `/research` and `/plan` skills use `AskUserQuestion` at mandatory checkpoints (R1/R2/R3, P1/P2/P3) to clarify requirements and get approval before implementation. This provides the same safeguards as Plan Mode without the editing restrictions.

**Required: Hookify Plugin**

```bash
# In Claude Code, run:
/install-plugin hookify
```

Or add to settings:
```json
{
  "plugins": ["hookify"]
}
```

Without hookify:
- Skills still work
- Behavior hooks won't function (no blocking, no auto-enforcement)
- Native hooks still work (session preservation)

### For Codex CLI Users

No plugins required. Hooks are Claude Code specific.

---

## Quick Start

```bash
# 1. Clone the repo
git clone <repo-url> rpi-stack
cd rpi-stack

# 2. Install everything
./install.sh

# 3. Restart terminal (for aliases)
source ~/.zshrc  # or ~/.bashrc

# 4. Verify
rpi-tracker-list  # Should show empty sessions
cat ~/.claude/settings.json | jq '.hooks'  # Should show PreCompact/SessionEnd
```

**What `./install.sh` does:**
1. Syncs skills to `~/.claude/skills/`
2. Syncs hookify hooks to `~/.claude/`
3. Initializes `~/.claude/sessions/`
4. Configures native hooks in `~/.claude/settings.json`
5. Adds shell aliases to `~/.zshrc` or `~/.bashrc`

---

## Hookify vs Native Hooks

### Hookify (Behavior Control)

**What it is:** Markdown-based rules that intercept Claude's actions

```markdown
<!-- hookify.rpi-p0-blocker.local.md -->
When: Claude marks session complete AND P0 issues exist
Action: Block and remind to fix P0 first
```

**Can do:**
- Block specific tool calls
- Inject reminders into Claude's context
- Pattern-match on Claude's reasoning
- Enforce workflow rules

**Cannot do:**
- Run when context is lost (hookify rules are in context)
- Execute external scripts
- Persist data outside Claude's session

### Native Hooks (Event Scripts)

**What it is:** Shell commands triggered by Claude Code events

```json
{
  "hooks": {
    "PreCompact": [{ "hooks": [{ "type": "command", "command": "script.sh" }] }]
  }
}
```

**Can do:**
- Run external scripts on events
- Save data to files
- Survive context compaction
- Call APIs, log data

**Cannot do:**
- Influence Claude's behavior
- Block or modify tool calls
- Access Claude's reasoning

### Summary

| Feature | Hookify | Native Hooks |
|---------|---------|--------------|
| Trigger | Pattern-based | Event-based |
| Controls Claude | Yes | No |
| Survives compaction | No | Yes |
| External scripts | No | Yes |
| Configuration | Markdown files | JSON in settings.json |

**RPI Stack uses both:**
- **Hookify** → Enforce audit before implement, block P0 completion
- **Native** → Save session state before context loss

---

## Commands

### Makefile
```bash
make install        # Sync to both ~/.claude/skills and ~/.codex/skills
make claude         # Claude Code only
make codex          # Codex CLI only
make tracker        # Show active session
make tracker-list   # List all sessions
make status         # Quick one-liner
```

### Shell Aliases (after install)
```bash
rpi-tracker         # Detailed session view
rpi-tracker-list    # All sessions with progress
rpi-status          # Quick one-liner (for prompt integration)
```

### RPI Commands (in Claude Code)
```bash
/rpi KB-1234                    # Full workflow (auto-creates session)
/rpi --session resume           # Resume active session
/rpi --session resume {id}      # Resume specific session
/rpi --session list             # List sessions
```

---

## Skills

| Skill | Description |
|-------|-------------|
| `rpi` | Orchestrator with session tracking |
| `research` | Gather context (R1/R2/R3 checkpoints) |
| `plan` | Create implementation plans (P1/P2/P3 checkpoints) |
| `implement` | Execute with background audits |
| `audit` | Validate research/plan quality |
| `audit-security` | Security audit (P0: credentials, injection, XSS) |
| `audit-performance` | Performance audit (P0: memory leaks, blocking) |
| `code-review` | Final code review |

---

## Directory Structure

```
rpi-stack/
├── Makefile                    # Make-based installer
├── install.sh                  # Full installer (skills + hooks + aliases)
├── README.md                   # This file
├── SKILL.md                    # Root skill documentation
│
├── rpi/                        # Orchestrator
├── research/                   # Research skill (R-checkpoints)
├── plan/                       # Planning skill (P-checkpoints)
├── implement/                  # Implementation skill
├── audit/                      # General audit
├── audit-security/             # Security-focused audit
├── audit-performance/          # Performance-focused audit
├── code-review/                # Code review skill
│
├── scripts/
│   ├── rpi-tracker.sh          # CLI ASCII tracker
│   ├── rpi-status.sh           # Quick status
│   └── rpi-session-save.sh     # Auto-save for native hooks
│
├── hooks/                      # Hookify rules
│   ├── hookify.rpi-session-autosave.local.md
│   ├── hookify.rpi-phase-transition.local.md
│   ├── hookify.rpi-audit-before-implement.local.md
│   └── hookify.rpi-p0-blocker.local.md
│
├── templates/
│   └── sessions/
│       └── index.json          # Session registry template
│
└── docs/
    └── claude-code-hooks-reference.md
```

---

## Troubleshooting

### Hooks not working
```bash
# Check hookify plugin
/plugins  # In Claude Code

# Check native hooks
cat ~/.claude/settings.json | jq '.hooks'
```

### Session not saving
```bash
# Check sessions directory exists
ls ~/.claude/sessions/

# Re-run install
./install.sh
```

### Aliases not found
```bash
# Reload shell config
source ~/.zshrc  # or ~/.bashrc

# Or restart terminal
```

---

## License

MIT
