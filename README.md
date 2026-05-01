# RPI Stack

RPI Stack packages Research-Plan-Implement workflow skills for both Claude Code and Codex. Each agent gets its own native skill payload, paths, tools, and workflow conventions instead of sharing a lowest-common-denominator prompt.

## What Gets Installed

`./install.sh` installs to computer-level agent directories:

| Agent | Source in this repo | Destination | Agent-specific behavior |
|-------|---------------------|-------------|-------------------------|
| Claude Code | `skills/claude/` | `~/.claude/skills` | Slash-command workflow, Claude session scripts, hookify files, native hooks, shell aliases. |
| Codex | `skills/codex/` | `~/.codex/skills` | Codex-native workflow, `.codex/output`, `.codex/sessions`, `update_plan`, framework profiles. |

## Install

```bash
git clone <this-repo-url>
cd rpi-stack
./install.sh
```

Install only one agent:

```bash
./install.sh claude
./install.sh codex
```

Useful options:

```bash
./install.sh --dry-run
./install.sh --clean
./install.sh --no-claude-tools
./install.sh --claude-dest /custom/claude/skills
./install.sh --codex-dest /custom/codex/skills
```

Restart Claude Code or Codex if the agent was already running.

## Skills

Both distributions include:

| Skill | Purpose |
|-------|---------|
| `rpi` | Full Research-Plan-Implement orchestrator. |
| `research` | Gather requirements and codebase context. |
| `audit` | Validate research/plans/code against hallucination, overengineering, underengineering, and traceability. |
| `plan` | Produce an implementation-ready plan. |
| `implement` | Execute the plan with progress tracking and validation. |
| `code-review` | Review changes using P0/P1/P2 severity. |
| `audit-security` | Focused security review. |
| `audit-performance` | Focused performance review. |

## Claude Code Usage

Use the Claude-native slash-command style:

```text
/rpi KB-1234
/research KB-1234
/audit plan
/plan
/implement
/code-review
```

Claude tools installed by default:

- Hookify files copied to `~/.claude/`.
- Session template initialized under `~/.claude/sessions` when missing.
- Native hooks added to `~/.claude/settings.json` when `jq` is available.
- Shell aliases added for `rpi-tracker`, `rpi-tracker-list`, and `rpi-status`.

## Codex Usage

Ask Codex to use the skill by name:

```text
Use rpi to implement KB-1234
Use research before changing checkout
Use plan to create a migration-safe implementation plan
Use code-review to review my current diff
```

Codex RPI supports three modes:

| Mode | Use when |
|------|----------|
| `fast` | Small bug fixes, obvious refactors, low-risk UI/content changes. |
| `standard` | Normal feature work and multi-file changes. |
| `strict` | Auth, payments, migrations, data loss risk, security, broad architecture changes, unclear PRD/Jira. |

Codex also includes optional framework profiles:

- `skills/codex/rpi/references/profiles/flutter.md`
- `skills/codex/rpi/references/profiles/frontend.md`
- `skills/codex/rpi/references/profiles/backend.md`
- `skills/codex/rpi/references/profiles/scripts.md`

## Output Files

Claude output defaults to:

```text
.claude/output/
```

Codex output defaults to:

```text
.codex/output/
```

Artifacts usually include:

- `research-{feature}.md`
- `plan-{feature}.md`
- `audit-{feature}-{phase}.md`
- `review-{feature}.md`

## Plugin Metadata

`.codex-plugin/plugin.json` points Codex plugin discovery at `skills/codex/`. Claude support is installed by `install.sh` because Claude uses its own skill and hook directories.
