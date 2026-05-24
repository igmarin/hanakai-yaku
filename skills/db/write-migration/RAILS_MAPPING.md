# ActiveRecord to Sequel Migration Syntax Mapping

Use this quick-lookup table when translating Rails/ActiveRecord migration concepts to Hanami/Sequel syntax.

---

## Command & Syntax Comparison

| Operation | Rails (ActiveRecord) | Hanami 2.x (Sequel) |
|---|---|---|
| **Create Table** | `create_table :users do \|t\| ... end` | `create_table(:users) do ... end` |
| **Primary Key** | Generated automatically | `primary_key :id` (must declare explicitly) |
| **Add Column** | `add_column :users, :bio, :string` | `alter_table(:users) { add_column :bio, :text }` |
| **Drop Column** | `remove_column :users, :legacy_token` | `alter_table(:users) { drop_column :legacy_token }` |
| **Add Index** | `add_index :users, :email` | `alter_table(:users) { add_index :email }` |
| **Rename Column** | `rename_column :users, :old, :new` | `alter_table(:users) { rename_column :old, :new }` |
| **Timestamp Types** | `t.timestamps` | `column :created_at, :timestamptz` |
| **Reversibility** | Inferred in `change` | Inferred in `change` (except drops/renames) |

---

## Key Differences

1. **Explicit PKs:** Sequel requires you to explicitly write `primary_key :id` inside the `create_table` block.
2. **Table Alteration Wrapping:** Sequel wraps all column additions, index updates, and column modifications in an `alter_table` block, rather than using separate top-level functions like `add_column` or `remove_column`.
3. **No Automatic Timestamps:** Sequel does not have a `timestamps` shorthand. Define `:created_at` and `:updated_at` explicitly.
