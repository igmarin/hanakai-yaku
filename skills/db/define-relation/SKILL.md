---
name: define-relation
version: "1.0.0"
license: MIT
description: >
  Use when defining ROM Relations in Hanami 2.x. Covers schema inference,
  associations, query methods, and the Relation as your data query layer.
ecosystem_sources:
  - rom-rb/rom
  - rom-rb/rom-sql
  - hanami/hanami-db
tags:
  - db
  - rom
  - relations
  - queries
---

# define-relation

Use this skill when defining ROM Relations that map to database tables in Hanami 2.x.

**Core principle:** The Relation is the query layer. It defines how to read and filter data, not business logic.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Define a Relation | Class inherits from `Hanami::DB::Relation` with `schema :table_name, infer: true` |
| Infer schema from DB | `schema :table_name, infer: true` |
| Define explicit schema | `schema :table_name do { attribute :id, Types::Integer } end` |
| Add a custom query method | Define a method that returns a restricted/ordered relation |
| Define an association | `many_to_one :users, as: :user` or `one_to_many :posts, as: :posts` |
| Access the Relation in an Action | `include Deps["relations.users"]` |
| Call a query method | `relations.users.active` or `relations.users.by_email("a@b.com")` |

---

## Core Rules

1. **Create the Relation file** in the app or slice:

   ```ruby
   # app/relations/users.rb
   # frozen_string_literal: true

   module MyApp
     module Relations
       class Users < Hanami::DB::Relation
         schema :users, infer: true
       end
     end
   end
   ```

2. **Use `infer: true`** for new tables where the database schema is the source of truth. ROM will introspect the table at boot.

3. **Define explicit schema** when you need custom type coercion or virtual attributes:

   ```ruby
   schema :users do
     attribute :id, Types::Integer
     attribute :email, Types::String
     attribute :created_at, Types::Time
   end
   ```

4. **Add query methods** for reusable filters:

   ```ruby
   def active
     where(status: "active")
   end

   def by_email(email)
     where(email: email)
   end
   ```

5. **Define associations** to navigate between Relations:

   ```ruby
   many_to_one :users, as: :author    # belongs_to
   one_to_many :posts, as: :posts     # has_many
   ```

6. **Never put business logic in Relations**. Relations filter and fetch data. Business decisions belong in Repositories, interactors, or service objects.

7. **Keep Relations in sync with migrations**. When a migration adds, removes, or renames columns, update the Relation schema if not using `infer: true`.

8. **Test Relations** with in-memory ROM setup (`skills/testing/write-rom-spec`).

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put business logic like `calculate_total` in the Relation" | Relations are for data access only. Business logic belongs in Repositories or service objects. |
| "I don't need to define associations — I'll join manually every time" | Associations DRY up join definitions and make the intent explicit. Use them. |
| "I'll use `infer: true` but also declare explicit attributes for the same columns" | Either infer or declare explicitly. Declaring attributes that conflict with inferred types causes boot errors. |
| "I'll access Relations directly from Views" | Views should receive data from Actions, which get it from Repositories. Do not bypass the Repository layer. |
| "I'll name the Relation class `User` (singular)" | Relation names are plural and match the table name: `Users`, `Posts`, `Organizations`. |

---

## Red Flags

- Business logic methods in Relation classes
- Direct Relation access from Views or templates
- Associations missing `as:` alias option
- Schema declarations that duplicate inferred columns
- Relation names that are singular instead of plural

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-migration** | After any migration that changes the schema — verify Relation still matches |
| **create-repository** | When you need domain-level read/write operations that wrap Relations |
| **define-entity** | When defining the data structures returned by Relations |
| **write-rom-spec** (testing) | When writing tests for Relation query methods |
| **build-crud-resource** | Full end-to-end: Relation → Repository → Action → View → Test |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (ROM) |
|---|---|
| `class User < ApplicationRecord` | `class Users < Hanami::DB::Relation` |
| `scope :active, -> { where(status: "active") }` | `def active; where(status: "active"); end` |
| `has_many :posts` | `one_to_many :posts, as: :posts` |
| `belongs_to :user` | `many_to_one :users, as: :user` |
| `User.where(email: "a@b.com").first` | `relations.users.by_email("a@b.com").one` |
| `User.all` | `relations.users.to_a` |
| `User.count` | `relations.users.count` |
