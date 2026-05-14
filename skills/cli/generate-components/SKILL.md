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

# generators

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
   - `db/migrate/20240601120000_create_users.rb`

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

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll use underscores instead of dots in generator commands" | Use dots: `hanami generate action users.index`, not `users_index`. |
| "I'll forget the slice prefix when generating in a slice" | Use `api.users.index` for slice `api`, not just `users.index`. |
| "I'll manually create files instead of using generators" | Generators ensure correct naming and structure. Use them for consistency. |
| "I'll run generators without verifying the output" | Always check generated files. Generators create boilerplate that needs editing. |
| "I'll use plural names for Actions" | Actions use the resource name: `users.index`, `users.show`, not `user.index`. |

---

## Red Flags

- Underscores instead of dots in generator commands
- Missing slice prefix for slice components
- Manually created files with wrong naming convention
- Unverified generator output
- Singular names for Action generators
- Overwriting generated files manually without checking

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-app** | Generators are used after creating the app. |
| **create-action** | Generated Actions need to be filled with logic. |
| **create-view** | Generated Views need exposures defined. |
| **create-slice** | Generated Slices need routes and configuration. |
| **write-migration** | Generated migrations need schema definitions. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Generators) |
|---|---|
| `rails generate controller Users index show` | `hanami generate action users.index` + `hanami generate action users.show` |
| `rails generate model User` | `hanami generate relation users` + `hanami generate repo user` + `hanami generate entity user` |
| `rails generate migration CreateUsers` | `hanami generate migration create_users` |
| `rails generate scaffold User` | No single scaffold command. Generate Action, View, Relation, Repo, and Migration separately. |
| `rails generate resource User` | No direct equivalent. Use individual generators. |
