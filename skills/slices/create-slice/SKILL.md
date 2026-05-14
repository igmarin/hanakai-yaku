---
name: create-slice
version: "1.0.0"
license: MIT
description: >
  Use when creating and configuring Slices in Hanami 2.x. Covers slice registration,
  routes, inter-slice communication, and the slice as a modular sub-container.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - slices
  - modules
  - bounded-contexts
  - containers
---

# create-slice

Use this skill when creating and configuring Hanami 2.x Slices.

**Core principle:** A Slice is a modular sub-container that encapsulates a bounded context. It has its own routes, actions, views, and dependencies.

---

## Quick Reference

| Scenario | Approach |
|---|---|
| Create a Slice | `hanami generate slice <name>` |
| Register a Slice | Add to `config/app.rb` with `slice :name, at: "/path"` |
| Define Slice routes | Create `slices/<name>/config/routes.rb` |
| Access Slice Actions | Routes point to `slice_name.action_name` |
| Import from another Slice | Use `import` in the Slice class or app config |
| Export from a Slice | Use `export` in the Slice class |
| Slice-level container | `MyApp::Slices::Api::Container` |
| Access Slice components | `include Deps["slices.api.repositories.users"]` |

---

## Core Rules

1. **Generate a Slice** using the Hanami CLI:

   ```bash
   hanami generate slice api
   ```

   Creates:
   - `slices/api/`
   - `slices/api/config/routes.rb`
   - `slices/api/actions/`
   - `slices/api/views/`
   - `slices/api/templates/`
   - `slices/api/relations/` (optional)
   - `slices/api/repos/` (optional)

2. **Register the Slice** in the app:

   ```ruby
   # config/app.rb
   # frozen_string_literal: true

   module MyApp
     class App < Hanami::App
       slice :api, at: "/api" do
         # Slice-specific configuration
       end
     end
   end
   ```

3. **Define Slice routes** in `slices/<name>/config/routes.rb`:

   ```ruby
   # slices/api/config/routes.rb
   # frozen_string_literal: true

   module MyApp
     module Slices
       module Api
         class Routes < Hanami::Routes
           get "/users", to: "users.index"
           get "/users/:id", to: "users.show"
         end
       end
     end
   end
   ```

4. **Access Slice Actions** from routes:

   ```ruby
   # Full path: /api/users → slices/api/actions/users/index.rb
   ```

5. **Import dependencies from another Slice**:

   ```ruby
   # config/app.rb
   module MyApp
     class App < Hanami::App
       slice :api, at: "/api" do
         import from: :main do
           # Import specific components from the main slice
         end
       end
     end
   end
   ```

6. **Export Slice components** for use by other slices:

   ```ruby
   # slices/api/config/slice.rb
   module MyApp
     module Slices
       module Api
         class Slice < Hanami::Slice
           export ["repositories.users"]
         end
       end
     end
   end
   ```

7. **Keep Slices self-contained**. A Slice should be able to function independently. Minimize cross-slice dependencies.

8. **Use Slices for bounded contexts**:

   - `slice :api` — Public API endpoints
   - `slice :admin` — Admin dashboard
   - `slice :billing` — Billing and payments
   - `slice :main` — Default/public web application

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll put everything in the main slice" | Slices exist to modularize. Extract bounded contexts into dedicated slices. |
| "I'll create circular dependencies between slices" | Slices should be acyclic. If Slice A imports from Slice B, Slice B should not import from Slice A. |
| "I'll access another slice's container directly" | Use `import` and `export` for cross-slice communication. Never access `Hanami.app["slices.other.component"]` directly. |
| "I'll forget to namespace Slice components correctly" | Slice components live under `MyApp::Slices::Api::`. File paths and namespaces must align. |
| "I'll duplicate routes between slices" | Each slice has its own routes. The app mounts slices at prefixes. Do not duplicate route logic. |
| "I'll share database tables across slices without clear ownership" | Each slice should own its tables. Shared tables create coupling. Use imports/exports for shared data access. |

---

## Red Flags

- Everything in the main slice with no modularization
- Circular dependencies between slices
- Direct cross-slice container access
- Misaligned file paths and namespaces
- Duplicate route definitions
- Shared database tables without clear ownership

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-routes** | Slices define their own routes. Master routes before creating slices. |
| **inject-dependencies** | Cross-slice dependencies use `import`/`export` and are injected via `Deps`. |
| **configure-slice** | Configure slice-level settings and providers after creating the slice. |
| **create-new-slice** (workflow) | Full workflow for creating and configuring a new slice. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Slice) |
|---|---|
| `namespace :api do ... end` in routes | `slice :api, at: "/api" do ... end` |
| `engines` | Slices are similar but lighter-weight. No separate gem required. |
| `isolate_namespace MyEngine` | Slices are naturally namespaced under `MyApp::Slices::Name` |
| `main_app.root_path` | `routes.path(:root)` or slice-specific route helpers |
| `EngineName::Engine.routes` | `MyApp::Slices::Api::Routes` |
| Mount engine at path | `slice :api, at: "/api"` |
| Cross-engine dependencies | `import` and `export` between slices |
