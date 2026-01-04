#!/bin/bash

# RPI Progress Update Script
# Updates session.json with progress based on phase and tasks
#
# Usage:
#   rpi-progress [session-id] --phase <phase> [--status <status>]
#   rpi-progress [session-id] --task-done <task-id>
#   rpi-progress [session-id] --task-start <task-id>
#   rpi-progress [session-id] --tasks-total <count>
#   rpi-progress [session-id] --audit <type> --passed <true|false> [--score <0-100>]
#   rpi-progress [session-id] --set <percentage>
#   rpi-progress [session-id] --calculate
#   rpi-progress --help
#
# Progress Formula:
#   Research phase:     0-15%  (start: 5%, audit pass: 15%)
#   Plan phase:        15-30%  (start: 20%, audit pass: 30%)
#   User approval:     35%
#   Implementation:    35-90%  (divided by tasks)
#   Code review:       90-100% (review pass: 100%)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

SESSION_DIR="$HOME/.claude/sessions"
SESSION_ID=""
SESSION_FILE=""

show_help() {
    echo "RPI Progress Update Script"
    echo ""
    echo "Usage: rpi-progress [session-id] <command>"
    echo ""
    echo "Commands:"
    echo "  --phase <phase>           Set current phase (research|plan|implement|review|complete)"
    echo "  --status <status>         Set phase status (pending|in_progress|complete|failed)"
    echo "  --task-start <id>         Mark task as started (T1, T2, etc.)"
    echo "  --task-done <id>          Mark task as completed"
    echo "  --tasks-total <count>     Set total task count"
    echo "  --audit <type>            Update audit result (research|plan|security|performance|code_review)"
    echo "    --passed <true|false>   Audit pass status"
    echo "    --score <0-100>         Audit score"
    echo "  --set <percentage>        Manually set progress percentage"
    echo "  --calculate               Calculate progress based on current state"
    echo "  --last <action>           Set last action description"
    echo "  --next <action>           Set next action description"
    echo "  --help                    Show this help"
    echo ""
    echo "Examples:"
    echo "  rpi-progress --phase research --status in_progress"
    echo "  rpi-progress --task-done T1"
    echo "  rpi-progress --audit plan --passed true --score 85"
    echo "  rpi-progress rpi-kb-123-20260104-abc123 --phase implement"
    echo ""
    echo "Progress Formula:"
    echo "  Research:    5-15%   (5% start, 15% audit pass)"
    echo "  Plan:       15-30%   (20% plan done, 30% audit pass)"
    echo "  Approval:   35%"
    echo "  Implement:  35-90%   (distributed by tasks)"
    echo "  Review:     90-100%  (100% on review pass)"
}

# Load session
load_session() {
    # Check if first arg is a session ID (starts with rpi-)
    if [[ "$1" == rpi-* ]]; then
        SESSION_ID="$1"
        shift
    elif [[ -f "$SESSION_DIR/index.json" ]]; then
        SESSION_ID=$(jq -r '.active_session // empty' "$SESSION_DIR/index.json" 2>/dev/null)
    fi

    if [[ -z "$SESSION_ID" ]]; then
        echo -e "${RED}Error: No active session found${NC}"
        echo "Specify a session ID or start a session with /rpi"
        exit 1
    fi

    SESSION_FILE="$SESSION_DIR/$SESSION_ID/session.json"

    if [[ ! -f "$SESSION_FILE" ]]; then
        echo -e "${RED}Error: Session file not found: $SESSION_FILE${NC}"
        exit 1
    fi

    # Return remaining args
    echo "$@"
}

