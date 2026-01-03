---
name: rpi-audit-before-implement
description: Ensure plan audit passes before starting implementation
enabled: true
---

# RPI Audit Before Implementation Hook

## Trigger Conditions

This hook activates when:
- "Invoking /implement" is detected
- "/implement" command is invoked
- "Starting implementation" is mentioned

AND the conversation does NOT contain:
- "Plan Audit: PASS"
- "audit plan: passed"
- "Gate 2: PASSED"

## Warning Message

```
**Plan Audit Required Before Implementation**

Cannot proceed to implementation without passing plan audit.

Please run `/audit plan` first and ensure:
- Traceability: 100%
- Balance Score: >= 70%
- Pattern Compliance: >= 90%

This prevents implementing unvalidated plans that may have:
- Missing requirement coverage
- Overengineered solutions
- Pattern violations

Run: `/audit plan` to validate the plan.
```

## Purpose

This hook enforces the RPI quality gate between planning and implementation phases. It prevents:
- Implementing unvalidated plans
- Missing requirement coverage
- Pattern violations from propagating to code
