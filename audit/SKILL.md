---
name: audit
description: Check research or an implementation plan against sources, project rules, feasibility, and scope when a quality gate would reduce meaningful risk.
---

# Audit

Review a research handoff or plan critically when asked or when uncertainty or impact justifies a separate check. The audit is an evidence check, not a mandatory ceremony before every edit.

## Check independently

- **Evidence:** Verify important claims against actual sources, code, and revision. Distinguish facts from inferences and missing access.
- **Requirement coverage:** Check that the requested outcome and material edge cases are addressed without adding unsupported requirements.
- **Feasibility:** Confirm proposed APIs, paths, dependencies, and verification methods exist and can be used under current instructions.
- **Risk:** Look for data, security, compatibility, and operational consequences proportionate to the change. Check backend test plans against the active environment policy.
- **Project fit:** Apply repository instructions and relevant conventions. Treat a generic [profile](../profiles/) as guidance, not an override.

Return specific findings with supporting evidence and the correction needed. Use **ready**, **ready with caveats**, or **revise** as a concise conclusion if a verdict helps. A caveat is acceptable when it does not block the requested next step; a material unsupported claim or unresolved safety issue requires revision. Do not demand a new approval gate unless active instructions require one.

Keep the report inline unless a persistent artifact was requested or would help a substantial handoff. Delegation can offer an independent perspective when explicitly authorized; otherwise inspect the underlying sources yourself.
