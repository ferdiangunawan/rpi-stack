# Backend/API RPI Profile

Load this profile for server, API, worker, database, and service-layer changes. `AGENTS.md` and existing code override these defaults.

## Detection

Common signals:

- Server entrypoints, routers, controllers, handlers, jobs, queues, or service modules.
- Database schemas, migrations, ORM models, OpenAPI/GraphQL/gRPC contracts.
- API integration tests or request specs.

## Implementation Guidance

- Keep validation, authorization, and business rules at authoritative server boundaries.
- Make API contract changes explicit: inputs, outputs, errors, status codes, compatibility.
- Use existing transaction, retry, idempotency, and error mapping patterns.
- Avoid schema changes without migration and rollback considerations.
- Preserve backwards compatibility unless the requirement explicitly permits a breaking change.

## Validation

Choose targeted checks:

- Unit tests for pure logic and service behavior.
- Handler/request/integration tests for API behavior.
- Migration tests or dry-run commands when schema changes are present.
- Typecheck/lint/build commands from the project manifest or CI config.

## Review Focus

- Auth/authz and tenant/user scoping.
- Input validation, output filtering, and sensitive logging.
- Transactions, concurrency, idempotency, retries, and partial failure behavior.
- N+1 queries, missing indexes, pagination, and large payloads.
