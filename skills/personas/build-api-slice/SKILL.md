---
name: build-api-slice
license: MIT
type: persona
description: >
  Use when building a REST API, scaffolding API endpoints, or creating a JSON API resource
  in a Hanami 2.x application. Creates a new Hanami slice, generates controller actions,
  defines RESTful routes, writes request specs, and performs a code review. Handles JSON
  serialization, parameter validation, and error responses for API endpoints.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-router
  tags:
  - personas
  - api
  - slices
  - json
  version: 1.0.0
---

# build-api-slice

Use this workflow when creating an API-only Slice in Hanami 2.x.

**Core principle:** API slices are self-contained. They have their own routes, actions, and dependencies, but share the app's database and settings.

> **Note:** Each step in this workflow delegates to a separate installed skill (`create-slice`, `create-action`, `define-routes`, `write-request-spec`, `review-code`). These must be available in your skill set.

---

## Core Process

1. **[Create Slice]** — Load skill: `create-slice`
   - Generate slice: `hanami generate slice api`
   - Register in `config/app.rb`: `slice :api, at: "/api"`
   - Define slice routes in `slices/api/config/routes.rb`
   - **Validate:** `bundle exec hanami routes` — confirm `/api` prefix appears
   - Handoff condition: Slice is registered and routes respond

2. **[Define Actions]** — Load skill: `create-action`
   - Create JSON API Actions in `slices/api/actions/`
   - Use `build-json-api` for serialization
   - Use `validate-params` for input validation
   - Use `handle-errors` for error responses
   - **Validate:** `bundle exec hanami routes` lists expected action mappings
   - Handoff condition: All Actions return correct JSON

3. **[Configure Routes]** — Load skill: `define-routes`
   - Define RESTful routes in `slices/api/config/routes.rb`
   - Use `resources` for standard CRUD
   - **Validate:** `bundle exec hanami routes` shows full resource routes
   - Handoff condition: Routes map to correct Actions

4. **[Write Tests]** — Load skill: `write-request-spec`
   - Write request specs for all API endpoints
   - Assert on JSON shape and status codes
   - Test error cases (400, 401, 404, 422)
   - **Validate:** `bundle exec rspec spec/requests/` — all tests green
   - Handoff condition: All tests pass

5. **[Review]** — Load skill: `review-code`
   - Check Action responsibility
   - Check JSON serialization consistency
   - Check error response shapes
   - Handoff condition: No critical violations

---

## Minimal API Action Example

This is the canonical pattern for a JSON API action in a Hanami 2.x slice:

```ruby
# slices/api/actions/users/index.rb
module Api
  module Actions
    module Users
      class Index < Api::Action
        include Deps[repo: "repositories.user_repo"]

        def handle(request, response)
          response.format = :json
          users = repo.all
          response.body = JSON.generate(users.map(&:to_h))
        end
      end
    end
  end
end
```

Key points:
- Always set `response.format = :json`
- Serialize via a consistent serializer or `to_h` — never ad-hoc hashes
- Inject dependencies via `Deps[]` rather than hard-coding

### Parameter Validation

```ruby
def handle(request, response)
  halt 422, JSON.generate(errors: ["name is required"]) unless request.params[:name]
  # proceed with validated params
end
```

### Error Response Pattern

```ruby
def handle(request, response)
  response.format = :json
  user = repo.find(request.params[:id])
  halt 404, JSON.generate(error: "not found") unless user
  response.body = JSON.generate(user.to_h)
end
```

Use consistent `{ error: "message" }` or `{ errors: [...] }` shapes across all endpoints.
