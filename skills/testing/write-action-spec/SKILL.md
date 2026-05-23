---
name: write-action-spec
version: "1.0.0"
license: MIT
description: >
  Use when writing RSpec unit specs for Hanami 2.x Actions, testing an action spec,
  or writing a Hanami controller test. Generates RSpec unit specs, stubs injected
  dependencies via dry-system, asserts HTTP response status and headers, tests params
  validation, and verifies action exposures in isolation without hitting the database
  or HTTP stack.
ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
tags:
  - testing
  - rspec
  - actions
  - unit-tests
---

# write-action-spec

Use this skill when writing isolated unit specs for Hanami 2.x Actions.

**Core principle:** Unit specs test the Action in isolation by stubbing all dependencies. They are fast and pinpoint failures.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Stub a Repository | `double("repo", all: [user1, user2])` |
| Instantiate Action with stubs | `action = described_class.new(user_repo: stub_repo)` |
| Call the Action | `response = action.call({})` |
| Assert on response status | `expect(response.status).to eq(200)` |
| Assert on rendered exposures | `expect(response[:users]).to eq([user1, user2])` |
| Verify stub interaction | `expect(stub_repo).to have_received(:all)` |
| Stub a View | `double("view", call: "rendered")` |
| Test error handling | Stub Repository to raise, assert on `response.status` |

---

## HARD-GATE

```text
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
```

---

## Workflow

Follow these steps in order, treating each as a checkpoint before proceeding.

### Step 1 — Create the spec file

Place it under `spec/actions/` mirroring the action namespace:

```ruby
# spec/actions/users/index_spec.rb
# frozen_string_literal: true

RSpec.describe MyApp::Actions::Users::Index, type: :action do
  # ...
end
```

### Step 2 — Define stubs for all injected dependencies

Stub every dependency declared in `Deps[]`. Prefer **verified doubles** to catch interface mismatches:

```ruby
let(:stub_repo) { instance_double(MyApp::Repos::UserRepo, all: [user1, user2]) }
let(:stub_view) { double("view", call: "rendered") }
```

Use plain `double` only when the real class is not available.

### Step 3 — Write the failing test

Test the Action contract — given inputs, it returns a response with the expected status and exposures:

```ruby
it "returns all users" do
  action = described_class.new(user_repo: stub_repo, view: stub_view)
  response = action.call({})

  expect(response.status).to eq(200)
  expect(response[:users]).to eq([user1, user2])
end
```

Also cover **interaction verification** and **error paths**:

```ruby
it "calls the repository" do
  action = described_class.new(user_repo: stub_repo, view: stub_view)
  action.call({})

  expect(stub_repo).to have_received(:all)
end

it "handles repository errors" do
  allow(stub_repo).to receive(:all).and_raise(StandardError)

  action = described_class.new(user_repo: stub_repo)
  response = action.call({})

  expect(response.status).to eq(500)
end
```

### Step 4 — Run and verify the test fails for the right reason

```text
$ bundle exec rspec spec/actions/users/index_spec.rb
```

Confirm the failure is a missing-implementation failure, not a setup error.

### Step 5 — Implement the Action

Write only the code needed to make the failing spec pass.

### Step 6 — Run and verify the test passes

```text
$ bundle exec rspec spec/actions/users/index_spec.rb
```

All examples must be green before moving on.

---

## Additional Rules

- **Do not test the framework.** Do not assert that `render` was called or that `halt` works. Test your Action's logic.
- **Keep unit specs fast.** No database, no HTTP stack. Only the Action and stubs.
- **Use `subject` sparingly.** Prefer explicit `action.call` for clarity.
- **Use `expect` to verify interactions; use `allow` for setup only.**

---

## Common Mistakes

- **Missing stubs:** The Action will crash with a missing dependency error. Stub every dependency declared in `Deps[]`.
- **Testing private methods:** Unit specs test the public `#handle` method only. Private methods are implementation details.
- **Complex stub setups:** Stubs should be simple. If setup is complex, the Action likely has too many dependencies. Use request specs for integration concerns.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Unit specs test Actions. Understand Action structure first. |
| **inject-dependencies** | Actions use `Deps[]` for injection. Understand how to stub injected dependencies. |
| **write-request-spec** | Use request specs for integration testing. Use unit specs for isolated logic. |
| **plan-tests** | Decide when unit specs are appropriate vs request specs. |
| **tdd-loop** | Follow the TDD workflow: write failing unit spec → implement → verify pass. |
