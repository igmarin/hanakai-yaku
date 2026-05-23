---
name: create-repository
version: "1.0.0"
license: MIT
description: >
  Use when creating ROM Repositories in Hanami 2.x, including CRUD operations, defining custom
  queries, configuring associations, setting up aggregate roots, entity mapping, transaction
  handling, and implementing the Repository as your domain persistence layer. Relevant for
  database access, rom-rb relations, sequel adapter setup, and wiring repositories into
  actions via dependency injection.
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

   **Verify registration:** After creating the file, confirm the repo is wired into the container by booting the app and checking `MyApp::App["repos.user_repo"]`. If it raises a key error, check the file path and module nesting.

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

4. **Use transactions** for multi-step writes, and handle failures explicitly. Always guard against `one` returning `nil` before mutating state:

   ```ruby
   def transfer_funds(from_id, to_id, amount)
     transaction do
       from_account = accounts.by_id(from_id).one
       to_account   = accounts.by_id(to_id).one

       # Guard against missing records before mutating state
       return Failure(:account_not_found) if from_account.nil? || to_account.nil?
       return Failure(:insufficient_funds) if from_account.balance < amount

       accounts.update(from_id, balance: from_account.balance - amount)
       accounts.update(to_id,   balance: to_account.balance + amount)

       Success(true)
     end
   rescue => e
     Failure(e.message)
   end
   ```

   If you don't need monadic results, raise an explicit error inside the transaction block so ROM automatically rolls back.

5. **Return Entities/Structs**, not raw hashes. Configure the Repository:

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

6. **Never expose Relations directly**. Actions receive data from Repositories, not Relations.

7. **Keep Repositories focused**. One Repository per bounded context or entity. Do not create a single "God" Repository.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-relation** | Repository wraps a Relation. Define the Relation first, then the Repository. |
| **define-entity** | Repository returns Entity objects. Define the Entity schema to match. |
| **create-action** | Actions inject Repositories via `Deps` and pass data to Views. |
| **handle-result-pattern** | Complex Repository operations return `Success`/`Failure` for explicit error handling. |
| **write-rom-spec** (testing) | Test Repository methods with in-memory ROM. |
