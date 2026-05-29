# Rails Routes vs Hanami Routes DSL Reference

This guide provides a comparative reference between Rails routing and the Hanami 2.x Routes DSL.

---

## Comparison Table

| Rails (config/routes.rb) | Hanami 2.x (config/routes.rb) |
|---|---|
| `get "/users", to: "users#index"` | `get "/users", to: "users.index"` |
| `resources :users` | `resources :users` |
| `resource :profile` | `resource :profile` |
| `scope "api" do ... end` | `scope "api" do ... end` |
| `namespace :api do ... end` | `scope "api" do ... end` or `slice :api, at: "/api"` |
| `root to: "home#index"` | `root to: "home.index"` |
| `users_path` | `routes.path(:users)` |
| `user_path(1)` | `routes.path(:user, id: 1)` |

---

## Route Ordering Pitfalls

Both routers evaluate definitions sequentially top-to-bottom. Specific paths must always be declared before wildcards to avoid shadowing:

```ruby
# CORRECT: Specific route evaluated first
get "/users/new", to: "users.new"
get "/users/:id", to: "users.show"

# INCORRECT: "/users/new" is shadowed as an :id parameter
get "/users/:id", to: "users.show"
get "/users/new", to: "users.new"
```
