# Backend profile

Use for services, APIs, jobs, and persistence code. Follow the active repository's instructions and established patterns first. Apply only checks relevant to the changed path.

## Trace the boundary

- Identify the caller, input validation, authorization, business operation, persistence, and outward response or event.
- Confirm actor or tenant scope where data access depends on it. Check idempotency and retry behavior for payments, webhooks, queues, and other repeated side effects.
- For multi-step writes, inspect transaction boundaries and external side effects. Assess schema changes against deployed readers and writers before proposing migration or rollback steps.
- Check query volume and indexing when the changed path is frequent or works over collections. Examine secrets, sensitive logs, and error exposure where data crosses a trust boundary.

## Verification boundary

Static inspection, syntax checks, and linting may be useful when they do not execute application tests or touch a database. Do not initiate backend tests, migrations, or seeds. When a backend test would help, state the exact command for the user to run or approve. If the user explicitly requests a run, inspect the active environment and database configuration before every run. Refuse remote, shared, staging, production, or unclear targets. For a confirmed local disposable database, state the exact command and effects, then obtain explicit approval for that command. Do not treat container-local execution as proof that its database is local.
