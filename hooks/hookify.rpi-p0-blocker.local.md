---
name: rpi-p0-blocker
description: Block completion when P0 issues are present
enabled: true
---

# RPI P0 Blocker Hook

## Trigger Conditions

This hook activates when attempting to complete/close work while P0 issues exist:
- "Implementation complete" or "Done implementing"
- "Ready for merge" or "Ready to merge"
- "Workflow complete"
- Attempting to close session

AND the conversation contains:
- "P0: 1" or "P0: 2" or similar (P0 count > 0)
- "P0 Issues: {n}" where n > 0
- "Critical" findings that are unresolved

## Warning Message

```
**P0 Issues Detected - Cannot Complete**

There are unresolved P0 (critical) issues in this session.
P0 issues MUST be fixed before marking implementation complete.

P0 categories that block completion:
- SECURITY: Hardcoded credentials, injection vulnerabilities
- PERFORMANCE: Memory leaks, infinite loops, blocking main thread
- CORRECTNESS: Data loss, crashes, breaking changes

Please:
1. Review all P0 findings in audit reports
2. Fix each P0 issue
3. Re-run the relevant audit to verify fixes
4. Only mark complete when P0 count = 0

Session cannot be closed with unresolved P0 issues.
```

## Purpose

This hook prevents shipping code with critical issues by blocking workflow completion when P0 findings exist. It enforces:
- Security-critical fixes before merge
- Performance-critical fixes before merge
- Correctness-critical fixes before merge
