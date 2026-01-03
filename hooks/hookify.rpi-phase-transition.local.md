---
name: rpi-phase-transition
description: Track phase transitions in RPI workflow and ensure proper state updates
enabled: true
---

# RPI Phase Transition Hook

## Trigger Conditions

This hook activates when detecting phase transitions:
- "Invoking /research", "Starting research"
- "Invoking /plan", "Starting plan"
- "Invoking /implement", "Starting implementation"
- "Invoking /audit", "Running audit"
- "Invoking /code-review", "Starting code review"

## Reminder Message

When a phase transition is detected:

```
**Phase Transition Detected**

Transitioning RPI workflow phase. Ensure:

1. Previous phase artifacts are saved to OUTPUT_DIR
2. Session state is updated:
   - phase.current = "{new_phase}"
   - phase.{previous_phase}.status = "complete"
   - phase.{new_phase}.status = "in_progress"
3. Quality gate results are recorded if applicable
4. Session file is saved: .claude/sessions/{active}/session.json

This ensures session continuity and proper tracking.
```

## Purpose

Ensures that phase transitions are properly tracked in the session system, enabling:
- Accurate progress display in CLI tracker
- Proper resume from any phase
- Quality gate status recording
