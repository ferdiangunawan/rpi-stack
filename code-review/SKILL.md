---
name: code-review
description: Reviews code for correctness, security, performance, and pattern compliance. P0/P1/P2 severity. Stack-agnostic core with domain profile integration.
---

# Code Review Skill

Performs a rigorous review of all newly created and modified files, evaluating correctness, security vulnerabilities, performance regressions, and adherence to project conventions.

## When to Run

- Immediately following the implementation phase before finalizing changes.
- Reviewing an active git diff or PR branch.
- Standalone check: `/code-review`, `/code-review --staged`, or `/code-review <path>`.

## Review Execution & Subagent Isolation

- **Clean Perspective**: When supported (`invoke_subagent` or `Task` tool), delegate code review to a separate subagent to evaluate changes objectively without conversational bias.
- **Context Loading**:
  1. Inspect the changed file diff (`git diff` or file inventory).
  2. Read `AGENTS.md` and the relevant profile in `profiles/` (`flutter.md`, `frontend.md`, `backend.md`, `scripts.md`).
  3. Compare changes against original acceptance criteria.

---

## Severity Classifications

### P0 — Critical (Blocking: Must Fix Before Completion)
- **Security Flaws**: Hardcoded API keys/credentials, SQL/command injection, authentication or tenant isolation bypass, insecure direct object references (IDOR).
- **Data Integrity**: Data corruption, accidental data deletion, unmigrated breaking schema alterations.
- **Stability & Crashes**: Unhandled promise rejections, unhandled fatal exceptions, null dereferences, infinite loops.
- **Memory & Resource Leaks**: Unclosed database connections, undisposed streams/controllers, open file handles.
- **Execution Blocking**: Blocking synchronous I/O operations on the main UI/event thread.

### P1 — Important (Should Fix)
- Logic flaws or unhandled edge cases in secondary flows.
- Missing input validation or missing error boundaries.
- Significant performance bottlenecks (N+1 queries, unindexed lookups, redundant heavy recalculations).
- Violations of core project architectural patterns from `AGENTS.md`.
- Sensitive data or credentials printed in application logs.

### P2 — Minor (Suggestions / Non-Blocking)
- Minor style inconsistencies or naming improvements.
- Opportunities for minor optimization or code simplification.
- Documentation or test coverage additions.

---

## Review Dimensions

### 1. Correctness
- Does the code fulfill the stated requirements and acceptance criteria?
- Are boundary conditions, empty collections, nulls, and error states handled gracefully?
- Are asynchronous operations, promises, and race conditions managed safely?

### 2. Security (OWASP & Secrets)
- Are all external inputs validated and sanitized before use?
- Are secrets strictly read from environment variables (never committed in code)?
- Are authorization checks enforced at data access boundaries?

### 3. Performance & Resource Management
- Are resources, subscriptions, and controllers properly released/disposed?
- Are list structures virtualized or paginated?
- Are database queries efficient and indexed?

### 4. Stack Profile & Pattern Compliance
- Check against repository `AGENTS.md`.
- Consult the matching domain profile in `profiles/`:
  - Flutter/Dart: Check `profiles/flutter.md` for widget splitting, `const` usage, and controller disposal.
  - Web Frontend: Check `profiles/frontend.md` for Server/Client boundaries, hydration, and a11y.
  - Backend API: Check `profiles/backend.md` for transactions, idempotency, and migration safety.
  - Scripts: Check `profiles/scripts.md` for variable quoting, exit codes, and dry-run support.

---

## Output Template

Save to `OUTPUT_DIR/review-{feature}.md` (or return inline):

```markdown
# Code Review: {Feature Name}

## Verdict: {APPROVE / REQUEST CHANGES}

### Severity Summary
| Severity | Count | Status |
|----------|-------|--------|
| P0 (Critical) | {n} | {BLOCKING / CLEAR} |
| P1 (Important) | {n} | {Actionable} |
| P2 (Minor) | {n} | {Informational} |

---

## P0 Issues (Critical Blockers)
{If none: "No critical blockers found."}

### P0-1: {Issue Title}
- **File**: `{path/to/file}:{line}`
- **Category**: Security / Correctness / Performance
- **Problem**: {Detailed description}
- **Required Fix**: {Exact guidance or code snippet to resolve}

---

## P1 Issues (Important)
### P1-1: {Issue Title}
- **File**: `{path/to/file}:{line}`
- **Category**: {Category}
- **Recommendation**: {Suggested fix}

---

## P2 Issues (Minor Improvements)
- `{file}:{line}`: {Suggestion}

---

## Pattern Compliance ({Stack})
- Architecture & `AGENTS.md`: {COMPLIANT / MINOR DEVIATIONS / NON-COMPLIANT}
- Notes: {Observations against relevant profile}

---

## Resolution Checklist
- [ ] Fix all P0 issues (Required)
- [ ] Address P1 issues or document justification
```
