---
name: audit-security
description: Security-focused audit that can run in background during implementation. Checks for vulnerabilities, auth issues, data exposure. Injects P0 findings to main agent.
---

# Security Audit Skill

Specialized audit focusing on security concerns. Can run standalone or in background during /implement.

---

## When to Use

- **Background Mode**: Automatically during /implement (spawned by implement skill)
- **Standalone Mode**: `/audit-security {files or feature}` for independent security review
- When reviewing code for security vulnerabilities before merge

---

## Agent Compatibility

- OUTPUT_DIR: `.claude/output` for Claude Code, `.codex/output` for Codex CLI
- Background mode uses Task tool with `run_in_background: true`
- Injection to main agent via findings file or direct message

---

## Check Categories

### P0 - Critical Security (MUST FIX IMMEDIATELY)

| Check | Description | Example |
|-------|-------------|---------|
| Hardcoded Credentials | API keys, passwords, secrets in code | `apiKey: "sk-1234..."` |
| SQL Injection | Unparameterized queries | `query("SELECT * FROM users WHERE id = $input")` |
| XSS Vulnerabilities | Unsanitized HTML rendering | `innerHTML = userInput` |
| Command Injection | Unescaped shell commands | `Process.run(userInput)` |
| Authentication Bypass | Missing or flawed auth checks | No token validation |
| Authorization Gaps | Missing permission checks | Direct object references |
| Insecure Data Storage | Sensitive data in plain text | Passwords in SharedPreferences |
| Path Traversal | Unvalidated file paths | `readFile(userPath)` |

### P1 - Important Security (SHOULD FIX)

| Check | Description | Example |
|-------|-------------|---------|
| Missing Input Validation | No sanitization on user input | Direct use of form values |
| Insecure Error Messages | Stack traces or internal info leaked | `catch (e) => show(e.toString())` |
| Missing Rate Limiting | No protection against brute force | Unlimited login attempts |
| Session Issues | Weak session handling | No session timeout |
| HTTPS Not Enforced | HTTP allowed for sensitive data | `http://api.example.com` |
| Weak Cryptography | MD5, SHA1 for security | `md5(password)` |
| Missing CSRF Protection | No CSRF tokens for state changes | POST without token |
| Logging Sensitive Data | Passwords/tokens in logs | `log.info("Token: $token")` |

### P2 - Minor Security (CONSIDER)

| Check | Description | Example |
|-------|-------------|---------|
| Verbose Error Messages | Too much info in errors | Detailed stack traces |
| Missing Security Headers | No CSP, HSTS, etc. | Response without headers |
| Outdated Dependencies | Known vulnerable versions | Old package versions |
| Missing Input Length Limits | No max length on inputs | Unbounded text fields |

---

## Flutter/Dart Specific Checks

```dart
// P0: Hardcoded secrets
const apiKey = "sk-live-abc123";  // ❌ CRITICAL

// P0: Insecure storage
final prefs = await SharedPreferences.getInstance();
prefs.setString('password', password);  // ❌ Use flutter_secure_storage

// P1: Missing input validation
final email = controller.text;  // ❌ Validate before use
await api.updateEmail(email);

// P1: Logging sensitive data
print("User token: $token");  // ❌ Never log tokens

// P0: No auth check
Future<void> deleteUser(String userId) async {
  await api.delete('/users/$userId');  // ❌ Check permissions first
}
```

---

## Execution Flow

### Background Mode (During /implement)

```
/implement invokes background audit:
    │
    ├── Task tool (background: true)
    │   └── Prompt: "Run /audit-security on files: {list}"
    │
    ├── Audit scans each file
    │   ├── Check P0 items
    │   ├── Check P1 items
    │   └── Check P2 items
    │
    ├── Generate findings
    │   └── Write to: .claude/output/audit-{session}-security.json
    │
    └── Injection Decision
        ├── If P0 found: Inject immediately to main agent
        │   └── Message: "SECURITY P0: {finding}. Fix before continuing."
        │   └── Main agent MUST fix before next task
        │
        └── If only P1/P2: Collect for summary
            └── Report at end of implementation
```

### Standalone Mode

