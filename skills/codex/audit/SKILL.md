---
name: audit
description: Validates research, plans, and implementation artifacts against hallucination, overengineering, underengineering, traceability, and project-pattern compliance.
---

# Audit Skill for Codex

Audit is a quality gate for AI-assisted work. It verifies that an artifact is grounded, appropriately scoped, and complete enough to implement or ship.

## Audit Types

- Research audit: validates requirements, evidence, assumptions, and confidence.
- Plan audit: validates traceability, task completeness, architecture fit, and risk handling.
- Implementation audit: validates code changes against requirements, tests, security, performance, and project conventions.

## Core Checks

### Hallucination

Signals:

- Requirement not traceable to source material or user confirmation.
- Behavior invented without project pattern or technical necessity.
- Fabricated API/schema/file detail.
- Misquoted or distorted requirement.

Scoring:

`hallucination = ungrounded_items / total_claims * 100`

Target: <= 20%.

### Overengineering

Signals:

- Scope creep beyond requirements.
- Premature abstraction for a single use.
- Extra layers, configuration, dependencies, or future-proofing without current need.
- Large rewrite where localized change would work.

Scoring:

`overengineering = unnecessary_items / total_items * 100`

Target: <= 25%, ideally <= 15%.

### Underengineering

Signals:

- Missing must-have requirement.
- Missing validation, error handling, compatibility, migration, or security behavior.
- Critical edge cases ignored.
- Tests do not cover changed behavior.

Scoring:

`underengineering = missing_items / required_items * 100`

Target: <= 20%, ideally <= 15%.

### Traceability

For each must-have requirement, verify:

- It maps to at least one task or implemented change.
- It has validation coverage or a documented reason for manual verification.
- It does not rely on an unstated assumption.

Target: 100% for must-have requirements.

### Pattern Compliance

Verify against:

- `AGENTS.md`.
- Existing similar code.
- Loaded RPI profile, if any.
- Language/framework conventions already used in the repo.

## Gate Results

Use this verdict:

- PASS: thresholds met and no blocking concerns.
- PASS WITH NOTES: safe to proceed, but assumptions or P2 issues remain.
- FAIL: missing critical information, high hallucination, over/underengineering, or P0/P1 implementation risk.

## Output

For formal audits, write `.codex/output/audit-{feature}-{phase}.md`:

```markdown
# Audit: {Feature} - {Phase}

## Verdict
- Result: {PASS|PASS WITH NOTES|FAIL}
- Hallucination: {x}%
- Overengineering: {x}%
- Underengineering: {x}%
- Traceability: {x}%

## Findings
- {severity}: {finding, evidence, fix}

## Required Fixes
- {only blocking fixes}

## Notes
- {non-blocking assumptions or risks}
```
