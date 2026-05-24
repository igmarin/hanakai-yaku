---
name: generate-components
license: MIT
description: >
  Use when generating Hanami 2.x components via CLI. Covers hanami generate action,
  view, slice, migration with output paths and naming conventions.
metadata:
  ecosystem_sources:
  - hanami/hanami-cli
  tags:
  - cli
  - generators
  - scaffolding
  version: 1.0.0
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

5. **Always verify generated files**:
   Generators will fail if target files already exist. Always check:
   - File paths match the expected pattern.
   - Class names align with module nesting (e.g. `users.index` → `MyApp::Actions::Users::Index`).
   - Slices are correctly prefixed: `<slice>.<resource>.<action>` (omitting this places components in the default `app/` folder).

---

## Common Mistakes & Troubleshooting

| Problem / Mistake | Resolution |
|---|---|
| Using underscores instead of dots | CLI commands require dot notation: `users.index`, not `users_index`. |
| Omitting the slice prefix | Use `api.users.index` to generate in the `api` slice. |
| Singular names for Actions | Actions should use plural resource names: `users.index`, not `user.index`. |
| File conflicts / stale files | Generators never overwrite. Manually delete conflicting files before re-generating. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-app** (`../create-app/SKILL.md`) | Generators are used after creating the app. |
| **create-action** (`../create-action/SKILL.md`) | Generated Actions need to be filled with logic. |
| **create-view** (`../create-view/SKILL.md`) | Generated Views need exposures defined. |
| **create-slice** (`../create-slice/SKILL.md`) | Generated Slices need routes and configuration. |
| **write-migration** (`../write-migration/SKILL.md`) | Generated migrations need schema definitions. |