```
/audit-security {target}
    │
    ├── Identify target files
    │   ├── Feature name → find related files
    │   ├── File paths → use directly
    │   └── "all" → scan entire codebase
    │
    ├── Run all security checks
    │
    ├── Generate report
    │   └── .claude/output/audit-security-{feature}.md
    │
    └── Display summary with P0/P1/P2 counts
```

---

## Output Format

### JSON Output (for background mode injection)

```json
{
  "audit_type": "security",
  "timestamp": "2026-01-03T10:30:00Z",
  "files_scanned": ["file1.dart", "file2.dart"],
  "severity_summary": {
    "P0": 1,
    "P1": 3,
    "P2": 2
  },
  "inject_to_main": true,
  "findings": [
    {
      "severity": "P0",
      "category": "hardcoded_credentials",
      "file": "lib/src/services/api_service.dart",
      "line": 42,
      "code": "const apiKey = 'sk-live-...'",
      "message": "Hardcoded API key detected",
      "fix": "Move to environment variable or secure storage"
    }
  ]
}
```

### Markdown Report (for standalone mode)

```markdown
# Security Audit Report: {Feature}

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| P0 (Critical) | 1 | MUST FIX |
| P1 (Important) | 3 | SHOULD FIX |
| P2 (Minor) | 2 | CONSIDER |

**Overall**: FAIL (P0 issues present)

## Critical Findings (P0)

### 1. Hardcoded API Key
- **File**: lib/src/services/api_service.dart:42
- **Code**: `const apiKey = 'sk-live-...'`
- **Risk**: API key exposed in source code
- **Fix**: Use environment variables via `--dart-define` or secure storage

## Important Findings (P1)
...

## Minor Findings (P2)
...

## Recommendations
1. Immediate: Fix all P0 issues before merge
2. Short-term: Address P1 issues in follow-up PR
3. Long-term: Consider P2 improvements
```

---

## Injection Protocol

When running in background mode and P0 is found:

```
1. Write finding to audit file immediately
2. Send message to main agent:

   "🚨 SECURITY P0 DETECTED

   File: {file}:{line}
   Issue: {category}
   Code: {code snippet}

   Fix Required: {fix description}

   ⚠️ You MUST fix this before continuing to the next task."

3. Main agent receives message and:
   a. Stops current task
   b. Fixes the security issue
   c. Re-runs audit on fixed file
   d. Continues only when P0 count = 0
```

---

## Integration with RPI Workflow

### In /implement Phase 2.5

```markdown
After completing each task group (e.g., after T1-T3):

1. Get list of files created/modified
2. Spawn background security audit:

   Task tool:
     subagent_type: "general-purpose"
     run_in_background: true
     prompt: "Run /audit-security on: {file list}.
              Write findings to .claude/output/audit-{session}-security.json.
              If P0 found, report immediately."

3. Continue with next task group
4. Before Phase 3 (Verification):
   - Wait for background audit completion
   - Check for any P0 findings
   - Fix all P0 before proceeding
```

---

## Prompt Template

When invoked, execute:

```
## Security Audit: {target}

Scanning for security vulnerabilities...

### Files to Audit
{list of files}

### P0 Checks (Critical)
□ Hardcoded credentials
□ SQL injection
□ XSS vulnerabilities
□ Command injection
□ Authentication bypass
□ Authorization gaps
□ Insecure data storage
□ Path traversal

### P1 Checks (Important)
□ Input validation
□ Error message exposure
□ Rate limiting
□ Session handling
□ HTTPS enforcement
□ Cryptography strength
□ CSRF protection
□ Logging sensitive data

### Findings

[Analyze each file and report findings by severity]

### Summary

| Severity | Count |
|----------|-------|
| P0 | {n} |
| P1 | {n} |
| P2 | {n} |

**Status**: {PASS if P0=0, FAIL otherwise}

{If P0 > 0: List required fixes}
{If background mode and P0 > 0: Inject to main agent}
```

---

## Quick Reference

```
# Standalone
/audit-security                    # Audit current feature
/audit-security lib/src/auth/      # Audit specific directory
/audit-security api_service.dart   # Audit specific file

# Background (invoked by /implement)
# Automatically runs during implementation
```
