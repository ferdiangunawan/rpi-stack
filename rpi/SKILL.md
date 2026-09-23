---
name: rpi
description: Coordinate research, planning, implementation, audit, and review for a software task, using only the phases its uncertainty and risk justify.
---

# RPI

Carry the user's request from the current state to a useful outcome. Select phases by what remains unknown or risky, not by ticket type or file count.

## Route the work

1. Read the request, applicable instructions, current worktree state, and any existing task artifacts. Check whether older artifacts still match the current code and requirements.
2. Establish the needed outcome and authorization. A request to investigate or plan alone ends with findings or a plan. A request to implement authorizes ordinary scoped edits; ask only for a material missing decision or an action that needs separate approval under the active instructions.
3. Use [research](../research/SKILL.md) when requirements, current behavior, or dependencies are unclear. Use [plan](../plan/SKILL.md) when implementation choices or sequencing need resolution. Use [audit](../audit/SKILL.md) when evidence checking would reduce a real risk. Implement with [implement](../implement/SKILL.md) when authorized, then inspect the result with [code-review](../code-review/SKILL.md) at a depth proportional to the change.
4. Resolve material findings and report what changed, what was verified, and what remains uncertain. Do not present a static check as runtime proof.

For a small, well-understood edit, this may be inspect → edit → focused check → diff review. For unfamiliar or consequential work, keep distinct research and plan decisions before editing. A source link or issue number alone does not make a full workflow necessary.

## Working state

Use conversation context for short tasks. When a durable artifact helps with a long task or handoff, use a project-appropriate location or the user's chosen path. Record evidence, decisions, status, and the next action. Resume from it only after checking for drift; a file's existence does not prove a phase is complete.

Use tools and domain profiles available in the active environment. Delegation is optional and only applies when explicitly authorized by the user or applicable instructions. Follow the active rules for tests, external writes, and approvals; the workflow itself grants no extra permission.
