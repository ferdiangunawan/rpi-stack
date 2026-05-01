---
name: code-review
description: Reviews code for correctness, security, performance, and pattern compliance. P0/P1/P2 severity. Absorbs security and performance audit checks.
---

# Code Review Skill

Reviews all new and modified files for correctness, security, performance, and best practices.

---

## Severity Levels

### P0 — Critical (Must Fix Before Merge)
- Security vulnerabilities (injection, auth bypass, hardcoded secrets, insecure storage)
- Data corruption or data loss risks
- Crashes or critical runtime errors
- Memory leaks (undisposed controllers, streams)
- Main thread blocking operations
- Breaking changes without migration

### P1 — Important (Should Fix)
- Logic errors in edge cases
- Missing error handling for critical paths
- Significant performance issues (unnecessary rebuilds, expensive build())
- Missing input validation
- Pattern violations causing maintenance burden
- Missing keys in dynamic lists
- Sensitive data logged

### P2 — Nice-to-have (Consider)
- Code style inconsistencies
- Minor performance improvements (missing const)
- Documentation gaps
- Refactoring opportunities

---

## Review Process

### Step 1: Gather Context

```
1. Identify files to review (new + modified, from implementation summary)
2. Read AGENTS.md patterns
3. Read original requirements if available
```

### Step 2: Review Each File

For each file, run all five checks below.

---

## Check 1: Correctness

```
□ Business logic implements requirements correctly
□ Calculations and conditions are accurate
□ Null/empty/boundary cases handled
□ State transitions are correct (no stale state)
□ Async operations handled properly (await, error propagation)
□ Race conditions considered
```

---

## Check 2: Security

### P0 — Critical Security

```
□ No hardcoded credentials, API keys, or secrets
□ No SQL injection (parameterized queries only)
□ No command injection (shell input unescaped)
□ Authentication check present on protected operations
□ Authorization / permission check on all resource access
□ Sensitive data not stored in plain text (use secure storage)
□ No path traversal vulnerabilities (validate file paths)
```

### P1 — Important Security

```
□ User input validated before use
□ Error messages don't leak internal info (no raw stack traces to UI)
□ Sensitive data (tokens, passwords) not in logs
□ HTTPS enforced for all sensitive API calls
□ Weak cryptography avoided (no MD5/SHA1 for security purposes)
□ CSRF protection on state-changing operations (web)
```

### P2 — Minor Security

```
□ Verbose error messages minimized
□ Security headers present (web)
□ Input length limits on text fields
```

---

## Check 3: Performance

### P0 — Critical Performance

```
□ No infinite loops or unbounded recursion
□ All controllers/streams/subscriptions disposed (no memory leaks)
□ No blocking synchronous I/O on main thread (readAsStringSync, etc.)
□ No O(n²) algorithms on large datasets
□ No unbounded list/map growth
```

### P1 — Important Performance

```
□ No unnecessary widget rebuilds (use const where possible)
□ No expensive operations inside build() (sorting, parsing, filtering)
□ Dynamic lists use keys (ValueKey or ObjectKey)
□ Long lists use lazy builders (ListView.builder, not ListView)
□ Same calculation not repeated multiple times without caching
□ Widget methods (_buildX) replaced with separate StatelessWidget classes
```

### P2 — Minor Performance

```
□ const constructors used where possible
□ String concatenation in loops uses StringBuffer
□ Repeated network calls consider local caching
```

---

## Check 4: Pattern Compliance (AGENTS.md)

```
□ State management follows project pattern (check AGENTS.md)
□ Models use project model pattern
□ Styling uses project constants (no hardcoded colors, sizes, text styles)
□ Widget structure follows project convention
□ File organization follows project structure
□ Naming conventions correct
```

---

## Check 5: Test Coverage

```
□ Critical logic has unit tests
□ Edge cases covered in tests
□ Error paths tested
□ UI states tested (loading, error, empty, success)
□ No real API calls in tests (proper mocking)
```

---

## Output Template

Save to `OUTPUT_DIR/review-{feature}.md`:

```markdown
# Code Review: {Feature Name}

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| P0 (Critical) | {n} | {BLOCKING / CLEAR} |
| P1 (Important) | {n} | |
| P2 (Nice-to-have) | {n} | |

**Verdict**: {APPROVE / REQUEST CHANGES}

---

## P0 — Critical Issues

{If none: "No critical issues found."}

### P0-1: {Issue Title}
- **File**: `path/to/file.dart:{line}`
- **Category**: {Security / Performance / Correctness}
- **Issue**: {description}
- **Impact**: {what goes wrong}
- **Fix**: {how to fix}

---

## P1 — Important Issues

### P1-1: {Issue Title}
- **File**: `path:{line}`
- **Category**: {category}
- **Issue**: {description}
- **Fix**: {suggestion}

---

## P2 — Nice-to-have

### P2-1: {Issue Title}
- **File**: `path:{line}`
- **Suggestion**: {improvement}

---

## Pattern Compliance

| Pattern | Status | Notes |
|---------|--------|-------|
| State Management | ✅/❌ | {notes} |
| Model Pattern | ✅/❌ | {notes} |
| Styling | ✅/❌ | {notes} |
| Widget Structure | ✅/❌ | {notes} |
| File Organization | ✅/❌ | {notes} |

---

## Files Reviewed

| File | Issues |
|------|--------|
| `path` | P0: {n}, P1: {n}, P2: {n} |

---

## Verdict

{APPROVED / APPROVED WITH COMMENTS / CHANGES REQUESTED}

{Reasoning. List must-fix items if changes requested.}
```

---

## Quick Commands

```
/code-review                — Review recent changes (all new/modified files)
/code-review path/to/file   — Review specific file
/code-review --security     — Security-focused review only
/code-review --staged       — Review staged git changes
```
