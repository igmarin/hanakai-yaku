---
name: hanami-new
version: "1.0.0"
license: MIT
description: >
  Use when scaffolding a new Hanami 2.x application. Covers generated directory
  layout, environment detection, and initial configuration.
ecosystem_sources:
  - hanami/hanami
  - hanami/hanami-cli
  - dry-rb/dry-system
tags:
  - cli
  - scaffolding
  - new-app
  - setup
---

# hanami-new

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
   ├── app/                    # Main application code
   │   ├── actions/           # Action classes (one per endpoint)
   │   ├── views/             # View classes
   │   ├── templates/         # ERB/HAML templates
   │   ├── relations/         # ROM Relations
   │   ├── repos/             # ROM Repositories
   │   ├── entities/          # ROM Entities
   │   └── assets/            # Static assets (CSS, JS, images)
   ├── config/
   │   ├── app.rb             # Application configuration
   │   ├── routes.rb          # Route definitions
   │   ├── settings.rb        # Environment settings
   │   └── providers/         # Provider definitions
   ├── db/
   │   ├── migrate/           # Sequel migration files
   │   └── seeds.rb           # Database seed data
   ├── slices/                # Modular slices (bounded contexts)
   ├── spec/                  # RSpec test files
   ├── Gemfile
   ├── config.ru              # Rack entry point
   └── README.md
   ```

3. **Key generated files**:

   | File | Purpose |
   |---|---|
   | `config/app.rb` | App class, slice registration, plugin config |
   | `config/routes.rb` | Root route and resource routing |
   | `config/settings.rb` | Typed environment variable declarations |
   | `config.ru` | Rack entry point for `rackup` or Puma |
   | `Gemfile` | Includes `hanami`, `hanami-router`, `rom`, `dry-system`, `puma` |

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

7. **Install dependencies**:

   ```bash
   bundle install
   hanami db create
   hanami db migrate
   ```

8. **Run the development server**:

   ```bash
   hanami dev
   ```

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll skip `hanami db create` and try to run migrations on a non-existent database" | Always create the database before running migrations. |
| "I'll edit `config/app.rb` to add business logic" | `config/app.rb` is for framework configuration only. Business logic belongs in Actions, Repositories, or service objects. |
| "I'll put routes in multiple files without using slices" | Keep routes in `config/routes.rb`. For large apps, extract bounded contexts into slices with their own routes. |
| "I'll forget to set `DATABASE_URL` before running CLI commands" | Hanami reads `DATABASE_URL` from the environment. Set it in `.env` or export it. |
| "I'll use `hanami new` without specifying a database" | The default may not match your needs. Explicitly choose `--database=postgres` or `--database=sqlite`. |

---

## Red Flags

- Missing `hanami db create` before migrations
- Business logic in `config/app.rb`
- Routes scattered across files without slice organization
- Missing `DATABASE_URL` environment variable
- Using default database without explicit choice
- Modifying generated files that should remain standard

---

## Integration

| Related Skill | When to chain |
|---|---|
| **cli/generators** | After creating the app, use generators to scaffold Actions, Views, and Slices. |
| **cli/db-commands** | Use `hanami db` commands to manage the database. |
| **cli/dev-runtime** | Use `hanami dev` and `hanami console` for development. |
| **slice-anatomy** | Extract bounded contexts into slices as the app grows. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (New App) |
|---|---|
| `rails new my_app` | `hanami new my_app --database=postgres` |
| `config/application.rb` | `config/app.rb` |
| `config/routes.rb` | `config/routes.rb` (same path) |
| `app/controllers/` | `app/actions/` |
| `app/views/` | `app/views/` + `app/templates/` |
| `app/models/` | `app/relations/` + `app/repos/` + `app/entities/` |
| `db/migrate/` | `db/migrate/` (same path) |
| `config/database.yml` | `DATABASE_URL` environment variable |
| `bin/rails` | `hanami` CLI |
