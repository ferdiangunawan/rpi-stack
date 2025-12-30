# Claude/Codex Skills Repository

Centralized repository for Claude Code and Codex CLI skills. Maintains a single source of truth with version control.

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
make install    # Copy to both destinations
make claude     # Copy to ~/.claude/skills only
make codex      # Copy to ~/.codex/skills only
make diff       # Show differences between repo and installed
make clean      # Remove skills from destinations
make help       # Show available commands
```

### Shell Script
```bash
./install.sh           # Copy to both destinations
./install.sh claude    # Copy to ~/.claude/skills only
./install.sh codex     # Copy to ~/.codex/skills only
```

## Skills

| Skill | Description |
|-------|-------------|
| `rpi` | Research-Plan-Implement orchestrator |
| `research` | Gather context from Jira, Confluence, codebase |
| `plan` | Create detailed implementation plans |
| `implement` | Execute implementation with quality checks |
| `audit` | Validate against overengineering/hallucination |
| `code-review` | Review code for correctness and security |

## Adding New Skills

1. Create a new directory: `mkdir my-skill`
2. Add `SKILL.md` inside: `my-skill/SKILL.md`
3. Run `make install` to sync

## Directory Structure

```
skills/
├── Makefile          # Make-based installer
├── install.sh        # Shell script installer
├── SKILL.md          # Root skill documentation
├── audit/
│   └── SKILL.md
├── code-review/
│   └── SKILL.md
├── implement/
│   └── SKILL.md
├── plan/
│   └── SKILL.md
├── research/
│   └── SKILL.md
└── rpi/
    └── SKILL.md
```
