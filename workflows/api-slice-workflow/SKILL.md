---
name: api-slice-workflow
version: "1.0.0"
license: MIT
description: >
  Use when creating an API-only Slice in Hanami 2.x. Chains slice-anatomy,
  action-anatomy, routes-dsl, request-specs, and code-review.
ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-router
tags:
  - workflows
  - api
  - slices
  - json
---

# api-slice-workflow

Use this workflow when creating an API-only Slice in Hanami 2.x.

**Core principle:** API slices are self-contained. They have their own routes, actions, and dependencies, but share the app's database and settings.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Create Slice | `slice-anatomy` | Slice directory structure exists, registered in app |
| 2. Define Actions | `action-anatomy` | Actions for all API endpoints exist |
| 3. Configure routes | `routes-dsl` | Routes mounted at `/api` |
| 4. Write tests | `request-specs` | All endpoints return correct JSON |
| 5. Review | `code-review` | No violations found |

---

## Core Process

1. **[Create Slice]** — Load skill: `slice-anatomy`
   - Generate slice: `hanami generate slice api`
   - Register in `config/app.rb`: `slice :api, at: "/api"`
   - Define slice routes in `slices/api/config/routes.rb`
   - Handoff condition: Slice is registered and routes respond

2. **[Define Actions]** — Load skill: `action-anatomy`
   - Create JSON API Actions in `slices/api/actions/`
   - Use `action-json-api` for serialization
   - Use `action-params-validation` for input validation
   - Use `action-halt-errors` for error responses
   - Handoff condition: All Actions return correct JSON

3. **[Configure Routes]** — Load skill: `routes-dsl`
   - Define RESTful routes in `slices/api/config/routes.rb`
   - Use `resources` for standard CRUD
   - Handoff condition: Routes map to correct Actions

4. **[Write Tests]** — Load skill: `request-specs`
   - Write request specs for all API endpoints
   - Assert on JSON shape and status codes
   - Test error cases (400, 401, 404, 422)
   - Handoff condition: All tests pass

5. **[Review]** — Load skill: `code-review`
   - Check Action responsibility
   - Check JSON serialization consistency
   - Check error response shapes
   - Handoff condition: No critical violations

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put API routes in the main app routes" | API routes belong in the slice's `config/routes.rb`. Keep the main app routes clean. |
| "I'll share database tables without clear ownership" | Each slice should own its tables. If the API slice needs user data, import the user Repository from the main slice. |
| "I'll skip authentication because it's an internal API" | Always authenticate API endpoints. Use `action-halt-errors` for 401/403 responses. |
| "I'll return different JSON shapes for the same resource" | Consistent serialization is critical for APIs. Use the same serializer for a resource across all endpoints. |
| "I'll forget to set `response.format = :json`" | Always set the response format for API Actions. |

---

## Red Flags

- API routes in main app instead of slice
- Shared database tables without clear ownership
- Missing API authentication
- Inconsistent JSON shapes
- Missing `response.format = :json`
- HTML responses from API endpoints
- Missing error case tests

---

## Integration

| Related Skill | When to chain |
|---|---|
| **slice-anatomy** | Step 1: Create the API slice. |
| **action-anatomy** | Step 2: Define API Actions. |
| **action-json-api** | Step 2: JSON serialization for API responses. |
| **routes-dsl** | Step 3: Configure API routes. |
| **request-specs** | Step 4: Test API endpoints. |
| **code-review** | Step 5: Review the API implementation. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (API Slice) |
|---|---|
| `namespace :api do resources :users end` | `slice :api, at: "/api"` + `resources :users` in slice routes |
| `Api::UsersController` | `MyApp::Slices::Api::Actions::Users::Index` |
| `respond_to :json` | `response.format = :json` |
| `rails api` | No separate API mode. Create an API slice. |
| `jbuilder` views | Custom serializer classes or `to_h` methods |
| API-only routes | `slice :api` with its own routes file |
