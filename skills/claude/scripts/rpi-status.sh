#!/bin/bash

# RPI Quick Status - One-liner display
# Usage: ./rpi-status.sh [session-id]

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m'

# Global sessions directory
SESSION_DIR="$HOME/.claude/sessions"

if [[ ! -d "$SESSION_DIR" ]]; then
    echo -e "${DIM}No RPI session${NC}"
    exit 0
fi

# Get active session
if [[ -f "$SESSION_DIR/index.json" ]]; then
    ACTIVE=$(jq -r '.active_session // empty' "$SESSION_DIR/index.json" 2>/dev/null)
    if [[ -n "$ACTIVE" && -f "$SESSION_DIR/$ACTIVE/session.json" ]]; then
        SESSION=$(cat "$SESSION_DIR/$ACTIVE/session.json")
        FEATURE=$(echo "$SESSION" | jq -r '.input.feature_name // "unknown"')
        PHASE=$(echo "$SESSION" | jq -r '.phase.current // "?"')
        PROGRESS=$(echo "$SESSION" | jq -r '.progress.percentage // 0')
        TASKS_DONE=$(echo "$SESSION" | jq -r '.progress.tasks_done // 0')
        TASKS_TOTAL=$(echo "$SESSION" | jq -r '.progress.tasks_total // 0')

        # Build mini progress bar (10 chars)
        FILLED=$((PROGRESS / 10))
        EMPTY=$((10 - FILLED))
        BAR=""
        for ((i=0; i<FILLED; i++)); do BAR+="█"; done
        for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

        # Phase indicator
        case "$PHASE" in
            "research")  PHASE_DISPLAY="${CYAN}RES${NC}" ;;
            "plan")      PHASE_DISPLAY="${CYAN}PLN${NC}" ;;
            "implement") PHASE_DISPLAY="${YELLOW}IMP${NC}" ;;
            "review")    PHASE_DISPLAY="${GREEN}REV${NC}" ;;
            "complete")  PHASE_DISPLAY="${GREEN}DON${NC}" ;;
            *)           PHASE_DISPLAY="${DIM}???${NC}" ;;
        esac

        echo -e "${BOLD}RPI${NC}: ${FEATURE} | ${PHASE_DISPLAY} | [${GREEN}${BAR}${NC}] ${PROGRESS}% | T:${TASKS_DONE}/${TASKS_TOTAL}"
    else
        echo -e "${DIM}RPI: No active session${NC}"
    fi
else
    echo -e "${DIM}RPI: No sessions${NC}"
fi
