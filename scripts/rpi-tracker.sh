#!/bin/bash

# RPI Session Tracker - CLI ASCII Display
# Usage: ./rpi-tracker.sh [session-id]

# ANSI Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Priority Colors
P0="${RED}${BOLD}P0${NC}"
P1="${YELLOW}P1${NC}"
P2="${CYAN}P2${NC}"

# Global sessions directory
SESSION_DIR="$HOME/.claude/sessions"

if [[ ! -d "$SESSION_DIR" ]]; then
    echo -e "${RED}Error: No ~/.claude/sessions directory found${NC}"
    echo "Run './install.sh' from the skills repo to initialize"
    exit 1
fi
SESSION_FILE=""

# Parse arguments
if [ -n "$1" ]; then
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "RPI Session Tracker"
        echo ""
        echo "Usage: rpi-tracker.sh [session-id]"
        echo ""
        echo "Options:"
        echo "  session-id    Display specific session (default: active session)"
        echo "  --list        List all sessions"
        echo "  --help        Show this help"
        exit 0
    elif [[ "$1" == "--list" ]]; then
        echo ""
        echo -e "${BOLD}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}║${NC}                              ${CYAN}${BOLD}RPI SESSIONS${NC}                                          ${BOLD}║${NC}"
        echo -e "${BOLD}╠══════════════════════════════════════════════════════════════════════════════════════╣${NC}"

        if [[ ! -f "$SESSION_DIR/index.json" ]]; then
            echo -e "${BOLD}║${NC}  ${DIM}No sessions found. Start one with: /rpi --session new {input}${NC}"
            echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
            exit 0
        fi

        # Get active session
        ACTIVE_ID=$(jq -r '.active_session // ""' "$SESSION_DIR/index.json" 2>/dev/null)

        # List all session directories
        SESSION_COUNT=0
        for session_dir in "$SESSION_DIR"/*/; do
            if [[ -f "$session_dir/session.json" ]]; then
                SESSION_COUNT=$((SESSION_COUNT + 1))
                SESSION=$(cat "$session_dir/session.json")

                ID=$(echo "$SESSION" | jq -r '.id // "unknown"')
                FEATURE=$(echo "$SESSION" | jq -r '.input.feature_name // "unknown"')
                PHASE=$(echo "$SESSION" | jq -r '.phase.current // "unknown"')
                PROGRESS=$(echo "$SESSION" | jq -r '.progress.percentage // 0')
                TASKS_DONE=$(echo "$SESSION" | jq -r '.progress.tasks_done // 0')
                TASKS_TOTAL=$(echo "$SESSION" | jq -r '.progress.tasks_total // 0')
                UPDATED=$(echo "$SESSION" | jq -r '.updated_at // ""' | cut -d'T' -f1)

                # Phase icon
                case "$PHASE" in
                    "research")  PHASE_ICON="${CYAN}◐${NC}" ;;
                    "plan")      PHASE_ICON="${CYAN}◑${NC}" ;;
                    "implement") PHASE_ICON="${YELLOW}◕${NC}" ;;
                    "review")    PHASE_ICON="${GREEN}◔${NC}" ;;
                    "complete")  PHASE_ICON="${GREEN}●${NC}" ;;
                    *)           PHASE_ICON="${DIM}○${NC}" ;;
                esac

                # Progress bar (10 chars)
                FILLED=$((PROGRESS / 10))
                EMPTY=$((10 - FILLED))
                BAR=""
                for ((i=0; i<FILLED; i++)); do BAR+="█"; done
                for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

                # Color based on progress
                if [ "$PROGRESS" -ge 75 ]; then
                    BAR_COLOR="${GREEN}"
                elif [ "$PROGRESS" -ge 50 ]; then
                    BAR_COLOR="${CYAN}"
                elif [ "$PROGRESS" -ge 25 ]; then
                    BAR_COLOR="${YELLOW}"
                else
                    BAR_COLOR="${DIM}"
                fi

                # Active indicator
                if [[ "$ID" == "$ACTIVE_ID" ]]; then
                    ACTIVE_MARK="${GREEN}▶${NC}"
                else
                    ACTIVE_MARK=" "
                fi

                # Status based on phase
                case "$PHASE" in
                    "complete") STATUS="${GREEN}DONE${NC}" ;;
                    *)          STATUS="${YELLOW}${PHASE^^}${NC}" ;;
                esac

                # Print row
                echo -e "${BOLD}║${NC} ${ACTIVE_MARK} ${BOLD}${FEATURE}${NC}"
                echo -e "${BOLD}║${NC}   ${PHASE_ICON} ${STATUS}  [${BAR_COLOR}${BAR}${NC}] ${BOLD}${PROGRESS}%${NC}  Tasks: ${TASKS_DONE}/${TASKS_TOTAL}  ${DIM}${UPDATED}${NC}"
                echo -e "${BOLD}║${NC}   ${DIM}${ID}${NC}"
                echo -e "${BOLD}╟──────────────────────────────────────────────────────────────────────────────────────╢${NC}"
            fi
        done

        if [[ $SESSION_COUNT -eq 0 ]]; then
            echo -e "${BOLD}║${NC}  ${DIM}No sessions found. Start one with: /rpi --session new {input}${NC}"
            echo -e "${BOLD}╟──────────────────────────────────────────────────────────────────────────────────────╢${NC}"
        fi

        echo -e "${BOLD}║${NC}  ${DIM}Total: ${SESSION_COUNT} session(s)${NC}  │  ${DIM}▶ = active${NC}  │  ${DIM}Commands: --help for options${NC}"
        echo -e "${BOLD}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        exit 0
    else
        SESSION_FILE="$SESSION_DIR/$1/session.json"
    fi
else
    # Get active session from index
    if [[ -f "$SESSION_DIR/index.json" ]]; then
        ACTIVE=$(jq -r '.active_session // empty' "$SESSION_DIR/index.json" 2>/dev/null)
        if [ -n "$ACTIVE" ]; then
            SESSION_FILE="$SESSION_DIR/$ACTIVE/session.json"
        fi
    fi
fi

if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
    echo -e "${YELLOW}No active session found${NC}"
    echo ""
    echo "Start a new session with: /rpi --session new {input}"
    echo "Or list sessions with:    ./rpi-tracker.sh --list"
    exit 0
fi

# Read session data
SESSION=$(cat "$SESSION_FILE")
ID=$(echo "$SESSION" | jq -r '.id // "unknown"')
FEATURE=$(echo "$SESSION" | jq -r '.input.feature_name // "unknown"')
SOURCE=$(echo "$SESSION" | jq -r '.input.source // "prompt"')
PHASE=$(echo "$SESSION" | jq -r '.phase.current // "unknown"')
PROGRESS=$(echo "$SESSION" | jq -r '.progress.percentage // 0')
TASKS_DONE=$(echo "$SESSION" | jq -r '.progress.tasks_done // 0')
TASKS_TOTAL=$(echo "$SESSION" | jq -r '.progress.tasks_total // 0')
UPDATED=$(echo "$SESSION" | jq -r '.updated_at // "unknown"')

# Header
echo ""
echo -e "${BOLD}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║${NC}                         ${CYAN}${BOLD}RPI SESSION TRACKER${NC}                              ${BOLD}║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Session Info
printf "${BOLD}║${NC} %-75s ${BOLD}║${NC}\n" "Feature: ${BOLD}$FEATURE${NC}"
printf "${BOLD}║${NC} %-75s ${BOLD}║${NC}\n" "Session: $ID"
printf "${BOLD}║${NC} %-75s ${BOLD}║${NC}\n" "Source:  $SOURCE"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Phase Progress
echo -e "${BOLD}║${NC}  ${DIM}WORKFLOW PHASES${NC}"
echo -e "${BOLD}║${NC}"

# Get phase statuses
RESEARCH_STATUS=$(echo "$SESSION" | jq -r '.phase.research.status // "pending"')
PLAN_STATUS=$(echo "$SESSION" | jq -r '.phase.plan.status // "pending"')
IMPLEMENT_STATUS=$(echo "$SESSION" | jq -r '.phase.implement.status // "pending"')
REVIEW_STATUS=$(echo "$SESSION" | jq -r '.phase.review.status // "pending"')

# Function to get phase indicator
get_indicator() {
    case "$1" in
        "complete")    echo -e "${GREEN}[✓]${NC}" ;;
        "in_progress") echo -e "${YELLOW}[▶]${NC}" ;;
        "pending")     echo -e "${DIM}[ ]${NC}" ;;
        "failed")      echo -e "${RED}[✗]${NC}" ;;
        *)             echo -e "${DIM}[?]${NC}" ;;
    esac
}

# Phase row
R_IND=$(get_indicator "$RESEARCH_STATUS")
P_IND=$(get_indicator "$PLAN_STATUS")
I_IND=$(get_indicator "$IMPLEMENT_STATUS")
V_IND=$(get_indicator "$REVIEW_STATUS")

echo -e "${BOLD}║${NC}    $R_IND RESEARCH ─▶ $P_IND PLAN ─▶ $I_IND IMPLEMENT ─▶ $V_IND REVIEW"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Progress Bar
echo -e "${BOLD}║${NC}  ${DIM}PROGRESS${NC}"
echo -e "${BOLD}║${NC}"

# Calculate bar
BAR_WIDTH=50
FILLED=$((PROGRESS * BAR_WIDTH / 100))
EMPTY=$((BAR_WIDTH - FILLED))

# Build progress bar
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# Color based on progress
if [ "$PROGRESS" -ge 75 ]; then
    BAR_COLOR="${GREEN}"
elif [ "$PROGRESS" -ge 50 ]; then
    BAR_COLOR="${CYAN}"
elif [ "$PROGRESS" -ge 25 ]; then
    BAR_COLOR="${YELLOW}"
else
    BAR_COLOR="${DIM}"
fi

echo -e "${BOLD}║${NC}    [${BAR_COLOR}${BAR}${NC}] ${BOLD}${PROGRESS}%${NC}"
echo -e "${BOLD}║${NC}    Tasks: ${TASKS_DONE}/${TASKS_TOTAL}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Quality Gates
echo -e "${BOLD}║${NC}  ${DIM}QUALITY GATES${NC}"
echo -e "${BOLD}║${NC}"

print_gate() {
    local name=$1
    local data=$2
    local passed=$(echo "$data" | jq -r '.passed // "null"')
    local score=$(echo "$data" | jq -r '.score // "-"')

    if [ "$passed" == "true" ]; then
        echo -e "${BOLD}║${NC}    ${GREEN}✓${NC} $name: PASS ($score%)"
    elif [ "$passed" == "false" ]; then
        echo -e "${BOLD}║${NC}    ${RED}✗${NC} $name: FAIL ($score%)"
    else
        echo -e "${BOLD}║${NC}    ${DIM}○${NC} $name: PENDING"
    fi
}

RESEARCH_AUDIT=$(echo "$SESSION" | jq '.progress.quality_gates.research_audit // {}')
PLAN_AUDIT=$(echo "$SESSION" | jq '.progress.quality_gates.plan_audit // {}')
SECURITY_AUDIT=$(echo "$SESSION" | jq '.progress.quality_gates.security_audit // {}')
PERF_AUDIT=$(echo "$SESSION" | jq '.progress.quality_gates.performance_audit // {}')
CODE_REVIEW=$(echo "$SESSION" | jq '.progress.quality_gates.code_review // {}')

print_gate "Research Audit   " "$RESEARCH_AUDIT"
print_gate "Plan Audit       " "$PLAN_AUDIT"
print_gate "Security Audit   " "$SECURITY_AUDIT"
print_gate "Performance Audit" "$PERF_AUDIT"
print_gate "Code Review      " "$CODE_REVIEW"

echo -e "${BOLD}║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Current Status
CURRENT_TASK=$(echo "$SESSION" | jq -r '.phase.implement.current_task // "N/A"')
NEXT_ACTION=$(echo "$SESSION" | jq -r '.continuation.next_action // "Ready to start"')
LAST_ACTION=$(echo "$SESSION" | jq -r '.continuation.last_action // "Session created"')

echo -e "${BOLD}║${NC}  ${DIM}CURRENT STATUS${NC}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}║${NC}    Current Task: ${YELLOW}${CURRENT_TASK}${NC}"
echo -e "${BOLD}║${NC}    Last Action:  ${DIM}${LAST_ACTION}${NC}"
echo -e "${BOLD}║${NC}    Next Action:  ${NEXT_ACTION}"
echo -e "${BOLD}║${NC}"
echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"

# Resume Prompt
RESUME=$(echo "$SESSION" | jq -r '.continuation.resume_prompt // ""')
if [ -n "$RESUME" ] && [ "$RESUME" != "null" ]; then
    echo -e "${BOLD}║${NC}  ${DIM}RESUME PROMPT${NC}"
    echo -e "${BOLD}║${NC}"
    # Word wrap the resume prompt
    echo -e "${BOLD}║${NC}    ${CYAN}${RESUME}${NC}" | fold -w 70 -s | sed "s/^/${BOLD}║${NC}    /"
    echo -e "${BOLD}║${NC}"
    echo -e "${BOLD}╠════════════════════════════════════════════════════════════════════════════╣${NC}"
fi

# Footer
echo -e "${BOLD}║${NC}  Updated: ${DIM}${UPDATED}${NC}"
echo -e "${BOLD}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
