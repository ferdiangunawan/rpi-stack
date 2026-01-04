---
name: rpi-session-autosave
description: Enforce RPI session progress updates after every task/phase completion
enabled: true
---

# RPI Session Progress Tracking Hook

## Trigger Conditions

This hook activates when detecting task or phase completion patterns:
- "Task completed", "Task done", "Task finished"
- "Moving to T{n}", "Next task", "Starting T{n}"
- "Phase complete", "Phase finished"
- "Research complete", "Plan complete", "Implementation complete"
- Marking todos as completed
- "Audit passed", "Audit failed"

## MANDATORY Progress Update

When any trigger is detected, the agent MUST run the progress update script:

```bash
# The agent MUST run this command after EVERY task/phase completion:
~/.claude/skills/scripts/rpi-progress.sh <appropriate flags>
```

## Required Commands by Context

### After Task Completion
```bash
~/.claude/skills/scripts/rpi-progress.sh --task-done T{n} --last "Completed T{n}: {title}" --next "Start T{n+1}: {next_title}"
```

### After Phase Transition
```bash
~/.claude/skills/scripts/rpi-progress.sh --phase <phase> --status <status>
```

### After Audit
```bash
~/.claude/skills/scripts/rpi-progress.sh --audit <type> --passed <true|false> --score <0-100>
```

## Reminder Message

When task/phase progress is detected, remind the agent:

```
**RPI Progress Update Required**

You completed a task or phase. Run the progress update:

~/.claude/skills/scripts/rpi-progress.sh --task-done T{n} --last "{what you did}" --next "{what's next}"

Progress formula:
- Research: 5% start → 10% complete → 15% audit pass
- Plan: 20% start → 25% complete → 30% audit pass
- Approval: 35%
- Implementation: 35% + (55% / total_tasks) per task completed
- Review: 90% start → 100% pass

Failing to update progress will cause rpi-tracker to show stale data!
```

## Validation

The hook should check:
1. Is there an active RPI session? (`~/.claude/sessions/index.json`)
2. Was progress actually updated? (Check `session.json` timestamp)
3. Does progress percentage match the formula?

If progress was NOT updated after a task completion, BLOCK and require:
```
BLOCKED: Progress update missing

Before continuing, run:
~/.claude/skills/scripts/rpi-progress.sh --task-done T{n}

Current session: {session_id}
Current progress: {percentage}%
```

## Purpose

This hook ensures:
- Real-time progress visibility via CLI tracker
- Accurate session state for resumption
- Cross-session continuity
- Progress doesn't jump from 5% to 100%
