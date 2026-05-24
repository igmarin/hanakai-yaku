---
name: create-app
license: MIT
description: >
  Use when starting a new Hanami 2.x project, running `hanami new`, or setting up
  a project structure from scratch. Generates directory layout, configures environment
  detection via HANAMI_ENV, sets up initial app configuration, and establishes database
  connectivity via DATABASE_URL. Use when getting started with Hanami, scaffolding
  a new app, or understanding app setup and project structure for Hanami 2.x.
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
  version: 1.0.0
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
   │   ├── actions/           # Action classes (one class per endpoint)
   │   ├── views/             # View classes
   │   ├── templates/         # HTML/JSON templates
   │   ├── relations/         # ROM Relations (SQL queries)
   │   ├── repos/             # ROM Repositories (data access)
   │   └── entities/          # ROM Entities (immutable data structs)
   ├── config/
   │   ├── app.rb             # Main application configuration
   │   ├── routes.rb          # Routing definitions
   │   ├── settings.rb        # Typed settings loaded from environment
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

3. **Key generated files** (non-obvious entries):

   | File | Purpose |
   |---|---|
   | `config/app.rb` | App class, slice registration, plugin config |
   | `config/routes.rb` | Root route and resource routing |
   | `config/settings.rb` | Typed environment variable declarations |

4. **Environment detection**:

   Hanami detects the environment via `HANAMI_ENV`:
   - `development` (default) — code reloading enabled
   - `test` — used by RSpec
   - `production` — code reloading disabled, logging to stdout

5. **Initial configuration**:

   ```ruby
   # config/app.rb
   # frozen_string_literal: true

   module MyApp
     class App < Hanami::App
     end
   end
   ```

6. **Database configuration** is read from `DATABASE_URL`:

   ```bash
   DATABASE_URL=postgres://localhost/my_app_development
   ```

7. **Install dependencies and set up the database**:

   ```bash
   bundle install
   hanami db create      # Creates the database
   hanami db migrate     # Applies migrations
   ```

8. **Run the development server**:

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

