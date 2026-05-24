# Sequel Column Types & Options

This document acts as a reference for generic column types and options available in Sequel database migrations.

---

## Generic Column Types

Sequel provides generic types that map to optimized native database types automatically:

* **`:integer`** — Standard integer.
* **`:bigint`** — 64-bit integer (use for large counts or foreign keys).
* **`:text`** — Unlimited length string/text.
* **`:varchar`** / **`String`** — Variable length character string.
* **`:double`** / **`:float`** — Floating-point numeric.
* **`:decimal`** / **`:numeric`** — Arbitrary precision decimals (essential for monetary values; e.g. `size: [10, 2]`).
* **`:boolean`** — Boolean (`true` or `false`).
* **`:date`** — Calendar date.
* **`:timestamptz`** — Timestamp with timezone information.
* **`:jsonb`** — Binary JSON format (PostgreSQL).
* **`:uuid`** — Universally Unique Identifier.

---

## Column Options

Customize columns using options passed to `column` or `add_column`:

* **`null: false`** — Disallows `NULL` values. (Sequel does **not** make columns non-nullable by default).
* **`default: value`** — Sets the database-level default.
* **`index: true`** — Automatically generates an index for this column.
* **`unique: true`** — Adds a unique constraint.
* **`fixed: true`** — Forces a fixed-width type (for `:varchar`/`String` types).
