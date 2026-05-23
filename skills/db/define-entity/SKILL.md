---
name: define-entity
version: "1.0.0"
license: MIT
description: >
  Use when defining ROM Struct attributes, configuring dry-types coercion for entity fields,
  implementing value-based equality semantics, or setting up a domain model class in Hanami 2.x.
  Handles creating entity classes, declaring typed attributes, enforcing immutability, configuring
  the repository struct namespace, and syncing entity definitions with schema changes. Use when
  working with ROM entity class definitions, persistence layer value objects, ROM relation mappings,
  or any Hanami 2.x domain model backed by rom-rb.
écosystem_sources:
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

5. **Keep Entities simple**. No business logic, no persistence methods, no validations.

6. **Register the Entity namespace** in the Repository:

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

7. **Update Entities when the schema changes**. When a migration adds or removes columns, update the corresponding Entity attributes. After updating, verify that the returned struct fields match the database columns with a quick REPL check:

   ```ruby
   # In a Hanami console (bundle exec hanami console)
   user = MyApp::App[:user_repo].users.first
   user.class            # => MyApp::Entities::User
   user.class.attributes # confirm all expected attribute keys are present
   user.respond_to?(:new_column) # => true after adding the attribute
   ```

   Or run the relevant unit/integration tests:

   ```bash
   bundle exec rspec spec/entities/user_spec.rb spec/repositories/user_repo_spec.rb
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| Calling `user.name = "new"` to mutate | Entities are frozen; use `user.copy(name: "new")` instead |
| Forgetting to update the Entity after a migration | The struct will raise `ROM::Struct::UnknownAttributeError` for unmapped columns; always sync attributes with schema changes |
| Adding business logic or validations inside the Entity | Entities are pure data containers; put validations in operations/actions and business logic in domain services |
| Using plain Ruby `Struct` or `Data` instead of `Hanami::DB::Entity` | You lose dry-types coercion, `.copy`, and value-based equality automatically provided by ROM Struct |
| Omitting `struct_namespace` in the Repository | ROM will return generic `ROM::Struct` instances instead of your typed Entity class |
| Declaring optional attributes without a default or `Types::Nominal` | A `nil` value will raise a type error; use `Types::String.optional.meta(omittable: true)` or provide a default |
