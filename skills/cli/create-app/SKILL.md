---
name: create-app
version: "1.0.0"
license: MIT
description: >
  Use when starting a new Hanami 2.x project, running `hanami new`, or setting
  up a project structure from scratch. Generates directory layout, configures
  environment detection via HANAMI_ENV, sets up initial app configuration, and
  establishes database connectivity via DATABASE_URL. Use when getting started
  with Hanami, scaffolding a new app, or understanding app setup and project
  structure for Hanami 2.x.
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
   hanami db create      # Creates the database; confirm output shows no errors
   hanami db migrate     # Applies migrations; verify with: hanami db version
   ```

   If `hanami db create` fails, confirm `DATABASE_URL` is set correctly and the database server is running. If `hanami db migrate` reports errors, check `db/migrate/` for invalid migration files.

8. **Run the development server**:

   ```bash
   hanami dev
   ```

---

## Common Mistakes & Red Flags

| Mistake / Red Flag | Reality |
|---|---|
| Skipping `hanami db create` before running migrations | Always create the database first; migrations will fail on a non-existent database. |
| Business logic in `config/app.rb` | `config/app.rb` is for framework configuration only; business logic belongs in Actions, Repositories, or service objects. |
| Routes scattered across files without slice organization | Keep routes in `config/routes.rb`; extract bounded contexts into slices with their own routes for large apps. |
| Using `hanami new` without specifying a database | The default may not match your needs; explicitly choose `--database=postgres` or `--database=sqlite`. |
| Modifying generated files that should remain standard | Regenerating the app will overwrite manual changes to scaffolded files. |
