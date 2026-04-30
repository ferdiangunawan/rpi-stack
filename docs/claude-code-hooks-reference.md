# Claude Code Hooks Reference

Reference documentation for Claude Code hook events used by RPI Stack.

---

## Hook Events

| Event | Description | RPI Usage |
|-------|-------------|-----------|
| `PreToolUse` | Before tool execution | **P0 blocker gate** |
| `PostToolUse` | After tool execution | - |
| `UserPromptSubmit` | When user submits a prompt | **Audit-before-implement gate** |
| `SessionStart` | Session initialization | - |
| `SessionEnd` | Session cleanup | - |
| `PreCompact` | Before context compaction | - |
| `Stop` | When main agent finishes | - |
| `SubagentStop` | When a subagent finishes | - |

---

## Active RPI Hooks

Two behavioral guards are active (configured via `./install.sh`):

### `hookify.rpi-audit-before-implement` (UserPromptSubmit)
Blocks `/implement` if the plan audit hasn't passed. Ensures `/audit` runs and passes before code is written.

### `hookify.rpi-p0-blocker` (PreToolUse)
Blocks marking any task complete when P0 issues exist in the current audit or code review output.

---

## Hook Input JSON

Hooks receive JSON input via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../conversation.jsonl",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "/implement"
}
```

---

## Built-in Resume (Claude Code)

Claude Code has native resume functionality:

| Command | Description |
|---------|-------------|
| `claude --continue` | Resume most recent session |
| `claude --resume` | Pick from previous sessions |
| `/rename <name>` | Name session for easy finding |

**RPI resume:** Output files in OUTPUT_DIR are the source of truth. Read `research-{feature}.md` and `plan-{feature}.md` to resume at the right step — no separate session tracking needed.

---

## Verification

Check if hooks are configured:

```bash
cat ~/.claude/settings.json | jq '.hooks'
```
