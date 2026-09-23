---
name: code-review
description: Review a diff, pull request, or changed code for actionable correctness, security, performance, and compatibility defects, with evidence and severity.
---

# Code Review

Identify issues the author can act on. Review the requested diff or scope, including enough surrounding code and requirements to understand the behavior. Check applicable instructions and a relevant [domain profile](../profiles/) when useful.

## Review method

1. Establish the base and changed files. Include staged and unstaged changes if the user asks to review the worktree. Preserve the initial worktree state.
2. Trace affected behavior through callers, state changes, error paths, and interfaces. Check security and performance where the change creates a plausible risk. Use current code and source requirements as evidence.
3. Report only concrete, introduced, or newly exposed defects. Include location, triggering condition, impact, and a practical correction. Label uncertainty and verification limits. Avoid speculative style findings or generic checklists.

Use severity by likely impact in this context:

| Level | Meaning |
| --- | --- |
| P0 | Broadly blocking release or causing critical security or data harm. |
| P1 | Likely to break an important flow or cause serious harm. |
| P2 | Real but limited defect worth fixing. |

Put findings first, ordered by severity. If no actionable finding is supported, say so and note any material evidence gap. For an implementation review, fix in-scope defects when authorized, then inspect the resulting diff. Review alone is read-only unless the user also requested a fix. Run checks only when authorized by active test and environment rules; backend tests are never an initiative review step.
