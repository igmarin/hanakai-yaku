---
name: create-repository
version: "1.0.0"
license: MIT
description: >
  Use when creating ROM Repositories in Hanami 2.x. Covers read/write operations,
  entity mapping, transaction handling, and the Repository as your domain persistence layer.
ecosystem_sources:
  - rom-rb/rom
  - rom-rb/rom-sql
  - hanami/hanami-db
tags:
  - db
  - rom
  - repositories
  - persistence
---

# create-repository

Use this skill when creating ROM Repositories that encapsulate domain-level persistence logic in Hanami 2.x.

**Core principle:** The Repository is the boundary between your domain and the database. It wraps Relations and exposes intent-revealing methods.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a Repository | Class includes `ROM::Repository[:relation_name]` or inherits from a base repo |
| Inject a Relation | `include Deps["relations.users"]` |
| Read all records | `repo.all` |
| Find by ID | `repo.by_id(id)` |
| Create a record | `repo.create(attrs)` |
| Update a record | `repo.update(id, attrs)` |
| Delete a record | `repo.delete(id)` |
| Wrap operations in a transaction | `repo.transaction { ... }` |
| Return an Entity | Configure `struct_namespace` and use `auto_struct true` |

---

## Core Rules

1. **Create the Repository file** in the app or slice:

   ```ruby
   # app/repos/user_repo.rb
   # frozen_string_literal: true

   module MyApp
     module Repos
       class UserRepo < Hanami::DB::Repo[:users]
       end
     end
   end
   ```

2. **Inject the Repository into Actions** using the Deps mixin:

   ```ruby
   # app/actions/users/index.rb
   # frozen_string_literal: true

   module MyApp
     module Actions
       module Users
         class Index < MyApp::Action
           include Deps["repos.user_repo"]

           def handle(request, response)
             response.render(view, users: user_repo.all)
           end
         end
       end
     end
   end
   ```

3. **Add domain methods** that express intent, not just data access:

   ```ruby
   def active
     users.active.to_a
   end

   def find_by_email(email)
     users.by_email(email).one
   end

   def create_with_defaults(attrs)
     create(attrs.merge(created_at: Time.now))
   end
   ```

4. **Use transactions** for multi-step writes:

   ```ruby
   def transfer_funds(from_id, to_id, amount)
     transaction do
       from_account = accounts.by_id(from_id).one
       to_account = accounts.by_id(to_id).one

       accounts.update(from_id, balance: from_account.balance - amount)
       accounts.update(to_id, balance: to_account.balance + amount)
     end
   end
   ```

5. **Return Entities/Structs**, not raw hashes. Configure the Repository:

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

6. **Never expose Relations directly**. The Repository is the public API. Views and Actions receive data from Repositories, not Relations.

7. **Keep Repositories focused**. One Repository per bounded context or entity. Do not create a single "God" Repository.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll let the Action call the Relation directly" | Actions receive data from Repositories. Relations are an implementation detail of the Repository. |
| "I'll put SQL fragments in the Action" | All query logic belongs in Relations or Repositories. Actions are HTTP handlers only. |
| "I'll return raw hashes from the Repository" | Configure `auto_struct true` and return Entity objects. Raw hashes leak implementation details. |
| "I'll create one giant Repository for all tables" | One Repository per entity/bounded context. `UserRepo`, `PostRepo`, not `AppRepo`. |
| "I'll skip transactions for multi-step writes" | Use `transaction` blocks to ensure atomicity. Partial writes corrupt data. |
| "I'll call `save!` and rescue exceptions" | ROM uses immutable structs. Use `create` and `update` which return ROM structs/entities (or check return values). Explicitly wrap in `Success`/`Failure` if you need monadic results. |

---

## Red Flags

- Actions accessing Relations directly
- SQL or query logic in Actions or Views
- Repositories returning raw hashes instead of Entities
- "God" Repositories that handle many unrelated entities
- Multi-step writes without transaction blocks
- Business rules mixed into Repository methods

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-relation** | Repository wraps a Relation. Define the Relation first, then the Repository. |
| **define-entity** | Repository returns Entity objects. Define the Entity schema to match. |
| **create-action** | Actions inject Repositories via `Deps` and pass data to Views. |
| **handle-result-pattern** | Complex Repository operations return `Success`/`Failure` for explicit error handling. |
| **write-rom-spec** (testing) | Test Repository methods with in-memory ROM. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (ROM Repository) |
|---|---|
| `User.create!(attrs)` | `user_repo.create(attrs)` |
| `User.find(id)` | `user_repo.by_id(id).one` |
| `User.where(email: "a@b.com").first` | `user_repo.find_by_email("a@b.com")` |
| `User.update(id, attrs)` | `user_repo.update(id, attrs)` |
| `User.destroy(id)` | `user_repo.delete(id)` |
| `User.all` | `user_repo.all` |
| `User.where(active: true)` | `user_repo.active` (custom method) |
| `User.transaction { ... }` | `user_repo.transaction { ... }` |
| `User.includes(:posts)` | `user_repo.aggregate(:posts).all` |
