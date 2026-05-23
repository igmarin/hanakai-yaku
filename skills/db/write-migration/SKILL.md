---
name: write-migration
version: "1.0.0"
license: MIT
description: >
  Use when creating or modifying database schemas in Hanami 2.x with Sequel.
  Covers create_table, add_column, drop_column, alter_table, primary_key, indexes,
  and migration lifecycle commands.
ecosystem_sources:
  - jeremyevans/sequel
  - hanami/hanami
tags:
  - db
  - migrations
  - sequel
  - schema
---

# write-migration

Use this skill when writing or running Sequel database migrations in Hanami 2.x.

**Core principle:** Sequel migration DSL is provided by `jeremyevans/sequel` — **not** ActiveRecord. Never use ActiveRecord syntax here.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a new table | `create_table(:table_name) { ... }` inside `Sequel.migration { change { ... } }` |
| Add a column to existing table | `alter_table(:table_name) { add_column :col, :type }` |
| Remove a column | `alter_table(:table_name) { drop_column :col }` |
| Add an index | `alter_table(:table_name) { add_index :col }` |
| Rename a column | `alter_table(:table_name) { rename_column :old, :new }` |
| Reversible migration | Use `change { }` block — Sequel infers the inverse automatically |
| Irreversible migration | Use `up { } / down { }` blocks explicitly |
| Generate migration file | `hanami generate migration create_users` |
| Run pending migrations | `hanami db migrate` |
| Roll back last migration | `hanami db rollback` |

---

## Core Rules

1. **Generate the migration file** using the Hanami CLI:

   ```bash
   hanami generate migration <migration_name>
   ```

   This creates `db/migrate/<timestamp>_<migration_name>.rb`.

2. **Open the generated file** and write the migration body inside the
   `Sequel.migration` block. Prefer `change { }` for reversible operations.

3. **Define the schema change** using the Sequel DSL. Always specify column types explicitly — do not rely on inference.

4. **Run the migration**:

   ```bash
   hanami db migrate
   ```

5. **Verify** the schema change in the database or via `hanami console`:

   ```ruby
   Hanami.app["db.rom"].relations[:users].schema.to_h
   ```

6. **Update the ROM Relation** (`define-relation`) to reflect any new
    or removed columns. The Relation schema must stay in sync with the database.

7. **Update Entities and Structs** (`define-entity`) if
    attribute lists change.

8. **Run the test suite** to confirm nothing is broken.

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Reality | Severity |
|---|---|---|
| ActiveRecord syntax in migration files (e.g. `add_column :users, :email, :string`) | Sequel uses `alter_table(:users) { add_column :email, :text }`. Column types are Sequel generic types (`:text`, `:integer`), not Rails types (`:string`, `:bigint`). | 🔴 Blocker |
| Missing `null: false` on required columns | Sequel does **not** add `NOT NULL` by default. Always declare `null: false` for required columns — omitting it allows NULL values silently. | 🔴 Blocker |
| Using `change { }` for `drop_column` or `rename_column` | These operations are **not** automatically reversible by Sequel. Use explicit `up { } / down { }` blocks. | 🔴 Blocker |
| Schema changes without corresponding ROM Relation updates | After adding or removing columns, the ROM Relation schema must be updated. If using `schema :table, infer: true`, the schema is re-inferred at boot, but explicit attribute declarations will be stale. | 🟠 High |
| Running migrations without checking `HANAMI_ENV` | `hanami db migrate` uses `DATABASE_URL` from the current environment. Always confirm `HANAMI_ENV` is set correctly before running in staging or production. | 🟠 High |
| Using `:timestamp` without timezone | Use `:timestamptz` (PostgreSQL) rather than `:timestamp` to avoid timezone-naive storage bugs. | 🟡 Medium |
| Migration files with duplicate timestamps | Sequel applies migrations in timestamp order; duplicates cause undefined behaviour. | 🟡 Medium |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-relation** | After every migration that adds, removes, or renames columns — update the Relation schema |
| **define-entity** | When column changes affect the Entity attribute list |
| **create-repository** | When new columns require new query methods or write operations |
| **add-table-column** (workflow) | Use the full workflow when adding a column end-to-end: migration → Relation → Entity → Repository → tests |
| **hanami-manage-database** | For `hanami db create`, `hanami db rollback`, and `hanami db seed` CLI reference |

---

## Reference Files

- **RAILS_MAPPING.md** — Side-by-side Rails (ActiveRecord) → Hanami 2.x (Sequel) syntax reference.
- **COLUMN_TYPES.md** — Sequel generic column types and their database-specific mappings (`:text`, `:timestamptz`, `:jsonb`, `:uuid`, etc.).

---

## Examples

### Create a table with a primary key and columns

```ruby
# db/migrate/20240601120000_create_users.rb

Sequel.migration do
  change do
    # create_table takes a symbol matching the intended table name
    create_table(:users) do
      # primary_key generates an auto-incrementing integer PK named :id
      primary_key :id

      # column :name, :type — always specify type explicitly
      column :email,      :text,    null: false
      column :first_name, :text,    null: false
      column :last_name,  :text,    null: false
      column :role,       :text,    null: false, default: "member"
      column :created_at, :timestamptz, null: false
      column :updated_at, :timestamptz, null: false

      # unique constraint on a single column
      unique [:email]
    end
  end
end
```

### Add a column to an existing table (reversible)

```ruby
# db/migrate/20240602090000_add_bio_to_users.rb

Sequel.migration do
  change do
    # alter_table wraps all modifications to an existing table
    alter_table(:users) do
      # add_column :name, :type, options
      add_column :bio, :text, null: true
    end
  end
end
```

### Drop a column (irreversible — use up/down)

```ruby
# db/migrate/20240603100000_remove_legacy_token_from_users.rb

Sequel.migration do
  up do
    alter_table(:users) do
      drop_column :legacy_token
    end
  end

  down do
    alter_table(:users) do
      add_column :legacy_token, :text, null: true
    end
  end
end
```
