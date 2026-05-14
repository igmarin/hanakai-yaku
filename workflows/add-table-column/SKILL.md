---
name: add-table-column
version: "1.0.0"
license: MIT
description: >
  Use when adding a column to an existing table in Hanami 2.x. Chains
  write-migration, define-relation, define-entity, create-repository, and write-request-spec.
ecosystem_sources:
  - jeremyevans/sequel
  - rom-rb/rom
  - hanami/hanami
tags:
  - workflows
  - migrations
  - schema-changes
  - database
---

# add-table-column

Use this workflow when adding a column to an existing table in Hanami 2.x.

**Core principle:** Schema changes cascade through the data layer. Update the database, then Relations, Entities, Repositories, and tests.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Generate migration | `write-migration` | Migration file created |
| 2. Run migration | `manage-database` | Migration applied successfully |
| 3. Update Relation | `define-relation` | Relation schema includes new column |
| 4. Update Entity | `define-entity` | Entity has new attribute |
| 5. Update Repository | `create-repository` | Repository methods use new column if needed |
| 6. Write tests | `write-request-spec` | Tests pass with new column |

---

## Core Process

1. **[Generate Migration]** — Load skill: `write-migration`
   - `hanami generate migration add_bio_to_users`
   - Write `alter_table(:users) { add_column :bio, :text, null: true }`
   - Handoff condition: Migration file exists and is valid

2. **[Run Migration]** — Load skill: `manage-database`
   - `hanami db migrate`
   - Verify schema change in database
   - Handoff condition: Schema updated in database

3. **[Update Relation]** — Load skill: `define-relation`
   - If using explicit schema (not `infer: true`), add the new column
   - If using `infer: true`, schema is auto-updated at boot
   - Handoff condition: Relation includes new column

4. **[Update Entity]** — Load skill: `define-entity`
   - Add attribute to Entity class: `attribute :bio, Types::String.optional`
   - Handoff condition: Entity includes new attribute

5. **[Update Repository]** — Load skill: `create-repository`
   - Update query methods if the new column affects filtering
   - Update create/update methods if the new column is required
   - Handoff condition: Repository methods handle new column

6. **[Write Tests]** — Load skill: `write-request-spec`
   - Update request specs to include new column in assertions
   - Test that the column is persisted and returned correctly
   - Handoff condition: All tests pass

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll update the Entity before running the migration" | The migration must be applied before the Entity can reference the new column. |
| "I'll forget to update the Repository" | If the new column affects queries or required fields, the Repository must be updated. |
| "I'll skip updating tests" | Tests must assert on the new column. Update existing specs and add new ones. |
| "I'll add the column as NOT NULL without a default" | Adding `NOT NULL` without a default fails on existing rows. Add a default or make it nullable first, backfill, then add NOT NULL. |

---

## Red Flags

- Entity updated before migration applied
- Repository not updated for new column
- Tests not updated
- `NOT NULL` column added without default on populated table
- Missing backfill strategy for existing data

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-migration** | Step 1: Create migration. |
| **manage-database** | Step 2: Run migration. |
| **define-relation** | Step 3: Update Relation schema. |
| **define-entity** | Step 4: Update Entity attributes. |
| **create-repository** | Step 5: Update Repository methods. |
| **write-request-spec** | Step 6: Update and run tests. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Add Column) |
|---|---|
| `rails generate migration AddBioToUsers bio:text` | `hanami generate migration add_bio_to_users` |
| `add_column :users, :bio, :text` | `alter_table(:users) { add_column :bio, :text }` |
| `rails db:migrate` | `hanami db migrate` |
| Update `app/models/user.rb` | Update `app/entities/user.rb` |
| Update controller strong params | Update Action `params` block |
| Update serializer | Update View/Serializer |
