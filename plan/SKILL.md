---
name: plan
description: Turn grounded software requirements and code findings into an implementation approach with clear decisions, scope, and proportionate verification.
---

# Plan

Produce a plan another developer can implement without guessing about material behavior or scope. Planning alone does not authorize implementation.

## Build the plan

1. Confirm the requested outcome, constraints, and current code. Validate research artifacts against the present worktree before relying on them.
2. Choose an approach that fits existing architecture and minimizes unrelated changes. Use applicable repository instructions and, when useful, a [domain profile](../profiles/).
3. Resolve decisions that materially affect behavior, data, APIs, security, or release risk. Use established patterns for ordinary details. If a decision needs the user, offer concrete options and a recommendation; mark dependent work as pending.
4. Describe the change in dependency order, with likely files or components, observable acceptance criteria, and important edge cases. Use as much detail as the work needs; do not impose a fixed data/domain/UI task breakdown.
5. Specify proportionate verification. Name exact commands only after confirming they exist and are allowed. Distinguish static checks, tests, manual checks, and runtime evidence. Do not schedule backend test execution on initiative; if the user requests it, the environment gate applies before any run.

Include migration, rollback, or deployment considerations only when the change can affect persisted data, public contracts, or releases. Record assumptions and remaining risks so implementation can revisit them.

Return the plan inline for short work. Create a persistent file only when requested or useful for a substantial handoff, using the user's chosen or a project-appropriate path.
