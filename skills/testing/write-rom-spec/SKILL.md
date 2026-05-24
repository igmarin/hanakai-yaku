---
name: write-rom-spec
license: MIT
description: >
  Use when writing ROM relation and repository specs in Hanami 2.x — creates relation
  query specs, configures test repositories, wraps tests in transactional rollback,
  sets up in-memory ROM gateways, and verifies isolated database testing. Use when
  testing custom Relation query methods, Repository CRUD operations, or entity creation
  and lookup in a Hanami 2.x ROM-backed app.
metadata:
  ecosystem_sources:
  - rspec/rspec
  - rom-rb/rom
  - hanami/hanami
  tags:
  - testing
  - rspec
  - rom
  - database
  version: 1.0.0
---

# write-rom-spec

Use this skill when writing specs for ROM Relations and Repositories in Hanami 2.x.

---

## Workflow

Follow these steps in order, treating each as a checkpoint:

### Step 1 — Create the spec file
Place it under `spec/relations/` or `spec/repos/`:

```ruby
# spec/repos/users_spec.rb
RSpec.describe MyApp::Repos::UserRepo, type: :repo do
  let(:repo) { described_class.new }

  it "creates and finds a user by email" do
    user = repo.create(email: "alice@example.com", name: "Alice")
    expect(user.id).not_to be_nil

    found = repo.find_by_email("alice@example.com")
    expect(found.name).to eq("Alice")
  end
end
```

### Step 2 — Run the test to verify it fails
Run RSpec and confirm the spec fails because the relation/repo method is unimplemented:
```bash
bundle exec rspec spec/repos/users_spec.rb
```

### Step 3 — Implement the Repository / Relation code
Write only the minimal ROM query or persistence logic to make the specs pass.

### Step 4 — Run specs to verify they pass
Verify all specs pass green:
```bash
bundle exec rspec spec/repos/users_spec.rb
```

---

## Core Rules

1. **Use transactional rollback** — ensure each test runs in isolation and rolls back its changes:

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

2. **Test custom Relation query methods** — assert on collections returned by custom filters:

   ```ruby
   it "returns active users" do
     # user1 and user2 created during setup
     active_users = relation.active.to_a

     expect(active_users.length).to eq(1)
     expect(active_users.first.email).to eq("alice@example.com")
   end
   ```

3. **Verify Repository CRUD operations** — verify custom read, write, and update methods:

   ```ruby
   it "updates a user" do
     repo.update(user1.id, first_name: "Alicia")
     user = repo.by_id(user1.id).one

     expect(user.first_name).to eq("Alicia")
   end
   ```

4. **Test expected edge cases** — verify empty lists, missing tuples, and mismatch errors:

   ```ruby
   it "raises when user is not found" do
     expect { repo.by_id(99999).one! }.to raise_error(ROM::TupleCountMismatchError)
   end
   ```

---

## Common Mistakes

- **Skipping Database Transactions:** Failing to wrap specs in a transactional rollback, which pollutes test databases and creates flaky/order-dependent tests.
- **Testing ROM Framework Internals:** Verifying ROM's native `where`/`insert`/`update` mechanics rather than your custom repository queries.
- **Persistent State Pollution:** Using `before(:all)` for database data setup, which operates outside individual test transaction boundaries.
- **Direct Entity Instantiation:** Manually instantiating ROM Structs instead of writing to the DB via repository/changeset calls to test lookup.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-repository** | Repository creation precedes spec implementation. |
| **define-relation** | Relation definitions are verified via custom specs. |

