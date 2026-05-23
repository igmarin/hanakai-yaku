---
name: write-rom-spec
version: "1.0.0"
license: MIT
description: >
  Use when writing ROM relation and repository specs in Hanami 2.x — creates
  relation query specs, configures test repositories, wraps tests in transactional
  rollback, sets up in-memory ROM gateways, and verifies isolated database testing.
  Use when testing custom Relation query methods, Repository CRUD operations,
  or entity creation and lookup in a Hanami 2.x ROM-backed app.
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

---

## HARD-GATE

```text
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
```

---

## Workflow

Follow this sequence for every ROM spec:

1. **Write the failing spec** — define the example describing the desired behaviour.
2. **Run the spec; verify the correct failure** — confirm the failure message matches the missing behaviour, not a setup error.
3. **Implement the minimum code** — write just enough Relation or Repository code to satisfy the spec.
4. **Run the spec; verify it passes** — confirm green with no unintended side effects.
5. **Refactor if needed** — clean up, then re-run to confirm still green.

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

| Mistake | Fix |
|---|---|
| Skipping transactional rollback | Without rollback, test data pollutes the database and causes flaky tests. |
| Testing ROM's built-in methods | Test only your custom Relation methods and Repository operations, not `where`/`insert`/`update`. |
| Creating test data in `before(:all)` | Use `let!` or `before(:each)` so each spec starts with known, isolated data. |
| Manual database cleanup in `after` blocks | Transactional rollback handles cleanup automatically. |
| Asserting on internal ROM structures | Assert on Entity attributes and collections, not raw ROM relation internals. |
| Sharing state across specs | Each spec must be independent; shared state causes order-dependent failures. |
