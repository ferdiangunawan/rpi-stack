---
name: audit-security
description: Security-focused audit for general coding tasks. Checks vulnerabilities, auth/authz issues, sensitive data exposure, unsafe inputs, and dependency risks using P0/P1/P2 severity.
---

# Security Audit Skill for Codex

Use this skill for changes involving authentication, authorization, user input, file/network boundaries, secrets, payments, personal data, external integrations, database access, or deployment configuration.

## Severity

### P0 Critical

- Hardcoded credentials, tokens, private keys, or production secrets.
- Auth bypass or missing authorization at a trust boundary.
- SQL/command/template/path injection with realistic exploit path.
- Sensitive data exposure in logs, responses, client bundles, or storage.
- Unsafe deserialization or remote code execution risk.
- Insecure migration or config that exposes production data.

### P1 Important

- Missing input validation or output encoding on reachable paths.
- Overly broad permissions or direct object references.
- Insecure error messages leaking internals.
- Missing CSRF/session protections where applicable.
- Weak crypto or insecure transport for sensitive data.
- Dependency with known vulnerability in affected runtime path.

### P2 Minor

- Security headers, rate limits, or hardening improvements not required for correctness.
- Documentation gaps around security-sensitive behavior.
- Defense-in-depth improvements.

## Review Process

1. Identify trust boundaries: user input, API requests, files, environment, database, third-party services.
2. Trace sensitive data: credentials, tokens, PII, payment data, internal identifiers.
3. Check auth/authz at the server or authoritative boundary, not only the client.
4. Check validation, encoding, parameterization, and error handling.
5. Check configuration and dependency risk when relevant.
6. Apply project conventions from `AGENTS.md` and relevant profiles.

## Output

For formal audits, write `.codex/output/audit-security-{feature}.md` or `.codex/output/audit-{session}-security.json` when a machine-readable result is useful.

```markdown
# Security Audit: {Feature}

## Summary
- P0: {count}
- P1: {count}
- P2: {count}
- Verdict: {PASS|FAIL}

## Findings
### P0 - {title}
- File: {path}:{line}
- Risk: {specific exploit or exposure}
- Fix: {concrete fix}

## Residual Risk
- {tests not run, assumptions, or none}
```

Fix all P0 findings before completion.
