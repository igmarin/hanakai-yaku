---
name: create-app
license: MIT
description: >
  Use when creating a new Hanami 2.x application — generate with `hanami new [name] --database=postgres`, configure environment detection via HANAMI_ENV (development/test/production), establish database connectivity via DATABASE_URL, install dependencies with `bundle install`, set up the database with `hanami db create && hanami db migrate && hanami db version`, and run the development server with `hanami dev`. Generates the full directory layout, config/app.rb, config/routes.rb, config/settings.rb, db/migrate/, slices/, and a config.ru. Use when starting a Hanami project from scratch, scaffolding a new app, or understanding project structure.
metadata:
  ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-cli
  - dry-rb/dry-system
  tags:
  - cli
  - scaffolding
  - new-app
  - setup
  version: "1.0.0"
---

# create-app

Use this skill when creating a new Hanami 2.x application.

**Core principle:** `hanami new` generates a production-ready application structure with slices, ROM, and dry-system preconfigured.

---

## Quick Reference

| Command | Generates |
|---|---|
| `hanami new my_app` | Full Hanami 2.x application |
| `hanami new my_app --database=postgres` | App with PostgreSQL configured |
| `hanami new my_app --database=sqlite` | App with SQLite configured |
| `hanami new my_app --head` | Uses latest (HEAD) versions of gems |

---

## Core Rules

1. **Generate the application**:

   ```bash
   hanami new my_app --database=postgres
   cd my_app
   ```

2. **Generated directory layout**:

   ```
   my_app/
   ├── app/                    # Default application slice
   │   ├── actions/           # Action classes
   │   ├── views/             # View classes
   │   ├── templates/         # HTML/JSON templates
   │   ├── relations/         # ROM Relations
   │   ├── repos/             # ROM Repositories
   │   └── entities/          # ROM Entities
   ├── config/
   │   ├── app.rb             # App class, slice registration, plugin config
   │   ├── routes.rb          # Root route and resource routing
   │   ├── settings.rb        # Typed environment variable declarations
   │   └── providers/         # External dependency providers
   ├── db/
   │   ├── migrate/           # Database migration files
   │   └── seeds.rb           # Seed data setup
   ├── slices/                # Modular slices (bounded contexts)
   ├── spec/
   ├── Gemfile
   ├── config.ru
   └── README.md
   ```

3. **Environment detection**:

   Hanami detects the environment via `HANAMI_ENV`:
   - `development` (default) — code reloading enabled
   - `test` — used by RSpec
   - `production` — code reloading disabled, logging to stdout

4. **Initial configuration**:

   ```ruby
   # config/app.rb
   # frozen_string_literal: true

   module MyApp
     class App < Hanami::App
     end
   end
   ```

5. **Database configuration** is read from `DATABASE_URL`:

   ```bash
   DATABASE_URL=postgres://localhost/my_app_development
   ```

6. **Install dependencies and set up the database**:

   ```bash
   bundle install
   hanami db create      # Creates the database
   hanami db migrate     # Applies migrations
   hanami db version     # Verify migrations applied successfully
   ```

7. **Run the development server**:

   ```bash
   hanami dev
   ```

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Reality |
|---|---|
| Business logic in `config/app.rb` | `config/app.rb` is for framework settings; business logic belongs in Actions, Repositories, or service objects. |
| Routes scattered across files without slice organization | Keep routing defined in `config/routes.rb`, dividing sections by slice or scope. |
| Using `hanami new` without specifying a database | The default may not match your project requirements; choose `--database=postgres` or `--database=sqlite`. |

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-slice** | [create-slice](../../slices/create-slice/SKILL.md) — Create modular bounded contexts after establishing the base app. |
| **manage-database** | [manage-database](../manage-database/SKILL.md) — Run migrations and seed files. |
| **define-relation** | [define-relation](../../db/define-relation/SKILL.md) — Establish ROM database schema connections. |
| **create-repository** | [create-repository](../../db/create-repository/SKILL.md) — Set up data query boundaries. |
