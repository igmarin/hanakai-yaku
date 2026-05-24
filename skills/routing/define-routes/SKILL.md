---
name: define-routes
license: MIT
description: >
  Use when defining routes in Hanami 2.x. Covers get, post, patch, delete, resources,
  resource, scope, and named route helpers in config/routes.rb.
metadata:
  ecosystem_sources:
  - hanami/hanami-router
  tags:
  - routing
  - routes
  - dsl
  - http
  version: 1.0.0
---

# define-routes

Use this skill when defining routes in Hanami 2.x.

**Core principle:** Routes map URLs to Actions. They are explicit, readable, and RESTful.

---

## Core Rules

1. **Define routes in `config/routes.rb`**:

   ```ruby
   # config/routes.rb
   module MyApp
     class Routes < Hanami::Routes
       root to: "home.index"

       get "/users", to: "users.index"
       get "/users/:id", to: "users.show"
       post "/users", to: "users.create"
       patch "/users/:id", to: "users.update"
       delete "/users/:id", to: "users.destroy"
     end
   end
   ```

2. **Use `resources` for RESTful routes**:

   ```ruby
   resources :users do
     resources :posts
   end
   ```

   Generates:
   - `GET /users` → `users.index`
   - `GET /users/:id` → `users.show`
   - `POST /users` → `users.create`
   - `PATCH /users/:id` → `users.update`
   - `DELETE /users/:id` → `users.destroy`

3. **Use `resource` for singular resources** (no index):

   ```ruby
   resource :profile
   ```

4. **Name routes** for URL generation:

   ```ruby
   get "/users", to: "users.index", as: :users
   get "/users/:id", to: "users.show", as: :user
   ```

   Access in Views or Actions:

   ```ruby
   routes.path(:user, id: 1)  # => "/users/1"
   routes.url(:users)          # => "http://example.com/users"
   ```

5. **Scope routes** for versioning or grouping:

   ```ruby
   scope "api" do
     scope "v1" do
       resources :users
     end
   end
   ```

6. **Mount slices** at paths:

   ```ruby
   slice :api, at: "/api" do
     resources :users
   end
   ```

7. **Order matters**:
   Hanami matches routes top-to-bottom. Put specific routes before general ones (wildcards):

   ```ruby
   # CORRECT: specific first
   get "/users/new", to: "users.new"
   get "/users/:id", to: "users.show"
   ```

---

## Common Mistakes & Red Flags

- **Shadowed Wildcard Routes:** Placing general routes (like `:id`) before specific static paths (like `new`), which intercepts the request.
- **Custom CRUD Routes:** Defining manual routes for standard REST operations instead of using `resources`.
- **String Interpolation:** Using interpolation instead of static paths and `:param` syntax for dynamic values.
- **Missing Named Helpers:** Forgetting `as:` named parameters for routes that are referenced in views.
- **Pluralization Confusion:** Forgetting that `resources` automatically generates plural routing helper suffixes (`users_path`).

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-action** | Routes point to Actions. Define routes after Actions exist. |
| **create-slice** | Slices can define their own routes. Understand slices before nesting routes. |
| **write-request-spec** (testing) | Test routes by making requests to them. |

---

## Rails → Hanami Reference

For developers transitioning from Rails routing syntax, see the [RAILS_COMPARISON.md](RAILS_COMPARISON.md) guide.
