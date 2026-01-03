---
name: rpi-session-autosave
description: Auto-save RPI session state when task progress is detected
enabled: true
---

# RPI Session Auto-Save Hook

## Trigger Conditions

This hook activates when detecting task completion patterns in the conversation:
- "Task completed", "Task done", "Task finished"
- "Moving to T{n}", "Next task"
- "Phase complete", "Phase finished"
- Marking todos as completed

## Reminder Message

When task progress is detected, remind the agent:

```
**Session Auto-Save Reminder**

RPI session state should be updated. Please ensure:
1. Session JSON is updated with current progress
2. Phase status reflects actual state
3. tasks_completed list is current
4. continuation.last_action reflects this completion
5. continuation.next_action points to next task

Session file: .claude/sessions/{active}/session.json
```

## Purpose

This hook helps maintain session continuity by reminding the agent to save progress after each significant task completion. This enables:
- Cross-session work continuation
- Progress visibility via CLI tracker
- Context preservation for handoff
