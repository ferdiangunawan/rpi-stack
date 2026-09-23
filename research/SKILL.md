---
name: research
description: Investigate a software request, issue, or unfamiliar code path and report grounded requirements, current behavior, risks, and open decisions.
---

# Research

Establish enough evidence to answer the user's question or support a sound implementation decision. Research alone does not authorize code changes.

## Investigate

1. Read applicable instructions and the user's source material. If a linked issue, design, or specification is authoritative, use an available authenticated source to inspect it. Identify inaccessible sources as gaps.
2. Inspect the relevant code and history. Trace actual entry points, data flow, callers, and existing patterns. Read a [domain profile](../profiles/) only when it applies, and prefer current repository conventions over generic advice.
3. Separate confirmed requirements, observed behavior, reasonable inferences, and unresolved assumptions. Cite paths, lines, revisions, or source links where they help someone verify an important claim.
4. Identify affected boundaries, likely failure modes, and useful verification evidence. Keep scope proportional to the request; do not invent product requirements or implementation tasks.

Answer discoverable questions from sources. Ask the user when a missing decision changes behavior, scope, contract, or risk and cannot be inferred safely. Present concise options and a recommendation when there is a meaningful choice. Continue independent investigation while waiting.

## Handoff

Report the requested answer or a compact handoff containing requirements, evidence, relevant code, risks, open decisions, and a recommended next step. State what was not verified. Write a separate research file only when requested or useful for a long-running handoff, at the user's chosen or a project-appropriate path.
