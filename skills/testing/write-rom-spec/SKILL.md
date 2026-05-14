---
name: write-rom-spec
version: "1.0.0"
license: MIT
description: >
  Use when writing ROM relation and repository specs in Hanami 2.x. Covers
  in-memory ROM setup, transaction rollback, and isolated database testing.
ecosystem_sources:
  - rspec/rspec
  - rom-rb/rom
  - hanami/hanami
tags:
  - testing
  - rspec
  - rom
  - database
---

# write-rom-spec

Use this skill when writing specs for ROM Relations and Repositories in Hanami 2.x.

**Core principle:** ROM specs test data access logic in isolation. Use in-memory ROM or transactional rollback for speed and isolation.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Setup ROM in spec | `Hanami.app["db.rom"]` or configure a test ROM container |
| Transaction rollback | Wrap each spec in a database transaction that rolls back |
| In-memory setup | Use ROM's in-memory gateway for fast, isolated tests |
| Create test data | Use ROM factories or direct repository calls |
| Test Relation queries | `expect(relation.active.to_a.length).to eq(2)` |
| Test Repository methods | `expect(repo.all.length).to eq(3)` |
| Test entity creation | `expect(user.id).not_to be_nil` |
| Clean up between specs | Transactions automatically rollback; no manual cleanup needed |

---

## HARD-GATE

```text
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
```

---

## Core Rules

1. **Structure the spec file** under `spec/relations/` or `spec/repos/`:

   ```ruby
   # spec/relations/users_spec.rb
   # frozen_string_literal: true

   RSpec.describe MyApp::Relations::Users, type: :relation do
     # ...
   end
   ```

2. **Use transactional rollback** for database isolation:

   ```ruby
   around do |example|
     Hanami.app["db.rom"] do |rom|
       rom.gateways[:default].transaction do |t|
         example.run
         t.rollback
       end
     end
   end
   ```

3. **Create test data** using Repositories or direct ROM calls:

   ```ruby
   let!(:user1) { repo.create(email: "alice@example.com", first_name: "Alice", status: "active") }
   let!(:user2) { repo.create(email: "bob@example.com", first_name: "Bob", status: "inactive") }
   ```

4. **Test Relation query methods**:

   ```ruby
   it "returns active users" do
     active_users = relation.active.to_a

     expect(active_users.length).to eq(1)
     expect(active_users.first.email).to eq("alice@example.com")
   end
   ```

5. **Test Repository read/write operations**:

   ```ruby
   it "creates a user" do
     user = repo.create(email: "charlie@example.com", first_name: "Charlie")

     expect(user.id).not_to be_nil
     expect(user.email).to eq("charlie@example.com")
   end

   it "finds a user by email" do
     user = repo.find_by_email("alice@example.com")

     expect(user.first_name).to eq("Alice")
   end

   it "updates a user" do
     repo.update(user1.id, first_name: "Alicia")
     user = repo.by_id(user1.id).one

     expect(user.first_name).to eq("Alicia")
   end
   ```

6. **Test edge cases**:

   ```ruby
   it "returns empty array when no users match" do
     expect(relation.by_email("nonexistent@example.com").to_a).to be_empty
   end

   it "raises when user not found" do
     expect { repo.by_id(99999).one! }.to raise_error(ROM::TupleCountMismatchError)
   end
   ```

7. **Avoid testing ROM itself**. Do not test that `where` works — test your custom query methods.

8. **Keep ROM specs focused**. One spec per query method or Repository operation.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll skip transactional rollback" | Without rollback, test data pollutes the database and causes flaky tests. |
| "I'll test ROM's built-in methods" | Do not test `where`, `insert`, or `update`. Test your custom Relation methods and Repository operations. |
| "I'll create test data in `before(:all)`" | Use `let!` or `before(:each)` so each spec starts with known data. |
| "I'll manually clean up database state" | Transactional rollback handles cleanup. Do not write manual `after` blocks to delete records. |
| "I'll test with the production database" | ROM specs should use a test database or in-memory setup. Never run specs against production. |
| "I'll assert on internal ROM structures" | Assert on Entity attributes and collections, not on raw ROM relation internals. |

---

## Red Flags

- Missing transactional rollback
- Tests for ROM built-in methods
- Test data created in `before(:all)`
- Manual database cleanup in `after` blocks
- Production database used for testing
- Assertions on internal ROM structures
- Shared database state between specs

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-relation** | Test custom Relation query methods. |
| **create-repository** | Test Repository read/write operations. |
| **define-entity** | Assert on Entity attributes in ROM specs. |
| **plan-tests** | Decide when ROM specs are needed vs request specs. |
| **tdd-loop** | Follow the TDD workflow: write failing ROM spec → implement → verify pass. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (ROM Specs) |
|---|---|
| `spec/models/user_spec.rb` | `spec/relations/users_spec.rb` + `spec/repos/user_repo_spec.rb` |
| `User.create!(attrs)` | `repo.create(attrs)` |
| `User.where(active: true)` | `relation.active.to_a` |
| `User.find(id)` | `repo.by_id(id).one` |
| `User.find_by(email: "a@b.com")` | `repo.find_by_email("a@b.com")` |
| `transaction { ... }` | `rom.gateways[:default].transaction { ... }` |
| `DatabaseCleaner` gem | Transactional rollback (built into ROM/Hanami test setup) |
| `FactoryBot.create(:user)` | ROM factories or direct repository calls |
