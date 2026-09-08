---
name: audit
description: Adversarial quality gate for research or plans. Validates evidence integrity, scope balance, safety, and AGENTS.md compliance with PASS/WARN/FAIL verdicts.
---

# Audit Skill

Quality gate that critically validates research findings or implementation plans before committing to code changes.

## When to Run

- `/audit research`: Validates research output before planning (recommended for complex or high-risk features).
- `/audit plan`: Validates the implementation plan before user approval and coding (mandatory quality gate).

## Adversarial Mindset & Subagent Execution

- **Avoid Self-Grading Bias**: Auditing your own plan in the same conversation turn can lead to sycophancy. When subagents (`invoke_subagent` or `Task`) are available, delegate the audit to a dedicated subagent with an adversarial reviewer role.
- **Evidence-Based Verification**: Check claims against actual code files and authoritative sources, not the subject document's claims.

---

## The Four Audit Checks

### Check 1: Evidence Integrity (Hallucination & Fabrication Guard)
- **Claim Grounding**: Are all technical claims, library methods, and APIs grounded in existing code or verified documentation?
- **Requirements Traceability**: Does every requirement originate from the user, Jira, PRD, or a clearly documented technical necessity?
- **Verdict**:
  - `PASS`: All claims grounded; assumptions explicitly labeled.
  - `WARN`: Minor unconfirmed assumptions that carry low technical risk.
  - `FAIL`: Invented requirements, non-existent APIs, or fabricated libraries.

### Check 2: Scope Balance (Over- vs. Under-Engineering)
- **Overengineering**: Are there unrequested abstractions, unnecessary configuration files, premature optimizations, or unwarranted design pattern overhauls?
- **Underengineering**: Are edge cases, error states, empty states, input validation, and boundary conditions addressed?
- **Verdict**:
  - `PASS`: Balanced, minimal sufficient implementation.
  - `WARN`: Minor scope additions that can easily be deferred.
  - `FAIL`: Major unrequested scope creep or missing core acceptance criteria.

### Check 3: Feasibility, Safety & Blast Radius
- **Breaking Changes**: Are public API contracts or database schemas modified without backward compatibility or rollback plans?
- **Security & Secrets**: Does the proposal introduce credentials, SQL injection, bypass authorization, or leak sensitive data?
- **Test Feasibility**: Are tests testing actual business logic rather than tautological mocks? Are dangerous tests (e.g. against non-local DBs) prevented?
- **Verdict**:
  - `PASS`: Safe, bounded blast radius, verified rollback/test strategy.
  - `WARN`: Minor edge-case risk with noted mitigation.
  - `FAIL`: High risk of data loss, breaking migration, or security regression.

### Check 4: Project Compliance (AGENTS.md & Profiles)
- **Rules & Conventions**: Does the plan follow `AGENTS.md` and the appropriate stack profile in `profiles/` (`flutter.md`, `frontend.md`, `backend.md`, `scripts.md`)?
- **Reuse**: Does it leverage existing project helpers, tokens, and components instead of rewriting them?
- **Verdict**:
  - `PASS`: 100% compliant with established conventions.
  - `WARN`: Justified deviation with clear explanation.
  - `FAIL`: Flagrant violation of established codebase architecture.

---

## Overall Verdict Matrix

| Verdict | Criteria | Action |
|---------|----------|--------|
| **PASS** | All checks PASS (or acceptable low-risk WARNs) | Proceed to next phase or user approval. |
| **WARN** | Non-blocking observations; carry forward to review | Proceed with noted mitigations. |
| **FAIL** | One or more checks FAIL | **Stop.** Revise research/plan and re-audit. |

---

## Output Template

Save to `OUTPUT_DIR/audit-{type}-{feature}.md` (or return inline for Fast-Path workflows):

```markdown
# Audit Report: {Feature} ({Research / Plan})

## Overall Verdict: {PASS / WARN / FAIL}

### Summary
| Check | Status | Notes |
|-------|--------|-------|
| 1. Evidence Integrity | {PASS / WARN / FAIL} | {Brief note} |
| 2. Scope Balance | {PASS / WARN / FAIL} | {Brief note} |
| 3. Feasibility & Safety | {PASS / WARN / FAIL} | {Brief note} |
| 4. Project Compliance | {PASS / WARN / FAIL} | {Brief note} |

---

### Blocking Issues (Must resolve before proceeding)
{List specific files/requirements or "None"}

### Non-Blocking Recommendations (Carried forward)
{List items to verify during implementation/code review or "None"}

### Next Action
{Proceed to User Approval / Revise Plan / Clarify with User}
```
