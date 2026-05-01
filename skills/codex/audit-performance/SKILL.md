---
name: audit-performance
description: Performance-focused audit for general coding tasks. Checks inefficient algorithms, memory leaks, blocking work, rendering hot paths, I/O, concurrency, and scalability risks using P0/P1/P2 severity.
---

# Performance Audit Skill for Codex

Use this skill for changes involving hot paths, large data, rendering, loops, caching, network/database calls, concurrency, background jobs, startup, or memory-sensitive code.

## Severity

### P0 Critical

- Infinite loop or unbounded recursion.
- Memory/resource leak with production impact.
- Blocking main/event/UI thread on heavy I/O or CPU work.
- Accidental quadratic or worse behavior on large expected inputs.
- Unbounded queue/cache/list growth.
- Deadlock or concurrency bug that can halt processing.

### P1 Important

- Repeated expensive work in a hot path.
- Missing pagination, streaming, virtualization, batching, or indexing where expected data size requires it.
- Avoidable N+1 calls or excessive network/database round trips.
- Inefficient rendering or state updates in UI code.
- Missing cleanup for timers, subscriptions, file handles, sockets, or workers.

### P2 Minor

- Small caching, allocation, or algorithm improvements.
- Cleanup that improves clarity but has limited measured impact.

## Review Process

1. Identify expected data size, call frequency, and runtime context.
2. Inspect loops, queries, renders, async flows, and resource lifecycles.
3. Look for repeated work, blocking operations, unbounded growth, and missing cleanup.
4. Check tests or benchmarks if performance behavior is critical.
5. Apply framework-specific profile guidance only when relevant.

## Output

For formal audits, write `.codex/output/audit-performance-{feature}.md` or `.codex/output/audit-{session}-performance.json` when a machine-readable result is useful.

```markdown
# Performance Audit: {Feature}

## Summary
- P0: {count}
- P1: {count}
- P2: {count}
- Verdict: {PASS|FAIL}

## Findings
### P1 - {title}
- File: {path}:{line}
- Impact: {specific runtime impact}
- Fix: {concrete fix}

## Residual Risk
- {tests not run, assumptions, or none}
```

Fix all P0 findings before completion.
