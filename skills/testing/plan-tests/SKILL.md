---
name: plan-tests
version: "1.0.0"
license: MIT
description: >
  Use when deciding what type of test to write in Hanami 2.x. Covers the decision
  between request specs, action unit specs, view specs, relation specs, and repository specs.
ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
tags:
  - testing
  - rspec
  - planning
  - tdd
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

## HARD-GATE

```
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
```

---

## Core Rules

1. **Start with the question**: "What behavior am I testing?"

   - User-facing HTTP endpoint → **Request spec**
   - Action logic with complex branching → **Action unit spec**
   - View rendering with specific data → **View spec**
   - Database query methods → **Relation spec**
   - Repository persistence logic → **Repository spec**

2. **Prefer request specs** for critical user paths:

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

3. **Use action unit specs** for isolated Action testing:

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

4. **Write Relation specs** for custom query methods:

   ```ruby
   # spec/relations/users_spec.rb
   RSpec.describe MyApp::Relations::Users, type: :relation do
     it "returns active users" do
       active_users = relation.active.to_a

       expect(active_users.length).to eq(2)
     end
   end
   ```

5. **Write Repository specs** for domain persistence methods:

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

6. **Avoid view specs** unless the View has complex presentation logic. Most Views are thin and tested implicitly by request specs.

7. **One assertion per test** is a guideline, not a rule. Group related assertions that test a single behavior.

8. **Test edge cases**:
   - Empty collections
   - Invalid params (400/422 responses)
   - Missing resources (404 responses)
   - Authentication failures (401/403 responses)
   - Large payloads
   - Special characters in input

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll skip request specs because they're slow" | Request specs give the highest confidence. Run the full suite in CI, run a subset locally. |
| "I'll test everything with request specs" | Unit specs are faster and pinpoint failures. Use the right tool for the job. |
| "I'll write tests after implementing" | Tests gate implementation. Write the failing test first, then implement. |
| "I'll test implementation details instead of behavior" | Test what the code does, not how it does it. Avoid testing private methods. |
| "I'll share database state between tests" | Each test should be independent. Use transactions or in-memory setup. |
| "I'll skip edge cases because they're unlikely" | Edge cases are where bugs hide. Always test empty input, invalid input, and boundary conditions. |

---

## Red Flags

- No request specs for HTTP endpoints
- Only request specs with no unit tests for complex logic
- Tests written after implementation
- Tests asserting on implementation details (method calls, private state)
- Shared database state between tests
- Missing edge case coverage
- Tests that don't fail when the feature is removed

---

## Integration

| Related Skill | When to chain |
|---|---|
| **write-request-spec** | Write request specs for full-stack HTTP behavior. |
| **write-action-spec** | Write action unit specs for isolated Action logic. |
| **write-rom-spec** | Write ROM specs for Relation and Repository testing. |
| **tdd-loop** | Follow the full TDD workflow: plan → test → implement → review. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Testing) |
|---|---|
| `spec/requests/` (integration tests) | `spec/requests/` (request specs with Rack::Test) |
| `spec/controllers/` | `spec/actions/` (unit specs with stubbed deps) |
| `spec/models/` | `spec/relations/` + `spec/repos/` + `spec/entities/` |
| `spec/views/` | `spec/views/` (rarely needed) |
| `type: :request` | `type: :request` (same) |
| `type: :controller` | `type: :action` (isolated unit tests) |
| `let(:user) { create(:user) }` | Factory or in-memory setup with ROM |
| `before { sign_in user }` | Stub authentication in request specs |
