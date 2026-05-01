# Scripts/Tooling RPI Profile

Load this profile for CLI tools, automation scripts, shell scripts, one-off utilities, CI helpers, and developer tooling. `AGENTS.md` and existing code override these defaults.

## Detection

Common signals:

- `scripts/`, `bin/`, `tools/`, `Makefile`, CI workflow files.
- Shell, Python, Node, Ruby, or Go command-line entrypoints.
- Argument parsing, file-system operations, subprocess calls, or generated artifacts.

## Implementation Guidance

- Keep commands non-interactive when used by automation.
- Validate arguments and paths before destructive or external operations.
- Quote shell variables and avoid command injection.
- Make outputs deterministic where possible.
- Support dry-run or clear logging when operations are risky.
- Preserve existing exit-code conventions.

## Validation

Prefer:

- Unit tests for parsing and pure functions.
- Fixture-based tests for file transforms.
- Shellcheck or language-specific linters when available.
- Dry-run commands before real side-effectful commands.

## Review Focus

- Unsafe file deletion, path traversal, glob surprises, and working-directory assumptions.
- Command injection and unquoted shell variables.
- Portability across local/CI environments.
- Idempotency and clear failure messages.
