---
name: define-entity
version: "1.0.0"
license: MIT
description: >
  Use when defining ROM Structs and Entities in Hanami 2.x. Covers immutability,
  dry-types coercion, equality semantics, and the Entity as your domain value object.
ecosystem_sources:
  - rom-rb/rom
  - rom-rb/rom-sql
  - hanami/hanami-db
tags:
  - db
  - rom
  - entities
  - structs
  - value-objects
---

# define-entity

Use this skill when defining ROM Structs and Entities in Hanami 2.x.

**Core principle:** Entities are immutable value objects. They represent domain data with typed attributes and value-based equality.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Define an Entity | `class User < Hanami::DB::Entity` with typed attributes |
| Enable dry-types coercion | Include `Types` module and use `attribute :name, Types::String` |
| Make an Entity immutable | ROM Structs are immutable by default; use `.new` to create, `.copy` to change |
| Check equality | Entities compare by value: `user1 == user2` compares all attributes |
| Return an Entity from a Repository | Configure `struct_namespace` and `auto_struct true` in the Repository |
| Define a custom Struct | Use `ROM::Struct` for simple data containers without domain behavior |

---

## Core Rules

1. **Create the Entity file** in the app or slice:

   ```ruby
   # app/entities/user.rb
   # frozen_string_literal: true

   module MyApp
     module Entities
       class User < Hanami::DB::Entity
         attribute :id, Types::Integer
         attribute :email, Types::String
         attribute :first_name, Types::String
         attribute :last_name, Types::String
         attribute :role, Types::String.default("member")
         attribute :created_at, Types::Time
       end
     end
   end
   ```

2. **Use dry-types for coercion and constraints**:

   ```ruby
   attribute :email, Types::String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.\w+\z/)
   attribute :age, Types::Integer.constrained(gt: 0)
   attribute :role, Types::String.default("member").enum("admin", "member", "guest")
   ```

3. **Entities are immutable**. To change an Entity, create a new one:

   ```ruby
   updated_user = user.copy(name: "New Name")
   ```

4. **Equality is value-based**. Two Entities with the same attributes are equal:

   ```ruby
   user1 = User.new(id: 1, email: "a@b.com")
   user2 = User.new(id: 1, email: "a@b.com")
   user1 == user2 # => true
   ```

5. **Keep Entities simple**. No business logic, no persistence methods, no validations. Entities are data with types.

6. **Register the Entity namespace** in the Repository:

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

7. **Update Entities when the schema changes**. When a migration adds or removes columns, update the corresponding Entity attributes.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll add `save` and `destroy` methods to the Entity" | Entities are pure data. Persistence belongs in Repositories. |
| "I'll make Entities mutable with attr_accessor" | ROM Structs are immutable by design. Mutability breaks value-based equality. |
| "I'll put validation logic in the Entity" | Validations belong in Actions (Params) or dry-validation Contracts, not Entities. |
| "I'll skip type declarations and use plain Ruby hashes" | Type coercion catches bugs at the boundary. Always declare attributes with types. |
| "I'll compare Entities with `equal?` instead of `==`" | `equal?` checks object identity. `==` checks value equality — use `==`. |
| "I'll define default values inline instead of using dry-types defaults" | Use `Types::String.default("value")` for explicit, testable defaults. |

---

## Red Flags

- Entities with persistence methods (`save`, `destroy`)
- Mutable Entities with setters or `attr_accessor`
- Validation logic inside Entity classes
- Untyped attributes (plain hashes without dry-types)
- Entities compared with `equal?` for business logic
- Business rules or side effects in Entity constructors

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-repository** | Repository returns Entity objects. Define the Entity, then configure the Repository. |
| **define-relation** | Relation schema drives Entity attributes. Keep them in sync. |
| **create-action** | Actions receive Entities from Repositories and pass them to Views. |
| **create-view** | Views receive Entities as exposures. Entities are the data contract between layers. |
| **write-migration** | Schema changes require Entity updates. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (ROM Entity) |
|---|---|
| `class User < ApplicationRecord` | `class User < Hanami::DB::Entity` |
| `user.name = "New"` (mutable) | `updated = user.copy(name: "New")` (immutable) |
| `user.save!` | `user_repo.update(user.id, name: "New")` |
| `user.valid?` | Validations are in Actions/Contracts, not Entities |
| `user.destroy` | `user_repo.delete(user.id)` |
| `user == other_user` (identity by default) | `user == other_user` (value equality by default) |
| `User.new(name: nil)` (nil allowed) | `User.new(name: nil)` (type coercion may raise or default) |
| `after_save :do_something` | No callbacks. Use Repository methods or interactors. |
