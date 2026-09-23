---
name: implement
description: Make an authorized software change from a current plan or clear request, preserving existing work and validating the result proportionately.
---

# Implement

Finish the requested change while keeping the diff focused and reviewable. A clear implementation request is sufficient authorization for ordinary scoped edits; an existing formal plan is optional.

## Execute

1. Read applicable instructions, current git status, relevant code, and any plan. Preserve unrelated user changes. Check whether the plan still matches the code.
2. Make the smallest coherent change that meets requirements and follows existing conventions. Use a [domain profile](../profiles/) only where relevant.
3. Reassess when evidence contradicts the approach. Resolve ordinary implementation details; ask when a material product decision, scope expansion, or separately controlled action is required.
4. Run focused, authorized checks that address a concrete risk. Prefer static inspection or analysis where execution is unnecessary. **Do not initiate backend tests.** When a backend test would help, give the exact command for the user to run or approve. If the user explicitly requests a run, inspect the active DB and environment first: refuse remote, shared, staging, production, or unclear targets; even for a confirmed local database, obtain approval for the exact command and its effects before running it.
5. Inspect the final diff and review it for correctness, security, performance, and project conventions. Fix material defects found within scope. Report checks as run, skipped, or blocked accurately.

Use task tracking when it helps a multi-step change. Do not require one task at a time, a full-repository check, a test suite, or a separate reviewer for every edit. Do not expand authorization to external writes, deployment, or destructive operations.
