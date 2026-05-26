---
name: write-request-spec
license: MIT
description: >
  Use when writing RSpec request specs for Hanami 2.x Actions — place specs under `spec/requests/`, send JSON request bodies with `.to_json` and `CONTENT_TYPE: application/json` header, assert responses via `last_response.successful?` and `json_body`, test both 404 and 422 error states, and wrap DB-touching specs in a transaction rollback context. Covers Rack test helpers,
  params, response assertions, and JSON shape validation.
metadata:
  ecosystem_sources:
  - rspec/rspec
  - hanami/hanami
  tags:
  - testing
  - rspec
  - requests
  - rack
  version: 1.0.0
---

# write-request-spec

Use this skill when writing RSpec request specs for Hanami 2.x Actions.

---

## Workflow

### Step 1 — Create the spec file
Place it under `spec/requests/`:

```ruby
# spec/requests/users_spec.rb
RSpec.describe "Users", type: :request do
  it "returns user JSON" do
    get "/users/1"

    expect(last_response).to be_successful
    expect(json_body).to include(:id, :email, :name)
    expect(json_body[:id]).to eq(1)
    expect(json_body[:email]).to be_a(String)
  end
end
```

### Step 2 — Verify the spec fails
```bash
bundle exec rspec spec/requests/users_spec.rb
```
Confirm it fails because the route or action is unimplemented. Use the **create-action** skill to implement the corresponding Hanami endpoint and route before proceeding.

### Step 3 — Verify specs pass
```bash
bundle exec rspec spec/requests/users_spec.rb
```

---

## Core Rules

1. **Send JSON request bodies** — serialize parameters with `.to_json` and set `CONTENT_TYPE` header explicitly:

   ```ruby
   it "creates a user" do
     post "/users",
          { user: { email: "alice@example.com", first_name: "Alice" } }.to_json,
          { "CONTENT_TYPE" => "application/json" }

     expect(last_response.status).to eq(201)
     expect(json_body[:id]).not_to be_nil
   end
   ```

2. **Test error responses** — cover both 404 (not found) and 422 (validation errors) states:

   ```ruby
   it "returns 404 for missing user" do
     get "/users/99999"

     expect(last_response.status).to eq(404)
     expect(json_body[:error]).to eq("User not found")
   end
   ```

3. **Isolate database state** — wrap specs that touch the database in a shared transaction context defined in `spec/support/database_cleaner.rb`:

   ```ruby
   # spec/support/database_cleaner.rb
   RSpec.shared_context "db transaction" do
     around do |example|
       Hanami.app["db.rom"] do |rom|
         rom.gateways[:default].transaction do |t|
           example.run
           t.rollback
         end
       end
     end
   end
   ```

   Include in specs with:
   ```ruby
   include_context "db transaction"
   ```

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Action definition precedes request spec implementation. |
| **validate-params** | Test validation contract parameters (422 responses). |
| **create-repository** | Database interactions are verified using real repositories. |
