---
name: research
description: Use when needing to understand requirements before implementation. Gathers context from Jira, Confluence, codebase, and docs. Produces research document with confidence scoring.
---

# Research Skill

Conducts thorough research on requirements and codebase before implementation.

## When to Use

Use this skill when:
- Need to understand a Jira ticket before planning
- Exploring feasibility of a feature
- Gathering context about existing code patterns
- Assessing complexity of a task

## Instructions

### Phase 1: Input Gathering

**From Jira:**
```
Use mcp__atlassian__getJiraIssue to extract:
- Summary (title)
- Description (requirements)
- Acceptance Criteria
- Linked Confluence pages
```

**From Codebase (Using Parallel Exploration):**
```
Use Task tool to launch 2-3 Explore subagents in parallel:

Agent 1 (quick thoroughness):
  "Search for similar features/patterns matching {feature keywords}"

Agent 2 (medium thoroughness):
  "Find all files that might be affected by {feature}, including
   dependencies and related components"

Agent 3 (thorough - optional for complex features):
  "Understand the existing architecture for {related domain},
   including data flow and state management patterns"

After agents complete:
1. Synthesize findings from all agents
2. Read AGENTS.md for project conventions
3. Identify existing components to reuse
```

### Phase 2: Requirement Analysis

For each requirement, identify:
- Type: functional/non-functional/constraint
- Priority: must-have/should-have/nice-to-have
- Complexity: low/medium/high
- Affected layers: presentation/application/domain/data
- Dependencies
- Risks

### Phase 3: Codebase Mapping

Map requirements to existing code:
- Similar features to reference
- Reusable components (widgets, services)
- API endpoints (existing vs new needed)
- State management patterns

### Phase 4: Gap Analysis

Identify:
- New code needed (screens, controllers, models, services)
- API gaps
- Missing information / unclear requirements
- Technical unknowns

### Phase 5: Confidence Scoring

Calculate confidence across dimensions:

| Dimension | Weight | Description |
|-----------|--------|-------------|
| Requirement Clarity | 25% | How clear are requirements? |
| Codebase Understanding | 25% | Do I understand patterns? |
| Technical Feasibility | 20% | Can this be implemented? |
| Scope Definition | 15% | Are boundaries clear? |
| Risk Identification | 15% | Are risks understood? |

**Overall Confidence = Weighted Sum**

Thresholds:
- ≥80%: High confidence, proceed
- 60-79%: Medium, clarify unknowns
- <60%: Low, request more info

### Output

Create `.claude/output/research-{feature}.md` with:

```markdown
# Research: {Feature Name}

## Metadata
- Date: {date}
- Source: {Jira/Confluence/Prompt}
- Confidence Score: {X}%

## Requirements Summary
{Parsed requirements with IDs}

## Codebase Analysis
{Related code, patterns to follow, reusable components}

## Technical Analysis
{Architecture impact, new code required, API needs}

## Risk Assessment
{Risks with likelihood/impact/mitigation}

## Confidence Assessment
{Scores per dimension, blockers, questions}

## Recommendation
{PROCEED / CLARIFY / HALT}
```

## Example

```
User: Research KB-1234 before we plan
Agent: [Fetches Jira, searches codebase, produces research doc]
```
