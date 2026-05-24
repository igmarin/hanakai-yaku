---
name: plan-tests
license: MIT
description: >
  Use when deciding what type of test to write in Hanami 2.x. Recommends the appropriate
  test type (request specs, action unit specs, view specs, relation specs, or repository
  specs), explains when to prefer request specs over action unit specs, and provides
  copy-paste RSpec examples with file paths and decision criteria for each test type.
metadata:
  ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
  tags:
  - testing
  - rspec
  - planning
  - tdd
  version: 1.0.0
---

# plan-tests

Use this skill when deciding which type of test to write for a Hanami 2.x feature.

**Core principle:** Test at the highest level that gives you confidence. Prefer request specs for user-facing behavior, unit specs for isolated logic.

---

## Quick Reference

| Test Type | Use When | Speed | Confidence |
|---|---|---|---|
| **Request spec** | Testing full HTTP request/response cycle | Slow | Highest |
| **Action unit spec** | Testing Action logic in isolation | Fast | Medium |
| **View spec** | Testing View rendering with fixtures | Fast | Medium |
| **Relation spec** | Testing ROM Relation query methods | Medium | Medium |
| **Repository spec** | Testing Repository read/write operations | Medium | Medium |

---

## Test-Planning Workflow

1. **Identify the behavior** — Ask: "What behavior am I testing?"
   - User-facing HTTP endpoint → **Request spec**
   - Action logic with complex branching → **Action unit spec**
   - View rendering with specific data → **View spec**
   - Database query methods → **Relation spec**
   - Repository persistence logic → **Repository spec**

2. **Choose the test type** from the Quick Reference table above and create the file at the appropriate path.

3. **Write the failing test** using the examples below. Do not write implementation code yet.

4. **Run the test and verify it fails for the right reason** — a compile error or missing constant means setup is incomplete; a meaningful assertion failure means you are ready to implement.

5. **Proceed to implementation** only after the test fails with the expected assertion.

---

## Core Rules

1. **Prefer request specs** for critical user paths:

   ```ruby
   # spec/requests/users_spec.rb
   RSpec.describe "Users", type: :request do
     it "returns a list of users" do
       get "/users"

       expect(last_response).to be_successful
       expect(json_body[:users].length).to eq(3)
     end
   end
   ```

2. **Use action unit specs** for isolated Action testing:

   ```ruby
   # spec/actions/users/index_spec.rb
   RSpec.describe MyApp::Actions::Users::Index, type: :action do
     it "renders all users" do
       action = described_class.new(user_repo: stub_repo)
       response = action.call({})

       expect(response.status).to eq(200)
     end
   end
   ```

3. **Write Relation specs** for custom query methods:

   ```ruby
   # spec/relations/users_spec.rb
   RSpec.describe MyApp::Relations::Users, type: :relation do
     it "returns active users" do
       active_users = relation.active.to_a

       expect(active_users.length).to eq(2)
     end
   end
   ```

4. **Write Repository specs** for domain persistence methods:

   ```ruby
   # spec/repos/user_repo_spec.rb
   RSpec.describe MyApp::Repos::UserRepo, type: :repository do
     it "creates a user" do
       user = repo.create(name: "Alice", email: "alice@example.com")

       expect(user.id).not_to be_nil
       expect(user.name).to eq("Alice")
     end
   end
   ```

5. **Avoid view specs** unless the View has complex presentation logic. Most Views are thin and tested implicitly by request specs.

---

## Pitfalls & Red Flags

| Issue | Guidance |
|---|---|
| Skipping request specs because they're slow | Request specs give the highest confidence. Run the full suite in CI, run a subset locally. |
| Testing everything with request specs | Unit specs are faster and pinpoint failures. Use the right tool for the job. |
| No request specs for HTTP endpoints | Every user-facing endpoint needs at least one request spec. |
| Only request specs with no unit tests for complex logic | Complex Action branching deserves isolated unit tests for faster feedback. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-request-spec** | Write request specs for full-stack HTTP behavior. |
| **write-action-spec** | Write action unit specs for isolated Action logic. |
| **write-rom-spec** | Write ROM specs for Relation and Repository testing. |
| **tdd-loop** | Follow the full TDD workflow: plan → test → implement → review. |
