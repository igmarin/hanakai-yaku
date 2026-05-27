---
name: write-rom-spec
license: MIT
description: >
  Use when writing ROM specs in Hanami 2.x — configure transactional rollback via a shared `"db rollback"` RSpec context wrapping every spec with `transaction(rollback: :always, auto_savepoint: true)`, place relation specs under `spec/relations/` and repository specs under `spec/repos/`, test custom Relation query methods with fully defined test data via `relation.insert(...)`, verify Repository CRUD operations including `one!` raising `ROM::TupleCountMismatchError` for missing tuples, and run specs to confirm failure before implementing. Use when testing Relation query methods, Repository CRUD operations, or entity creation and lookup in a Hanami ROM-backed app.
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

### Step 0 — Configure transactional rollback (prerequisite)
Before writing any spec, ensure every test is wrapped in a transaction that rolls back. Place this in a shared context (e.g., `spec/support/db_rollback.rb`) and include it in your repo/relation specs:

```ruby
# spec/support/db_rollback.rb
RSpec.shared_context "db rollback" do
  around do |example|
    rom = Hanami.app["persistence.rom"]
    rom.gateways[:default].connection.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end
end
```

Then include it via metadata in `spec/spec_helper.rb`:

```ruby
RSpec.configure do |config|
  config.include_context "db rollback", type: :repo
  config.include_context "db rollback", type: :relation
end
```

### Step 1 — Create the spec file
Place it under `spec/relations/` or `spec/repos/`. Initialize `relation` or `repo` in a `let` block and define all test data inline:

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

  it "updates a user" do
    user = repo.create(email: "alice@example.com", first_name: "Alice")
    repo.update(user.id, first_name: "Alicia")
    expect(repo.by_id(user.id).one.first_name).to eq("Alicia")
  end

  it "raises when user is not found" do
    expect { repo.by_id(99999).one! }.to raise_error(ROM::TupleCountMismatchError)
  end
end
```

```ruby
# spec/relations/users_spec.rb
RSpec.describe MyApp::Relations::Users, type: :relation do
  let(:relation) { Hanami.app["persistence.rom"].relations[:users] }
  let!(:alice) { relation.insert(email: "alice@example.com", active: true) }
  let!(:bob)   { relation.insert(email: "bob@example.com",   active: false) }

  it "returns active users" do
    active_users = relation.active.to_a
    expect(active_users.length).to eq(1)
    expect(active_users.first[:email]).to eq("alice@example.com")
  end
end
```

### Step 2 — Run the test and implement
Confirm the spec fails, then write only the minimal ROM query or persistence logic to make it pass:
```bash
bundle exec rspec spec/repos/users_spec.rb   # expect failure
# implement the relation/repo method …
bundle exec rspec spec/repos/users_spec.rb   # expect green
```

---

## Core Rules

1. **Use transactional rollback** — every spec must roll back via the shared context configured in Step 0. Never rely on manual teardown.

2. **Test custom Relation query methods** — assert on collections returned by custom filters with fully defined test data. See the relation spec example in Step 1.

3. **Verify Repository CRUD operations** — verify custom read, write, update, and edge-case methods. See the repo spec examples in Step 1, including `one!` raising `ROM::TupleCountMismatchError` for missing tuples.

---

## Common Mistakes

- **Skipping Database Transactions:** Failing to wrap specs in a transactional rollback pollutes test databases and creates flaky/order-dependent tests.
- **Testing ROM Framework Internals:** Verifying ROM's native `where`/`insert`/`update` mechanics rather than your custom repository queries.
- **Persistent State Pollution:** Using `before(:all)` for database data setup, which operates outside individual test transaction boundaries.
- **Direct Entity Instantiation:** Manually instantiating ROM Structs instead of writing to the DB via repository/changeset calls to test lookup.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-repository** | Repository creation precedes spec implementation. |
| **define-relation** | Relation definitions are verified via custom specs. |