# Calculate progress based on current state
calculate_progress() {
    local session=$(cat "$SESSION_FILE")
    local phase=$(echo "$session" | jq -r '.phase.current // "research"')
    local research_status=$(echo "$session" | jq -r '.phase.research.status // "pending"')
    local plan_status=$(echo "$session" | jq -r '.phase.plan.status // "pending"')
    local implement_status=$(echo "$session" | jq -r '.phase.implement.status // "pending"')
    local review_status=$(echo "$session" | jq -r '.phase.review.status // "pending"')
    local tasks_done=$(echo "$session" | jq -r '.progress.tasks_done // 0')
    local tasks_total=$(echo "$session" | jq -r '.progress.tasks_total // 0')
    local research_audit=$(echo "$session" | jq -r '.progress.quality_gates.research_audit.passed // null')
    local plan_audit=$(echo "$session" | jq -r '.progress.quality_gates.plan_audit.passed // null')
    local code_review=$(echo "$session" | jq -r '.progress.quality_gates.code_review.passed // null')

    local progress=0

    # Phase-based progress calculation
    case "$phase" in
        "research")
            if [[ "$research_status" == "complete" ]]; then
                if [[ "$research_audit" == "true" ]]; then
                    progress=15
                else
                    progress=10
                fi
            elif [[ "$research_status" == "in_progress" ]]; then
                progress=5
            else
                progress=0
            fi
            ;;
        "plan")
            if [[ "$plan_status" == "complete" ]]; then
                if [[ "$plan_audit" == "true" ]]; then
                    progress=30
                else
                    progress=25
                fi
            elif [[ "$plan_status" == "in_progress" ]]; then
                progress=20
            else
                progress=15
            fi
            ;;
        "implement")
            # Implementation takes 35-90% based on tasks
            local base=35
            local impl_range=55  # 35-90 = 55%

            if [[ "$tasks_total" -gt 0 ]]; then
                local per_task=$((impl_range / tasks_total))
                progress=$((base + (tasks_done * per_task)))
            else
                progress=$base
            fi

            # Cap at 90 until review
            if [[ "$progress" -gt 90 ]]; then
                progress=90
            fi
            ;;
        "review")
            if [[ "$code_review" == "true" ]]; then
                progress=100
            else
                progress=95
            fi
            ;;
        "complete")
            progress=100
            ;;
    esac

    echo "$progress"
}

