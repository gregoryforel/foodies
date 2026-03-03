# Development Guide

## Prerequisites

- Go 1.22+
- PostgreSQL 17 (or Docker)
- [sqlc](https://sqlc.dev/) (`go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest`)
- [templ](https://templ.guide/) (`go install github.com/a-h/templ/cmd/templ@latest`)
- psql (PostgreSQL client)

## Quick Start

```bash
# 1. Start Postgres (via Docker)
make up

# 2. Run migrations
make migrate

# 3. Load seed data
make seed

# 4. Compile recipes (populates compiled_recipes)
make compile-recipes

# 5. Run the server
make dev

# Visit http://localhost:8080
```

## Make Targets

| Target | Description |
|--------|-------------|
| `make up` | Start Docker containers (Postgres) |
| `make down` | Stop Docker containers |
| `make migrate` | Run all SQL migrations |
| `make seed` | Load seed data |
| `make sqlc` | Regenerate Go types from SQL |
| `make templ` | Regenerate Go from templ files |
| `make test` | Run all tests |
| `make compile-recipes` | Run compilation pipeline on all recipes |
| `make dev` | Run server with hot reload (air) or plain |
| `make build` | Build production binary |

## Adding a Migration

1. Create `db/migrations/NNN_description.up.sql`
2. Create `db/migrations/NNN_description.down.sql`
3. Run `make migrate`
4. Update queries in `db/sql/` as needed
5. Run `make sqlc`

## Regenerating sqlc

```bash
make sqlc
```

This reads `sqlc.yaml`, processes queries in `db/sql/` against the schema in `db/migrations/`, and writes Go types to `internal/dbgen/`.

## Regenerating templ

```bash
make templ
```

This processes `.templ` files in `web/templates/` and generates corresponding `*_templ.go` files.

## Running Tests

```bash
make test
```

Tests include:
- Unit conversion tests (metric ↔ US)
- Handler tests (HTTP response codes)
- Database integration tests (requires running Postgres)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATABASE_URL` | `postgres://recipe:recipe@localhost:5432/recipe_platform?sslmode=disable` | PostgreSQL connection string |
| `PORT` | `8080` | HTTP server port |

## Checklist for New Features

- [ ] Schema migration created and tested
- [ ] sqlc queries updated and regenerated
- [ ] templ templates updated and regenerated
- [ ] Compilation pipeline handles new data
- [ ] Tests pass
- [ ] No secrets in code
