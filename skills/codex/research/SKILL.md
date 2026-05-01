---
name: research
description: Use to understand requirements and codebase context before implementation. Produces concise, evidence-based research for general coding tasks in Codex.
---

# Research Skill for Codex

Research gathers enough truth to implement safely without guessing. Prefer repo inspection and primary sources over user questions.

## Inputs

Supported sources:

- Jira issue key or ticket text.
- Confluence/PRD URL or pasted requirements.
- Direct user prompt.
- Existing code, bug report, failing test, or stack trace.

## Process

### 1. Requirement Capture

Extract:

- Goal and user-visible behavior.
- Must-have acceptance criteria.
- Explicit constraints and out-of-scope items.
- Non-functional requirements: security, performance, reliability, compatibility, accessibility, observability.
- Risk level: low, normal, high.

For Jira/Confluence, use Atlassian tools when available. If the source cannot be fetched, ask for the missing content instead of inventing it.

### 2. Codebase Exploration

Use fast local inspection:

- `rg --files` to locate manifests, entrypoints, tests, and related modules.
- `rg` for feature names, API routes, models, state, handlers, commands, or error strings.
- Read `AGENTS.md`, README files, package manifests, and nearby tests.
- Identify similar implementations to copy patterns from.

Record evidence with file paths when it affects implementation decisions.

### 3. Profile Detection

Detect technology and load only relevant optional profile references from `rpi/references/profiles/`:

- Flutter/Dart.
- Frontend web.
- Backend/API.
- Scripts/tooling.

Project conventions always override profile guidance.

### 4. Gap Analysis

Identify:

- Files/subsystems likely affected.
- Interfaces or schemas likely to change.
- Tests that should be updated or added.
- Missing requirements or high-impact ambiguities.
- Risks and constraints.

Ask the user only for decisions that cannot be discovered and materially change behavior. For low-impact gaps, choose the safest default and record it as an assumption.

### 5. Confidence Score

Score confidence from 0 to 100 using:

| Dimension | Weight |
|-----------|--------|
| Requirement clarity | 25% |
| Codebase understanding | 25% |
| Technical feasibility | 20% |
| Scope definition | 15% |
| Risk identification | 15% |

Thresholds:

- 80-100: proceed.
- 60-79: proceed with documented assumptions or ask targeted questions.
- Below 60: stop and gather missing information.

## Output

For standard/strict RPI, write `.codex/output/research-{feature}.md`:

```markdown
# Research: {Feature}

## Summary
- Source: {Jira/PRD/prompt/bug/etc.}
- Confidence: {score}%
- Risk: {low|normal|high}

## Requirements
- {requirement}

## Codebase Findings
- {finding with path evidence}

## Affected Areas
- {subsystem/file group}

## Assumptions and Questions
- Assumption: {safe default}
- Question: {only if blocking}

## Validation Candidates
- {test/check command or scenario}
```

For fast mode, keep the same content in the conversation summary instead of writing an artifact unless useful.