# Update session JSON
update_session() {
    local key="$1"
    local value="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update the session file
    local updated=$(jq --arg key "$key" --argjson value "$value" --arg ts "$timestamp" '
        setpath($key | split("."); $value) |
        .updated_at = $ts
    ' "$SESSION_FILE")

    echo "$updated" > "$SESSION_FILE"
}

# Update multiple fields atomically
update_session_multi() {
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local updates="$1"

    local updated=$(echo "$updates" | jq --arg ts "$timestamp" '. + {updated_at: $ts}' |
        jq -s '.[0] * .[1]' "$SESSION_FILE" -)

    echo "$updated" > "$SESSION_FILE"
}

# Main logic
main() {
    # Handle help first
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    fi

    # Load session and get remaining args
    ARGS=$(load_session "$@")
    eval set -- $ARGS

    local phase=""
    local status=""
    local task_start=""
    local task_done=""
    local tasks_total=""
    local audit_type=""
    local audit_passed=""
    local audit_score=""
    local set_progress=""
    local do_calculate=""
    local last_action=""
    local next_action=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --phase)
                phase="$2"
                shift 2
                ;;
            --status)
                status="$2"
                shift 2
                ;;
            --task-start)
                task_start="$2"
                shift 2
                ;;
            --task-done)
                task_done="$2"
                shift 2
                ;;
            --tasks-total)
                tasks_total="$2"
                shift 2
                ;;
            --audit)
                audit_type="$2"
                shift 2
                ;;
            --passed)
                audit_passed="$2"
                shift 2
                ;;
            --score)
                audit_score="$2"
                shift 2
                ;;
            --set)
                set_progress="$2"
                shift 2
                ;;
            --calculate)
                do_calculate="true"
                shift
                ;;
            --last)
                last_action="$2"
                shift 2
                ;;
            --next)
                next_action="$2"
                shift 2
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done

    local session=$(cat "$SESSION_FILE")
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local updates="{}"

    # Handle phase update
    if [[ -n "$phase" ]]; then
        updates=$(echo "$updates" | jq --arg phase "$phase" '.phase.current = $phase')

        # If status not provided, set to in_progress
        if [[ -z "$status" ]]; then
            status="in_progress"
        fi
        updates=$(echo "$updates" | jq --arg phase "$phase" --arg status "$status" '.phase[$phase].status = $status')
    fi

    # Handle phase status
    if [[ -n "$status" && -n "$phase" ]]; then
        updates=$(echo "$updates" | jq --arg phase "$phase" --arg status "$status" '.phase[$phase].status = $status')
    fi

    # Handle task start
    if [[ -n "$task_start" ]]; then
        updates=$(echo "$updates" | jq --arg task "$task_start" '
            .phase.implement.current_task = $task |
            .phase.implement.status = "in_progress"
        ')
    fi

    # Handle task completion
    if [[ -n "$task_done" ]]; then
        local current_done=$(echo "$session" | jq -r '.progress.tasks_done // 0')
        local new_done=$((current_done + 1))

        updates=$(echo "$updates" | jq --arg task "$task_done" --argjson done "$new_done" '
            .phase.implement.tasks_completed += [$task] |
            .phase.implement.tasks_remaining -= [$task] |
            .progress.tasks_done = $done
        ')
    fi

    # Handle tasks total
    if [[ -n "$tasks_total" ]]; then
        # Generate task IDs T1, T2, ... TN
        local task_ids="[]"
        for ((i=1; i<=tasks_total; i++)); do
            task_ids=$(echo "$task_ids" | jq --arg t "T$i" '. += [$t]')
        done

        updates=$(echo "$updates" | jq --argjson total "$tasks_total" --argjson tasks "$task_ids" '
            .progress.tasks_total = $total |
            .phase.implement.tasks_remaining = $tasks
        ')
    fi

    # Handle audit
    if [[ -n "$audit_type" ]]; then
        local audit_key="${audit_type}_audit"
        if [[ "$audit_type" == "code_review" ]]; then
            audit_key="code_review"
        fi

        if [[ -n "$audit_passed" ]]; then
            local passed_bool=$(if [[ "$audit_passed" == "true" ]]; then echo "true"; else echo "false"; fi)
            updates=$(echo "$updates" | jq --arg key "$audit_key" --argjson passed "$passed_bool" '
                .progress.quality_gates[$key].passed = $passed
            ')
        fi

        if [[ -n "$audit_score" ]]; then
            updates=$(echo "$updates" | jq --arg key "$audit_key" --argjson score "$audit_score" '
                .progress.quality_gates[$key].score = $score
            ')
        fi
    fi

    # Handle last/next action
    if [[ -n "$last_action" ]]; then
        updates=$(echo "$updates" | jq --arg action "$last_action" '.continuation.last_action = $action')
    fi

    if [[ -n "$next_action" ]]; then
        updates=$(echo "$updates" | jq --arg action "$next_action" '.continuation.next_action = $action')
    fi

    # Handle manual progress set
    if [[ -n "$set_progress" ]]; then
        updates=$(echo "$updates" | jq --argjson pct "$set_progress" '.progress.percentage = $pct')
    fi

    # Apply updates
    if [[ "$updates" != "{}" ]]; then
        local updated=$(jq -s '.[0] * .[1]' "$SESSION_FILE" <(echo "$updates"))
        echo "$updated" > "$SESSION_FILE"
        session=$(cat "$SESSION_FILE")
    fi

    # Calculate and update progress
    if [[ -n "$do_calculate" || -n "$phase" || -n "$task_done" || -n "$audit_type" ]]; then
        local new_progress=$(calculate_progress)
        local final=$(jq --argjson pct "$new_progress" --arg ts "$timestamp" '
            .progress.percentage = $pct |
            .updated_at = $ts
        ' "$SESSION_FILE")
        echo "$final" > "$SESSION_FILE"

        echo -e "${GREEN}Progress updated: ${BOLD}${new_progress}%${NC}"
    fi

    # Update resume prompt
    local feature=$(jq -r '.input.feature_name // "unknown"' "$SESSION_FILE")
    local current_phase=$(jq -r '.phase.current // "research"' "$SESSION_FILE")
    local progress_pct=$(jq -r '.progress.percentage // 0' "$SESSION_FILE")
    local current_task=$(jq -r '.phase.implement.current_task // ""' "$SESSION_FILE")

    local resume_prompt="Continue RPI session $SESSION_ID. Phase: $current_phase. Progress: $progress_pct%"
    if [[ -n "$current_task" && "$current_task" != "null" ]]; then
        resume_prompt="$resume_prompt. Current task: $current_task"
    fi

    jq --arg prompt "$resume_prompt" '.continuation.resume_prompt = $prompt' "$SESSION_FILE" > "${SESSION_FILE}.tmp"
    mv "${SESSION_FILE}.tmp" "$SESSION_FILE"

    # Show current state
    echo -e "${DIM}Session: $SESSION_ID${NC}"
    echo -e "${DIM}Phase: $current_phase | Tasks: $(jq -r '.progress.tasks_done // 0' "$SESSION_FILE")/$(jq -r '.progress.tasks_total // 0' "$SESSION_FILE")${NC}"
}

main "$@"
