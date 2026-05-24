---
name: write-request-spec
license: MIT
description: >
  Use when writing RSpec request specs for Hanami 2.x Actions. Covers Rack test helpers,
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

Follow these steps in order, treating each as a checkpoint:

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

### Step 2 — Run the test to verify it fails
Run RSpec and confirm the spec fails because the route or action is unimplemented:
```bash
bundle exec rspec spec/requests/users_spec.rb
```

### Step 3 — Implement the Endpoint
Write only the minimal code in the action and routing to make the spec pass.

### Step 4 — Run specs to verify they pass
Verify all specs pass green:
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

3. **Isolate database state** — wrap specs that touch the database in transactions to ensure clean tests:

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
| **create-action** | Action definition precedes request spec implementation. |
| **validate-params** | Test validation contract parameters (422 responses). |
| **create-repository** | Database interactions are verified using real repositories. |

