---
name: research
description: Investigate requirements and codebase context before planning or implementation. Gathers evidence from issues, PRDs, code, and docs. Resolves uncertainty with smart recommendations.
---

# Research Skill

Conducts thorough, evidence-grounded research on requirements and codebase architecture before planning or editing code.

## When to Use

- Understanding a Jira ticket, GitHub issue, PRD, or feature request.
- Exploring technical feasibility and architectural implications.
- Mapping existing patterns, reusable components, and potential dependencies.

## Agent Compatibility & Environment

- **Inquiry Tool**: Use `ask_question` (Antigravity/Gemini), `AskUserQuestion`/`AskFollowupQuestion` (Claude Code), or ask directly in conversation (Codex/CLI).
- **Subagent Parallelism**: If subagent tools (`invoke_subagent` or `Task`) are available, delegate broad searches or documentation research to background subagents to preserve main context.
- **Output Storage**: Save to `OUTPUT_DIR/research-{feature}.md` (`.claude/output`, `.codex/output`, or project artifacts directory) when formal artifacts or multi-session persistence is needed; otherwise, return a structured conversational handoff.

---

## Phase 1: Context & Evidence Gathering

### 1. External & Authoritative Sources
- **Issue Trackers (Jira / GitHub / PRD)**: Use available issue tools (e.g. Jira MCP, Atlassian Rovo, or prompt text) to extract Summary, Description, Acceptance Criteria, and linked specifications.
- **Missing Sources**: If an authoritative link is inaccessible, state the gap clearly. **Never hallucinate or invent specifications.**

### 2. Codebase Inspection (Parallelize searches when possible)
1. **Conventions & Rules**: Read applicable `AGENTS.md` or architectural guidelines first.
2. **Existing Patterns**: Search for similar features, models, controllers, or API clients.
3. **Blast Radius**: Identify files, services, and tests likely affected by the proposed changes.
4. **Relevant Profiles**: Inspect project files to identify the tech stack and read relevant guides in `profiles/` (`flutter.md`, `frontend.md`, `backend.md`, `scripts.md`).

---

## Phase 2: Requirement Analysis & Mapping

For each requirement:
- **Type**: Functional / Non-functional / Security / Constraint.
- **Mapping**: Existing code to extend vs. new code to create.
- **Reusability**: Identify existing helpers, design tokens, error handlers, and utilities to reuse.

---

## Phase 3: Smart Clarification Protocol

Avoid "learned helplessness" — do not halt execution to ask trivial questions that standard conventions or existing codebase patterns answer.

### Clarification Rules:
1. **Discoverable Questions**: Answer through codebase inspection before asking the user.
2. **Safe Technical Defaults**: For low-risk implementation details (e.g., standard empty state presentation, internal helper naming), apply safe defaults and document them explicitly under **Assumptions & Defaults**.
3. **Material Decisions**: When a choice materially alters product behavior, scope boundaries, API contracts, or security posture, **ask in a single batch**.
4. **Provide Recommendations**: When asking the user, always provide concrete options with trade-offs and an explicit recommendation:
   ```text
   Before proceeding with planning, I need your decision on [Topic]:
   - (Recommended) Option A: [Description] (Pros: ..., Cons: ...)
   - Option B: [Description] (Pros: ..., Cons: ...)
   ```

---

## Phase 4: Confidence & Risk Assessment

Evaluate qualitative confidence:

| Dimension | Confidence | Notes |
|-----------|------------|-------|
| Requirement Clarity | High / Medium / Low | Are specifications complete? |
| Codebase Mapping | High / Medium / Low | Are patterns and touchpoints identified? |
| Technical Feasibility | High / Medium / Low | Are APIs and dependencies validated? |
| Blast Radius & Risk | High / Medium / Low | Are migration/breaking risks understood? |

**Overall Recommendation**:
- `PROCEED`: Confident and ready to plan.
- `CLARIFY`: Awaiting user input on material decisions.
- `HALT`: Critical requirement missing or blocker discovered.

---

## Output Template

When persisting an artifact, create `OUTPUT_DIR/research-{feature}.md`:

```markdown
# Research: {Feature Name}

## Metadata
- Date: {YYYY-MM-DD}
- Source: {Jira / PRD / Issue / Prompt}
- Stack: {Flutter / Web / Backend / Tooling}
- Confidence: {High / Medium / Low} ({PROCEED / CLARIFY / HALT})

## Requirements Summary
- R1: {Requirement description}
- R2: {Requirement description}

## Codebase & Architecture Mapping
- **Reference Implementations**: `{path/to/existing/code}`
- **Affected Components**: `{paths}`
- **Reusable Elements**: `{helpers, tokens, shared widgets/services}`

## Assumptions & Confirmed Decisions
- [Assumption]: {Reasoning for default choice}
- [Confirmed]: {User-confirmed decision from clarification}

## Identified Risks & Blast Radius
- {Risk description, likelihood, and mitigation strategy}

## Recommendation
**{PROCEED / CLARIFY / HALT}**: {Brief rationale}
```
