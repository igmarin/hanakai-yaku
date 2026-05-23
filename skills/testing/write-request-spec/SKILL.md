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

## Workflow

Follow this sequence when writing a request spec:

1. **Create the spec file** under `spec/requests/` with the correct describe block.
2. **Write a failing test** for the target HTTP behavior (status, body shape, headers).
3. **Run the test and verify it fails for the right reason** — a setup failure (missing route, missing factory) must be fixed before proceeding; a logic failure is expected.
4. **Implement the Action** (or the missing layer) to make the test pass.
5. **Run the test again and verify it passes** — confirm no other specs broke.
6. **Add error-case specs** (404, 422, etc.) and repeat steps 3–5 for each.

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

2. **Assert on JSON shape** for API endpoints — use `include` for key presence and type checks:

   ```ruby
   it "returns user JSON" do
     get "/users/1"

     expect(last_response).to be_successful
     expect(json_body).to include(:id, :email, :name)
     expect(json_body[:id]).to eq(1)
     expect(json_body[:email]).to be_a(String)
   end
   ```

3. **Send JSON request bodies** — serialize with `.to_json` and set `CONTENT_TYPE`:

   ```ruby
   it "creates a user" do
     post "/users",
          { user: { email: "alice@example.com", first_name: "Alice" } }.to_json,
          { "CONTENT_TYPE" => "application/json" }

     expect(last_response.status).to eq(201)
     expect(json_body[:id]).not_to be_nil
   end
   ```

4. **Test error responses** — cover both 404 and 422 cases:

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

5. **Isolate database state** with transactions:

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

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Request specs test Actions. Understand Action structure first. |
| **validate-params** | Test invalid params in request specs (422 responses). |
| **create-repository** | Request specs exercise the full stack including Repositories. |
| **plan-tests** | Decide when request specs are appropriate vs unit specs. |
| **tdd-loop** | Follow the TDD workflow: write failing request spec → implement → verify pass. |
