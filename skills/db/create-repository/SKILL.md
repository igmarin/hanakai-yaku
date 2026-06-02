---
name: create-repository
license: MIT
type: atomic
description: >
  Use when creating ROM Repositories in Hanami 2.x, including CRUD operations, defining
  custom queries, configuring associations, setting up aggregate roots, entity mapping,
  transaction handling, and implementing the Repository as your domain persistence
  layer. Relevant for database access, rom-rb relations, sequel adapter setup, and
  wiring repositories into actions via dependency injection.
metadata:
  ecosystem_sources:
  - rom-rb/rom
  - rom-rb/rom-sql
  - hanami/hanami-db
  tags:
  - db
  - rom
  - repositories
  - persistence
  version: 1.0.0
---

# create-repository

Use this skill when creating ROM Repositories that encapsulate domain-level persistence logic in Hanami 2.x.

---

## Quick Reference

| Action | Approach |
|---|---|
| Create Repository | Inherit from `Hanami::DB::Repo[:relation_name]` |
| Inject Repository | `include Deps["repos.user_repo"]` |
| Execute transaction | `repo.transaction { ... }` |

---

## Essentials

1. **Create the Repository file**:
   Place repositories under `app/repos/`:

   ```ruby
   # app/repos/user_repo.rb
   module MyApp
     module Repos
       class UserRepo < Hanami::DB::Repo[:users]
       end
     end
   end
   ```

2. **Verify container registration**:
   After creating the repository, confirm it is correctly registered in the Hanami container before wiring it into actions. Run in the console:

   ```ruby
   MyApp::App["repos.user_repo"]
   # => #<MyApp::Repos::UserRepo ...>
   ```

   If this raises a key error, check the file path and module namespace match the expected container key.

3. **Inject into Actions**:
   Inject repositories using the container dependency injection (`Deps`):

   ```ruby
   # app/actions/users/index.rb
   class Index < MyApp::Action
     include Deps["repos.user_repo"]

     def handle(request, response)
       response.render(view, users: user_repo.all)
     end
   end
   ```

4. **Add domain methods**:
   Write specific read and write methods to isolate your actions from raw relation access:

   ```ruby
   def active
     users.active.to_a
   end

   def find_by_email(email)
     users.by_email(email).one
   end
   ```

---

## Advanced Topics

5. **Use transactions for multi-step writes**:
   Wrap mutations in transaction blocks. If the block raises an error, the transaction is automatically rolled back and the error is re-raised.

   ```ruby
   transaction do
     accounts.update(from_id, balance: from_account.balance - amount)
     accounts.update(to_id,   balance: to_account.balance + amount)
   end
   ```

6. **Map to custom Entities**:
   Configure the `struct_namespace` to automatically map SQL relation rows to custom Entity domain models.

   ```ruby
   class UserRepo < Hanami::DB::Repo[:users]
     struct_namespace MyApp::Entities
     auto_struct true
   end
   ```

7. **Do not expose Relations directly**:
   Actions must fetch and modify data via Repositories. Bypassing repositories to query relations directly in actions/views is an anti-pattern.

---

> For detailed repository pattern examples, see [REPOSITORIES.md](REPOSITORIES.md).

## Integration

| Related Skill | When to chain |
|---|---|
| **define-relation** | [define-relation](../define-relation/SKILL.md) — Relations map table schemas before repositories query them. |
| **define-entity** | [define-entity](../define-entity/SKILL.md) — Represents the struct objects returned by the repository. |
| **create-action** | Actions inject repositories to read/write data. |
| **write-rom-spec** | Test repository methods inside in-memory ROM database specs. |
