---
name: action-anatomy
version: "1.0.0"
license: MIT
description: >
  Use when creating or reviewing Hanami 2.x Actions. Covers class structure,
  lifecycle, dependency injection, response rendering, and error handling.
ecosystem_sources:
  - hanami/hanami-controller
tags:
  - actions
  - http
  - controllers
  - endpoints
---

# action-anatomy

Use this skill when creating or reviewing Hanami 2.x Actions.

**Core principle:** One Action = one HTTP endpoint. Actions are single-responsibility classes, not controllers with many methods.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a new Action | Generate with `hanami generate action <slice>::<module>::<name>` |
| Handle a GET request | Implement `#handle(request, response)` with read logic |
| Handle a POST request | Implement `#handle(request, response)` with write logic |
| Inject dependencies | `include Deps["repos.user_repo"]` |
| Render a view | `response.render(view, **exposures)` |
| Return JSON | `response.format = :json; response.body = data.to_json` |
| Handle errors | Use `halt` or rescue + render error response |
| Redirect | `response.redirect_to("/path")` |
| Access params | `request.params[:key]` (validated by Params DSL) |
| Set status | `response.status = 201` |

---

## Core Rules

1. **One Action per file**, one endpoint per Action class:

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

2. **Actions are HTTP handlers only**. No business logic. Delegate to Repositories, interactors, or service objects.

3. **Inject dependencies via `Deps`**:

   ```ruby
   include Deps["repos.user_repo", "views.users.show"]
   ```

4. **Render Views by passing exposures**:

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     response.render(view, user: user)
   end
   ```

5. **Handle errors gracefully**. Use `halt` for early returns or rescue exceptions:

   ```ruby
   def handle(request, response)
     user = user_repo.by_id(request.params[:id]).one
     halt 404, { error: "User not found" }.to_json unless user

     response.render(view, user: user)
   end
   ```

6. **Set appropriate HTTP status codes**:

   - `200` for successful reads
   - `201` for successful creates
   - `204` for successful deletes with no body
   - `400` for bad requests
   - `404` for not found
   - `422` for validation errors
   - `500` for server errors (avoid explicitly; let the framework handle)

7. **Use `request.params`** for input. Params are validated by the Action's Params DSL (`skills/actions/action-params-validation`).

8. **Never access the container directly in Actions**. Always use `Deps` injection.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put business logic like `calculate_discount` in the Action" | Actions are HTTP handlers only. Business logic belongs in Repositories, interactors, or service objects registered in the DI container. |
| "I'll create a controller class with multiple methods" | Hanami uses one class per endpoint. Generate `Index`, `Show`, `Create`, `Update`, `Destroy` as separate Action classes. |
| "I'll access the container directly with `Hanami.app['key']`" | Always use `include Deps["key"]` for dependency injection. Direct container access is untestable. |
| "I'll skip params validation and access `request.params` directly" | Define a Params block to validate and coerce input. Invalid params should halt with 422 before any business logic runs. |
| "I'll use instance variables to share state between methods" | Actions have only `#handle`. There are no other methods to share state with. Pass data via arguments. |
| "I'll rescue exceptions silently" | Log errors and return meaningful error responses. Never swallow exceptions. |

---

## Red Flags

- Business logic methods in Action classes
- Direct container access (`Hanami.app['key']`)
- Multiple endpoints in one Action class
- Unvalidated params accessed directly
- Instance variables used for state sharing
- Silent exception rescuing
- Actions returning raw database hashes instead of Entities

---

## Integration

| Related Skill | When to chain |
|---|---|
| **rom-repositories** | Actions inject Repositories to fetch and persist data. |
| **view-objects** | Actions render Views by passing exposures. |
| **action-params-validation** | Actions define Params blocks to validate input. |
| **action-halt-errors** | Actions use `halt` for early returns and error responses. |
| **deps-mixin** | Actions use `include Deps[]` for dependency injection. |
| **request-specs** (testing) | Test Actions via Rack request specs. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Action) |
|---|---|
| `class UsersController < ApplicationController` | `class Index < MyApp::Action` (one class per endpoint) |
| `def index; ...; end` | `def handle(request, response); ...; end` |
| `before_action :authenticate` | Use `before` callbacks in the Action class or middleware |
| `@users = User.all` | `users: user_repo.all` (injected repo, passed to view) |
| `render json: @user` | `response.format = :json; response.body = user.to_json` |
| `redirect_to user_path` | `response.redirect_to("/users/#{user.id}")` |
| `params.require(:user).permit(...)` | Params DSL block in the Action class |
| `head :no_content` | `response.status = 204; response.body = ""` |
| `rescue_from ...` | `rescue` in `#handle` or use `halt` |
