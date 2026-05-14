---
name: run-development
version: "1.0.0"
license: MIT
description: >
  Use when running Hanami 2.x development commands. Covers hanami dev
  (development server with code reloading) and hanami console (REPL with full container).
ecosystem_sources:
  - hanami/hanami-cli
tags:
  - cli
  - development
  - server
  - console
---

# run-development

Use this skill when running Hanami 2.x development commands.

**Core principle:** Development commands provide fast feedback loops with code reloading and full container access.

---

## Quick Reference

| Command | Purpose |
|---|---|
| `hanami dev` | Start development server with code reloading |
| `hanami console` | Start interactive REPL with full container loaded |
| `hanami routes` | List all routes |
| `hanami middleware` | List middleware stack |
| `hanami version` | Show Hanami version |

---

## Core Rules

1. **Start the development server**:

   ```bash
   hanami dev
   ```

   Expected behavior:
   - Server starts on `http://localhost:2300`
   - Code reloading is enabled (changes take effect without restart)
   - Logs print to stdout

2. **Start the console**:

   ```bash
   hanami console
   ```

   Expected behavior:
   - IRB or Pry starts with the Hanami container loaded
   - Access components directly:

   ```ruby
   app = Hanami.app
   rom = app["db.rom"]
   users = rom.relations[:users]
   users.insert(email: "test@example.com")
   ```

3. **Use the console for exploration**:

   ```ruby
   # Query the database
   Hanami.app["db.rom"].relations[:users].to_a

   # Access a Repository
   Hanami.app["repos.user_repo"].all

   # Access settings
   Hanami.app[:settings].database_url

   # Test a Relation query
   Hanami.app["relations.users"].active.to_a
   ```

4. **Development server behavior**:
   - Auto-reloads Ruby files on change
   - Does not reload configuration files (requires restart)
   - Shows detailed error pages for exceptions
   - Logs all requests to stdout

5. **Console environment**:
   - Loads the full Hanami application
   - Uses `development` environment by default
   - Can override with `HANAMI_ENV=test hanami console`

6. **List routes**:

   ```bash
   hanami routes
   ```

   Expected output: Table of HTTP methods, paths, and Action names.

7. **List middleware**:

   ```bash
   hanami middleware
   ```

   Expected output: Ordered list of middleware in the stack.

---

## Common Mistakes

| Mistake | Reality |
|---|---|
| "I'll use `hanami dev` in production" | `hanami dev` is for development only. Use a production server like Puma or Falcon in production. |
| "I'll expect config files to reload without restart" | `hanami dev` reloads Ruby code, not configuration. Restart the server after editing `config/app.rb` or `config/routes.rb`. |
| "I'll run the console without setting `DATABASE_URL`" | The console loads the full app, which needs `DATABASE_URL` to connect to the database. |
| "I'll use the console to run destructive commands without checking the environment" | The console uses `development` by default, but always verify `HANAMI_ENV` before running destructive operations. |
| "I'll forget that the console loads the entire app" | The console boots Hanami. It may take a few seconds and requires all dependencies to be resolvable. |

---

## Red Flags

- Using `hanami dev` in production
- Expecting config reload without server restart
- Running console without `DATABASE_URL`
- Destructive console commands without environment check
- Console startup failures due to missing dependencies

---

## Integration

| Related Skill | When to chain |
|---|---|
| **create-app** | Development commands are used after creating the app. |
| **manage-database** | Database commands may be needed before starting the dev server. |
| **define-relation** | Use the console to explore and test Relation queries. |
| **create-repository** | Use the console to test Repository methods interactively. |

---

## Rails → Hanami

| Rails (ActiveRecord) | Hanami 2.x (Dev Runtime) |
|---|---|
| `rails server` | `hanami dev` |
| `rails console` | `hanami console` |
| `rails routes` | `hanami routes` |
| `rails middleware` | `hanami middleware` |
| `rails --version` | `hanami version` |
| Spring preloader | Code reloading built into `hanami dev` |
| `bin/rails` | `hanami` CLI |
