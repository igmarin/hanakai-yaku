---
name: manage-database
license: MIT
description: >
  Use when running Hanami 2.x database CLI commands — always confirm HANAMI_ENV and DATABASE_URL before destructive operations, create databases with `hanami db create`, run/revert migrations with `hanami db migrate`/`rollback` validating via `hanami db version`, seed data with `hanami db seed` from `db/seeds.rb`, prepare the full database with `hanami db prepare`, and never edit already-run migrations or use `hanami db drop` without environment confirmation. Covers create, migrate, rollback, seed with preconditions and expected outcomes.
metadata:
  version: "1.0.0"
  ecosystem_sources:
    - hanami/hanami-cli
    - jeremyevans/sequel
  tags:
    - cli
    - database
    - migrations
    - sequel
---

# manage-database

Use this skill when running Hanami 2.x database CLI commands.

**Core principle:** Database commands are environment-aware. Always confirm `HANAMI_ENV` and `DATABASE_URL` before running destructive commands.

---

## Commands

| Command | Purpose | Preconditions | Validate |
|---|---|---|---|
| `hanami db create` | Create the database | `DATABASE_URL` must be set | - |
| `hanami db drop` | Drop the database | **Warning:** Destructive - see below | - |
| `hanami db migrate` | Run pending migrations | Database must exist | `hanami db version` |
| `hanami db rollback` | Roll back the last migration | Database must exist; migration must be reversible | `hanami db version` |
| `hanami db seed` | Run seed data | Database must exist; migrations must be current | - |
| `hanami db prepare` | Create + migrate + seed (development) | `DATABASE_URL` must be set | - |
| `hanami db version` | Show current migration version | Database must exist | - |

### Usage examples

**Create the database:**
```bash
DATABASE_URL=postgres://localhost/my_app_development hanami db create
```

**Run migrations** (validate with `hanami db version` - prints timestamp of last applied migration):
```bash
hanami db migrate
hanami db version
```

**Roll back the last migration** (only works if migration is reversible - `change` block, or explicit `up`/`down`; `drop_column`/`rename_column` require explicit `up`/`down`):
```bash
hanami db rollback
hanami db version  # Should print the previous migration's timestamp
```

**Run seed data** (`db/seeds.rb` is executed):
```bash
hanami db seed
```

```ruby
# db/seeds.rb
# frozen_string_literal: true

rom = Hanami.app["db.rom"]
users = rom.relations[:users]

users.insert(email: "admin@example.com", first_name: "Admin", role: "admin")
```

**Prepare the database:**
```bash
hanami db prepare
```

---

## Destructive Operations

> **`hanami db drop` deletes all data and cannot be undone. Always validate before proceeding.**

Safe drop procedure:

```bash
echo $HANAMI_ENV   # Must output "development" or "test" - never "production"
hanami db drop     # Only proceed if environment is confirmed
```

Preconditions for all commands:
- `DATABASE_URL` environment variable is set
- Database server is running (for PostgreSQL/MySQL)
- User has permissions to create/drop databases (for `db create` / `db drop`)

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll edit a migration file after it has been run" | Do not edit ran migrations. Create a new migration to fix the schema. |
| "I'll skip `hanami db seed` because I don't have seed data yet" | Create an empty `db/seeds.rb` so `hanami db prepare` works. Add seed data later. |
| "I'll run `hanami db rollback` on an irreversible migration" | `drop_column` and `rename_column` migrations require explicit `up`/`down`. Rolling back a `change`-only irreversible migration fails. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-migration** | Create migration files before running `hanami db migrate`. |
| **create-app** | Database commands are used after creating the app. |
| **define-relation** | Verify Relations match the migrated schema. |
| **write-request-spec** | Test database setup may need `hanami db prepare`. |
