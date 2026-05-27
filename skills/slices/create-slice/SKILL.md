---
name: create-slice
license: MIT
description: >
  Use when creating Hanami Slices — generate a slice with `hanami generate slice [name]`, register it in `config/app.rb` via `slice :name, at: "/path"`, define slice routes in `slices/[name]/config/routes.rb`, configure inter-slice dependencies with `import`/`export` (avoid circular deps: if A imports from B, B must not import from A), and keep slices self-contained for distinct bounded contexts like API, admin, or billing, the main web application. Covers slice directory generation, route configuration, cross-slice dependency management, and slice-level container access.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
  tags:
  - slices
  - modules
  - bounded-contexts
  - containers
  version: "1.0.0"
---

# create-slice

Use this skill when creating and configuring Hanami 2.x Slices.

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

   Creates `slices/api/` with subdirectories including `config/routes.rb`, `actions/`, `views/`, and `templates/`.

   **Verify:** Run `hanami routes` and confirm the new slice's routes appear in the output.

2. **Register the Slice** in the app:

   ```ruby
   # config/app.rb
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

   Routes map to action files under `slices/api/actions/` (e.g. `/api/users` → `slices/api/actions/users/index.rb`).

   **Verify:** Run `hanami routes` and confirm `/api/users` and `/api/users/:id` are listed.

4. **Import dependencies from another Slice**:

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

   **Verify:** Boot the app (`hanami console`) and resolve the imported component: `MyApp::Slices::Api::Container["main.repositories.users"]`.

5. **Export Slice components** for use by other slices:

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

   **Verify:** In `hanami console`, confirm the consuming slice can resolve the exported key.

6. **Keep Slices self-contained** and minimize cross-slice dependencies. Use `import`/`export` as the formal contract between slices.

7. **Use Slices for bounded contexts** — each slice encapsulates a distinct domain concern such as a public API, admin dashboard, billing, or main web application.

---

## Common Mistakes

- **Circular slice dependencies**: Slices should be acyclic. If Slice A imports from Slice B, Slice B must not import from Slice A.
- **Direct container access across slices**: Use `import`/`export` for cross-slice communication. Never access `Hanami.app["slices.other.component"]` directly.
- **Misaligned namespaces**: Slice components live under `MyApp::Slices::Api::`. File paths and module namespaces must align.

---

## Integration

| Related Skill | When to chain |
|---|---|
| **define-routes** | Slices define their own routes. Master routes before creating slices. |
| **inject-dependencies** | Cross-slice dependencies use `import`/`export` and are injected via `Deps`. |
| **configure-slice** | Configure slice-level settings and providers after creating the slice. |
| **create-new-slice** (workflow) | Full workflow for creating and configuring a new slice. |
