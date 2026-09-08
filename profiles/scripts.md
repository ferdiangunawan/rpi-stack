# Scripts & Tooling Profile

Load this profile when working with CLI utilities, automation scripts, shell scripts, Makefile targets, or CI/CD pipelines. Project-level `AGENTS.md` and existing repository conventions override these defaults.

## Detection Signals

- Directories: `scripts/`, `bin/`, `tools/`, `.github/workflows/`, `Makefile`.
- File extensions: `.sh`, `.bash`, `.py`, `.js` (CLI entrypoints).
- Subprocess executions, file system manipulation, or environment provisioning.

## Shell & Scripting Standards

- **Strict mode**: In Bash scripts, always start with `set -euo pipefail` to fail fast on errors, undefined variables, and pipe failures.
- **Variable Quoting**: Always quote variables (`"$VAR"`, `"${ARRAY[@]}"`) to prevent word splitting, path globbing surprises, and command injection.
- **Input Validation**: Validate CLI arguments, file paths, and prerequisites at the start of the script. Provide clear `--help` usage text.
- **Non-Interactive by Default**: For CI/automation scripts, ensure commands do not prompt interactively for input (e.g. use `DEBIAN_FRONTEND=noninteractive`, `-y` flags, or non-blocking prompts).
- **Dry-run Support**: Scripts that perform destructive actions (deletion, file overwrite, cloud provisioning) must support a `--dry-run` or `-n` flag.

## Path Safety & Idempotency

- **Working Directory**: Derive paths relative to the script location using `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`, not assuming the caller's current working directory.
- **Path Traversal**: Validate and sanitize any user-supplied directory path before passing it to `rm -rf` or file copy commands.
- **Idempotency**: Script executions should be safe to run multiple times without duplicating entries, corrupting config files, or failing if a target already exists (`mkdir -p`, `ln -sf`).

## Validation Commands

```bash
# Shell script syntax check
bash -n <script.sh>

# Shellcheck (static analysis for shell scripts)
shellcheck <script.sh>

# Dry-run execution
./<script.sh> --dry-run
```

## Review Focus

- Command injection or unquoted variable expansion (P0 security).
- Destructive operations without path validation or dry-run option (P0 data loss).
- Missing `set -euo pipefail` leading to silent partial failures (P1 robustness).
- Platform portability issues (GNU vs BSD tools on macOS vs Linux) (P1 compatibility).
