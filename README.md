# Claude/Codex Skills Repository

Centralized repository for Claude Code and Codex CLI skills. Maintains a single source of truth with version control.

## Prerequisites

### For Claude Code Users

**Required: Hookify Plugin**

The RPI workflow hooks require the `hookify` plugin. Install it in Claude Code:

```bash
# In Claude Code, run:
/install-plugin hookify
```

Or add to your Claude Code settings:
```json
{
  "plugins": ["hookify"]
}
```

Without hookify, the hooks in `skills/hooks/` will not function (skills still work, just without automation).

### For Codex CLI Users

No additional plugins required. Hooks are Claude Code specific.

---

## Quick Start

```bash
# Using Make
make install    # Sync to both ~/.claude/skills and ~/.codex/skills

# Using Shell Script
./install.sh    # Same as above
```

## Commands

### Makefile
```bash
# Sync Commands
make install      # Copy to both destinations
make claude       # Copy to ~/.claude/skills only
make codex        # Copy to ~/.codex/skills only
make diff         # Show differences between repo and installed
make clean        # Remove skills from destinations
make help         # Show available commands

# RPI Session Tracker
make tracker      # Show active session (detailed view)
make tracker-list # List all sessions with progress
make status       # Quick one-liner status
```

### Shell Script
```bash
./install.sh           # Copy to both destinations + setup aliases
./install.sh claude    # Copy to ~/.claude/skills only + aliases
./install.sh codex     # Copy to ~/.codex/skills only
./install.sh aliases   # Setup shell aliases only
```

### Shell Aliases (after install)
```bash
rpi-tracker            # Show active session (detailed view)
rpi-tracker-list       # List all sessions with progress
rpi-status             # Quick one-liner status
```
These work from any directory in your project.

## Skills

| Skill | Description |
|-------|-------------|
| `rpi` | Research-Plan-Implement orchestrator with session tracking |
| `research` | Gather context from Jira, Confluence, codebase (R-checkpoints) |
| `plan` | Create detailed implementation plans (P-checkpoints) |
| `implement` | Execute implementation with background audits |
| `audit` | Validate against overengineering/hallucination |
| `audit-security` | Security-focused audit (background mode available) |
| `audit-performance` | Performance-focused audit (background mode available) |
| `code-review` | Review code for correctness and security |

## CLI Utilities

```bash
# Display session tracker (ANSI colors)
./scripts/rpi-tracker.sh              # Active session
./scripts/rpi-tracker.sh {session-id} # Specific session
./scripts/rpi-tracker.sh --list       # List all sessions

# Quick status one-liner
./scripts/rpi-status.sh
```

## Session Tracking

Sessions enable cross-session continuity. Stored globally at `~/.claude/sessions/` so you can track sessions across all projects.

```bash
# Start tracked session
/rpi --session new KB-1234

# Resume session
/rpi --session resume {session-id}
/rpi --session resume              # Resume active

# View sessions (works from any directory)
/rpi --session list
/rpi --session status
rpi-tracker                        # Shell alias (after install)
rpi-tracker-list                   # List all sessions
```

## Adding New Skills

1. Create a new directory: `mkdir my-skill`
2. Add `SKILL.md` inside: `my-skill/SKILL.md`
3. Run `make install` to sync

## Directory Structure

```
rpi-stack/
├── Makefile              # Make-based installer
├── install.sh            # Shell script installer (syncs + configures hooks)
├── README.md             # This file
├── SKILL.md              # Root skill documentation
├── audit/
│   └── SKILL.md          # General audit skill
├── audit-security/
│   └── SKILL.md          # Security audit (P0: credentials, injection, XSS)
├── audit-performance/
│   └── SKILL.md          # Performance audit (P0: memory leaks, blocking)
├── code-review/
│   └── SKILL.md          # Code review skill
├── implement/
│   └── SKILL.md          # Implementation with background audits
├── plan/
│   └── SKILL.md          # Planning with P-checkpoints
├── research/
│   └── SKILL.md          # Research with R-checkpoints
├── rpi/
│   └── SKILL.md          # Orchestrator with session tracking
├── scripts/
│   ├── rpi-tracker.sh    # CLI ASCII tracker
│   ├── rpi-status.sh     # Quick status one-liner
│   └── rpi-session-save.sh  # Auto-save for native hooks
├── hooks/
│   ├── hookify.rpi-session-autosave.local.md
│   ├── hookify.rpi-phase-transition.local.md
│   ├── hookify.rpi-audit-before-implement.local.md
│   └── hookify.rpi-p0-blocker.local.md
├── templates/
│   └── sessions/
│       └── index.json    # Session tracker template
└── docs/
    └── claude-code-hooks-reference.md  # Hook events reference
```

## Hookify Integration

Hooks are stored in `hooks/` and synced to `~/.claude/` during install:

| Hook | Purpose |
|------|---------|
| `hookify.rpi-session-autosave.local.md` | Auto-save session on task progress |
| `hookify.rpi-phase-transition.local.md` | Track phase changes |
| `hookify.rpi-audit-before-implement.local.md` | Enforce audit before implement |
| `hookify.rpi-p0-blocker.local.md` | Block completion with P0 issues |

## Native Claude Code Hooks

In addition to Hookify, `install.sh` configures native Claude Code hooks in `~/.claude/settings.json`:

| Hook Event | Purpose |
|------------|---------|
| `PreCompact` | Auto-save RPI session before context compaction |
| `SessionEnd` | Auto-save RPI session when Claude Code exits |

These ensure RPI session state is preserved even if context runs out or session ends unexpectedly.

**Verify configuration:**
```bash
cat ~/.claude/settings.json | jq '.hooks'
```

See `docs/claude-code-hooks-reference.md` for detailed hook documentation.
