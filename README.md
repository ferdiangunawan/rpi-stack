# RPI Stack

Lean Research-Plan-Implement workflow system for Claude Code and Codex. Quality-gated, context-preserving, and focused on keeping the agent productive without ceremony.

---

## Design Principles

1. **Linear and clear** — research, audit, plan, audit, approve, implement, review
2. **Low ceremony** — 6 focused skills, not a large process framework
3. **Qualitative gates** — PASS/WARN/FAIL criteria instead of invented scoring
4. **Outputs as state** — markdown artifacts are the source of truth
5. **Ask once** — clarification questions are batched instead of interrupting repeatedly

---

## Architecture

```
Input (Jira / PRD / Prompt)
         │
         ▼
   [RESEARCH]  ─── Ask all clarifying questions at once (if any)
         │          Output: research-{feature}.md
         ▼
  [AUDIT RESEARCH]  ─── PASS / WARN / FAIL
         │ FAIL → revise and re-run
         ▼
    [PLAN]  ─── Ask all open questions at once (if any)
         │       Output: plan-{feature}.md
         ▼
  [AUDIT PLAN]  ─── Requirements traced? Balanced? Pattern-compliant?
         │ FAIL → revise and re-run
         ▼
 [USER APPROVAL]  ─── Present plan summary, wait for explicit yes
         │
         ▼
  [IMPLEMENT]  ─── Task by task, verify each
         │          Output: code changes
         ▼
 [CODE REVIEW]  ─── Correctness + Security + Performance (P0/P1/P2)
                    Output: review-{feature}.md
```

---

## Skills

| Skill | Purpose |
|-------|---------|
| `rpi` | Full orchestrator — runs all skills in sequence |
| `research` | Gather context; ask clarifying questions as a batch |
| `audit` | Qualitative gate for hallucination, scope, and traceability |
| `plan` | Task breakdown with dependencies; ask open questions as a batch |
| `implement` | Task-by-task execution following `AGENTS.md` |
| `code-review` | Final review: correctness, security, performance, patterns |

Security and performance checks live inside `code-review`; there are no separate `audit-security` or `audit-performance` skills.

---

## Agent-Specific Support

RPI uses the same lean 6-skill model for both agents, but installs the right supporting tools per agent.

| Agent | Skills Destination | Agent-Specific Support |
|-------|--------------------|------------------------|
| Claude Code | `~/.claude/skills` | Slash-command usage and hookify guard files copied to `~/.claude/` |
| Codex | `~/.codex/skills` | Codex skill loading plus `.codex-plugin/plugin.json` metadata |

Claude hooks are behavioral guards only:

| Hook | Purpose |
|------|---------|
| `rpi-audit-before-implement` | Blocks `/implement` if plan audit has not passed |
| `rpi-p0-blocker` | Blocks completion when P0 findings are unresolved |

No session scripts, progress scripts, or session JSON tracker are installed.

---

## Install

```bash
git clone <this-repo-url>
cd rpi-stack
./install.sh
```

Install one agent only:

```bash
./install.sh claude
./install.sh codex
```

Useful options:

```bash
./install.sh --dry-run
./install.sh --clean
./install.sh --claude-dest /custom/claude/skills
./install.sh --codex-dest /custom/codex/skills
```

Restart Claude Code or Codex if it was already running.

---

## Usage

Claude Code uses slash commands:

```text
/rpi KB-1234
/research KB-1234
/audit plan
/plan
/implement
/code-review
```

Codex uses skill names in the prompt:

```text
Use rpi to implement KB-1234
Use research to inspect checkout before changing it
Use plan to create an implementation plan
Use code-review to review my current diff
```

> Run RPI in the agent's normal execution/autopilot mode, not the built-in planning-only mode. RPI already contains its own research and planning phases.

---

## Output Files

Artifacts are written in the active project:

```text
.claude/output/   # Claude Code
.codex/output/    # Codex
```

Common artifacts:

```text
research-{feature}.md
audit-research-{feature}.md
plan-{feature}.md
audit-plan-{feature}.md
review-{feature}.md
```

These files serve as resumable state. To resume after context loss, read the output files and continue at the next unfinished phase.

---

## Integration with AGENTS.md

All skills reference the project's `AGENTS.md`:

1. **Research** reads `AGENTS.md` to understand existing patterns
2. **Audit** checks plan compliance against `AGENTS.md`
3. **Implement** follows `AGENTS.md` before writing files
4. **Code Review** checks `AGENTS.md` adherence in changed files
