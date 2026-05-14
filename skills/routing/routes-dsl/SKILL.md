---
name: routes-dsl
version: "1.0.0"
license: MIT
description: >
  Use when defining routes in Hanami 2.x. Covers get, post, patch, delete,
  resources, resource, scope, and named route helpers in config/routes.rb.
ecosystem_sources:
  - hanami/hanami-router
tags:
  - routing
  - routes
  - dsl
  - http
---

# routes-dsl

Use this skill when defining routes in Hanami 2.x.

**Core principle:** Routes map URLs to Actions. They are explicit, readable, and RESTful.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Define a GET route | `get "/users", to: "users.index"` |
| Define a POST route | `post "/users", to: "users.create"` |
| Define a PATCH route | `patch "/users/:id", to: "users.update"` |
| Define a DELETE route | `delete "/users/:id", to: "users.destroy"` |
| RESTful resource | `resources :users` generates index, show, create, update, destroy |
| Singular resource | `resource :profile` generates show, create, update, destroy (no index) |
| Nested resources | `resources :users do resources :posts end` |
| Route with parameter | `get "/users/:id", to: "users.show"` |
| Named route | `get "/users", to: "users.index", as: :users` |
| Scope routes | `scope "api" do ... end` |
| Slice routes | `slice :api, at: "/api" do ... end` |

---

## Core Rules

1. **Define routes in `config/routes.rb`**:

   ```ruby
   # config/routes.rb
   # frozen_string_literal: true

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

   Generates:
   - `GET /profile` → `profile.show`
   - `POST /profile` → `profile.create`
   - `PATCH /profile` → `profile.update`
   - `DELETE /profile` → `profile.destroy`

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

7. **Keep routes RESTful**. Avoid custom routes when RESTful ones suffice. Use `resources` and `resource`.

8. **Order matters**. Hanami matches routes top-to-bottom. Put specific routes before general ones:

   ```ruby
   # GOOD
   get "/users/new", to: "users.new"
   get "/users/:id", to: "users.show"

   # BAD ("new" would match as an :id)
   get "/users/:id", to: "users.show"
   get "/users/new", to: "users.new"
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll define custom routes instead of using `resources`" | Use `resources` and `resource` for standard CRUD. Custom routes are for exceptional cases only. |
| "I'll forget to name routes I need in Views" | Name routes with `as:` if you need to generate URLs for them later. |
| "I'll put specific routes after general ones" | Hanami matches top-to-bottom. `/users/new` must come before `/users/:id`. |
| "I'll define routes in multiple files without structure" | Keep all routes in `config/routes.rb` or use slice-level route files for large apps. |
| "I'll use string interpolation in route paths" | Route paths are static strings. Dynamic segments use `:param` syntax. |
| "I'll forget that `resources` generates plural route names" | `resources :users` generates `users_path`, not `user_path`. Use `resource` for singular. |

---

## Red Flags

- Custom routes for standard CRUD operations
- Missing named routes that are used in Views
- Specific routes placed after general wildcard routes
- Routes scattered across multiple files without slices
- String interpolation in route definitions
- Inconsistent RESTful conventions

---

## Integration

| Related Skill | When to chain |
|---|---|
| **action-anatomy** | Routes point to Actions. Define routes after Actions exist. |
| **slice-anatomy** | Slices can define their own routes. Understand slices before nesting routes. |
| **request-specs** (testing) | Test routes by making requests to them. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Routes DSL) |
|---|---|
| `get "/users", to: "users#index"` | `get "/users", to: "users.index"` |
| `resources :users` | `resources :users` (same) |
| `resource :profile` | `resource :profile` (same) |
| `scope "api" do ... end` | `scope "api" do ... end` (same) |
| `namespace :api do ... end` | `scope "api" do ... end` or `slice :api, at: "/api"` |
| `root to: "home#index"` | `root to: "home.index"` |
| `users_path` | `routes.path(:users)` |
| `user_path(1)` | `routes.path(:user, id: 1)` |
| `constraints` | Use middleware or slice-level constraints |
