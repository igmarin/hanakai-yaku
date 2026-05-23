---
name: create-changeset
license: MIT
description: >
  Creates a ROM changeset for write operations — creating, updating, or deleting
  data. Covers changeset types, input transformation, validation, and command
  composition. Use when implementing write operations for a repository.
  Trigger words: changeset, ROM changeset, create changeset, update changeset,
  ROM::Changeset, write operation, data mutation, command.
metadata:
  version: 1.0.0
  user-invocable: "true"
---
# Creating a ROM Changeset

Define write rules for a relation. Every data mutation goes through a changeset — never call `relation.insert` directly.

## Quick Reference

- **Location:** `slices/<slice>/changesets/`
- **Types:** `ROM::Changeset::Create`, `ROM::Changeset::Update`, `ROM::Changeset::Delete`.
- **Usage:** `repo.create(attrs)` internally calls the changeset.
- **Rule:** Changesets validate and transform input. Repositories call them.

## HARD-GATE

**Changeset Constraints:**
```text
DO NOT call relation.command(:create).call(...) directly. Use a changeset.
DO NOT put business logic in changesets. Changesets validate and map input only.
```

## Core Process

1. **Create the changeset** for the target relation:
   ```ruby
   module Api
     module Changesets
       class CreateUser < ROM::Changeset::Create
         map do |attrs|
           attrs.merge(
             created_at: Time.now,
             status: "active"
           )
         end

         # Validate before persistence
         def default_contract = UserContract.new
       end
     end
   end
   ```
2. **Run the spec to verify changeset transforms input correctly** before wiring into the repository:
   ```bash
   bundle exec rspec spec/changesets/create_user_spec.rb
   # Confirm map block and contract behave as expected
   ```
3. **Use in the repository** — the repository's `create` method delegates to the changeset:
   ```ruby
   class UserRepo < ROM::Repository[:users]
     def create(attrs)
       users.changeset(CreateUser, attrs).commit
     end
   end
   ```
4. **Update changeset** — map input, merge timestamps, validate:
   ```ruby
   class UpdateUser < ROM::Changeset::Update
     map do |attrs|
       attrs.merge(updated_at: Time.now)
     end

     # Restrict which fields can be updated
     def allowed_keys = [:name, :email, :role]
   end
   ```
5. **Compose changesets** — chain multiple changesets with `.data` for multi-step writes:
   ```ruby
   class UserRepo < ROM::Repository[:users]
     def create_with_profile(user_attrs, profile_attrs)
       user_cs = users.changeset(CreateUser, user_attrs)
       profile_cs = profiles.changeset(CreateProfile, profile_attrs)

       # Pass transformed data from the first changeset into the second
       user_cs.data.then { |data| profile_cs.data.merge(owner_id: data[:id]) }
       user_cs.commit
       profile_cs.commit
     end
   end
   ```

## Extended Resources (Progressive Disclosure)

Load these files only when needed:

- **[CHANGESET_PATTERNS.md](./CHANGESET_PATTERNS.md)** — Patterns: timestamps, allowed keys, custom types, contract integration, testing.

## Integration

| Skill | When to chain |
|-------|---------------|
| **define-relation** | Define the relation schema before creating its changeset |
| **create-repository** | Use the changeset in the repository's write methods |
| **create-operation** | Operations call repositories which use changesets |
