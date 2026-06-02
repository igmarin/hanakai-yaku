---
name: write-action-spec
license: MIT
type: atomic
description: >
  Use when writing isolated RSpec unit specs for Hanami 2.x Actions — place spec under `spec/actions/` mirroring the action namespace with `type: :action` metadata, stub all `Deps[...]` dependencies via `instance_double` passed to `described_class.new(dep: stub)`, test both success (200/201) and error (422/500) paths, assert on `response.status`, `response.headers`, and action exposures without hitting the database or HTTP stack, and confirm the spec fails before implementing the Action. Generates specs with test doubles, status assertions, and params validation tests.
metadata:
  ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
  tags:
  - testing
  - rspec
  - actions
  - unit-tests
  version: 1.0.0
---

# write-action-spec

Use this skill when writing isolated unit specs for Hanami 2.x Actions.

**Core principle:** Unit specs test the Action in isolation by stubbing all dependencies. They are fast and pinpoint failures.

---

## Workflow

Follow these steps in order, treating each as a checkpoint:

### Step 1 — Create the spec file
Place it under `spec/actions/` mirroring the action namespace:

```ruby
# spec/actions/users/index_spec.rb
RSpec.describe MyApp::Actions::Users::Index, type: :action do
  let(:stub_repo) { instance_double(MyApp::Repos::UserRepo, all: [user]) }
  let(:stub_view) { double("view", call: "rendered") }
  let(:user) { double("user") }

  it "returns all users" do
    action = described_class.new(user_repo: stub_repo, view: stub_view)
    response = action.call({})

    expect(response.status).to eq(200)
    expect(response[:users]).to eq([user])
  end

  it "handles repository errors" do
    allow(stub_repo).to receive(:all).and_raise(StandardError)

    action = described_class.new(user_repo: stub_repo)
    response = action.call({})

    expect(response.status).to eq(500)
  end
end
```

### Step 2 — Params validation pattern
Test that invalid params produce the expected status and that valid params expose the right values:

```ruby
# spec/actions/users/create_spec.rb
RSpec.describe MyApp::Actions::Users::Create, type: :action do
  let(:stub_repo) { instance_double(MyApp::Repos::UserRepo, create: user) }
  let(:user) { double("user") }

  it "returns 422 when required params are missing" do
    action = described_class.new(user_repo: stub_repo)
    response = action.call({})

    expect(response.status).to eq(422)
  end

  it "returns 201 and sets Location header on success" do
    action = described_class.new(user_repo: stub_repo)
    response = action.call({ name: "Alice", email: "alice@example.com" })

    expect(response.status).to eq(201)
    expect(response.headers["Location"]).to eq("/users")
  end
end
```

### Step 3 — Run the test to verify it fails
Run RSpec and confirm the spec fails because the implementation is missing (not due to setup issues):
```bash
bundle exec rspec spec/actions/users/index_spec.rb
```

### Step 4 — Implement the Action
Write only the minimal code in the action to make the specs pass.

### Step 5 — Run specs to verify they pass
Verify all specs pass green.

---

## Common Mistakes

- Only test your Action's exposures and returned attributes — not `render` or `halt`.
- Stub all `Deps[...]` items via `described_class.new(dep: stub)`.
- Use request specs for integration; unit specs must not hit the database or HTTP stack.
- Only verify the public `#call` signature.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Unit specs test Actions. Understand Action structure first. |
| **inject-dependencies** | Actions use `Deps[]` for injection. Understand how to stub injected dependencies. |
| **write-request-spec** | Use request specs for integration testing. Use unit specs for isolated logic. |
| **plan-tests** | Decide when unit specs are appropriate vs request specs. |
| **tdd-loop** | Follow the TDD workflow: write failing unit spec → implement → verify pass. |
