---
name: code-review
description: Reviews code for correctness, regressions, security, performance, maintainability, tests, and project-pattern compliance using P0/P1/P2 severity.
---

# Code Review Skill for Codex

Review code with a bug-finding mindset. Findings come first, ordered by severity. Avoid broad summaries unless there are no findings.

## Severity

- P0 Critical: must fix before completion or merge. Security vulnerability, data loss/corruption, crash, broken build, unsafe migration, auth bypass, or severe business logic error.
- P1 Important: should fix. Real edge-case bug, meaningful regression risk, missing critical test, performance issue, maintainability issue that will likely cause bugs.
- P2 Minor: optional improvement. Style, small cleanup, documentation, low-risk refactor.

## Review Inputs

Gather:

- Modified files and diff.
- Original requirement, plan, or ticket when available.
- `AGENTS.md` and nearby existing patterns.
- Relevant tests and validation output.
- Relevant RPI profile if the repo technology requires special checks.

## Review Checklist

### Correctness

- Requirements implemented as specified.
- Edge cases handled: null/empty, bounds, invalid input, missing data, concurrency, retries, timeouts.
- Error handling maps to existing project behavior.
- State transitions, caching, and async behavior are safe.
- Backwards compatibility is preserved where required.

### Security

- No hardcoded secrets or sensitive logging.
- Inputs are validated and encoded/sanitized correctly.
- Auth and authorization checks are enforced at trust boundaries.
- External calls, file paths, SQL/commands, and deserialization are safe.
- Error messages do not leak sensitive internals.

### Performance and Reliability

- No avoidable hot-path work, blocking I/O, unbounded memory growth, leaks, or accidental quadratic behavior.
- Retries, transactions, locks, and idempotency are appropriate where relevant.
- UI/rendering changes avoid unnecessary work according to framework conventions.

### Maintainability

- Follows `AGENTS.md`, existing architecture, naming, and layering.
- Avoids speculative abstractions and broad rewrites.
- Code is testable and localized to the requirement.
- New dependencies are justified.

### Tests

- Critical paths covered.
- Failure paths covered where behavior changed.
- Existing tests updated for intentional behavior changes.
- No brittle tests that depend on unrelated implementation details.

## Output Format

If findings exist:

```markdown
## Findings

### P0 - {title}
- File: {path}:{line}
- Issue: {specific bug/risk}
- Impact: {user/system impact}
- Fix: {concrete fix}

### P1 - {title}
- File: {path}:{line}
- Issue: {specific bug/risk}
- Impact: {impact}
- Fix: {concrete fix}

## Open Questions
- {only if blocking or materially ambiguous}

## Residual Risk
- {tests not run, area not reviewed, or none}
```

If no findings:

```markdown
No findings.

Residual risk: {tests not run or limits of review, or "None identified"}.
```
