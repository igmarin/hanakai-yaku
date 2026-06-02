---
name: define-entity
license: MIT
type: atomic
description: >
  Use when defining ROM Struct attributes, configuring dry-types coercion for entity
  fields, implementing value-based equality semantics, or setting up a domain model
  class in Hanami 2.x. Handles creating entity classes, declaring typed attributes,
  enforcing immutability, configuring the repository struct namespace, and syncing
  entity definitions with schema changes. Use when working with ROM entity class definitions,
  persistence layer value objects, ROM relation mappings, or any Hanami 2.x domain
  model backed by rom-rb.
metadata:
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
  version: 1.0.0
---

# define-entity

Use this skill when defining ROM Structs and Entities in Hanami 2.x.

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

2. **Apply dry-types coercion and constraints**:
   Specify attribute types using standard dry-types constraints. For a comprehensive list of type modifiers, constraints, and defaults, see [TYPES.md](TYPES.md).

   ```ruby
   attribute :email, Types::String.constrained(format: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.\w+\z/)
   attribute :role, Types::String.default("member")
   ```

3. **Entities are immutable**:
   Entities cannot be mutated in place. Use `#copy` to return a new instance with updated attributes:

   ```ruby
   updated_user = user.copy(first_name: "Alicia")
   ```

4. **Equality is value-based**:
   Two entity instances with identical attributes are considered equivalent:

   ```ruby
   user1 == user2 # => true if attributes match
   ```

5. **Register the Entity namespace in Repositories**:
   Wired repositories require mapping directives to output typed Entity classes rather than generic ROM structs:

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

6. **Sync Entities with migrations**:
   Keep entity class attributes manually updated with database schema modifications. Verify using the Hanami console or spec suite:

   ```bash
   bundle exec hanami console
   # check MyApp::App[:user_repo].users.first.class.attributes
   ```

---

## Common Mistakes

| Mistake | Resolution |
|---|---|
| Attempting in-place mutations (`user.name = "new"`) | Entities are frozen. Always use `user.copy(name: "new")`. |
| Out of sync migrations | Stale attributes cause `UnknownAttributeError`. Sync entity attributes with database migrations. |
| Putting business logic inside Entities | Entities are pure data structs. Place logic in domain services or actions. |
| Omitting `struct_namespace` configuration | Omitting this returns generic `ROM::Struct` objects instead of your custom Entity class. |
| Missing `.optional` on nullable fields | Null database columns require `Types::String.optional` to prevent boot/coercion type errors. |
