# Claude Code Hooks Reference

Reference documentation for Claude Code hook events used by RPI Stack.

---

## Hook Events

| Event | Description | RPI Usage |
|-------|-------------|-----------|
| `PreToolUse` | Before tool execution | - |
| `PostToolUse` | After tool execution | - |
| `UserPromptSubmit` | When user submits a prompt | - |
| `SessionStart` | Session initialization | - |
| `SessionEnd` | Session cleanup | **Auto-save RPI session** |
| `PreCompact` | Before context compaction | **Auto-save RPI session** |
| `Stop` | When main agent finishes | - |
| `SubagentStop` | When a subagent finishes | - |

---

## RPI Native Hooks

Configured automatically by `./install.sh`:

### PreCompact Hook
Saves RPI session state before Claude Code compacts context (prevents data loss).

```json
{
  "hooks": {
    "PreCompact": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/scripts/rpi-session-save.sh"
      }]
    }]
  }
}
```

### SessionEnd Hook
Saves RPI session state when Claude Code session ends.

```json
{
  "hooks": {
    "SessionEnd": [{
      "hooks": [{
        "type": "command",
        "command": "~/.claude/skills/scripts/rpi-session-save.sh"
      }]
    }]
  }
}
```

---

## Hook Input JSON

Hooks receive JSON input via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../conversation.jsonl",
  "hook_event_name": "PreCompact",
  "reason": "auto"
}
```

---

## Built-in Resume (Claude Code)

Claude Code has native resume functionality (separate from RPI sessions):

| Command | Description |
|---------|-------------|
| `claude --continue` | Resume most recent session |
| `claude --resume` | Pick from previous sessions |
| `/rename <name>` | Name session for easy finding |

---

## RPI Session Resume

RPI has its own session tracking at `~/.claude/sessions/`:

```bash
# View sessions
rpi-tracker-list

# Resume in Claude Code
/rpi --session resume {session-id}
/rpi --session resume              # Resume active
```

---

## Verification

Check if native hooks are configured:

```bash
cat ~/.claude/settings.json | jq '.hooks'
```

Expected output:
```json
{
  "PreCompact": [...],
  "SessionEnd": [...]
}
```
