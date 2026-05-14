---
name: action-unit-specs
version: "1.0.0"
license: MIT
description: >
  Use when writing unit specs for Hanami 2.x Actions. Covers dependency injection
  stubs and isolated action testing.
ecosystem_sources:
  - hanami/hanami-rspec
tags:
  - testing
  - rspec
  - actions
  - unit-tests
---

# action-unit-specs

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

```
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
```

---

## Core Rules

1. **Structure the spec file** under `spec/actions/`:

   ```ruby
   # spec/actions/users/index_spec.rb
   # frozen_string_literal: true

   RSpec.describe MyApp::Actions::Users::Index, type: :action do
     # ...
   end
   ```

2. **Stub all injected dependencies**:

   ```ruby
   let(:stub_repo) { double("user_repo", all: [user1, user2]) }
   let(:stub_view) { double("view", call: "rendered") }

   it "returns all users" do
     action = described_class.new(user_repo: stub_repo, view: stub_view)
     response = action.call({})

     expect(response.status).to eq(200)
     expect(response[:users]).to eq([user1, user2])
   end
   ```

3. **Use verified doubles** to catch interface mismatches:

   ```ruby
   let(:stub_repo) { instance_double(MyApp::Repos::UserRepo, all: []) }
   ```

4. **Test the Action contract**, not implementation:

   ```ruby
   # Test what the Action promises: given inputs, it returns a response
   it "calls the repository" do
     action = described_class.new(user_repo: stub_repo, view: stub_view)
     action.call({})

     expect(stub_repo).to have_received(:all)
   end
   ```

5. **Test error paths** by stubbing failures:

   ```ruby
   it "handles repository errors" do
     allow(stub_repo).to receive(:all).and_raise(StandardError)

     action = described_class.new(user_repo: stub_repo)
     response = action.call({})

     expect(response.status).to eq(500)
   end
   ```

6. **Do not test the framework**. Do not assert that `render` was called or that `halt` works. Test your Action's logic.

7. **Keep unit specs fast**. No database, no HTTP stack. Only the Action and stubs.

8. **Use `subject` sparingly**. Prefer explicit `action.call` for clarity.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll use real dependencies instead of stubs" | Unit specs must be fast. Use stubs. Integration testing belongs in request specs. |
| "I'll test that `render` was called" | Do not test the framework. Test your Action's behavior (status, exposures). |
| "I'll forget to stub a dependency" | The Action will crash with a missing dependency error. Stub everything in `Deps[]`. |
| "I'll use `allow` when I should use `expect`" | Use `expect` to verify that a dependency was called. Use `allow` for setup only. |
| "I'll test private methods" | Unit specs test the public `#handle` method. Private methods are implementation details. |
| "I'll create complex stub setups that duplicate the production code" | Stubs should be simple. If setup is complex, the Action may have too many dependencies. |

---

## Red Flags

- Real database or HTTP stack in unit specs
- Testing framework methods (`render`, `halt`)
- Missing stubs for injected dependencies
- `allow` used where `expect` is needed
- Tests for private methods
- Complex stub setups that mirror production code
- Unit specs that test integration concerns

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | Unit specs test Actions. Understand Action structure first. |
| **deps-mixin** | Actions use `Deps[]` for injection. Understand how to stub injected dependencies. |
| **request-specs** | Use request specs for integration testing. Use unit specs for isolated logic. |
| **test-planning** | Decide when unit specs are appropriate vs request specs. |
| **tdd-workflow** | Follow the TDD workflow: write failing unit spec → implement → verify pass. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Action Unit Specs) |
|---|---|
| `spec/controllers/users_controller_spec.rb` | `spec/actions/users/index_spec.rb` |
| `allow(User).to receive(:all).and_return([user])` | `double("repo", all: [user])` |
| `get :index` | `action.call({})` |
| `expect(response).to render_template(:index)` | Do not test framework. Assert on `response.status` and `response[:exposure]`. |
| `expect(assigns(:users)).to eq([user])` | `expect(response[:users]).to eq([user])` |
| `expect(controller).to receive(:authenticate!)` | Stub the injected auth service, not the Action method. |
