#!/bin/bash

# RPI Session Auto-Save
# Called by Claude Code hooks: PreCompact, SessionEnd
# Ensures RPI session state is preserved before context loss

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
DIM='\033[2m'
NC='\033[0m'

SESSION_DIR="$HOME/.claude/sessions"
TIMESTAMP=$(date +%Y-%m-%d_%H:%M:%S)

# Read hook input from stdin
INPUT=$(cat)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // "unknown"' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

# Check if we have an active RPI session
if [[ ! -f "$SESSION_DIR/index.json" ]]; then
    exit 0
fi

ACTIVE_RPI=$(jq -r '.active_session // empty' "$SESSION_DIR/index.json" 2>/dev/null)

if [[ -z "$ACTIVE_RPI" ]]; then
    exit 0
fi

SESSION_FILE="$SESSION_DIR/$ACTIVE_RPI/session.json"

if [[ ! -f "$SESSION_FILE" ]]; then
    exit 0
fi

# Update session with context save info
UPDATED_SESSION=$(jq --arg ts "$TIMESTAMP" --arg event "$HOOK_EVENT" --arg claude_session "$SESSION_ID" '
  .context.last_save = $ts |
  .context.save_trigger = $event |
  .context.claude_session_id = $claude_session |
  .updated_at = (now | strftime("%Y-%m-%dT%H:%M:%SZ"))
' "$SESSION_FILE")

echo "$UPDATED_SESSION" > "$SESSION_FILE"

# Create human-readable context summary
CONTEXT_FILE="$SESSION_DIR/$ACTIVE_RPI/context-summary.md"
FEATURE=$(echo "$UPDATED_SESSION" | jq -r '.input.feature_name // "unknown"')
PHASE=$(echo "$UPDATED_SESSION" | jq -r '.phase.current // "unknown"')
PROGRESS=$(echo "$UPDATED_SESSION" | jq -r '.progress.percentage // 0')
LAST_ACTION=$(echo "$UPDATED_SESSION" | jq -r '.continuation.last_action // "N/A"')
NEXT_ACTION=$(echo "$UPDATED_SESSION" | jq -r '.continuation.next_action // "N/A"')
RESUME_PROMPT=$(echo "$UPDATED_SESSION" | jq -r '.continuation.resume_prompt // ""')

cat > "$CONTEXT_FILE" << EOF
# RPI Session Context Summary

**Auto-saved**: $TIMESTAMP
**Trigger**: $HOOK_EVENT
**Claude Session**: $SESSION_ID

---

## Session Info
- **Feature**: $FEATURE
- **RPI Session ID**: $ACTIVE_RPI
- **Phase**: $PHASE
- **Progress**: $PROGRESS%

## Continuation
- **Last Action**: $LAST_ACTION
- **Next Action**: $NEXT_ACTION

## Resume Prompt
\`\`\`
$RESUME_PROMPT
\`\`\`

## To Resume
\`\`\`bash
# In Claude Code
/rpi --session resume $ACTIVE_RPI

# Or check status first
rpi-tracker
\`\`\`
EOF

echo -e "${GREEN}RPI session saved${NC}: $ACTIVE_RPI (trigger: $HOOK_EVENT)"
