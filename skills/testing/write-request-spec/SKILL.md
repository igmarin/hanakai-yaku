---
name: write-request-spec
version: "1.0.0"
license: MIT
description: >
  Use when writing RSpec request specs for Hanami 2.x Actions. Covers Rack test
  helpers, params, response assertions, and JSON shape validation.
ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
tags:
  - testing
  - rspec
  - requests
  - rack
---

# write-request-spec

Use this skill when writing RSpec request specs for Hanami 2.x Actions.

**Core principle:** Request specs test the full HTTP cycle. They give the highest confidence that endpoints work correctly.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Make a GET request | `get "/users"` |
| Make a POST request | `post "/users", { user: { name: "Alice" } }` |
| Assert status | `expect(last_response).to be_successful` |
| Assert JSON body | `expect(json_body[:users].length).to eq(3)` |
| Assert headers | `expect(last_response.headers["Content-Type"]).to include("application/json")` |
| Set headers | `header "Authorization", "Bearer token"` |
| Follow redirects | `follow_redirect!` |
| Access params in test | Pass them as the second argument to the request method |
| JSON request body | `post "/users", { user: { name: "Alice" } }.to_json, { "CONTENT_TYPE" => "application/json" }` |

---

## HARD-GATE

```text
DO NOT write implementation code before a failing test exists.
ALWAYS run the test and verify it fails for the right reason before implementing.
IF the test fails for a setup reason, diagnose and fix the setup before proceeding.
```

---

## Core Rules

1. **Structure the spec file** under `spec/requests/`:

   ```ruby
   # spec/requests/users_spec.rb
   # frozen_string_literal: true

   RSpec.describe "Users", type: :request do
     # ...
   end
   ```

2. **Use Rack::Test helpers** to make requests:

   ```ruby
   it "returns a list of users" do
     get "/users"

     expect(last_response).to be_successful
     expect(json_body[:users].length).to eq(3)
   end
   ```

3. **Assert on status codes**:

   ```ruby
   expect(last_response).to be_successful           # 200-299
   expect(last_response.status).to eq(200)
   expect(last_response.status).to eq(201)
   expect(last_response.status).to eq(404)
   expect(last_response.status).to eq(422)
   ```

4. **Assert on JSON shape** for API endpoints:

   ```ruby
   it "returns user JSON" do
     get "/users/1"

     expect(last_response).to be_successful
     expect(json_body).to include(:id, :email, :name)
     expect(json_body[:id]).to eq(1)
     expect(json_body[:email]).to be_a(String)
   end
   ```

5. **Send JSON request bodies**:

   ```ruby
   it "creates a user" do
     post "/users",
          { user: { email: "alice@example.com", first_name: "Alice" } }.to_json,
          { "CONTENT_TYPE" => "application/json" }

     expect(last_response.status).to eq(201)
     expect(json_body[:id]).not_to be_nil
   end
   ```

6. **Set request headers**:

   ```ruby
   header "Authorization", "Bearer #{token}"
   header "Accept", "application/json"
   get "/users"
   ```

7. **Test error responses**:

   ```ruby
   it "returns 404 for missing user" do
     get "/users/99999"

     expect(last_response.status).to eq(404)
     expect(json_body[:error]).to eq("User not found")
   end

   it "returns 422 for invalid params" do
     post "/users", { user: { email: "" } }.to_json, { "CONTENT_TYPE" => "application/json" }

     expect(last_response.status).to eq(422)
     expect(json_body[:errors]).to include(:email)
   end
   ```

8. **Isolate database state** with transactions:

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

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll test only the happy path" | Test error cases (400, 404, 422) as thoroughly as success cases. |
| "I'll share database state across request specs" | Each spec should be independent. Use transactions to rollback after each test. |
| "I'll assert on exact JSON strings" | Assert on shape and types, not exact serialization. `"2024-01-01T00:00:00Z"` vs `iso8601`. |
| "I'll skip setup because it's repetitive" | Extract setup into `let` or `before`, but do not skip it. Each test needs valid data. |
| "I'll make requests without setting `CONTENT_TYPE` for JSON" | Always set `"CONTENT_TYPE" => "application/json"` when sending JSON bodies. |
| "I'll test private methods or internal state" | Request specs test HTTP behavior only. Do not assert on internal implementation. |

---

## Red Flags

- Only testing happy paths
- Shared database state between specs
- Exact JSON string assertions
- Missing `CONTENT_TYPE` header for JSON requests
- Testing internal state or private methods
- No error case coverage
- Tests that pass when the endpoint is broken

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Request specs test Actions. Understand Action structure first. |
| **validate-params** | Test invalid params in request specs (422 responses). |
| **create-repository** | Request specs exercise the full stack including Repositories. |
| **plan-tests** | Decide when request specs are appropriate vs unit specs. |
| **tdd-loop** | Follow the TDD workflow: write failing request spec → implement → verify pass. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Request Specs) |
|---|---|
| `spec/requests/users_spec.rb` | `spec/requests/users_spec.rb` (same path) |
| `get users_path` | `get "/users"` |
| `expect(response).to have_http_status(:ok)` | `expect(last_response).to be_successful` |
| `JSON.parse(response.body)` | `json_body` helper (or `JSON.parse(last_response.body)`) |
| `post users_path, params: { user: {...} }` | `post "/users", { user: {...} }.to_json, { "CONTENT_TYPE" => "application/json" }` |
| `sign_in user` | Set auth header: `header "Authorization", "Bearer #{token}"` |
| `FactoryBot.create(:user)` | Use ROM factories or in-memory setup |
