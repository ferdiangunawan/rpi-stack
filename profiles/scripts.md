# Scripts and tooling profile

Use for CLI tools, shell scripts, build automation, and CI configuration. Follow the active repository's instructions and the script's declared shell or runtime first.

## Review the operation

- Validate arguments and fail with useful errors. Quote shell expansions and use arrays or safe APIs when passing user input to subprocesses.
- Resolve paths deliberately; check the actual target before deletion or overwrite. Make destructive operations previewable or explicitly scoped when that reduces real risk.
- Preserve useful exit codes, handle partial failure, and make repeated runs safe where the workflow may be retried.
- Use shell options supported by the declared interpreter. For Bash, strict mode can help, but account for intentional nonzero statuses and pipelines. Do not put Bash-only syntax in a POSIX sh script.
- Check portability only across the platforms the project supports. Avoid assuming GNU and BSD utilities behave alike.

## Verification

Syntax checks and static analysis are usually cheap. If a dry run exists, inspect what it would change. For installers or cleanup tools, test against isolated temporary destinations before writing to a real user configuration.
