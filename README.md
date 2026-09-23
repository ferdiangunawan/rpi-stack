# RPI Stack

Six portable skills for researching, planning, implementing, auditing, and reviewing software changes. Use one skill for a focused task, or use **rpi** to coordinate several. The workflow scales with uncertainty and risk; it does not require a full ceremony for every edit.

## Choose a skill

| Skill | Use it when you need to… |
| --- | --- |
| [research](research/SKILL.md) | Establish requirements and current behavior from issues, source code, or documentation. |
| [plan](plan/SKILL.md) | Resolve implementation choices, scope, and verification before editing. |
| [audit](audit/SKILL.md) | Check research or a plan against the underlying evidence and project rules. |
| [implement](implement/SKILL.md) | Make an authorized code change and verify it proportionately. |
| [code-review](code-review/SKILL.md) | Find actionable defects in a diff or pull request. |
| [rpi](rpi/SKILL.md) | Coordinate the phases that a larger request actually needs. |

The [root skill](SKILL.md) is a short route map. The optional [profiles](profiles/) add checks for backend, web frontend, Flutter, and scripts. They are guidance, not replacements for your project's instructions or established code patterns.

## How it works

For a clear, contained fix, rpi can inspect the affected code, make the change, run a focused allowed check, and review the diff. For a change with unclear requirements or meaningful risk, it can research the source, settle an approach, audit important assumptions, implement when authorized, and review the result. A ticket ID, a file count, or the presence of an old plan does not by itself decide the path.

Each skill respects the scope of the request. Asking for research or a plan does not authorize implementation. Asking for implementation covers ordinary scoped edits; a second approval is needed only where the active instructions or the action itself require it. Artifacts are optional for short tasks. For a long task, save evidence, decisions, status, and next steps in a project-appropriate location, then recheck them against current code when resuming.

Verification distinguishes static checks, automated tests, and runtime evidence. Backend tests are never run on initiative. If explicitly requested, the agent must inspect the active database environment, refuse remote or unclear targets, and obtain approval for the exact command even when the database is confirmed local.

## Install

Clone the repository, then preview what the installer would copy:

```bash
git clone https://github.com/ferdiangunawan/rpi-stack.git
cd rpi-stack
./install.sh --dry-run
```

Install for a specific agent or into a project:

```bash
./install.sh codex
./install.sh claude
./install.sh gemini
./install.sh --project
./install.sh --project path/to/project/.agents/skills
```

Running `./install.sh` without a target detects existing agent configuration directories; `./install.sh all` selects all three. The default destinations are `~/.codex/skills`, `~/.claude/skills`, and `~/.gemini/config/skills`. The installer copies the six skill folders, the root skill, and profiles. It replaces same-named destination folders, so inspect an existing installation before running it. It does not install anything merely because this repository was cloned. Restart an active agent session after installing so it can discover changed skills.

Run `./install.sh --clean codex` to remove this stack from one agent, or `./install.sh --clean --project path/to/project/.agents/skills` for a project install. Without a target, `--clean` selects all three agent destinations. Preview with `--dry-run` and run `./install.sh --help` for destination overrides. The [Makefile](Makefile) provides shortcuts such as `make codex`, `make dry-run`, and `make diff`.

## Use

Ask for the outcome in normal language; skill invocation syntax varies by agent. Examples:

```text
Use research to trace why this callback fires twice and cite the relevant code.
Use plan to design the smallest safe migration for this API field.
Use audit to check this plan against the current code and project instructions.
Use implement to apply the approved change.
Use code-review to review my current diff for actionable defects.
Use rpi to investigate and fix this issue, then report checks and remaining risks.
```

The skills work best when you supply the repository, issue or specification, desired outcome, and any limits on edits or verification. If a source is inaccessible, the agent should identify the gap instead of inventing its contents.

## Repository layout

```text
SKILL.md                 Route map
rpi/SKILL.md             Workflow coordination
research/SKILL.md        Evidence gathering
plan/SKILL.md            Implementation design
audit/SKILL.md           Evidence and plan checks
implement/SKILL.md       Authorized code changes
code-review/SKILL.md     Diff and PR review
profiles/                Optional domain guidance
install.sh               Local skill installer
```
