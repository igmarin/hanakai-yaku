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

   ```
   hanami generate migration <migration_name>
   ```

   This creates `db/migrate/<timestamp>_<migration_name>.rb`.

2. **Open the generated file** and write the migration body inside the
   `Sequel.migration` block. Prefer `change { }` for reversible operations.

3. **Define the schema change** using the Sequel DSL. Always specify column types explicitly — do not rely on inference.

4. **Run the migration**:

   ```
   hanami db migrate
   ```

5. **Verify** the schema change in the database or via `hanami console`:

   ```ruby
   Hanami.app["db.rom"].relations[:users].schema.to_h
   ```

6. **Update the ROM Relation** (`define-relation`) to reflect any new
   or removed columns. The Relation schema must stay in sync with the database.

6. **Update Entities and Structs** (`define-entity`) if
   attribute lists change.

8. **Run the test suite** to confirm nothing is broken.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll use ActiveRecord syntax like `add_column :users, :email, :string`" | Sequel uses `alter_table(:users) { add_column :email, :text }`. The column type is a Sequel generic type (`:text`, `:integer`), not a Rails type (`:string`, `:bigint`). |
| "I don't need `null: false` — Sequel handles that" | Sequel does **not** add `NOT NULL` by default. Always declare `null: false` for required columns. Omitting it allows NULL values silently. |
| "I'll use `change { }` for `drop_column` and `rename_column`" | These operations are **not** automatically reversible by Sequel. Use explicit `up { } / down { }` blocks. |
| "I changed the schema but forgot to update ROM Relations" | After adding or removing columns, the ROM Relation schema must be updated. If using `schema :table, infer: true`, the schema is re-inferred at boot, but explicit attribute declarations will be stale. |
| "I'll run migrations without checking `HANAMI_ENV`" | `hanami db migrate` uses `DATABASE_URL` from the current environment. Always confirm `HANAMI_ENV` is set correctly before running in staging or production. |
| "I'll use `:timestamp` without timezone" | Use `:timestamptz` (PostgreSQL) rather than `:timestamp` to avoid timezone-naive storage bugs. |

---

## Red Flags

- ActiveRecord syntax appearing in migration files
- Missing `null: false` on required columns
- Using `change { }` for `drop_column` or `rename_column`
- Migration files with duplicate timestamps
- Schema changes without corresponding ROM Relation updates
- `:timestamp` instead of `:timestamptz` for time columns

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

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Sequel) |
|---|---|
| `create_table :users do \|t\|` | `create_table(:users) do` |
| `t.string :email, null: false` | `column :email, :text, null: false` |
| `t.integer :count, default: 0` | `column :count, :integer, default: 0` |
| `t.timestamps` | `column :created_at, :timestamptz, null: false` + `column :updated_at, :timestamptz, null: false` |
| `t.references :user, foreign_key: true` | `foreign_key :user_id, :users, null: false` |
| `add_column :users, :bio, :text` | `alter_table(:users) { add_column :bio, :text }` |
| `remove_column :users, :bio` | `alter_table(:users) { drop_column :bio }` |
| `add_index :users, :email, unique: true` | `alter_table(:users) { add_index :email, unique: true }` |
| `change_column_null :users, :email, false` | `alter_table(:users) { set_column_not_null :email }` |
| `rename_column :users, :username, :handle` | `alter_table(:users) { rename_column :username, :handle }` |
| `rails db:migrate` | `hanami db migrate` |
| `rails db:rollback` | `hanami db rollback` |
| Migration class inherits `ActiveRecord::Migration[7.1]` | `Sequel.migration do ... end` (no class inheritance) |

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

### Add a column to an existing table

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

### Composite primary key and foreign key

```ruby
# db/migrate/20240604110000_create_memberships.rb

Sequel.migration do
  change do
    create_table(:memberships) do
      foreign_key :user_id,         :users,         null: false
      foreign_key :organization_id, :organizations, null: false

      column :role,       :text, null: false, default: "member"
      column :created_at, :timestamptz, null: false

      primary_key [:user_id, :organization_id]
    end
  end
end
```

### Add an index

```ruby
# db/migrate/20240605080000_add_index_to_posts_published_at.rb

Sequel.migration do
  change do
    alter_table(:posts) do
      add_index :published_at
      add_index [:author_id, :published_at], name: :posts_author_published_idx
    end
  end
end
```

### Common Sequel column types

```ruby
# Reference: Sequel generic types map to DB-specific types automatically
#
# :integer       → INTEGER
# :bigint        → BIGINT
# :text          → TEXT
# :varchar       → VARCHAR(255) — prefer :text unless length matters
# :boolean       → BOOLEAN
# :date          → DATE
# :timestamp     → TIMESTAMP (no timezone)
# :timestamptz   → TIMESTAMP WITH TIME ZONE  ← prefer this for Hanami apps
# :float         → FLOAT
# :decimal       → DECIMAL (use :numeric for precision)
# :json          → JSON
# :jsonb         → JSONB (PostgreSQL only — prefer over :json)
# :uuid          → UUID (PostgreSQL only)
# :blob          → BYTEA / BLOB
```
