---
name: research
description: Use when needing to understand requirements before implementation. Gathers context from Jira, Confluence, codebase, and docs. Produces research document with confidence assessment.
---

# Research Skill

Conducts thorough research on requirements and codebase before implementation.

## When to Use

- Need to understand a Jira ticket or PRD before planning
- Exploring feasibility of a feature
- Gathering context about existing code patterns

## Agent Compatibility

- AskUserQuestion: use the tool in Claude Code; in Codex CLI, ask the user directly.
- Subagents/Task tool: use if available; otherwise run searches yourself in parallel.
- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI.

---

## Phase 1: Input Gathering

**From Jira:**
```
Use mcp__atlassian__getJiraIssue to extract:
- Summary, Description, Acceptance Criteria, linked Confluence pages
```

**From Codebase (run in parallel when possible):**
```
Search 1: Similar features / patterns matching {feature keywords}
Search 2: Files likely affected by this feature (dependencies, related components)
Search 3 (complex features): Architecture for {related domain} — data flow, state management
```

After gathering:
1. Synthesize findings
2. Read AGENTS.md for project conventions
3. Identify existing components to reuse

---

## Phase 2: Requirement Analysis

For each requirement, identify:
- Type: functional / non-functional / constraint
- Priority: must-have / should-have / nice-to-have
- Complexity: low / medium / high
- Affected layers: presentation / application / domain / data

---

## Phase 3: Codebase Mapping

Map requirements to existing code:
- Similar features to reference
- Reusable components (widgets, services)
- API endpoints (existing vs. new needed)
- State management patterns in use

---

## Phase 4: Gap Analysis & Clarifications

Identify:
- Missing information or unclear requirements
- Edge cases with no specified behavior
- Technical unknowns or multiple valid approaches

**If there are ANY open questions, list them ALL and ask in a single batch before writing the output.**

> Do NOT write open questions and then answer them yourself with recommendations.
> Do NOT proceed with assumptions — ask.
> Document the user's answer before continuing.

Example:
```
Before I write the research document, I have a few questions:

1. [Requirement ambiguity] "{X}" could mean A or B — which is correct?
2. [Missing spec] The PRD doesn't say what should happen when {Y}. Options: A / B / skip for now?
3. [Technical choice] Implementing {Z} could use approach A (pros: X, cons: Y) or B (pros: Y, cons: X) — preference?
```

---

## Phase 5: Confidence Assessment

Rate confidence across dimensions (qualitative):

| Dimension | Confidence | Notes |
|-----------|------------|-------|
| Requirement Clarity | High / Medium / Low | |
| Codebase Understanding | High / Medium / Low | |
| Technical Feasibility | High / Medium / Low | |
| Scope Definition | High / Medium / Low | |
| Risk Identification | High / Medium / Low | |

**Overall:** High / Medium / Low — and whether to PROCEED / CLARIFY FURTHER / HALT.

---

## Output

Create `OUTPUT_DIR/research-{feature}.md`:

```markdown
# Research: {Feature Name}

## Metadata
- Date: {date}
- Source: {Jira/Confluence/Prompt}
- Confidence: {High / Medium / Low}

## Requirements Summary
{Parsed requirements with IDs: R1, R2, R3...}

## Codebase Analysis
{Related code, patterns to follow, reusable components}

## Technical Analysis
{Architecture impact, new code required, API needs}

## Clarified Questions
{Questions asked and user answers — or "None"}

## Risk Assessment
{Risks with likelihood/impact/mitigation}

## Confidence Assessment
{Per-dimension table, overall confidence, recommendation}

## Recommendation
{PROCEED / CLARIFY FURTHER / HALT}
```
