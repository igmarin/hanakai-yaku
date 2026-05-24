---
name: write-action-spec
license: MIT
description: >
  Use when writing RSpec unit specs for Hanami 2.x Actions, testing an action spec,
  or writing a Hanami controller test. Generates RSpec unit specs, stubs injected
  dependencies via dry-system, asserts HTTP response status and headers, tests params
  validation, and verifies action exposures in isolation without hitting the database
  or HTTP stack.
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

### Step 2 — Run the test to verify it fails
Run RSpec and confirm the spec fails because the implementation is missing (not due to setup issues):
```bash
bundle exec rspec spec/actions/users/index_spec.rb
```

### Step 3 — Implement the Action
Write only the minimal code in the action to make the specs pass.

### Step 4 — Run specs to verify they pass
Verify all specs pass green.

---

## Common Mistakes

- **Testing the Framework:** Asserting that `render` was called or that `halt` works. Test your Action's logic and returned attributes/exposures, not Hanami's internal routing.
- **Unstubbed Dependencies:** The Action crashes with a missing container dependency. Ensure all items declared in `Deps[...]` are stubbed via `described_class.new(stub_dep: stub)`.
- **Database/HTTP access:** Unit specs must be isolated and fast. If you need to hit the database or route requests, use request specs instead.
- **Testing private methods:** Action specs should only verify the public `#call` signature.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Unit specs test Actions. Understand Action structure first. |
| **inject-dependencies** | Actions use `Deps[]` for injection. Understand how to stub injected dependencies. |
| **write-request-spec** | Use request specs for integration testing. Use unit specs for isolated logic. |
| **plan-tests** | Decide when unit specs are appropriate vs request specs. |
| **tdd-loop** | Follow the TDD workflow: write failing unit spec → implement → verify pass. |
