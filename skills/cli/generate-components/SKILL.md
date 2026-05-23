---
name: generate-components
version: "1.0.0"
license: MIT
description: >
  Use when generating Hanami 2.x components via CLI. Covers hanami generate action,
  view, slice, migration with output paths and naming conventions.
ecosystem_sources:
  - hanami/hanami-cli
tags:
  - cli
  - generators
  - scaffolding
---

# generate-components

Use this skill when generating Hanami 2.x components via the CLI.

**Core principle:** Generators follow naming conventions. The command name determines the file path and class name.

---

## Quick Reference

| Command | Generates | Path |
|---|---|---|
| `hanami generate action <name>` | Action class | `app/actions/{path}.rb` |
| `hanami generate view <name>` | View class + template | `app/views/{path}.rb` + `app/templates/{path}.html.erb` |
| `hanami generate slice <name>` | Slice directory structure | `slices/{name}/` |
| `hanami generate migration <name>` | Migration file | `db/migrate/{timestamp}_{name}.rb` |
| `hanami generate relation <name>` | Relation class | `app/relations/{name}.rb` |
| `hanami generate repo <name>` | Repository class | `app/repos/{name}.rb` |
| `hanami generate entity <name>` | Entity class | `app/entities/{name}.rb` |

---

## Core Rules

1. **Generate an Action**:

   ```bash
   hanami generate action users.index
   ```

   Generates:
   - `app/actions/users/index.rb`
   - Class: `MyApp::Actions::Users::Index`

   With a Slice:

   ```bash
   hanami generate action api.users.index
   ```

   Generates:
   - `slices/api/actions/users/index.rb`
   - Class: `MyApp::Slices::Api::Actions::Users::Index`

2. **Generate a View**:

   ```bash
   hanami generate view users.index
   ```

   Generates:
   - `app/views/users/index.rb`
   - `app/templates/users/index.html.erb`

3. **Generate a Slice**:

   ```bash
   hanami generate slice api
   ```

   Generates:
   - `slices/api/config/routes.rb`
   - `slices/api/config/slice.rb`
   - `slices/api/actions/`
   - `slices/api/views/`
   - `slices/api/templates/`

4. **Generate a migration**:

   ```bash
   hanami generate migration create_users
   ```

   Generates:
   - `db/migrate/{timestamp}_create_users.rb`

5. **Naming convention**:

   - Commands use dot notation: `users.index` → `app/actions/users/index.rb`
   - Each segment becomes a directory
   - The last segment becomes the class name
   - Slices are prefixed: `api.users.index` → `slices/api/actions/users/index.rb`

6. **Generator commands** never overwrite existing files. They fail if the target exists.

7. **Always verify generated files** after running a generator. Check that:
   - File paths match the naming convention
   - Class names match the file path
   - Templates are in the correct directory

   **If verification fails:**
   - Wrong path or class name: delete the generated file and re-run with the correct dot-notation name.
   - Missing template: check that `hanami generate view` was used (not `generate action`) when a template is expected.
   - Existing file conflict: inspect the existing file; if stale or incorrect, remove it manually before re-running.
   - Slice component in `app/` instead of `slices/`: slice prefix was omitted — re-run with `<slice>.<resource>.<action>` notation.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| Using underscores instead of dots in generator commands | Use dots: `hanami generate action users.index`, not `users_index`. |
| Forgetting the slice prefix when generating in a slice | Use `api.users.index` for slice `api`, not just `users.index`. |
| Manually creating files instead of using generators | Generators ensure correct naming and structure. |
| Using singular names for Actions | Actions use the plural resource name: `users.index`, `users.show`, not `user.index`. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-app** (`../create-app/SKILL.md`) | Generators are used after creating the app. |
| **create-action** (`../create-action/SKILL.md`) | Generated Actions need to be filled with logic. |
| **create-view** (`../create-view/SKILL.md`) | Generated Views need exposures defined. |
| **create-slice** (`../create-slice/SKILL.md`) | Generated Slices need routes and configuration. |
| **write-migration** (`../write-migration/SKILL.md`) | Generated migrations need schema definitions. |
