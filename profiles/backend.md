# Backend API & Systems Profile

Load this profile when working with backend services, APIs, databases, or microservices (Node.js, Go, Python, Java, Rust, etc.). Project-level `AGENTS.md` and existing repository conventions override these defaults.

## Detection Signals

- Server frameworks: Express, NestJS, FastAPI, Django, Gin, Echo, Actix, Spring Boot.
- Database tools: Prisma, Drizzle, TypeORM, SQLAlchemy, GORM, Diesel, Alembic, Flyway.
- API specs: OpenAPI/Swagger, Protocol Buffers, GraphQL schemas.

## Architecture & Security Standards

- **Tenant & User Authorization**: Every data access operation must explicitly enforce tenant/user scoping. Never rely solely on client-provided IDs without server-side ownership verification (prevent IDOR).
- **Secrets & Credentials**: Never hardcode API keys, database credentials, or secret tokens. Always read via validated environment configs.
- **SQL & Query Safety**: Use parameterized queries or ORM query builders. Never concatenate raw user input into SQL strings.
- **Input Validation**: Validate and sanitize all incoming request payloads at the boundary using schema validators (Zod, Pydantic, Joi, class-validator).

## Data & Database Safety (P0 Guards)

- **Migrations**: Database schema alterations must be backward-compatible (expand-contract pattern). Never drop columns or tables in a single step if active code reads them.
- **Transactions & Idempotency**: Use database transactions for multi-step mutations. Implement idempotency keys for payment, webhook processing, or non-idempotent side effects.
- **Performance & N+1 queries**: Avoid N+1 queries by eager-loading relations or batching with DataLoader/JOINs. Add database indexes for query filter and foreign key columns.
- **Test Safety**: Never execute backend integration tests against non-local, shared, staging, or production databases. Always confirm isolated local test databases before running migrations or test suites.

## Resilience & Observability

- **Rate Limiting**: Protect public-facing endpoints and expensive operations with rate limiting (Redis/token bucket).
- **Error Handling**: Catch and map errors to standardized API response structures. Never expose internal stack traces, database schema details, or raw server errors to API clients.
- **Sensitive Logging**: Redact passwords, tokens, credit card numbers, and PII from application logs.

## Validation Commands

```bash
# Typecheck / compilation
npm run build / go build ./... / cargo check

# Lint
npm run lint / golangci-lint run / ruff check .

# Unit tests (pure business logic)
npm test / go test ./... / pytest -v
```

## Review Focus

- Missing authorization or tenant boundaries (P0 security).
- Data loss risks during schema migration (P0 data integrity).
- Unindexed queries or N+1 query loops (P1 performance).
- Unhandled promise rejections or unhandled exceptions crashing the process (P0 stability).
- Unchecked input boundaries or missing request schema validation (P1 correctness).
