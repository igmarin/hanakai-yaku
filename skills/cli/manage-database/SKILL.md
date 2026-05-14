---
name: manage-database
version: "1.0.0"
license: MIT
description: >
  Use when running Hanami 2.x database CLI commands. Covers hanami db create,
  migrate, rollback, seed with preconditions and expected outcomes.
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

## Quick Reference

| Command | Purpose | Preconditions |
|---|---|---|
| `hanami db create` | Create the database | `DATABASE_URL` must be set |
| `hanami db drop` | Drop the database | Confirm `HANAMI_ENV` — never run in production |
| `hanami db migrate` | Run pending migrations | Database must exist |
| `hanami db rollback` | Roll back the last migration | Database must exist; migration must be reversible |
| `hanami db seed` | Run seed data | Database must exist; migrations must be current |
| `hanami db prepare` | Create + migrate + seed (development) | `DATABASE_URL` must be set |
| `hanami db version` | Show current migration version | Database must exist |

---

## Core Rules

1. **Create the database**:

   ```bash
   DATABASE_URL=postgres://localhost/my_app_development hanami db create
   ```

   Expected outcome: Database `my_app_development` is created.

2. **Run migrations**:

   ```bash
   hanami db migrate
   ```

   Expected outcome: All pending migrations in `db/migrate/` are applied.

3. **Roll back the last migration**:

   ```bash
   hanami db rollback
   ```

   Expected outcome: The most recently applied migration is reversed.

   **Warning**: Only works if the migration was defined with `change` (reversible) or explicit `up`/`down`.

4. **Run seed data**:

   ```bash
   hanami db seed
   ```

   Expected outcome: `db/seeds.rb` is executed.

   ```ruby
   # db/seeds.rb
   # frozen_string_literal: true

   rom = Hanami.app["db.rom"]
   users = rom.relations[:users]

   users.insert(email: "admin@example.com", first_name: "Admin", role: "admin")
   ```

5. **Prepare the database** (create + migrate + seed):

   ```bash
   hanami db prepare
   ```

   Expected outcome: Database is created, migrations applied, and seeds run.

6. **Check migration version**:

   ```bash
   hanami db version
   ```

   Expected outcome: Prints the timestamp of the last applied migration.

7. **Never run `db drop` in production**. Always confirm `HANAMI_ENV`:

   ```bash
   echo $HANAMI_ENV  # Should be "development" or "test"
   hanami db drop    # DESTRUCTIVE — deletes all data
   ```

8. **Preconditions for all commands**:
   - `DATABASE_URL` environment variable is set
   - Database server is running (for PostgreSQL/MySQL)
   - User has permissions to create/drop databases (for `db create` / `db drop`)

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll run `hanami db migrate` before creating the database" | Always run `hanami db create` first. Migration fails if the database does not exist. |
| "I'll run `hanami db drop` without checking `HANAMI_ENV`" | `db drop` deletes all data. Confirm environment. Never run in production. |
| "I'll run migrations in the wrong environment" | `hanami db migrate` uses `DATABASE_URL` from the current environment. Check `HANAMI_ENV` before running in staging/production. |
| "I'll edit a migration file after it has been run" | Do not edit ran migrations. Create a new migration to fix the schema. |
| "I'll skip `hanami db seed` because I don't have seed data yet" | Create an empty `db/seeds.rb` so `hanami db prepare` works. Add seed data later. |
| "I'll run `hanami db rollback` on an irreversible migration" | `drop_column` and `rename_column` migrations require explicit `up`/`down`. Rolling back a `change`-only irreversible migration fails. |

---

## Red Flags

- Running migrations on a non-existent database
- `db drop` without environment confirmation
- Editing already-ran migrations
- Missing `DATABASE_URL`
- Running destructive commands in production
- Irreversible migrations without explicit `up`/`down`

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-migration** | Create migration files before running `hanami db migrate`. |
| **create-app** | Database commands are used after creating the app. |
| **define-relation** | Verify Relations match the migrated schema. |
| **write-request-spec** | Test database setup may need `hanami db prepare`. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (DB Commands) |
|---|---|
| `rails db:create` | `hanami db create` |
| `rails db:drop` | `hanami db drop` |
| `rails db:migrate` | `hanami db migrate` |
| `rails db:rollback` | `hanami db rollback` |
| `rails db:seed` | `hanami db seed` |
| `rails db:setup` | `hanami db prepare` |
| `rails db:version` | `hanami db version` |
| `rails db:schema:dump` | No direct equivalent. Schema is inferred by ROM. |
| `db/seeds.rb` | `db/seeds.rb` (same path) |
