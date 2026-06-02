---
name: create-action
license: MIT
type: atomic
description: >
  Use when creating, generating, or reviewing Hanami 2.x Action classes (route handlers,
  request handling, hanami controller equivalents). Generates Action classes with
  proper handle method signatures, configures dependency injection via Deps[], renders
  views with exposures, validates params, redirects, returns JSON responses, sets
  HTTP status codes, and implements halt-based error handling. Use when building a
  hanami action, wiring a new endpoint, handling params, or structuring request/response
  logic in a Hanami 2.x app.
metadata:
  ecosystem_sources:
  - hanami/hanami-controller
  tags:
  - actions
  - http
  - controllers
  - endpoints
  version: 1.0.0
---

# create-action

Use this skill when creating or reviewing Hanami 2.x Actions.

**Core principle:** One Action = one HTTP endpoint.

---

## Quick Reference (jump to workflow step)

| Scenario | Workflow Step |
|---|---|
| Create a new Action | Step 1: Generate |
| Validate / coerce params | Step 2: Params block |
| Implement request logic | Step 3: `#handle` |
| Inject dependencies | Step 4: `Deps[]` |
| Handle errors / halt | Step 5: Error handling |
| Set HTTP status codes | Step 6: Status codes |
| Test the action | Step 7: Request spec |

---

## Workflow: Creating a New Action

1. **Generate** the Action file. One Action per file — generate `Index`, `Show`, `Create`, `Update`, `Destroy` as separate classes:
   ```bash
   hanami generate action Users::Index
   ```

2. **Define a Params block** to validate and coerce input. Invalid params should `halt 422` before any business logic runs:

   ```ruby
   class Create < MyApp::Action
     params do
       required(:user).hash do
         required(:name).filled(:string)
         required(:email).filled(:string)
       end
     end

     def handle(request, response)
       halt 422, { errors: request.params.errors.to_h }.to_json unless request.params.valid?
       # proceed with valid params
     end
   end
   ```

3. **Implement `#handle`** — Actions are HTTP handlers only; delegate all business logic to repositories, interactors, or service objects. Actions have only `#handle`; never use instance variables for state sharing between methods:

   ```ruby
   # app/actions/users/index.rb
   # frozen_string_literal: true

   module MyApp
     module Actions
       module Users
         class Index < MyApp::Action
           include Deps["repos.user_repo"]

           def handle(request, response)
             response.render(view, users: user_repo.all)
           end
         end
       end
     end
   end
   ```

4. **Inject dependencies** via `Deps` — never access the container directly (`Hanami.app['key']` is untestable and forbidden):

   ```ruby
   include Deps["repos.user_repo", "views.users.show"]
   ```

5. **Wire error handling** — use `halt` for early returns. Log errors and return meaningful responses; never swallow exceptions silently:

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     halt 404, { error: "User not found" }.to_json unless user
     response.render(view, user: user)
   end
   ```

6. **Set appropriate HTTP status codes** where they differ from defaults:
   - `201` for successful creates
   - `204` for successful deletes with no body
   - `422` for validation errors

   To return JSON: `response.format = :json; response.body = data.to_json`
   To redirect: `response.redirect_to("/path")`

7. **Validate with a request spec** (see `write-request-spec` skill) before considering the action complete.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-repository** | Actions inject Repositories to fetch and persist data. |
| **create-view** | Actions render Views by passing exposures. |
| **validate-params** | Actions define Params blocks to validate input. |
| **handle-errors** | Actions use `halt` for early returns and error responses. |
| **inject-dependencies** | Actions use `include Deps[]` for dependency injection. |
| **write-request-spec** (testing) | Test Actions via Rack request specs. |
