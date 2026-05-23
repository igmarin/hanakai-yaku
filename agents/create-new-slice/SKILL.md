---
name: create-new-slice
version: "1.0.0"
license: MIT
description: >
  Use when creating a new Slice in Hanami 2.x. Chains create-slice,
  define-routes, configure-slice, inject-dependencies, and write-request-spec.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - agents
  - slices
  - modularization
  - bounded-contexts
---

# create-new-slice

Use this workflow when creating a new Slice in Hanami 2.x.

**Core principle:** A Slice is a bounded context. It should be self-contained with minimal dependencies on other slices.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Generate slice | `create-slice` | Slice directory structure exists |
| 2. Configure routes | `define-routes` | Routes respond at slice path |
| 3. Configure slice | `configure-slice` | Settings and providers configured |
| 4. Setup DI | `inject-dependencies` | Cross-slice dependencies injectable |
| 5. Write tests | `write-request-spec` | Smoke tests pass |

---

## Core Process

1. **[Generate Slice]** — Load skill: `create-slice`
   - `hanami generate slice <name>`
   - Register in `config/app.rb`: `slice :name, at: "/path"`
   - Handoff condition: Slice registered and bootable

2. **[Configure Routes]** — Load skill: `define-routes`
   - Define routes in `slices/<name>/config/routes.rb`
   - Use `resources` for RESTful endpoints
   - Handoff condition: Routes respond correctly

3. **[Configure Slice]** — Load skill: `configure-slice`
   - Define slice-specific settings if needed
   - Register slice-specific providers
   - Configure auto-registration paths
   - Handoff condition: Slice configuration is valid

4. **[Setup DI]** — Load skill: `inject-dependencies`
   - Import required components from other slices
   - Export components for other slices to use
   - Verify cross-slice dependencies resolve
   - Handoff condition: All dependencies injectable

5. **[Write Tests]** — Load skill: `write-request-spec`
   - Write smoke tests for slice routes
   - Test that the slice mounts correctly at its path
   - Handoff condition: Smoke tests pass

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll create a slice with no clear bounded context" | Slices represent bounded contexts. Do not create slices for arbitrary grouping. |
| "I'll create circular dependencies between slices" | Slices should be acyclic. Slice A imports from Slice B, not vice versa. |
| "I'll forget to register the slice in `config/app.rb`" | The slice must be registered in the app to be mounted. |
| "I'll duplicate the main slice's configuration" | Slices inherit app configuration. Only override when necessary. |
| "I'll put routes in the main app instead of the slice" | Slice routes belong in `slices/<name>/config/routes.rb`. |

---

## Red Flags

- Slice without clear bounded context
- Circular dependencies between slices
- Slice not registered in `config/app.rb`
- Duplicated configuration from main app
- Routes defined in main app instead of slice
- Missing smoke tests for slice routes

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-slice** | Step 1: Generate and register the slice. |
| **define-routes** | Step 2: Configure slice routes. |
| **configure-slice** | Step 3: Configure slice settings and providers. |
| **inject-dependencies** | Step 4: Setup cross-slice DI. |
| **write-request-spec** | Step 5: Write smoke tests. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (New Slice) |
|---|---|
| `rails plugin new` | `hanami generate slice <name>` |
| `isolate_namespace MyEngine` | Natural namespace under `MyApp::Slices::Name` |
| Engine routes | `slices/<name>/config/routes.rb` |
| Engine config | `slices/<name>/config/slice.rb` |
| Mount engine | `slice :name, at: "/path"` |
| Cross-engine dependencies | `import` and `export` between slices |
