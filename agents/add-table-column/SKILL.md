---
name: add-table-column
license: MIT
description: >
  Use when adding a column, field, or new attribute to an existing table in Hanami 2.x, or when performing a database schema change such as altering a table. Chains write-migration,
  define-relation, define-entity, create-repository, and write-request-spec.
metadata:
  ecosystem_sources:
  - jeremyevans/sequel
  - rom-rb/rom
  - hanami/hanami
  tags:
  - agents
  - migrations
  - schema-changes
  - database
  version: 1.0.0
---

# add-table-column

Use this workflow when adding a column to an existing table in Hanami 2.x.

**Core principle:** Schema changes cascade through the data layer. Update the database, then Relations, Entities, Repositories, and tests.

---

## Core Process

| Step | Skill | What to do | Handoff Condition |
|---|---|---|---|
| 1. Generate migration | `write-migration` | `hanami generate migration add_bio_to_users`; write the migration body | Migration file exists and is valid |
| 2. Run migration | `manage-database` | `hanami db migrate`; verify schema change in database | Schema updated in database |
| 3. Update Relation | `define-relation` | If explicit schema, add new column; if `infer: true`, auto-updated at boot | Relation includes new column |
| 4. Update Entity | `define-entity` | Add attribute: `attribute :bio, Types::String.optional` | Entity includes new attribute |
| 5. Update Repository | `create-repository` | Update query/create/update methods if new column affects filtering or is required | Repository methods handle new column |
| 6. Write Tests | `write-request-spec` | Update request specs to assert on new column; test persistence and return | All tests pass |

---

## Complete Migration File Example

```ruby
# db/migrate/20240601120000_add_bio_to_users.rb
Rom::SQL::Migration do
  change do
    alter_table(:users) do
      add_column :bio, :text, null: true
    end
  end
end
```

For a `NOT NULL` column on a populated table, use a three-step approach:

```ruby
# Step 1: Add as nullable with a default
alter_table(:users) do
  add_column :bio, :text, null: true, default: ''
end

# Step 2: Backfill existing rows (separate migration or script)
# Step 3: Add NOT NULL constraint after backfill
alter_table(:users) do
  set_column_not_null :bio
end
```

---

## Pitfalls

| Mistake / Red Flag | Correct Approach |
|---|---|
| Entity updated before migration applied | The migration must be applied before the Entity can reference the new column. |
| Repository not updated for new column | If the new column affects queries or required fields, the Repository must be updated. |
| Tests not updated | Tests must assert on the new column. Update existing specs and add new ones. |
| `NOT NULL` column added without a default on a populated table | Adding `NOT NULL` without a default fails on existing rows. Add a default or make it nullable first, backfill, then add `NOT NULL`. |
| Missing backfill strategy for existing data | Plan a backfill step in a separate migration or script before enforcing constraints. |
