---
name: new-slice
version: "1.0.0"
license: MIT
description: >
  Use when creating a new Slice in Hanami 2.x. Chains slice-anatomy,
  routes-dsl, slice-configuration, deps-mixin, and request-specs.
ecosystem_sources:
  - hanami/hanami
  - dry-rb/dry-system
tags:
  - workflows
  - slices
  - modularization
  - bounded-contexts
---

# new-slice

Use this workflow when creating a new Slice in Hanami 2.x.

**Core principle:** A Slice is a bounded context. It should be self-contained with minimal dependencies on other slices.

---

## Quick Reference

| Step | Skill | Handoff Condition |
|---|---|---|
| 1. Generate slice | `slice-anatomy` | Slice directory structure exists |
| 2. Configure routes | `routes-dsl` | Routes respond at slice path |
| 3. Configure slice | `slice-configuration` | Settings and providers configured |
| 4. Setup DI | `deps-mixin` | Cross-slice dependencies injectable |
| 5. Write tests | `request-specs` | Smoke tests pass |

---

## Core Process

1. **[Generate Slice]** — Load skill: `slice-anatomy`
   - `hanami generate slice <name>`
   - Register in `config/app.rb`: `slice :name, at: "/path"`
   - Handoff condition: Slice registered and bootable

2. **[Configure Routes]** — Load skill: `routes-dsl`
   - Define routes in `slices/<name>/config/routes.rb`
   - Use `resources` for RESTful endpoints
   - Handoff condition: Routes respond correctly

3. **[Configure Slice]** — Load skill: `slice-configuration`
   - Define slice-specific settings if needed
   - Register slice-specific providers
   - Configure auto-registration paths
   - Handoff condition: Slice configuration is valid

4. **[Setup DI]** — Load skill: `deps-mixin`
   - Import required components from other slices
   - Export components for other slices to use
   - Verify cross-slice dependencies resolve
   - Handoff condition: All dependencies injectable

5. **[Write Tests]** — Load skill: `request-specs`
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
| **slice-anatomy** | Step 1: Generate and register the slice. |
| **routes-dsl** | Step 2: Configure slice routes. |
| **slice-configuration** | Step 3: Configure slice settings and providers. |
| **deps-mixin** | Step 4: Setup cross-slice DI. |
| **request-specs** | Step 5: Write smoke tests. |

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
