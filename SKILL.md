# RPI Stack Skill Distribution

This repository packages agent-specific RPI skills for Claude Code and Codex.

## Layout

- `skills/claude/`: Claude-native skills using Claude Code conventions, slash commands, session scripts, hooks, and `TodoWrite`-style workflow guidance.
- `skills/codex/`: Codex-native skills using `.codex/output`, `.codex/sessions`, `update_plan`, and framework profiles.
- `hooks/`: Claude Code hookify files.
- `templates/`: Claude session tracker templates.
- `.codex-plugin/`: Codex plugin metadata.

## Install

Run `./install.sh` from the repo root to install both agent distributions to computer-level directories:

- Claude Code: `~/.claude/skills`
- Codex: `~/.codex/skills`

Use `./install.sh claude` or `./install.sh codex` for a single agent.
